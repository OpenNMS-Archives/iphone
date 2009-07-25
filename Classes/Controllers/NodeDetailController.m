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

@implementation NodeDetailController

@synthesize nodeTable;
@synthesize nodeId;

-(id) init
{
	if (self = [super init]) {
	}
	return self;
}

-(void) dealloc
{
	[nodeTable release];
	
	[nodeId release];
	[node release];
	[outages release];
	[interfaces release];
	[snmpInterfaces release];

	[super dealloc];
}

- (void) viewDidLoad
{
	fuzzyDate = [[FuzzyDate alloc] init];
	fuzzyDate.mini = YES;

	[super viewDidLoad];
}

- (void) viewDidUnload
{
	[fuzzyDate release];

	[sections release];
	[node release];
	[outages release];
	[interfaces release];
	[snmpInterfaces release];
	
	[super viewDidUnload];
}

- (void) initializeData
{
	sections = [[NSMutableArray alloc] init];
	OpenNMSRestAgent* agent = [[[OpenNMSRestAgent alloc] init] autorelease];
	node = [agent getNode:nodeId];
	
	outages = [agent getViewOutages:nodeId distinct:NO];
	if ([outages count] > 0) {
		[sections addObject:@"Recent Outages"];
	}
	
	interfaces = [agent getIpInterfaces:nodeId];
	if ([interfaces count] > 0) {
		[sections addObject:@"IP Interfaces"];
	}

	snmpInterfaces = [agent getSnmpInterfaces:nodeId];
	if ([snmpInterfaces count] > 0) {
		[sections addObject:@"SNMP Interfaces"];
	}
}

#pragma mark UIViewController delegates

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.title = node.label;
	nodeTable.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
	nodeTable.rowHeight = 34.0;
	[self initializeData];
	[nodeTable reloadData];
}

/*
-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}
 */

#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([sections objectAtIndex:section] == @"Recent Outages") {
		return [outages count];
	}
	if ([sections objectAtIndex:section] == @"IP Interfaces") {
		return [interfaces count];
	}
	if ([sections objectAtIndex:section] == @"SNMP Interfaces") {
		return [snmpInterfaces count];
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
	return [sections objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* sectionName = [sections objectAtIndex:indexPath.section];

	UIColor* white = [UIColor colorWithWhite:1.0 alpha:1.0];
	UIColor* clear = [UIColor colorWithWhite:1.0 alpha:0.0];
	UIFont* font   = [UIFont boldSystemFontOfSize:11];

	ColumnarTableViewCell* cell = [[[ColumnarTableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	cell.backgroundColor = white;
	cell.textLabel.font = font;

	if (sectionName == @"Recent Outages") {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		ViewOutage* outage = [outages objectAtIndex:indexPath.row];

		// IP Address
		UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, 115.0, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = outage.ipAddress;
		[cell addColumn:outage.ipAddress];
		[cell.contentView addSubview:label];

		// Service
		label = [[[UILabel alloc] initWithFrame:CGRectMake(130.0, 0, 60.0, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = outage.serviceName;
		[cell addColumn:outage.serviceName];
		[cell.contentView addSubview:label];

		// Up/Down
		label = [[[UILabel alloc] initWithFrame:CGRectMake(195.0, 0, 45.0, tableView.rowHeight)] autorelease];
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
		label = [[[UILabel alloc] initWithFrame:CGRectMake(240.0, 0, 57.0, tableView.rowHeight)] autorelease];
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
		OnmsIpInterface* iface = [interfaces objectAtIndex:indexPath.row];
		
		// IP Address
		UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(5.0, 0, 80.0, tableView.rowHeight)] autorelease];
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
		OnmsSnmpInterface* iface = [snmpInterfaces objectAtIndex:indexPath.row];

		// IfIndex
		UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(5.0, 0, 30.0, tableView.rowHeight)] autorelease];
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
	}

	return cell;
}


@end
