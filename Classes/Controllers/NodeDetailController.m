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
#import "OnmsSeverity.h"
#import "NodeFactory.h"
#import "OutageFactory.h"
#import "IpInterfaceFactory.h"
#import "SnmpInterfaceFactory.h"
#import "EventFactory.h"
#import "CalculateSize.h"

@implementation NodeDetailController

@synthesize nodeTable;
@synthesize spinner;
@synthesize fuzzyDate;

@synthesize nodeId;
@synthesize sections;
@synthesize node;
@synthesize outages;
@synthesize interfaces;
@synthesize snmpInterfaces;
@synthesize events;

@synthesize screenWidth;
@synthesize tableWidth;
@synthesize cellBorder;
@synthesize cellSeparator;

- (void) loadView
{
	[super loadView];
	nodeTable = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
	nodeTable.delegate = self;
	nodeTable.dataSource = self;
	self.view = nodeTable;
	self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	self.spinner.hidesWhenStopped = YES;
	self.spinner.center = self.view.center;
	[self.navigationController.view addSubview:self.spinner];
    
    CGRect screenArea = [[UIScreen mainScreen] applicationFrame];
    screenWidth = screenArea.size.width;
    tableWidth = round(screenWidth * 0.9375);
    if (screenWidth == 768) {
        tableWidth = round(screenWidth * 0.881510416666667);
    }
	cellBorder = round(screenWidth * 0.09375);
	cellSeparator = round(screenWidth * 0.015625);
}

- (void) initializeData
{
	[self.spinner startAnimating];
	self.sections = [NSMutableArray array];

	NodeFactory* nodeFactory = [NodeFactory getInstance];
	self.node = [nodeFactory getNode:nodeId];

	self.title = self.node.label;
	self.nodeTable.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
	self.nodeTable.rowHeight = 34.0;

	OutageFactory* outageFactory = [OutageFactory getInstance];
	self.outages = [outageFactory getOutagesForNode:nodeId];
	if ([self.outages count] > 0) {
		[self.sections addObject:@"Recent Outages"];
	}

	IpInterfaceFactory* ipInterfaceFactory = [IpInterfaceFactory getInstance];
	self.interfaces = [ipInterfaceFactory getIpInterfacesForNode:nodeId];
	if ([self.interfaces count] > 0) {
		[self.sections addObject:@"IP Interfaces"];
	}
	
	SnmpInterfaceFactory* snmpInterfaceFactory = [SnmpInterfaceFactory getInstance];
	self.snmpInterfaces = [snmpInterfaceFactory getSnmpInterfacesForNode:nodeId];
	if ([self.snmpInterfaces count] > 0) {
		[self.sections addObject:@"SNMP Interfaces"];
	}
	
	EventFactory* eventFactory = [EventFactory getInstance];
	self.events = [eventFactory getEventsForNode:nodeId];
	if ([self.events count] > 0) {
		[self.sections addObject:@"Recent Events"];
	}

	[self.nodeTable reloadData];
	[self.spinner stopAnimating];
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
	UINavigationController* cont = [self navigationController];
	[cont pushViewController:someController animated:YES];
}
*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [self.sections objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0;
	if ([self.sections objectAtIndex:indexPath.section] == @"Recent Events") {
		Event* event = [self.events objectAtIndex:indexPath.row];
		CGSize size = [CalculateSize calcLabelSize:event.logMessage font:[UIFont boldSystemFontOfSize:11]
					lines:10 width:(tableWidth - (cellSeparator * 3) - 50.0) mode:(UILineBreakModeWordWrap|UILineBreakModeTailTruncation)];
		height = size.height;
	}
	return MAX(height, tableView.rowHeight);
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

	CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];

	if (sectionName == @"Recent Outages") {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		Outage* outage = [self.outages objectAtIndex:indexPath.row];

		CGFloat ipWidth      = round(tableWidth * 0.25);    // 80
        CGFloat serviceWidth = round(tableWidth * 0.225);   // 72
		CGFloat upDownWidth  = round(tableWidth * 0.21875); // 70
        CGFloat timeWidth    = tableWidth - (cellSeparator * 5) - ipWidth - serviceWidth - upDownWidth;

		// IP Address
		label = [[[UILabel alloc] initWithFrame:CGRectMake(cellSeparator, 0, ipWidth, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.adjustsFontSizeToFitWidth = YES;
		label.text = outage.ipAddress;
		[cell addColumn:outage.ipAddress];
		[cell.contentView addSubview:label];

		// Service
		label = [[[UILabel alloc] initWithFrame:CGRectMake(cellSeparator + ipWidth + cellSeparator, 0, serviceWidth, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.adjustsFontSizeToFitWidth = YES;
		label.text = outage.serviceName;
		[cell addColumn:outage.serviceName];
		[cell.contentView addSubview:label];

		NSString* regained = [fuzzyDate format:outage.ifRegainedService];
		NSString* lost = [fuzzyDate format:outage.ifLostService];

		// Up/Down
		label = [[[UILabel alloc] initWithFrame:CGRectMake(cellSeparator + ipWidth + cellSeparator + serviceWidth + cellSeparator, 0, upDownWidth, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.adjustsFontSizeToFitWidth = YES;
		if (regained != nil) {
			label.text = @"Regained";
			[cell addColumn:@"Regained"];
		} else {
			label.text = @"Lost";
			[cell addColumn:@"Lost"];
		}
        label.textAlignment = UITextAlignmentRight;
		[cell.contentView addSubview:label];

		// time
		label = [[[UILabel alloc] initWithFrame:CGRectMake(cellSeparator + ipWidth + cellSeparator + serviceWidth + cellSeparator + upDownWidth + cellSeparator, 0, timeWidth, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.adjustsFontSizeToFitWidth = YES;
		if (regained != nil) {
			label.text = regained;
			[cell addColumn:regained];
		} else {
			label.text = lost;
			[cell addColumn:lost];
		}
        label.textAlignment = UITextAlignmentRight;
		[cell.contentView addSubview:label];
		
	} else if (sectionName == @"IP Interfaces") {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		IpInterface* iface = [self.interfaces objectAtIndex:indexPath.row];
		
		CGFloat ipWidth               = round(tableWidth * 0.25);    // 80
		CGFloat managedUnmanagedWidth = round(tableWidth * 0.21875); // 70
		CGFloat hostNameWidth         = tableWidth - (cellSeparator * 4) - ipWidth - managedUnmanagedWidth;

		// IP Address
		label = [[[UILabel alloc] initWithFrame:CGRectMake(cellSeparator, 0, ipWidth, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = iface.ipAddress;
		label.adjustsFontSizeToFitWidth = YES;
		[cell addColumn:iface.ipAddress];
		[cell.contentView addSubview:label];
		
		// Host Name
		label = [[[UILabel alloc] initWithFrame:CGRectMake(cellSeparator + ipWidth + cellSeparator, 0, hostNameWidth, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = iface.hostName;
		label.adjustsFontSizeToFitWidth = YES;
		[cell addColumn:iface.hostName];
		[cell.contentView addSubview:label];
		
		// Managed/Unmanaged
		label = [[[UILabel alloc] initWithFrame:CGRectMake(cellSeparator + ipWidth + cellSeparator + hostNameWidth + cellSeparator, 0, managedUnmanagedWidth, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = [iface.managedFlag isEqual:@"M"]? @"Managed" : @"Unmanaged";
        label.textAlignment = UITextAlignmentRight;
		[cell addColumn:label.text];
		[cell.contentView addSubview:label];
		
	} else if (sectionName == @"SNMP Interfaces") {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		SnmpInterface* iface = [self.snmpInterfaces objectAtIndex:indexPath.row];

        CGFloat ifIndexWidth = round(tableWidth * 0.09375);  // 30
        CGFloat ifSpeedWidth = round(tableWidth * 0.309375); // 99
        CGFloat ipWidth      = round(tableWidth * 0.25);     // 80
        CGFloat ifDescrWidth = tableWidth - (cellSeparator * 5) - ifIndexWidth - ifSpeedWidth - ipWidth;

		// IfIndex
		label = [[[UILabel alloc] initWithFrame:CGRectMake(cellSeparator, 0, ifIndexWidth, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = [iface.ifIndex stringValue];
		[cell addColumn:[iface.ifIndex stringValue]];
		[cell.contentView addSubview:label];

		// IfDescr
		label = [[[UILabel alloc] initWithFrame:CGRectMake(cellSeparator + ifIndexWidth + cellSeparator, 0, ifDescrWidth, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = iface.ifDescription;
		[cell addColumn:iface.ifDescription];
		[cell.contentView addSubview:label];
		
		// IfSpeed
		label = [[[UILabel alloc] initWithFrame:CGRectMake(cellSeparator + ifIndexWidth + cellSeparator + ifDescrWidth + cellSeparator, 0, ifSpeedWidth, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = [iface.ifSpeed stringValue];
		[cell addColumn:[iface.ifSpeed stringValue]];
		[cell.contentView addSubview:label];
		
		// IP Address
		label = [[[UILabel alloc] initWithFrame:CGRectMake(cellSeparator + ifIndexWidth + cellSeparator + ifDescrWidth + cellSeparator + ifSpeedWidth + cellSeparator, 0, ipWidth, tableView.rowHeight)] autorelease];
		label.backgroundColor = clear;
		label.font = font;
		label.text = iface.ipAddress;
        label.textAlignment = UITextAlignmentRight;
		[cell addColumn:iface.ipAddress];
		[cell.contentView addSubview:label];
	} else if (sectionName == @"Recent Events") {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

		Event* event = [self.events objectAtIndex:indexPath.row];
		OnmsSeverity* sev = [[[OnmsSeverity alloc] initWithSeverity:event.severity] autorelease];

		UIColor* color = [sev getDisplayColor];
		cell.backgroundColor = color;

        CGFloat timeWidth = 50;
        CGFloat logWidth = tableWidth - (cellSeparator * 3) - timeWidth;

		label = [[[UILabel alloc] initWithFrame:CGRectMake(cellSeparator, 0, logWidth, height)] autorelease];
		[cell addColumn:event.logMessage];
		
		label.font = font;
		label.text = event.logMessage;
		label.lineBreakMode = UILineBreakModeWordWrap|UILineBreakModeTailTruncation;
		label.numberOfLines = 10;
		label.backgroundColor = clear;
		[cell.contentView addSubview:label];
		
		label = [[[UILabel	alloc] initWithFrame:CGRectMake(cellSeparator + logWidth + cellSeparator, 0, timeWidth, height)] autorelease];
		NSString* eventString = [fuzzyDate format:event.time];
		[cell addColumn:eventString];
		label.backgroundColor = clear;
		label.font = font;
		label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		label.text = eventString;
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.numberOfLines = 10;
        label.textAlignment = UITextAlignmentRight;
		[cell.contentView addSubview:label];
		
	}

	return cell;
}


@end
