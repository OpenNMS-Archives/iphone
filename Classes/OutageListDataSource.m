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

#import "OutageListDataSource.h"
#import "OutageListModel.h"
#import "OutageModel.h"

#import "ONMSSeverityItem.h"
#import "ONMSSeverityItemCell.h"

#import "Three20Core/NSStringAdditions.h"

@implementation OutageListDataSource

- (id)init
{
  if (self = [super init]) {
    _outageListModel = [[OutageListModel alloc] init];
  }
  return self;
}

- (void)dealloc
{
  // Don't do this!  It's done for us.
  // TT_RELEASE_SAFELY(_outageListModel);
  [super dealloc];
}

- (id<TTModel>)model
{
  return _outageListModel;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object
{
  if ([object isKindOfClass:[ONMSSeverityItem class]]) {
    return [ONMSSeverityItemCell class];
  } else {
    return [super tableView:tableView cellClassForObject:object];
  }
}

- (void)tableViewDidLoadModel:(UITableView*)tableView
{
  NSMutableArray* items = [[NSMutableArray alloc] init];
  NSArray* outages = _outageListModel.outages;

  for (id o in outages) {
    OutageModel* outage = (OutageModel*)o;
    NSString* host = outage.ipAddress;
	if (host == nil) {
	  host = @"Unknown";
	}

    ONMSSeverityItem* item = [[[ONMSSeverityItem alloc] init] autorelease];
	item.text = [host stringByAppendingFormat:@"/%@", outage.serviceName];
    item.caption = [outage.logMessage stringByRemovingHTMLTags];
    item.timestamp = outage.ifLostService;
    item.severity = outage.severity;
    item.URL = [@"onms://nodes/get/" stringByAppendingString:outage.nodeId];
    [items addObject:item];
  }
  
  self.items = items;
  
  TT_RELEASE_SAFELY(items);
}

@end
