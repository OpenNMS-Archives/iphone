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

@implementation AlarmListController

@synthesize alarmTable;

-(void) dealloc
{
	[fuzzyDate release];
	[alarmTable release];
	[alarms release];

    [super dealloc];
}

-(void) initializeData
{
	OpenNMSRestAgent* agent = [[[OpenNMSRestAgent alloc] init] autorelease];
	alarms = [agent getAlarms];
}

-(IBAction) reload:(id) sender
{
	[self initializeData];
	[alarmTable reloadData];
}

-(UIColor*) getColorForSeverity:(NSString*)severity
{
	/*
	static UIColor* color_INDETERMINATE = [UIColor colorWithRed:0.6784 green:0.8470 blue:0.9019 alpha:1.0];
	static UIColor* color_CLEARED       = [UIColor colorWithWhite:1.0 alpha:1.0];
	static UIColor* color_NORMAL        = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
	static UIColor* color_WARNING       = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1.0];
	static UIColor* color_MINOR         = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
	static UIColor* color_MAJOR         = [UIColor colorWithRed:1.0 green:0.6470 blue:0.0 alpha:1.0];
	static UIColor* color_CRITICAL      = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	*/
	
	if ([severity isEqual:@"INDETERMINATE"]) {
		return [UIColor colorWithRed:0.6784 green:0.8470 blue:0.9019 alpha:1.0];
	} else if ([severity isEqual:@"CLEARED"]) {
		return [UIColor colorWithWhite:1.0 alpha:1.0];
	} else if ([severity isEqual:@"NORMAL"]) {
		return [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
	} else if ([severity isEqual:@"WARNING"]) {
		return [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1.0];
	} else if ([severity isEqual:@"MINOR"]) {
		return [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
	} else if ([severity isEqual:@"MAJOR"]) {
		return [UIColor colorWithRed:1.0 green:0.6470 blue:0.0 alpha:1.0];
	} else if ([severity isEqual:@"CRITICAL"]) {
		return [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	}
	return [UIColor colorWithWhite:1.0 alpha:1.0];
}

#pragma mark UIViewController delegates

- (void) viewDidLoad
{
	fuzzyDate = [[FuzzyDate alloc] init];
	[self initializeData];
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	[fuzzyDate release];
	[alarms release];
	[super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
	NSIndexPath* tableSelection = [alarmTable indexPathForSelectedRow];
	if (tableSelection) {
		[alarmTable deselectRowAtIndexPath:tableSelection animated:NO];
	}
}

#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger retVal = 0;
	if (alarms) {
		retVal = [alarms count];
	}
	return retVal;
}

/*
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (alarms && [alarms count] > 0) {
		OnmsAlarm* alarm = [alarms objectAtIndex:indexPath.row];
		[nodeDetailController setNodeId:outage.nodeId];
		UINavigationController* cont = [self navigationController];
		[cont pushViewController:nodeDetailController animated:YES];
	}
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (alarms && [alarms count] > 0) {
		OnmsAlarm* alarm = [alarms objectAtIndex:indexPath.row];
		CGSize size = [alarm.logMessage sizeWithFont:[UIFont boldSystemFontOfSize:12]
						constrainedToSize:CGSizeMake(220.0, 1000.0)
						lineBreakMode:UILineBreakModeWordWrap];
		if ((size.height + 10) >= tableView.rowHeight) {
			return (size.height + 10);
		}
	}
	return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ColumnarTableViewCell* cell = [[[ColumnarTableViewCell alloc] initWithFrame:CGRectZero] autorelease];

	UIView* backgroundView = [[[UIView alloc] init] autorelease];
	backgroundView.backgroundColor = [UIColor colorWithWhite:0.9333333 alpha:1.0];
	cell.selectedBackgroundView = backgroundView;
	
	if (alarms && [alarms count] > 0) {
		tableView.separatorColor = [UIColor colorWithWhite:0.0 alpha:1.0];
		OnmsAlarm* alarm = [alarms objectAtIndex:indexPath.row];
		
		UIColor* color = [self getColorForSeverity:alarm.severity];
		cell.contentView.backgroundColor = color;
		
		UILabel *label = [[[UILabel	alloc] initWithFrame:CGRectMake(10.0, 0, 220.0, tableView.rowHeight)] autorelease];
		[cell addColumn:alarm.logMessage];
		label.font = [UIFont boldSystemFontOfSize:12];
		label.text = alarm.logMessage;
		label.backgroundColor = color;
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.numberOfLines = 0;
		[cell.contentView addSubview:label];

		label = [[[UILabel	alloc] initWithFrame:CGRectMake(235.0, 0, 75.0, tableView.rowHeight)] autorelease];
		NSString* eventString = [fuzzyDate format:alarm.lastEventTime];
		[cell addColumn:eventString];
		label.font = [UIFont boldSystemFontOfSize:12];
		label.text = eventString;
		label.backgroundColor = color;
		[cell.contentView addSubview:label];
	} else {
		cell.textLabel.text = @"";
	}
	
	return cell;
}

@end

