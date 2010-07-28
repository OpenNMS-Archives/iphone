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

#import <UIKit/UIKit.h>
#import "OrientationHandler.h"
#import "ContextService.h"

@interface BaseController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    OrientationHandler* orientationHandler;
    ContextService* contextService;
	NSManagedObjectContext* _context;
    IBOutlet UIActivityIndicatorView* spinner;
    IBOutlet UITableView* tableView;
    NSString* cellIdentifier;
}

@property (nonatomic, retain) OrientationHandler* orientationHandler;
@property (retain) ContextService* contextService;
@property (retain) NSManagedObjectContext* _context;
@property (retain) UIActivityIndicatorView* spinner;
@property (retain) UITableView* tableView;
@property (nonatomic, retain) NSString* cellIdentifier;

-(void) initializeScreenWidth:(UIInterfaceOrientation)interfaceOrientation;
-(void) mergeContextChanges:(NSNotification *)notification;
-(NSManagedObjectContext*) context;
-(NSFetchedResultsController*) fetchedResultsController;
-(void) initializeData;
-(void) refreshData;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) configureCell:(UITableViewCell*)cellToConfigure atIndexPath:(NSIndexPath*)indexPath;

- (UIBarButtonItem*) getSpinner;

@end
