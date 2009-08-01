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

#import "AlarmDetailController.h"
#import "ColumnarTableViewCell.h"
#import "OpenNMSRestAgent.h"
#import "OnmsSeverity.h"

@implementation AlarmDetailController

@synthesize alarmTable;
@synthesize fuzzyDate;

// @synthesize alarmId;
@synthesize sections;
@synthesize alarm;

/*
@synthesize outages;
@synthesize interfaces;
@synthesize snmpInterfaces;
@synthesize events;
*/

- (void) loadView
{
	[super loadView];
	alarmTable = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
	alarmTable.delegate = self;
	alarmTable.dataSource = self;
	self.view = alarmTable;
}

- (void) initializeData
{
	self.title = [NSString stringWithFormat:@"Alarm #%@", self.alarm.alarmId];

	OnmsSeverity* severity = [[OnmsSeverity alloc] initWithSeverity:self.alarm.severity];
	self.alarmTable.backgroundColor = [severity getDisplayColor];
	self.alarmTable.rowHeight = 34.0;
	[severity release];
	
	self.sections = [NSMutableArray array];

	/*
	self.outages = [agent getViewOutages:alarmId distinct:NO mini:YES];
	if ([self.outages count] > 0) {
		[self.sections addObject:@"Recent Outages"];
	}
	
	self.interfaces = [agent getIpInterfaces:alarmId];
	if ([self.interfaces count] > 0) {
		[self.sections addObject:@"IP Interfaces"];
	}
	
	self.snmpInterfaces = [agent getSnmpInterfaces:alarmId];
	if ([self.snmpInterfaces count] > 0) {
		[self.sections addObject:@"SNMP Interfaces"];
	}

	self.events = [agent getEvents:alarmId limit:[NSNumber numberWithInt:5]];
	if ([self.events count] > 0) {
		[self.sections addObject:@"Recent Events"];
	}
	*/

	[self.alarmTable reloadData];
}

#pragma mark -
#pragma mark Lifecycle methods

-(void) dealloc
{
	[self.alarmTable release];
	
//	[self.alarmId release];
	[self.alarm release];

	/*
	[self.outages release];
	[self.interfaces release];
	[self.snmpInterfaces release];
	[self.events release];
	*/

	[super dealloc];
}

- (void) viewWillAppear:(BOOL)animated
{
	[self initializeData];
	[super viewWillAppear:animated];
}

- (void) viewDidLoad
{
	self.fuzzyDate = [[FuzzyDate alloc] init];
	self.fuzzyDate.mini = YES;

	[self initializeData];

	[super viewDidLoad];
}

- (void) viewDidUnload
{
	[self.fuzzyDate release];

	[self.sections release];
	[self.alarm release];

	/*
	[self.outages release];
	[self.interfaces release];
	[self.snmpInterfaces release];
	[self.events release];
	*/
	
	[super viewDidUnload];
}

#pragma mark UITableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 6;
}

/*
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	ViewOutage* outage = [outages objectAtIndex:indexPath.row];
	[alarmDetailController setAlarmId:outage.alarmId];
	UINavigationController* cont = [self navigationController];
	[cont pushViewController:alarmDetailController animated:YES];
}
*/

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.sections objectAtIndex:indexPath.section] == @"Recent Events") {
		OnmsEvent* event = [self.events objectAtIndex:indexPath.row];
		CGSize size = [event.eventLogMessage sizeWithFont:[UIFont boldSystemFontOfSize:11]
					   constrainedToSize:CGSizeMake(220.0, 1000.0)
					   lineBreakMode:UILineBreakModeWordWrap];
		if ((size.height + 10) >= tableView.rowHeight) {
			return (size.height + 10);
		}
	}
	return tableView.rowHeight;
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSString* sectionName = [self.sections objectAtIndex:indexPath.section];

//	UIColor* white = [UIColor colorWithWhite:1.0 alpha:1.0];
//	UIColor* clear = [UIColor colorWithWhite:1.0 alpha:0.0];
	UIFont* font   = [UIFont boldSystemFontOfSize:11];

	UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
//	cell.backgroundColor = white;
//	cell.textLabel.font = font;
	cell.textLabel.textColor = [UIColor colorWithWhite:0.0 alpha:1.0];

	switch(indexPath.row) {
		case 0:
			cell.textLabel.font = font;
			cell.textLabel.text = @"UEI";
			cell.detailTextLabel.text = alarm.uei;
			break;
		case 1:
			cell.textLabel.font = font;
			cell.textLabel.text = @"Severity";
			cell.detailTextLabel.text = alarm.severity;
			break;
		case 2:
			cell.textLabel.font = font;
			cell.textLabel.text = @"# Events";
			cell.detailTextLabel.text = [alarm.count stringValue];
			break;
		case 3:
			cell.textLabel.font = font;
			cell.textLabel.text = @"Message";
			cell.detailTextLabel.text = alarm.logMessage;
			break;
		case 4:
			cell.textLabel.font = font;
			cell.textLabel.text = @"First Event";
			cell.detailTextLabel.text = [fuzzyDate format:alarm.firstEventTime];
			break;
		case 5:
			cell.textLabel.font = font;
			cell.textLabel.text = @"Last Event";
			cell.detailTextLabel.text = [fuzzyDate format:alarm.lastEventTime];
			break;
	}
	
	return cell;
}


@end
