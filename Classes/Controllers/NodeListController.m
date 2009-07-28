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

#import "NodeListController.h"
#import "ColumnarTableViewCell.h"
#import "OpenNMSRestAgent.h"
#import "OnmsNode.h"

@implementation NodeListController

@synthesize savedSearchTerm;
@synthesize savedScopeButtonIndex;
@synthesize searchWasActive;
@synthesize nodeList;

- (void) viewDidLoad
{
	self.title = @"Nodes";
	self.nodeList = [NSMutableArray array];
	
	if (self.savedSearchTerm)
	{
		[self.searchDisplayController setActive:self.searchWasActive];
		[self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
		[self.searchDisplayController.searchBar setText:savedSearchTerm];
		
		self.savedSearchTerm = nil;
	}

	[self.tableView reloadData];
	self.tableView.scrollEnabled = YES;
}

- (void) viewDidUnload
{
	self.searchWasActive = [self.searchDisplayController isActive];
	self.savedSearchTerm = [self.searchDisplayController.searchBar text];
	self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
	self.nodeList = nil;
}

-(void) dealloc
{
	[nodeList release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of the filtered list, otherwise return the count of the main list.
	 */
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [self.nodeList count];
    }
	else
	{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	// Set the selected color.
	UIView* backgroundView = [[[UIView alloc] init] autorelease];
	backgroundView.backgroundColor = [UIColor colorWithWhite:0.9333333 alpha:1.0];
	cell.selectedBackgroundView = backgroundView;
	
	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
	 */
	OnmsNode *node = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        node = [self.nodeList objectAtIndex:indexPath.row];
    } else {
		NSLog(@"tableview is not in search display controller");
	}
	
	cell.textLabel.text = node.label;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	OnmsNode* node = [self.nodeList objectAtIndex:indexPath.row];
	NSLog(@"displaying %@", node);
	// NodeDetailController* ndc = [[NodeDetailController alloc] init];
	// ndc.nodeId = [NSNumber numberWithInt:node.nodeId];
	UIViewController* ndc = [[UIViewController alloc] init];
	[self.searchDisplayController.searchContentsController pushViewController:ndc animated:YES];
	// [[self searchDisplayController] pushViewController:ndc animated:YES];
	[ndc release];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	NSLog(@"scope = %@", scope);
	OpenNMSRestAgent* agent = [[OpenNMSRestAgent alloc] init];
	self.nodeList = [agent getNodesForSearch:searchText];
	NSLog(@"node list = %@", self.nodeList);
	[agent release];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end

