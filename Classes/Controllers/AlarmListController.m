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

@synthesize fuzzyDate;

@synthesize _fetchedResultsController;

-(id)init
{
    if (self = [super init]) {
       [self initializeData];
        cellIdentifier = @"alarmList";
    }
    return self;
}

-(void) dealloc
{
    fuzzyDate = nil;
    _fetchedResultsController = nil;

    [super dealloc];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self initializeData];
}

-(NSFetchedResultsController*)fetchedResultsController
{
    if (_fetchedResultsController == nil) {
        NSFetchRequest* fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription* entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:[contextService readContext]];
        [fetchRequest setEntity:entity];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastEventTime" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptors release];
        [sortDescriptor release];
        
        NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]
                                                  initWithFetchRequest:fetchRequest
                                                  managedObjectContext:[contextService readContext]
                                                  sectionNameKeyPath:nil
                                                  cacheName:@"alarmByLastEventTime"];
        controller.delegate = self;
        _fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(void) initializeData
{
    self.navigationItem.rightBarButtonItem = [self getSpinner];
    [super initializeData];
	AlarmListUpdater* updater = [[[AlarmListUpdater alloc] init] autorelease];
	AlarmUpdateHandler* handler = [[[AlarmUpdateHandler alloc] initWithMethod:@selector(refreshData) target:self] autorelease];
	handler.clearOldObjects = YES;
	updater.handler = handler;
	[updater update];
}

-(void) refreshData
{
    [super refreshData];
    self.navigationItem.rightBarButtonItem = nil;
}

-(IBAction) reload:(id) sender
{
	[self initializeData];
}

#pragma mark UIViewController delegates

- (void) viewDidLoad
{
	self.fuzzyDate = [[FuzzyDate alloc] init];
	[self initializeData];
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	[self.fuzzyDate release];
	[super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
	[self initializeData];
	[super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
//    _fetchedResultsController = nil;
}

#pragma mark UITableView delegates

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[[contextService readContext] lock];
    Alarm* alarm = (Alarm*)[[self fetchedResultsController] objectAtIndexPath:indexPath];
	NSNumber* aId = alarm.alarmId;
	[[contextService readContext] unlock];
	if (alarm) {
		AlarmDetailController* adc = [[AlarmDetailController alloc] init];
        adc.alarmId = aId;
		UINavigationController* cont = [self navigationController];
		[cont pushViewController:adc animated:YES];
		[adc release];
	}
}

- (void)configureCell:(UITableViewCell*)cellToConfigure atIndexPath:(NSIndexPath*)indexPath
{
    [super configureCell:cellToConfigure atIndexPath:indexPath];
	ColumnarTableViewCell* cell = (ColumnarTableViewCell*)cellToConfigure;

	UIView* backgroundView = [[[UIView alloc] init] autorelease];
	backgroundView.backgroundColor = [UIColor colorWithRed:0.1 green:0.0 blue:1.0 alpha:0.75];
	cell.selectedBackgroundView = backgroundView;
    
    UIColor* clear = [UIColor colorWithWhite:1.0 alpha:0.0];
    
    // set the border based on the severity (can only set entire table background color :( )
    // tableView.separatorColor = [self getSeparatorColorForSeverity:alarm.severity];
    
    CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    
    CGFloat dateWidth = 75; // 75
    CGFloat logWidth = orientationHandler.screenWidth - (orientationHandler.cellSeparator * 3) - dateWidth;

    [[contextService readContext] lock];
    Alarm* alarm = (Alarm*)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
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
    [[contextService readContext] unlock];

	cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[cell sizeToFit];
}

-(CGFloat) tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	[[contextService readContext] lock];
    Alarm* alarm = (Alarm*)[[self fetchedResultsController] objectAtIndexPath:indexPath];
	NSString* logMessage = alarm.logMessage;
    [[contextService readContext] unlock];

	CGFloat height = 0;
	CGSize size;

    CGFloat dateWidth = 75; // 75
    CGFloat logWidth = orientationHandler.screenWidth - (orientationHandler.cellSeparator * 3) - dateWidth;

	size = [CalculateSize calcLabelSize:logMessage font:[UIFont boldSystemFontOfSize:12] lines:10 width:logWidth
								   mode:(UILineBreakModeWordWrap|UILineBreakModeTailTruncation)];
	height = size.height;
	return MAX(height, tv.rowHeight);
}

@end