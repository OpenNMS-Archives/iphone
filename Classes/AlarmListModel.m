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

#import "AlarmListModel.h"
#import "AlarmModel.h"
#import "Severity.h"
#import "extThree20XML/extThree20XML.h"
#import "AlarmXMLParserDelegate.h"
#import "SettingsModel.h"

@implementation AlarmListModel

@synthesize alarms = _alarms;

- (void)dealloc
{
  TT_RELEASE_SAFELY(_alarms);
  [super dealloc];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
  if (!self.isLoading) {
    NSString* url = [ONMSURLRequestModel getURL:@"/alarms?limit=50&orderBy=lastEventTime&order=desc&alarmAckUser=null"];
    
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

  TT_RELEASE_SAFELY(_alarms);

  NSXMLParser* parser = [[NSXMLParser alloc] initWithData:response.data];
  AlarmXMLParserDelegate* apd = [[AlarmXMLParserDelegate alloc] init];
  parser.delegate = apd;
  [parser parse];
  _alarms = [apd.alarms retain];

  TT_RELEASE_SAFELY(apd);
  TT_RELEASE_SAFELY(parser);
  
  [super requestDidFinishLoad:request];
}

@end
