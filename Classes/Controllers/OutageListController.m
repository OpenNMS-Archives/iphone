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
#import "OutageListUpdater.h"
#import "OutageUpdateHandler.h"
#import "OpenNMSAppDelegate.h"
#import "Outage.h"
#import "OutageFactory.h"

@implementation OutageListController

@synthesize outageTable;
@synthesize spinner;
@synthesize fuzzyDate;
@synthesize managedObjectContext;

@synthesize outageList;

-(void) dealloc
{
	[self.fuzzyDate release];
	[self.outageTable release];
	[self.managedObjectContext release];
	[self.spinner release];

	[self.outageList release];
	
    [super dealloc];
}

-(void) initializeData
{
	if (!self.outageList) {
		[spinner startAnimating];
		self.outageList = [NSMutableArray array];
	}
	[self.outageTable reloadData];

	OutageListUpdater* updater = [[[OutageListUpdater alloc] init] autorelease];
	OutageUpdateHandler* handler = [[[OutageUpdateHandler alloc] initWithTableView:self.outageTable objectList:self.outageList] autorelease];
	handler.spinner = spinner;
	updater.handler = handler;
	[updater update];
}

-(IBAction) reload:(id) sender
{
	[spinner startAnimating];
	[self initializeData];
}

#pragma mark UIViewController delegates

- (void) viewDidLoad
{
	if (!managedObjectContext) {
		managedObjectContext = [(OpenNMSAppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
	}
	
	self.fuzzyDate = [[FuzzyDate alloc] init];
	[self initializeData];

	[super viewDidLoad];
}

- (void) viewDidUnload
{
	[self.fuzzyDate release];
	[self.outageTable release];
	[self.outageList release];
	
	[super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
	NSIndexPath* tableSelection = [self.outageTable indexPathForSelectedRow];
	if (tableSelection) {
		[self.outageTable deselectRowAtIndexPath:tableSelection animated:NO];
	}
	[self.outageTable reloadData];
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
		Outage* outage = [self.outageList objectAtIndex:indexPath.row];
		NSLog(@"viewing outage %@", [outage objectID]);
		if (outage) {
			[managedObjectContext refreshObject:outage mergeChanges:YES];
			outage = (Outage*)[managedObjectContext objectWithID:[outage objectID]];
			NSLog(@"outage = %@");
			NodeDetailController* ndc = [[NodeDetailController alloc] init];
			ndc.nodeId = outage.nodeId;
			UINavigationController* cont = [self navigationController];
			[cont pushViewController:ndc animated:YES];
			[ndc release];
		} else {
			NSLog(@"warning, no outage object at row %d", indexPath.row);
		}
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
		Outage* outage = [[self.outageList objectAtIndex:indexPath.row] retain];
		
		if (outage) {
			NSString* nodeLabel = outage.ipAddress;
			if (outage.node != nil) {
				nodeLabel = outage.node.label;
			}
			[cell addColumn:nodeLabel];
			label.font = [UIFont boldSystemFontOfSize:12];
			label.text = nodeLabel;
			[cell.contentView addSubview:label];

			label = [[[UILabel	alloc] initWithFrame:CGRectMake(235.0, 0, 75.0, tableView.rowHeight)] autorelease];
			NSString* date = [fuzzyDate format:outage.ifLostService];
			[cell addColumn:date];
			label.font = [UIFont boldSystemFontOfSize:12];
			label.text = date;
			[cell.contentView addSubview:label];
			[outage release];
		}
	}

	return cell;
}

@end
