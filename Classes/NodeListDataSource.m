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

#import "NodeListDataSource.h"
#import "NodeListModel.h"
#import "NodeModel.h"

#import "ONMSSeverityItem.h"
#import "ONMSSeverityItemCell.h"

#import "Three20Core/NSStringAdditions.h"

@implementation NodeListDataSource

@synthesize nodeListModel = _nodeListModel;

- (id)init
{
	if (self = [super init]) {
    _nodeListModel = [[NodeListModel alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (id<TTModel>)model
{
	return _nodeListModel;
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView
{
  return [TTTableViewDataSource lettersForSectionsWithSearch:YES summary:NO];
}

- (void)tableViewDidLoadModel:(UITableView*)tableView
{
  self.items = [NSMutableArray array];
  self.sections = [NSMutableArray array];

  NSMutableDictionary* groups = [NSMutableDictionary dictionary];
  
  id key;
  NSEnumerator* en = [_nodeListModel.nodes keyEnumerator];
  while (key = [en nextObject]) {
    NSString* name = [_nodeListModel.nodes valueForKey:key];
    NSString* letter = [NSString stringWithFormat:@"%c", [name characterAtIndex:0]];
    NSMutableArray* section = [groups objectForKey:letter];
    if (!section) {
      section = [NSMutableArray array];
      [groups setObject:section forKey:letter];
    }
    
    TTTableItem* item = [TTTableTextItem itemWithText:name URL:nil];
    [section addObject:item];
  }

  NSArray* letters = [groups.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  for (NSString* letter in letters) {
    NSArray* items = [groups objectForKey:letter];
    [_sections addObject:letter];
    [_items addObject:items];
  }
}

- (NSString*)titleForLoading:(BOOL)reloading {
  return @"Searching...";
}

- (NSString*)titleForNoData {
  return @"No nodes found.";
}

@end
