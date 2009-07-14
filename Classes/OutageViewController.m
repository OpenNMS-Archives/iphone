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

#import "OutageViewController.h"
#import "NodeDetailController.h"
#import "OpenNMSRestAgent.h"
#import "OnmsOutage.h"
#import "OnmsEvent.h"
#import "OnmsNode.h"
#import "ViewOutage.h"

@implementation OutageViewController

@synthesize outageTable;
@synthesize nodeDetailController;

static NSString *CellIdentifier = @"Cell";

-(void) dealloc {
	[outageTable release];
	[nodeDetailController release];
	
	[agent release];
	[fuzzyDate release];
	
	[outages release];
	
    [super dealloc];
}

-(void) awakeFromNib {
	self.title = @"Outages";
	agent = [[OpenNMSRestAgent alloc] init];
	outages = [agent getViewOutages];
}

-(IBAction) reload:(id) sender
{
	outages = [agent getViewOutages];
	[outageTable reloadData];
}

#pragma mark UIViewController delegates

-(void) viewWillAppear:(BOOL)animated
{
	[outageTable reloadData];
	NSIndexPath* tableSelection = [outageTable indexPathForSelectedRow];
	[outageTable deselectRowAtIndexPath:tableSelection animated:NO];
}

#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [outages count];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	ViewOutage* outage = [outages objectAtIndex:indexPath.row];
	[nodeDetailController setNodeId:outage.nodeId];
	UINavigationController* cont = [self navigationController];
	[cont pushViewController:nodeDetailController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Set up the cell...
	cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
	cell.textLabel.text = [[outages objectAtIndex:indexPath.row] getCellText];
	return cell;
}

@end
