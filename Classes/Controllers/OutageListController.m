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
#import "Outage.h"
#import "OutageFactory.h"

#define IFLOSTSERVICEWIDTH 75.0

@implementation OutageListController

@synthesize fuzzyDate;
@synthesize nodeFactory;

@synthesize _fetchedResultsController;
@synthesize _refreshTimer;

-(id)init
{
    if (self = [super init]) {
        cellIdentifier = @"outageList";
		[NSFetchedResultsController deleteCacheWithName:@"outageByIfLostService"];
    }
    return self;
}

-(void) dealloc
{
	if (_refreshTimer) {
		[_refreshTimer invalidate];
		_refreshTimer = nil;
	}
    fuzzyDate = nil;
    spinner = nil;
    _fetchedResultsController = nil;
    
    [super dealloc];
}

-(NSFetchedResultsController*)fetchedResultsController
{
#if DEBUG
	NSLog(@"%@: fetchedResultsController", self);
#endif
    if (!_fetchedResultsController) {
        NSFetchRequest* fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription* entity = [NSEntityDescription entityForName:@"Outage" inManagedObjectContext:[contextService readContext]];
        [fetchRequest setEntity:entity];
#if DEBUG
        NSLog(@"%@: fetchRequest = %@", self, fetchRequest);
#endif
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ifLostService" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
#if DEBUG
        NSLog(@"%@: sortDescriptors = %@", self, sortDescriptors);
#endif
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptors release];
        [sortDescriptor release];
        
#if DEBUG
        NSLog(@"%@: getting new controller", self);
#endif
        NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]
                                                  initWithFetchRequest:fetchRequest
                                                  managedObjectContext:[contextService readContext]
                                                  sectionNameKeyPath:nil
                                                  cacheName:@"outageByIfLostService"];
#if DEBUG
        NSLog(@"%@: fetchedResultsController = %@", self, controller);
#endif
        controller.delegate = self;
        _fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(void) initializeData
{
    self.navigationItem.rightBarButtonItem = [self getSpinner];
    [super initializeData];
	OutageListUpdater* updater = [[[OutageListUpdater alloc] init] autorelease];
	OutageUpdateHandler* handler = [[[OutageUpdateHandler alloc] initWithMethod:@selector(refreshData) target:self] autorelease];
	handler.clearOldObjects = YES;
	updater.handler = handler;
	[updater update];
}

-(void) refreshData
{
    [super refreshData];
    self.navigationItem.rightBarButtonItem = nil;
}

-(IBAction) reload:(id) sender
{
	[self initializeData];
}

#pragma mark UIViewController delegates

- (void) viewDidLoad
{
	self.fuzzyDate = [[FuzzyDate alloc] init];
	if (!nodeFactory) {
		self.nodeFactory = [NodeFactory getInstance];
	}
	[super viewDidLoad];
}

- (void) viewDidUnload
{
    fuzzyDate = nil;
	[super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
	[self initializeData];
	[super viewWillAppear:animated];
	_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_INTERVAL target:self selector:@selector(initializeData) userInfo:nil repeats:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[_refreshTimer invalidate];
	_refreshTimer = nil;
    [super viewWillDisappear:animated];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    Outage* outage = (Outage*)[[self fetchedResultsController] objectAtIndexPath:indexPath];
	if (outage) {
		NodeDetailController* ndc = [[NodeDetailController alloc] init];
		ndc.nodeId = outage.nodeId;
		UINavigationController* cont = [self navigationController];
		[cont pushViewController:ndc animated:YES];
		[ndc release];
	}
}

- (void)configureCell:(UITableViewCell*)cellToConfigure atIndexPath:(NSIndexPath*)indexPath
{
    [super configureCell:cellToConfigure atIndexPath:indexPath];
	ColumnarTableViewCell* cell = (ColumnarTableViewCell*)cellToConfigure;

	// Set the selected color.
	UIView* backgroundView = [[[UIView alloc] init] autorelease];
	backgroundView.backgroundColor = [UIColor colorWithRed:0.1 green:0.0 blue:1.0 alpha:0.75];
	cell.selectedBackgroundView = backgroundView;

	CGFloat nodeLabelWidth = orientationHandler.screenWidth - (orientationHandler.cellSeparator * 3) - IFLOSTSERVICEWIDTH;

    Outage* outage = (Outage*)[[self fetchedResultsController] objectAtIndexPath:indexPath];
	
	if (outage) {
		UILabel *label = [[[UILabel	alloc] initWithFrame:CGRectMake(orientationHandler.cellSeparator, 0, nodeLabelWidth, self.tableView.rowHeight)] autorelease];
		
        NSString* nodeLabel = outage.ipAddress;
        Node* node = [self.nodeFactory getCoreDataNode:outage.nodeId];
        if (node != nil) {
            nodeLabel = node.label;
        }
        [cell addColumn:nodeLabel];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.text = nodeLabel;
        [cell.contentView addSubview:label];
		
        label = [[[UILabel	alloc] initWithFrame:CGRectMake(orientationHandler.cellSeparator + nodeLabelWidth + orientationHandler.cellSeparator, 0, IFLOSTSERVICEWIDTH, self.tableView.rowHeight)] autorelease];
        NSString* date = [fuzzyDate format:outage.ifLostService];
        [cell addColumn:date];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.text = date;
        [cell.contentView addSubview:label];
	} else {
#if DEBUG
        NSLog(@"%@: no outage found", self);
#endif
    }
}

@end
