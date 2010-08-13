//
//  AlarmListModel.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmListModel.h"
#import "AlarmModel.h"
#import "Severity.h"
#import "extThree20XML/extThree20XML.h"
#import "AlarmXMLParserDelegate.h"

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
