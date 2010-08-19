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

#import "NodeListModel.h"
#import "Three20Core/NSArrayAdditions.h"

@implementation NodeListModel

@synthesize isLoaded = _isLoaded;
@synthesize isLoading = _isLoading;
@synthesize isOutdated = _isOutdated;

@synthesize nodes = _nodes;

- (id)init
{
  if (self = [super init]) {
    _isLoaded = NO;
    _isLoading = NO;
    _isOutdated = NO;
  }
  return self;
}

- (BOOL)isLoaded
{
  return _isLoaded;
}

- (BOOL)isLoading
{
  return _isLoading;
}

- (BOOL)isLoadingMore
{
  return NO;
}

- (BOOL)isOutdated
{
  return _isOutdated;
}

- (void)search:(NSString*)text
{
  TTDINFO(@"searching");
  [self load:TTURLRequestCachePolicyNone more:NO];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
  TTDINFO(@"load:more");
  [self didStartLoad];
  _isLoading = YES;

  [_nodes setValue:@"google" forKey:@"1"];
  [_nodes setValue:@"yahoo" forKey:@"2"];
  [_nodes setValue:@"opennms" forKey:@"3"];
  
  _isLoaded = YES;
  _isLoading = NO;
  _isOutdated = NO;
  [self didFinishLoad];
}

- (void)invalidate:(BOOL)erase
{
  _isOutdated = YES;
}

@end
