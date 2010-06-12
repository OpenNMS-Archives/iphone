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

#import "config.h"
#import "NodeListController.h"
#import "ColumnarTableViewCell.h"
#import "NodeFactory.h"
#import "NodeSearchUpdater.h"
#import "NodeUpdateHandler.h"
#import "Node.h"

@implementation NodeListController

@synthesize savedSearchTerm;
@synthesize savedScopeButtonIndex;
@synthesize searchWasActive;
@synthesize nodeList;
@synthesize contextService;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) viewDidLoad
{
	self.title = @"Nodes";
	if (!self.nodeList) {
		self.nodeList = [NSMutableArray array];
	}
	if (!self.contextService) {
		self.contextService = [[ContextService alloc] init];
	}
	
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
	[self.contextService release];
	self.contextService = nil;
}

-(void) dealloc
{
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
	backgroundView.backgroundColor = [UIColor colorWithRed:0.1 green:0.0 blue:1.0 alpha:0.75];
	cell.selectedBackgroundView = backgroundView;
	
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		NSManagedObjectContext* context = [contextService managedObjectContext];
		Node* node = (Node*)[context objectWithID:[self.nodeList objectAtIndex:indexPath.row]];
		cell.textLabel.text = node.label;
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.textLabel.minimumFontSize = 9.0;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSManagedObjectID* objId = [self.nodeList objectAtIndex:indexPath.row];
	Node* node = (Node*) [[contextService managedObjectContext] objectWithID:objId];
	NodeDetailController* ndc = [[NodeDetailController alloc] init];
	ndc.nodeId = node.nodeId;
	[self.navigationController pushViewController:ndc animated:YES];
	[ndc release];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
}

-(void) refreshData
{
#if DEBUG
	NSLog(@"%@: refreshData called", self);
#endif
	self.nodeList = [[NodeFactory getInstance] getCoreDataNodeObjectIDs:[self.searchDisplayController.searchBar text]];
	[self.searchDisplayController.searchResultsTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	/*
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
	 */

	NodeSearchUpdater* updater = [[[NodeSearchUpdater alloc] initWithSearchString:searchString] autorelease];
	NodeUpdateHandler* handler = [[NodeUpdateHandler alloc] initWithMethod:@selector(refreshData) target:self];
	// FIXME: spinner!
//	handler.spinner = spinner;
	updater.handler = handler;
	[updater update];
	
	return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (IBAction) addInterface:(id) sender
{
#if DEBUG
	NSLog(@"%@: adding interface", self);
#endif
	IPAddressInputController* inputController = [[IPAddressInputController alloc] initWithNibName:@"DiscoverIPAddressView" bundle:nil];
    [self presentModalViewController:inputController animated:YES];
	[inputController release];
}

@end

