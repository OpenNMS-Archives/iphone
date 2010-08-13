//
//  AlarmModel.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmModel.h"
#import "AlarmXMLParserDelegate.h"

@implementation AlarmModel

@synthesize alarmId        = _alarmId;
@synthesize uei            = _uei;
@synthesize firstEventTime = _firstEventTime;
@synthesize lastEventTime  = _lastEventTime;
@synthesize ipAddress      = _ipAddress;
@synthesize host           = _host;
@synthesize severity       = _severity;
@synthesize logMessage     = _logMessage;
@synthesize ackTime        = _ackTime;
@synthesize ackUser        = _ackUser;

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	if (!self.isLoading) {
		NSString* url = @"http://admin:admin@sin.local:8980/opennms/rest/alarms?limit=50&orderBy=lastEventTime&order=desc&alarmAckUser=null";
		
		TTURLRequest* request = [TTURLRequest requestWithURL:url delegate:self];
    
		id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
		request.response = response;
		TT_RELEASE_SAFELY(response);
		
		[request send];
	}
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
	TTURLDataResponse* response = request.response;
  
	NSString* string = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
	TT_RELEASE_SAFELY(string);
  
  NSXMLParser* parser = [[NSXMLParser alloc] initWithData:response.data];
  AlarmXMLParserDelegate* apd = [[AlarmXMLParserDelegate alloc] init];
  parser.delegate = apd;
  [parser parse];
  if (apd.alarms && [apd.alarms count] > 0) {
    AlarmModel* model = [apd.alarms objectAtIndex:0];
    _alarmId = model.alarmId;
    _uei = model.uei;
    _firstEventTime = model.firstEventTime;
    _lastEventTime = model.lastEventTime;
    _ipAddress = model.ipAddress;
    _host = model.host;
    _severity = model.severity;
    _logMessage = model.logMessage;
    _ackTime = model.ackTime;
    _ackUser = model.ackUser;
    [model release];
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
