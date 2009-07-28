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

#import "NodeDetailController.h"
#import "ColumnarTableViewCell.h"
#import "ViewOutage.h"
#import "OnmsIpInterface.h"
#import "OnmsSnmpInterface.h"
#import "OpenNMSRestAgent.h"
#import "OnmsEvent.h"
#import "OnmsSeverity.h"

@implementation NodeDetailController

@synthesize nodeTable;
@synthesize fuzzyDate;

@synthesize nodeId;
@synthesize sections;
@synthesize node;
@synthesize outages;
@synthesize interfaces;
@synthesize snmpInterfaces;
@synthesize events;

- (void) initializeData
{
	OpenNMSRestAgent* agent = [[OpenNMSRestAgent alloc] init];

	self.title = self.node.label;
	self.nodeTable.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
	self.nodeTable.rowHeight = 34.0;
	
	self.sections = [NSMutableArray array];
	self.node = [agent getNode:nodeId];
	
	self.outages = [agent getViewOutages:nodeId distinct:NO mini:YES];
	if ([self.outages count] > 0) {
		[self.sections addObject:@"Recent Outages"];
	}
	
	self.interfaces = [agent getIpInterfaces:nodeId];
	if ([self.interfaces count] > 0) {
		[self.sections addObject:@"IP Interfaces"];
	}
	
	self.snmpInterfaces = [agent getSnmpInterfaces:nodeId];
	if ([self.snmpInterfaces count] > 0) {
		[self.sections addObject:@"SNMP Interfaces"];
	}

	self.events = [agent getEvents:nodeId limit:[NSNumber numberWithInt:5]];
	if ([self.events count] > 0) {
		[self.sections addObject:@"Recent Events"];
	}

	[agent release];
	[self.nodeTable reloadData];
}

#pragma mark -
#pragma mark Lifecycle methods

-(void) dealloc
{
	[self.nodeTable release];
	
	[self.nodeId release];
	[self.node release];
	[self.outages release];
	[self.interfaces release];
	[self.snmpInterfaces release];
	[self.events release];

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
	[self.node release];
	[self.outages release];
	[self.interfaces release];
	[self.snmpInterfaces release];
	[self.events release];
	
	[super viewDidUnload];
}

#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([self.sections objectAtIndex:section] == @"Recent Outages") {
		return [self.outages count];
	}
	if ([self.sections objectAtIndex:section] == @"IP Interfaces") {
		return [self.interfaces count];
	}
	if ([self.sections objectAtIndex:section] == @"SNMP Interfaces") {
		return [self.snmpInterfaces count];
	}
	if ([self.sections objectAtIndex:section] == @"Recent Events") {
		return [self.events count];
	}
	return 0;
}

/*
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	ViewOutage* outage = [outages objectAtIndex:indexPath.row];
	[nodeDetailController setNodeId:outage.nodeId];
	UINavigationController* cont = [self navigationController];
	[cont pushViewController:nodeDetailController animated:YES];
}
*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [self.sections objectAtIndex:section];
}

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* sectionName = [self.sections objectAtIndex:indexPath.section];

	UIColor* white = [UIColor colorWithWhite:1.0 alpha:1.0];
	UIColor* clear = [UIColor colorWithWhite:1.0 alpha:0.0];
	UIFont* font   = [UIFont boldSystemFontOfSize:11];

	ColumnarTableViewCell* cell = [[[ColumnarTableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	cell.backgroundColor = white;
	cell.textLabel.font = font;

	UILabel* label = nil;
	
	if (sectionName == @"Recent Outages") {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		ViewOutage* outage = [self.outages objectAtIndex:indexPath.row];

		// IP Address
		label = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, 115.0, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = outage.ipAddress;
		[cell addColumn:outage.ipAddress];
		[cell.contentView addSubview:label];

		// Service
		label = [[[UILabel alloc] initWithFrame:CGRectMake(130.0, 0, 67.0, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = outage.serviceName;
		[cell addColumn:outage.serviceName];
		[cell.contentView addSubview:label];

		// Up/Down
		label = [[[UILabel alloc] initWithFrame:CGRectMake(202.0, 0, 45.0, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		if (outage.serviceRegainedDate != nil) {
			label.text = @"Regained";
			[cell addColumn:@"Regained"];
		} else {
			label.text = @"Lost";
			[cell addColumn:@"Lost"];
		}
		[cell.contentView addSubview:label];

		// time
		label = [[[UILabel alloc] initWithFrame:CGRectMake(247.0, 0, 50.0, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		if (outage.serviceRegainedDate != nil) {
			label.text = outage.serviceRegainedDate;
			[cell addColumn:outage.serviceRegainedDate];
		} else {
			label.text = outage.serviceLostDate;
			[cell addColumn:outage.serviceLostDate];
		}
		[cell.contentView addSubview:label];
		
	} else if (sectionName == @"IP Interfaces") {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		OnmsIpInterface* iface = [self.interfaces objectAtIndex:indexPath.row];
		
		// IP Address
		label = [[[UILabel alloc] initWithFrame:CGRectMake(5.0, 0, 80.0, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = iface.ipAddress;
		[cell addColumn:iface.ipAddress];
		[cell.contentView addSubview:label];
		
		// Host Name
		label = [[[UILabel alloc] initWithFrame:CGRectMake(85.0, 0, 143.0, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = iface.hostName;
		[cell addColumn:iface.hostName];
		[cell.contentView addSubview:label];
		
		// Managed/Unmanaged
		label = [[[UILabel alloc] initWithFrame:CGRectMake(228.0, 0, 72, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = [iface.isManaged isEqual:@"M"]? @"Managed" : @"Unmanaged";
		[cell addColumn:([iface.isManaged isEqual:@"M"]? @"Managed" : @"Unmanaged")];
		[cell.contentView addSubview:label];
		
	} else if (sectionName == @"SNMP Interfaces") {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		OnmsSnmpInterface* iface = [self.snmpInterfaces objectAtIndex:indexPath.row];

		// IfIndex
		label = [[[UILabel alloc] initWithFrame:CGRectMake(5.0, 0, 30.0, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = [iface.ifIndex stringValue];
		[cell addColumn:[iface.ifIndex stringValue]];
		[cell.contentView addSubview:label];

		// IfDescr
		label = [[[UILabel alloc] initWithFrame:CGRectMake(35.0, 0, 64.0, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = iface.ifDescription;
		[cell addColumn:iface.ifDescription];
		[cell.contentView addSubview:label];
		
		// IfSpeed
		label = [[[UILabel alloc] initWithFrame:CGRectMake(99.0, 0, 99.0, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = [iface.ifSpeed stringValue];
		[cell addColumn:[iface.ifSpeed stringValue]];
		[cell.contentView addSubview:label];
		
		// IP Address
		label = [[[UILabel alloc] initWithFrame:CGRectMake(198.0, 0, 102.0, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = iface.ipAddress;
		[cell addColumn:iface.ipAddress];
		[cell.contentView addSubview:label];
	} else if (sectionName == @"Recent Events") {

		UIView* backgroundView = [[[UIView alloc] init] autorelease];
		backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
		cell.selectedBackgroundView = backgroundView;

		OnmsEvent* event = [self.events objectAtIndex:indexPath.row];
		OnmsSeverity* sev = [[[OnmsSeverity alloc] initWithSeverity:event.severity] autorelease];

		UIColor* color = [sev getDisplayColor];
		NSLog(@"color = %@", color);
		// cell.contentView.backgroundColor = color;
		cell.backgroundColor = color;
			
		label = [[[UILabel	alloc] initWithFrame:CGRectMake(5.0, 0, 240.0, tableView.rowHeight)] autorelease];
		[cell addColumn:event.eventLogMessage];
		
		label.font = font;
		label.text = event.eventLogMessage;
		label.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
		label.numberOfLines = 2;
		label.backgroundColor = clear;
		[cell.contentView addSubview:label];
		
		label = [[[UILabel	alloc] initWithFrame:CGRectMake(255.0, 0, 50.0, tableView.rowHeight)] autorelease];
		NSString* eventString = [fuzzyDate format:event.time];
		[cell addColumn:eventString];
		label.backgroundColor = clear;
		label.font = font;
		label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		label.text = eventString;
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.numberOfLines = 0;
		[cell.contentView addSubview:label];
		
	}

	return cell;
}


@end
