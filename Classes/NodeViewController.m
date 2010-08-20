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

#import "NodeViewController.h"
#import "NodeDataSource.h"

@implementation NodeViewController

@synthesize nodeId = _nodeId;

- (id)initWithNodeId:(NSString*)nid
{
  if (self = [self init]) {
    TTDINFO(@"initialized with node ID %@", nid);
    self.nodeId = [nid retain];
    self.title = [@"Node #" stringByAppendingString:nid];
  }
  return self;
}

- (void)dealloc
{
  TT_RELEASE_SAFELY(_nodeId);

  [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

// Hmm, no good with large node labels
/*
- (void)modelDidFinishLoad:(id <TTModel>)model
{
  if (_model == model) {
    NSString* label = ((NodeDataSource*)self.dataSource).label;
    if (label) {
      self.title = [label stringByAppendingFormat:@" (%@)", _nodeId];
    }
  }
  [super modelDidFinishLoad:model];
}
*/

- (void)loadView
{
  self.tableViewStyle = UITableViewStyleGrouped;
  self.variableHeightRows = YES;
  [super loadView];
}

- (void)createModel
{
  self.dataSource = [[[NodeDataSource alloc] initWithNodeId:_nodeId] autorelease];
}

@end
