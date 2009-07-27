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
#import "OpenNMSRestAgent.h"
#import "OnmsAlarm.h"
#import "OnmsSeverity.h"

@implementation AlarmListController

@synthesize alarmTable;
@synthesize fuzzyDate;

@synthesize alarmList;

-(void) dealloc
{
	[self.fuzzyDate release];
	[self.alarmTable release];
	[self.alarmList release];

    [super dealloc];
}

-(void) initializeData
{
	OpenNMSRestAgent* agent = [[OpenNMSRestAgent alloc] init];
	self.alarmList = [agent getAlarms];
	[agent release];
	[self.alarmTable reloadData];
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
}

#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.alarmList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.alarmList count] > 0) {
		OnmsAlarm* alarm = [self.alarmList objectAtIndex:indexPath.row];
		CGSize size = [alarm.logMessage sizeWithFont:[UIFont boldSystemFontOfSize:12]
						constrainedToSize:CGSizeMake(220.0, 1000.0)
						lineBreakMode:UILineBreakModeWordWrap];
		if ((size.height + 20) >= tableView.rowHeight) {
			return (size.height + 20);
		}
	}
	return tableView.rowHeight;
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

		OnmsAlarm* alarm = [self.alarmList objectAtIndex:indexPath.row];
		OnmsSeverity* sev = [[[OnmsSeverity alloc] initWithSeverity:alarm.severity] autorelease];
		UIColor* color = [sev getDisplayColor];
		cell.contentView.backgroundColor = color;
		
		UILabel *label = [[[UILabel	alloc] initWithFrame:CGRectMake(10.0, 0, 220.0, tableView.rowHeight)] autorelease];
		[cell addColumn:alarm.logMessage];
		label.font = [UIFont boldSystemFontOfSize:12];
		label.text = alarm.logMessage;
		label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.numberOfLines = 0;
		label.backgroundColor = clear;
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[label sizeToFit];
		[cell.contentView addSubview:label];

		label = [[[UILabel	alloc] initWithFrame:CGRectMake(235.0, 0, 75.0, tableView.rowHeight)] autorelease];
		NSString* eventString = [fuzzyDate format:alarm.lastEventTime];
		[cell addColumn:eventString];
		label.font = [UIFont boldSystemFontOfSize:12];
		label.text = eventString;
		label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		label.backgroundColor = clear;
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[label sizeToFit];
		[cell.contentView addSubview:label];
	} else {
		cell.textLabel.text = @"";
	}
	
	return cell;
}

@end

