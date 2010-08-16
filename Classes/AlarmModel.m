//
//  AlarmModel.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

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
		NSString* url = [@"http://admin:admin@sin.local:8980/opennms/rest/alarms/" stringByAppendingString:_alarmId];
		
		RESTURLRequest* request = [RESTURLRequest requestWithURL:url delegate:self];
//    request.cachePolicy = cachePolicy;
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
    _eventCount = model.eventCount;
    _ipAddress = model.ipAddress;
    _host = model.host;
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
