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

#import "AlarmListController.h"
#import "ColumnarTableViewCell.h"
#import "AlarmDetailController.h"
#import "OpenNMSRestAgent.h"
#import "Alarm.h"
#import "OnmsSeverity.h"
#import "AlarmListUpdater.h"
#import "AlarmUpdateHandler.h"
#import "OpenNMSAppDelegate.h"

@implementation AlarmListController

@synthesize alarmTable;
@synthesize fuzzyDate;
@synthesize managedObjectContext;
@synthesize spinner;

@synthesize alarmList;

-(void) dealloc
{
	[self.fuzzyDate release];
	[self.alarmTable release];
	[self.managedObjectContext release];
	[self.spinner release];

	[self.alarmList release];

    [super dealloc];
}

-(void) initializeData
{
	if (!self.alarmList) {
		[spinner startAnimating];
		self.alarmList = [NSMutableArray array];
	}
	[self.alarmTable reloadData];
	AlarmListUpdater* updater = [[[AlarmListUpdater alloc] init] autorelease];
	AlarmUpdateHandler* handler = [[[AlarmUpdateHandler alloc] initWithTableView:self.alarmTable objectList:self.alarmList] autorelease];
	handler.spinner = spinner;
	updater.handler = handler;
	[updater update];
}

-(IBAction) reload:(id) sender
{
	[spinner startAnimating];
	[self initializeData];
}

#pragma mark UIViewController delegates

- (void) viewDidLoad
{
	if (!managedObjectContext) {
		managedObjectContext = [(OpenNMSAppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
	}

	self.fuzzyDate = [[FuzzyDate alloc] init];
	[self initializeData];
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	managedObjectContext = nil;
	
	[self.alarmTable release];
	[self.fuzzyDate release];
	[self.alarmList release];

	[super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ColumnarTableViewCell* cell = [[[ColumnarTableViewCell alloc] initWithFrame:CGRectZero] autorelease];

	UIView* backgroundView = [[[UIView alloc] init] autorelease];
	backgroundView.backgroundColor = [UIColor colorWithWhite:0.9333333 alpha:1.0];
	cell.selectedBackgroundView = backgroundView;
	
	if ([self.alarmList count] > 0) {
		UIColor* clear = [UIColor colorWithWhite:1.0 alpha:0.0];
		
		// set the border based on the severity (can only set entire table background color :( )
		// tableView.separatorColor = [self getSeparatorColorForSeverity:alarm.severity];

		NSManagedObjectID* alarmObjId = [self.alarmList objectAtIndex:indexPath.row];

		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self == %@", alarmObjId];
		[request setPredicate:predicate];
		
		NSError *error;
		NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
		if (!array || [array count] == 0) {
			if (error) {
				NSLog(@"error retrieving object %@: %@", alarmObjId, [error localizedDescription]);
			} else {
				NSLog(@"error retrieving object %@", alarmObjId);
			}
			return cell;
		}

		Alarm* alarm = (Alarm*)[array objectAtIndex:0];
		OnmsSeverity* sev = [[[OnmsSeverity alloc] initWithSeverity:alarm.severity] autorelease];
		UIColor* color = [sev getDisplayColor];
		cell.contentView.backgroundColor = color;
		
		UILabel *label = [[[UILabel	alloc] initWithFrame:CGRectMake(10.0, 0, 220.0, tableView.rowHeight)] autorelease];
		[cell addColumn:alarm.logMessage];
		label.font = [UIFont boldSystemFontOfSize:12];
		label.text = alarm.logMessage;
		label.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
		label.numberOfLines = 2;
		label.backgroundColor = clear;
		[cell.contentView addSubview:label];

		label = [[[UILabel	alloc] initWithFrame:CGRectMake(235.0, 0, 75.0, tableView.rowHeight)] autorelease];
		NSString* eventString = [fuzzyDate format:alarm.lastEventTime];
		[cell addColumn:eventString];
		label.font = [UIFont boldSystemFontOfSize:12];
		label.text = eventString;
		label.backgroundColor = clear;
		[cell.contentView addSubview:label];
	} else {
		cell.textLabel.text = @"";
	}
	
	cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[cell sizeToFit];
	
	return cell;
}

@end

