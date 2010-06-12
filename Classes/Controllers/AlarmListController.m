/*******************************************************************************
 * This file is part of the OpenNMS(R) iPhone Application.
 * OpenNMS(R) is a registered trademark of The OpenNMS Group, Inc.
 *
 * Copyright (C) 2009 The OpenNMS Group, Inc.  All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc.:
 *
 *      51 Franklin Street
 *      5th Floor
 *      Boston, MA 02110-1301
 *      USA
 *
 * For more information contact:
 *
 *      OpenNMS Licensing <license@opennms.org>
 *      http://www.opennms.org/
 *      http://www.opennms.com/
 *
 *******************************************************************************/

#import "config.h"
#import "AlarmListController.h"
#import "ColumnarTableViewCell.h"
#import "AlarmDetailController.h"
#import "Alarm.h"
#import "OnmsSeverity.h"
#import "AlarmListUpdater.h"
#import "AlarmUpdateHandler.h"
#import "CalculateSize.h"

@implementation AlarmListController

@synthesize alarmTable;
@synthesize fuzzyDate;
@synthesize contextService;
@synthesize spinner;

@synthesize alarmList;

-(void) dealloc
{
	[self.fuzzyDate release];
	[self.alarmTable release];
	[self.contextService release];
	[self.spinner release];

	[self.alarmList release];

    [super dealloc];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.alarmTable reloadData];
}

-(void) refreshData
{
	if (!self.alarmList) {
		[spinner startAnimating];
		self.alarmList = [NSMutableArray array];
	}
	
	NSManagedObjectContext *context = [contextService managedObjectContext];
	
	NSFetchRequest* req = [[[NSFetchRequest alloc] init] autorelease];
	[req setResultType:NSManagedObjectIDResultType];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:context];
	[req setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastEventTime" ascending:NO];
	[req setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError* error = nil;
	NSArray *array = [context executeFetchRequest:req error:&error];
	if (array == nil) {
		if (error) {
			NSLog(@"error fetching alarms: %@", [error localizedDescription]);
		} else {
			NSLog(@"error fetching alarms");
		}
	} else {
		[self.alarmList removeAllObjects];
		[self.alarmList addObjectsFromArray:array];
	}
	[self.alarmTable reloadData];
}

-(void) initializeData
{
	AlarmListUpdater* updater = [[[AlarmListUpdater alloc] init] autorelease];
	AlarmUpdateHandler* handler = [[[AlarmUpdateHandler alloc] initWithMethod:@selector(refreshData) target:self] autorelease];
	handler.clearOldObjects = YES;
	handler.spinner = spinner;
	updater.handler = handler;
	[updater update];
	[self.spinner stopAnimating];
}

-(IBAction) reload:(id) sender
{
	[spinner startAnimating];
	[self initializeData];
}

#pragma mark UIViewController delegates

- (void) viewDidLoad
{
	if (!contextService) {
		contextService = [[ContextService alloc] init];
	}

	self.fuzzyDate = [[FuzzyDate alloc] init];
	[self initializeData];
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	[contextService release];
	contextService = nil;
	
	[self.alarmTable release];
	[self.fuzzyDate release];
	[self.alarmList release];

	[super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	NSIndexPath* tableSelection = [self.alarmTable indexPathForSelectedRow];
	if (tableSelection) {
		[self.alarmTable deselectRowAtIndexPath:tableSelection animated:NO];
	}
	[self.alarmTable reloadData];
}

#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.alarmList count];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	if ([self.alarmList count] > 0) {
		NSManagedObjectID* objId = [self.alarmList objectAtIndex:indexPath.row];
		AlarmDetailController* adc = [[AlarmDetailController alloc] init];
		[adc setAlarmObjectId:objId];
		UINavigationController* cont = [self navigationController];
		[cont pushViewController:adc animated:YES];
		[adc release];
	}
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0;
	CGSize size;

    CGFloat dateWidth = 75; // 75
    CGFloat logWidth = orientationHandler.screenWidth - (orientationHandler.cellSeparator * 3) - dateWidth;

    NSManagedObjectID* alarmObjId = [self.alarmList objectAtIndex:indexPath.row];
	Alarm* alarm = (Alarm*)[[contextService managedObjectContext] objectWithID:alarmObjId];
	size = [CalculateSize calcLabelSize:alarm.logMessage font:[UIFont boldSystemFontOfSize:12] lines:10 width:logWidth
								   mode:(UILineBreakModeWordWrap|UILineBreakModeTailTruncation)];
	height = size.height;
	return MAX(height, tableView.rowHeight);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ColumnarTableViewCell* cell = [[[ColumnarTableViewCell alloc] initWithFrame:CGRectZero] autorelease];

	UIView* backgroundView = [[[UIView alloc] init] autorelease];
	backgroundView.backgroundColor = [UIColor colorWithRed:0.1 green:0.0 blue:1.0 alpha:0.75];
	cell.selectedBackgroundView = backgroundView;

#if DEBUG
	NSLog(@"%@: %d alarms found", self, [self.alarmList count]);
#endif
	if ([self.alarmList count] > 0) {
		UIColor* clear = [UIColor colorWithWhite:1.0 alpha:0.0];

		// set the border based on the severity (can only set entire table background color :( )
		// tableView.separatorColor = [self getSeparatorColorForSeverity:alarm.severity];

		CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];

        CGFloat dateWidth = 75; // 75
        CGFloat logWidth = orientationHandler.screenWidth - (orientationHandler.cellSeparator * 3) - dateWidth;

		NSManagedObjectID* alarmObjId = [self.alarmList objectAtIndex:indexPath.row];
		Alarm* alarm = (Alarm*)[[contextService managedObjectContext] objectWithID:alarmObjId];

#if DEBUG
		NSLog(@"%@: Alarm = %@", self, alarm);
#endif
		OnmsSeverity* sev = [[[OnmsSeverity alloc] initWithSeverity:alarm.severity] autorelease];
		UIColor* color = [sev getDisplayColor];
		cell.contentView.backgroundColor = color;
		
		UILabel *label = [[[UILabel	alloc] initWithFrame:CGRectMake(orientationHandler.cellSeparator, 0, logWidth, height)] autorelease];
		[cell addColumn:alarm.logMessage];
		label.font = [UIFont boldSystemFontOfSize:12];
		label.text = alarm.logMessage;
		label.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
		label.numberOfLines = 10;
		label.textColor = [UIColor blackColor];
		label.backgroundColor = clear;
		[cell.contentView addSubview:label];

		label = [[[UILabel	alloc] initWithFrame:CGRectMake(orientationHandler.cellSeparator + logWidth + orientationHandler.cellSeparator, 0, dateWidth, height)] autorelease];
		NSString* eventString = [fuzzyDate format:alarm.lastEventTime];
		[cell addColumn:eventString];
		label.font = [UIFont boldSystemFontOfSize:12];
		label.text = eventString;
        label.textAlignment = UITextAlignmentRight;
		label.backgroundColor = clear;
		[cell.contentView addSubview:label];
		
		NSLog(@"label = %@", label);
	} else {
#if DEBUG
		NSLog(@"%@: no alarms to list", self);
#endif
		cell.textLabel.text = @"";
	}
	
	cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[cell sizeToFit];
	
	return cell;
}

@end