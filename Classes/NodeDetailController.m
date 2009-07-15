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
#import "OpenNMSRestAgent.h"
#import "OnmsOutage.h"
#import "OnmsIpInterface.h"

@implementation NodeDetailController

@synthesize nodeTable;
@synthesize nodeId;

static NSString *CellIdentifier = @"Cell";

-(void) dealloc {
	[nodeTable release];
	[agent release];
	[fuzzyDate release];
	
	[nodeId release];
	[node release];
	[outages release];
	[interfaces release];

	[super dealloc];
}

-(void) awakeFromNib {
	agent = [[OpenNMSRestAgent alloc] init];
	fuzzyDate = [[FuzzyDate alloc] init];
}

#pragma mark UIViewController delegates

-(void) viewWillAppear:(BOOL)animated
{
	sections = [[NSMutableArray alloc] init];
	node = [agent getNode:nodeId];
	
	outages = [agent getOutagesForNode:nodeId];
	if ([outages count] > 0) {
		[sections addObject:@"Recent Outages"];
	}

	interfaces = [agent getIpInterfaces:nodeId];
	if ([interfaces count] > 0) {
		[sections addObject:@"IP Interfaces"];
	}

	self.title = node.label;
	nodeTable.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
}

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
	return 0;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	/*
	ViewOutage* outage = [outages objectAtIndex:indexPath.row];
	[nodeDetailController setNodeId:outage.nodeId];
	UINavigationController* cont = [self navigationController];
	[cont pushViewController:nodeDetailController animated:YES];
	 */
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [sections objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	ColumnarTableViewCell *cell = (ColumnarTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[ColumnarTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}

	cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:12];

	NSString* sectionName = [sections objectAtIndex:indexPath.section];
	if (sectionName == @"Recent Outages") {
		OnmsOutage* outage = [outages objectAtIndex:indexPath.row];
		if (outage.serviceRegainedEvent != nil) {
			cell.textLabel.text = [NSString stringWithFormat:@"%@:%@ Regained %@ ago", outage.ipAddress, outage.serviceName, [fuzzyDate format:outage.ifRegainedService]];
		} else {
			cell.textLabel.text = [NSString stringWithFormat:@"%@:%@ Lost %@ ago", outage.ipAddress, outage.serviceName, [fuzzyDate format:outage.ifLostService]];
		}
	} else if (sectionName == @"IP Interfaces") {
		cell.textLabel.text = @"test";
		/*
		 ColumnarTableViewCell *cell = [[[ColumnarTableViewCell alloc] initWithFrame:CGRectZero] autorelease];
		 cell.textLabel.adjustsFontSizeToFitWidth;
		 
		 UILabel *label = [[[UILabel	alloc] initWithFrame:CGRectMake(10.0, 0, 230.0, tableView.rowHeight)] autorelease];
		 ViewOutage* outage = [outages objectAtIndex:indexPath.row];
		 [cell addColumn:outage.nodeLabel];
		 label.font = [UIFont boldSystemFontOfSize:12];
		 label.text = outage.nodeLabel;
		 [cell.contentView addSubview:label];
		 
		 label = [[[UILabel	alloc] initWithFrame:CGRectMake(250.0, 0, 60.0, tableView.rowHeight)] autorelease];
		 [cell addColumn:outage.serviceLostDate];
		 label.font = [UIFont boldSystemFontOfSize:12];
		 label.text = outage.serviceLostDate;
		 [cell.contentView addSubview:label];
			*/
	}

	return cell;
}


@end
