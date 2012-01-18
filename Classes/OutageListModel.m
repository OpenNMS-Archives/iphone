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

#import "OutageListModel.h"
#import "OutageModel.h"
#import "Severity.h"
#import "extThree20XML/extThree20XML.h"
#import "ONMSDateFormatter.h"
#import "SettingsModel.h"

@implementation OutageListModel

@synthesize outages = _outages;

- (void)dealloc
{
  TT_RELEASE_SAFELY(_outages);
  [super dealloc];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
  if (!self.isLoading) {
    NSString* url = [ONMSURLRequestModel getURL:@"/outages?limit=50&orderBy=ifLostService&order=desc&ifRegainedService=null"];
    
    TTDINFO(@"url = %@", url);
    
    TTURLRequest* request = [TTURLRequest requestWithURL:url delegate:self];
    request.cachePolicy = cachePolicy;

    id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);
    
    [request send];
  }
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
  TTURLDataResponse* response = request.response;
  
  TT_RELEASE_SAFELY(_outages);
  _outages = [[OutageListModel outagesFromXML:response.data withDuplicates:NO] retain];

  [super requestDidFinishLoad:request];
}

+(NSArray*)outagesFromXML:(NSData *)data withDuplicates:(BOOL)duplicates
{
  NSMutableArray* nodeIds = [NSMutableArray array];
  
  TTXMLParser* parser = [[TTXMLParser alloc] initWithData:data];
  parser.treatDuplicateKeysAsArrayItems = YES;
  [parser parse];
  
  NSDateFormatter* dateFormatter = [[ONMSDateFormatter alloc] init];
  
  NSMutableArray* outages = [[[NSMutableArray alloc] init] autorelease];

  NSArray* xmlOutages;
  if ([parser.rootObject valueForKey:@"outage"]) {
    if ([[parser.rootObject valueForKey:@"outage"] isKindOfClass:[NSArray class]]) {
      xmlOutages = [parser.rootObject valueForKey:@"outage"];
    } else {
      xmlOutages = [NSArray arrayWithObject:[parser.rootObject valueForKey:@"outage"]];
    }
    for (id o in xmlOutages) {
      OutageModel* outage = [[[OutageModel alloc] init] autorelease];

      outage.outageId = [o valueForKey:@"id"];
      outage.serviceName = [[[[o valueForKey:@"monitoredService"] valueForKey:@"serviceType"] valueForKey:@"name"] valueForKey:@"___Entity_Value___"];
      outage.ifLostService = [dateFormatter dateFromString:[[o valueForKey:@"ifLostService"] valueForKey:@"___Entity_Value___"]];
      NSString* ifRegainedService = [[o valueForKey:@"ifRegainedService"] valueForKey:@"___Entity_Value___"];
      if (ifRegainedService) {
        outage.ifRegainedService = [dateFormatter dateFromString:ifRegainedService];
      }
      
      NSDictionary* serviceLostEvent = [o valueForKey:@"serviceLostEvent"];
      outage.desc = [[serviceLostEvent valueForKey:@"description"] valueForKey:@"___Entity_Value___"];
      outage.ipAddress = [[serviceLostEvent valueForKey:@"ipAddress"] valueForKey:@"___Entity_Value___"];
      outage.host = [[serviceLostEvent valueForKey:@"host"] valueForKey:@"___Entity_Value___"];
      outage.logMessage = [[serviceLostEvent valueForKey:@"logMessage"] valueForKey:@"___Entity_Value___"];
      outage.uei = [[serviceLostEvent valueForKey:@"uei"] valueForKey:@"___Entity_Value___"];
      outage.severity = [serviceLostEvent valueForKey:@"severity"];

      NSString* nodeId = [[serviceLostEvent valueForKey:@"nodeId"] valueForKey:@"___Entity_Value___"];
      outage.nodeId = nodeId;

      if (duplicates) {
        [outages addObject:outage];
      } else if (![nodeIds containsObject:nodeId]) {
        [nodeIds addObject:nodeId];
        [outages addObject:outage];
      }
    }
  }

  TT_RELEASE_SAFELY(dateFormatter);
  TT_RELEASE_SAFELY(parser);
  
  return outages;
}

@end
