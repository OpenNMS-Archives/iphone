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

#import "OutageListController.h"
#import "NodeDetailController.h"
#import "ColumnarTableViewCell.h"
#import "OnmsOutage.h"
#import "OnmsEvent.h"
#import "OnmsNode.h"
#import "ViewOutage.h"
#import "OpenNMSRestAgent.h"

@implementation OutageListController

@synthesize outageTable;
@synthesize outageList;

-(void) initializeData
{
	OpenNMSRestAgent* agent = [[OpenNMSRestAgent alloc] init];
	self.outageList = [agent getViewOutages:nil distinct:YES mini:NO];
	[agent release];
	[outageTable reloadData];
}

-(IBAction) reload:(id) sender
{
	[self initializeData];
}

#pragma mark -
#pragma mark Lifecycle methods

-(void) dealloc
{
	[outageTable release];
	[outageList release];
	
    [super dealloc];
}

#pragma mark UIViewController delegates

- (void) viewDidLoad
{
	[self initializeData];
}

- (void) viewDidUnload
{
	outageList = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
	NSIndexPath* tableSelection = [outageTable indexPathForSelectedRow];
	if (tableSelection) {
		[outageTable deselectRowAtIndexPath:tableSelection animated:NO];
	}
}

#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.outageList count];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	if ([self.outageList count] > 0) {
		ViewOutage* outage = [self.outageList objectAtIndex:indexPath.row];
		NodeDetailController* ndc = [[NodeDetailController alloc] initWithNibName:@"NodeDetailView" bundle:nil];
		[ndc setNodeId:outage.nodeId];
		UINavigationController* cont = [self navigationController];
		[cont pushViewController:ndc animated:YES];
		[ndc release];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ColumnarTableViewCell* cell = [[[ColumnarTableViewCell alloc] initWithFrame:CGRectZero] autorelease];

	// Set the selected color.
	UIView* backgroundView = [[[UIView alloc] init] autorelease];
	backgroundView.backgroundColor = [UIColor colorWithWhite:0.9333333 alpha:1.0];
	cell.selectedBackgroundView = backgroundView;

	if ([self.outageList count] > 0) {
	
		UILabel *label = [[[UILabel	alloc] initWithFrame:CGRectMake(10.0, 0, 220.0, tableView.rowHeight)] autorelease];
		ViewOutage* outage = [self.outageList objectAtIndex:indexPath.row];
		[cell addColumn:outage.nodeLabel];
		label.font = [UIFont boldSystemFontOfSize:12];
		label.text = outage.nodeLabel;
		[cell.contentView addSubview:label];

		label = [[[UILabel	alloc] initWithFrame:CGRectMake(235.0, 0, 75.0, tableView.rowHeight)] autorelease];
		[cell addColumn:outage.serviceLostDate];
		label.font = [UIFont boldSystemFontOfSize:12];
		label.text = outage.serviceLostDate;
		[cell.contentView addSubview:label];

	}

	return cell;
}

@end
