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
#import "NodeXMLParserDelegate.h"
#import "Three20Core/NSArrayAdditions.h"

@implementation NodeListModel

@synthesize nodes = _nodes;

- (id)init
{
  if (self = [super init]) {
    _nodes = [[NSMutableDictionary alloc] init];
    _alwaysLoad = YES;
  }
  return self;
}

- (void)search:(NSString*)text
{
  _search = text;
  [self load:TTURLRequestCachePolicyNone more:NO];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
  if (_alwaysLoad || !self.isLoading) {
    if (_search && [_search length] > 0) {
      NSString* escaped = [_search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      NSString* url = [ONMSURLRequestModel getURL:[NSString stringWithFormat:@"/nodes?comparator=ilike&match=any&label=%@%%25&ipInterface.ipAddress=%@%%25&ipInterface.ipHostName=%@%%25", escaped, escaped, escaped]];
      TTURLRequest* request = [TTURLRequest requestWithURL:url delegate:self];
      request.cachePolicy = cachePolicy;
      
      id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
      request.response = response;
      TT_RELEASE_SAFELY(response);
      
      [request send];
    } else {
      [_nodes removeAllObjects];
      [self didFinishLoad];
    }
  }
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
  TTURLDataResponse* response = request.response;
  
  NSString* text = [self stringWithUTF8Data:response.data];
  text = [self stringWithUTF8String:text];
  NSData* data = [text dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
  NodeXMLParserDelegate* npd = [[NodeXMLParserDelegate alloc] init];
  parser.delegate = npd;
  [parser parse];

  [_nodes removeAllObjects];
  for (id n in npd.nodes) {
    NodeModel* node = n;
    [_nodes setValue:node.nodeId forKey:node.label];
  }
  
  TT_RELEASE_SAFELY(npd);
  TT_RELEASE_SAFELY(parser);

  [super requestDidFinishLoad:request];
}

@end
