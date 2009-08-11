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

#import <UIKit/UIKit.h>
#import "FuzzyDate.h"
#import "Node.h"

@interface NodeDetailController : UIViewController <UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource> {
	@private UITableView* nodeTable;
	@private FuzzyDate* fuzzyDate;
	@private NSManagedObjectContext* managedObjectContext;

	@private NSMutableArray* sections;
	@private NSNumber* nodeId;
	@private Node* node;
	@private NSArray* outages;
	@private NSArray* interfaces;
	@private NSArray* snmpInterfaces;
	@private NSArray* events;

}

@property (retain) IBOutlet UITableView* nodeTable;
@property (nonatomic, retain) FuzzyDate* fuzzyDate;
@property (retain) NSManagedObjectContext* managedObjectContext;

@property (nonatomic, retain) NSMutableArray* sections;
@property (retain) NSNumber* nodeId;
@property (retain) Node* node;
@property (nonatomic, retain) NSArray* outages;
@property (nonatomic, retain) NSArray* interfaces;
@property (nonatomic, retain) NSArray* snmpInterfaces;
@property (nonatomic, retain) NSArray* events;

-(void)initializeData;

@end