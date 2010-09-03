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

#import "AlarmModel.h"
#import "AlarmXMLParserDelegate.h"
#import "RESTURLRequest.h"

@implementation AlarmModel

@synthesize alarmId        = _alarmId;
@synthesize uei            = _uei;
@synthesize firstEventTime = _firstEventTime;
@synthesize lastEventTime  = _lastEventTime;
@synthesize eventCount     = _eventCount;
@synthesize ipAddress      = _ipAddress;
@synthesize host           = _host;
@synthesize label          = _label;
@synthesize severity       = _severity;
@synthesize logMessage     = _logMessage;
@synthesize ackTime        = _ackTime;
@synthesize ackUser        = _ackUser;

- (id)initWithAlarmId:(NSString*)alarmId {
  if (self = [super init]) {
    self.alarmId = alarmId;
  }
  return self;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
  if (!self.isLoading && _alarmId != nil) {
    NSString* url = [[ONMSURLRequestModel getURL:@"/alarms/"] stringByAppendingString:_alarmId];
    
    RESTURLRequest* request = [RESTURLRequest requestWithURL:url delegate:self];
    request.cachePolicy = cachePolicy;
    request.cachePolicy = TTURLRequestCachePolicyNone;
    id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
    request.response = response;
    TT_RELEASE_SAFELY(response);
    
    [request send];
  }
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
  TTURLDataResponse* response = request.response;
  
  NSString* text = [self stringWithUTF8Data:response.data];
  text = [self stringWithUTF8String:text];
  NSData* data = [text dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
  AlarmXMLParserDelegate* apd = [[AlarmXMLParserDelegate alloc] init];
  parser.delegate = apd;
  [parser parse];
  if (apd.alarms && [apd.alarms count] > 0) {
    AlarmModel* model = [apd.alarms objectAtIndex:0];
    _alarmId = model.alarmId;
    _uei = model.uei;
    _firstEventTime = model.firstEventTime;
    _lastEventTime = model.lastEventTime;
    _eventCount = model.eventCount;
    _ipAddress = model.ipAddress;
    _host = model.host;
    _label = model.label;
    _severity = model.severity;
    _logMessage = model.logMessage;
    _ackTime = model.ackTime;
    _ackUser = model.ackUser;
  }
  TT_RELEASE_SAFELY(apd);
  TT_RELEASE_SAFELY(parser);
  
  [super requestDidFinishLoad:request];
}


- (NSString*)description
{
  return [NSString stringWithFormat:@"AlarmModel[%@/%@/%@/%@/%@]", _alarmId, _firstEventTime, _ipAddress, _severity, _logMessage];
}

@end
