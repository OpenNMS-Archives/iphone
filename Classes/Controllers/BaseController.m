/*******************************************************************************
 * This file is part of the OpenNMS(R) iPhone Application.
 * OpenNMS(R) is a registered trademark of The OpenNMS Group, Inc.
 *
 * Copyright (C) 2010 The OpenNMS Group, Inc.  All rights reserved.
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
#import "BaseController.h"
#import "ColumnarTableViewCell.h"

@implementation BaseController

@synthesize orientationHandler;
@synthesize contextService;
@synthesize spinner;
@synthesize tableView;
@synthesize cellIdentifier;

-(void)initializeScreenWidth:(UIInterfaceOrientation)interfaceOrientation
{
    if (!orientationHandler) {
        orientationHandler = [[OrientationHandler alloc] init];
    }
    [orientationHandler updateWithOrientation:interfaceOrientation];
}

-(void)loadView
{
#if DEBUG
	NSLog(@"%@: loadView", self);
#endif
	[self initializeScreenWidth:[[UIApplication sharedApplication] statusBarOrientation]];
    cellIdentifier = nil;
	[super loadView];
}

-(void)viewWillAppear:(BOOL)animated
{
	[self initializeScreenWidth:[[UIApplication sharedApplication] statusBarOrientation]];
    [super viewWillAppear:animated];

    if (tableView) {
        NSIndexPath* tableSelection = [tableView indexPathForSelectedRow];
        if (tableSelection) {
            [tableView deselectRowAtIndexPath:tableSelection animated:NO];
        }
        [tableView reloadData];
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
#if DEBUG
    NSLog(@"%@: willRotateToInterfaceOrientation:%d", self, orientation);
#endif
    [super willRotateToInterfaceOrientation:orientation duration:duration];
    [orientationHandler updateWithOrientation:orientation];
}

-(NSFetchedResultsController*) fetchedResultsController
{
    return nil;
}

-(void) initializeData
{
#if DEBUG
	NSLog(@"%@: initializeData", self);
#endif
	[spinner startAnimating];
	if (!contextService) {
		contextService = [[ContextService alloc] init];
	}
#if DEBUG
	NSLog(@"%@: contextService = %@", self, contextService);
#endif
}

-(void) refreshData
{
    NSError *error;
    @try {
        if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"%@: error fetching: %@", self, error);
            [error release];
        }
    }
    @catch (NSException* exception) {
        NSLog(@"%@: Caught %@: %@", self, [exception name], [exception reason]);
    }
    [tableView reloadData];
	[spinner stopAnimating];
}

#pragma mark NSFetchedResultsController delegates

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
#if DEBUG
	NSLog(@"%@: controllerWillChangeContent:%@", self, controller);
#endif
    [tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
#if DEBUG
	NSLog(@"%@: controller:%@ didChangeSection:%@ atIndex:%d forChangeType:%d", self, controller, sectionInfo, sectionIndex, type);
#endif
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
#if DEBUG
	NSLog(@"%@: controller:%@ didChangeObject:%@ atIndexPath:%@ forChangeType:%d newIndexPath:%@", self, controller, anObject, indexPath, type, newIndexPath);
#endif
	
    switch(type) {
			
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
			
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
#if DEBUG
	NSLog(@"%@: controllerDidChangeContent:%@", self, controller);
#endif
    [tableView endUpdates];
}

#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count = [[[self fetchedResultsController] sections] count];
    if (count == 0) {
        count = 1;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [[self fetchedResultsController] sections];
    NSUInteger count = 0;
    if ([sections count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    }
#if DEBUG
    NSLog(@"%@: tableView:%@ numberOfRowsInSection:%@ = %d", self, tv, section, count);
#endif
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
#ifdef DEBUG
	NSLog(@"%@: tableView:%@ cellForRowAtIndexPath:%@", self, tv, indexPath);
#endif
	ColumnarTableViewCell* cell = (ColumnarTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[[ColumnarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

- (void)configureCell:(UITableViewCell*)cellToConfigure atIndexPath:(NSIndexPath*)indexPath
{
#if DEBUG
	NSLog(@"%@: configureCell:%@ atIndexPath:%@", self, cellToConfigure, indexPath);
#endif
	for (id subview in cellToConfigure.contentView.subviews) {
		[subview removeFromSuperview];
	}
}

@end
