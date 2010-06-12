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
@synthesize _viewMoc;
@synthesize _updateMoc;

-(id)init
{
    if (self = [super init]) {
        [self initializeData];
        cellIdentifier = @"outageList";
    }
    return self;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self initializeData];
}

-(void)registerListener:(NSManagedObjectContext*)context
{
    NSNotificationCenter* dnc = [NSNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(mergeChangesFromContextSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:context];
#if DEBUG
    NSLog(@"%@: observer registered", self);
#endif
}

-(void)unregisterListener:(NSManagedObjectContext*)context
{
    NSNotificationCenter* dnc = [NSNotificationCenter defaultCenter];
    [dnc removeObserver:self];
#if DEBUG
    NSLog(@"%@: observer removed", self);
#endif
}

-(void) dealloc
{
    [self unregisterListener:_updateMoc];
    fuzzyDate = nil;
    contextService = nil;
    spinner = nil;
    _fetchedResultsController = nil;
    _viewMoc = nil;
    _updateMoc = nil;
    
    [super dealloc];
}

-(NSManagedObjectContext*)viewMoc
{
    if (!_viewMoc) {
        _viewMoc = [contextService managedObjectContext];
    }
    return _viewMoc;
}

-(NSManagedObjectContext*)updateMoc
{
    if (!_updateMoc) {
        _updateMoc = [contextService managedObjectContext];
//        [self registerListener:_updateMoc];
    }
    return _updateMoc;
}

-(NSFetchedResultsController*)fetchedResultsController
{
#if DEBUG
	NSLog(@"%@: fetchedResultsController", self);
#endif
    if (_fetchedResultsController == nil) {
        NSFetchRequest* fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription* entity = [NSEntityDescription entityForName:@"Outage" inManagedObjectContext:[self viewMoc]];
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
                                                  managedObjectContext:[self viewMoc]
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
    [super initializeData];
	OutageListUpdater* updater = [[[OutageListUpdater alloc] init] autorelease];
	OutageUpdateHandler* handler = [[[OutageUpdateHandler alloc] initWithMethod:@selector(refreshData) target:self context:[self updateMoc]] autorelease];
	handler.clearOldObjects = YES;
	handler.spinner = spinner;
	updater.handler = handler;
	[updater update];
}

- (void) mergeChangesFromContextSaveNotification:(NSNotification*)notification
{
#if DEBUG
    NSLog(@"%@: mergeChangesFromContextSaveNotification:%@", self, notification);
#endif
    NSManagedObjectContext* viewMoc = [self viewMoc];
	if (viewMoc) {
#if DEBUG
        NSLog(@"merging changes");
#endif
        NSArray* updates = [[notification.userInfo objectForKey:@"updated"] allObjects];
        for (NSInteger i = [updates count]-1; i >= 0; i--)
        {
            [[viewMoc objectWithID:[[updates objectAtIndex:i] objectID]] willAccessValueForKey:nil];
        }
		[viewMoc mergeChangesFromContextDidSaveNotification:notification];
	}
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
	[self initializeData];

	[super viewDidLoad];
}

- (void) viewDidUnload
{
    fuzzyDate = nil;
    _fetchedResultsController = nil;
	
	[super viewDidUnload];
}

/*
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	if ([self.outageList count] > 0) {
		NSManagedObjectID* objId = [self.outageList objectAtIndex:indexPath.row];
		if (objId) {
#ifdef DEBUG
			NSLog(@"viewing outage with object ID %@", objId);
#endif
			Outage* outage = (Outage*)[[contextService managedObjectContext] objectWithID:objId];
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
*/

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
#ifdef DEBUG
        NSLog(@"%@: no outage found", self);
#endif
    }
}

@end
