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

#import "NodeModel.h"
#import "OutageListModel.h"
#import "IPInterfaceModel.h"
#import "SNMPInterfaceModel.h"
#import "EventModel.h"
#import "extThree20XML/extThree20XML.h"
#import "RESTURLRequest.h"

@implementation NodeModel

@class RESTURLRequest;

@synthesize nodeId  = _nodeId;
@synthesize label   = _label;
@synthesize outages = _outages;
@synthesize ipInterfaces = _ipInterfaces;
@synthesize snmpInterfaces = _snmpInterfaces;
@synthesize events = _events;

- (id)initWithNodeId:(NSString*)nodeId
{
  if (self = [super init]) {
    self.nodeId = nodeId;
    _inProgressCount = 0;
  }
  return self;
}

- (void)dealloc
{
  TT_RELEASE_SAFELY(_events);
  TT_RELEASE_SAFELY(_snmpInterfaces);
  TT_RELEASE_SAFELY(_ipInterfaces);
  TT_RELEASE_SAFELY(_outages);
  TT_RELEASE_SAFELY(_nodeId);
  TT_RELEASE_SAFELY(_label);
  [super dealloc];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
  if (!self.isLoading && _nodeId != nil) {
    TTDINFO(@"sending requests for node %@", _nodeId);
    _inProgressCount = 5;

    // Node
    RESTURLRequest* request = [RESTURLRequest requestWithURL:[[ONMSURLRequestModel getURL:@"/nodes/"] stringByAppendingString:_nodeId] delegate:self];
    request.cachePolicy = cachePolicy;
    request.modelName = @"nodes";

    id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);

    [request send];

    // Outages
    request = [RESTURLRequest requestWithURL:[[ONMSURLRequestModel getURL:@"/outages/forNode/"] stringByAppendingFormat:@"%@?limit=%d&orderBy=ifLostService&order=desc", _nodeId, 50] delegate:self];
    request.cachePolicy = cachePolicy;
    request.modelName = @"outages";

    response = [[TTURLDataResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);

    [request send];

    // IPInterface
    request = [RESTURLRequest requestWithURL:[[ONMSURLRequestModel getURL:@"/nodes/"] stringByAppendingFormat:@"%@/ipinterfaces", _nodeId] delegate:self];
    request.cachePolicy = cachePolicy;
    request.modelName = @"ipinterfaces";
    
    response = [[TTURLDataResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);
    
    [request send];
    
    // SNMPInterface
    request = [RESTURLRequest requestWithURL:[[ONMSURLRequestModel getURL:@"/nodes/"] stringByAppendingFormat:@"%@/snmpinterfaces", _nodeId] delegate:self];
    request.cachePolicy = cachePolicy;
    request.modelName = @"snmpinterfaces";
    
    response = [[TTURLDataResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);
    
    [request send];
    
    // Events
    request = [RESTURLRequest requestWithURL:[[ONMSURLRequestModel getURL:@"/events"] stringByAppendingFormat:@"?limit=%d&node.id=%@", 10, _nodeId] delegate:self];
    request.cachePolicy = cachePolicy;
    request.modelName = @"events";
    
    response = [[TTURLDataResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);
    
    [request send];
  }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
  TTDWARNING(@"Failed request for model %@", ((RESTURLRequest*)request).modelName);
  _inProgressCount--;
  [super request:request didFailLoadWithError:error];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
  TTURLDataResponse* response = request.response;
  NSString* modelName = ((RESTURLRequest*)request).modelName;

  _inProgressCount--;

  TTDINFO(@"Got response for model %@", modelName);

  NSString* string = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];

  if (TTIsStringWithAnyText(string)) {
    TTXMLParser* parser = [[TTXMLParser alloc] initWithData:response.data];
    parser.treatDuplicateKeysAsArrayItems = YES;
    [parser parse];

    if ([modelName isEqualToString:@"nodes"]) {
      TT_RELEASE_SAFELY(_nodeId);
      TT_RELEASE_SAFELY(_label);

      _nodeId = [parser.rootObject valueForKey:@"id"];
      _label  = [[parser.rootObject valueForKey:@"label"] copy];
    } else if ([modelName isEqualToString:@"outages"]) {
      TT_RELEASE_SAFELY(_outages);
	      _outages = [[OutageListModel outagesFromXML:response.data withDuplicates:YES] retain];
    } else if ([modelName isEqualToString:@"ipinterfaces"]) {
      TT_RELEASE_SAFELY(_ipInterfaces);
      _ipInterfaces = [[IPInterfaceModel interfacesFromXML:response.data] retain];
    } else if ([modelName isEqualToString:@"snmpinterfaces"]) {
      TT_RELEASE_SAFELY(_snmpInterfaces);
      _snmpInterfaces = [[SNMPInterfaceModel interfacesFromXML:response.data] retain];
    } else if ([modelName isEqualToString:@"events"]) {
      TT_RELEASE_SAFELY(_events);
      _events = [[EventModel eventsFromXML:response.data] retain];
    } else {
      TTDWARNING(@"unmatched model name: %@", modelName);
    }

    TT_RELEASE_SAFELY(parser);
  }
  TT_RELEASE_SAFELY(string);

  if (_inProgressCount == 0) {
    [super requestDidFinishLoad:request];
  }
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"NodeModel[%@/%@]", _nodeId, _label];
}

@end
