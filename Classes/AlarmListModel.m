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

@implementation AlarmListModel

@synthesize alarms = _alarms;

- (void)dealloc
{
	TT_RELEASE_SAFELY(_alarms);
  TT_RELEASE_SAFELY(_currentAlarm);
  TT_RELEASE_SAFELY(_currentElement);
  TT_RELEASE_SAFELY(_currentValue);
  TT_RELEASE_SAFELY(_dateFormatter);
	[super dealloc];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
	TTDINFO(@"load called");
	if (!self.isLoading) {
		NSString* url = @"http://admin:admin@sin.local:8980/opennms/rest/alarms?limit=50&orderBy=lastEventTime&order=desc&alarmAckUser=null";
		
		TTURLRequest* request = [TTURLRequest requestWithURL:url delegate:self];

		id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
		request.response = response;
		TT_RELEASE_SAFELY(response);
		
		[request send];
	}
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	TTURLDataResponse* response = request.response;

	NSString* string = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
	TT_RELEASE_SAFELY(string);

	TT_RELEASE_SAFELY(_alarms);
  _alarms = [[[NSMutableArray alloc] init] autorelease];

  NSXMLParser* parser = [[NSXMLParser alloc] initWithData:response.data];
  parser.delegate = self;
  [parser parse];
  
	[super requestDidFinishLoad:request];
}

- (NSDateFormatter*) dateFormatter
{
  if (!_dateFormatter) {
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
  }
  return _dateFormatter;
}

- (void)parser:          (NSXMLParser*)parser
didStartElement: (NSString*)elementName
  namespaceURI: (NSString*)namespaceURI
 qualifiedName: (NSString*)qName
    attributes: (NSDictionary*)attributeDict
{
  if ([elementName isEqualToString:@"alarm"]) {
    TTDINFO(@"creating new alarm");
    _currentAlarm = [[[AlarmModel alloc] init] autorelease];
    _currentAlarm.alarmId = [attributeDict valueForKey:@"id"];
    _currentAlarm.severity = [attributeDict valueForKey:@"severity"];
  } else {
    _currentElement = elementName;
  }
}

- (void)parser:        (NSXMLParser *)parser
 didEndElement: (NSString *)elementName
  namespaceURI: (NSString *)namespaceURI
 qualifiedName: (NSString *)qName
{
  if ([elementName isEqualToString:@"alarm"]) {
    TTDINFO(@"saving alarm: %@", _currentAlarm);
    [_alarms addObject:_currentAlarm];
    _currentAlarm = nil;
  } else if ([elementName isEqualToString:@"lastEventTime"]) {
    NSDate* date = [[self dateFormatter] dateFromString:_currentValue];
    _currentAlarm.ifLostService = date;
  } else if ([elementName isEqualToString:@"ipAddress"]) {
    _currentAlarm.ipAddress = _currentValue;
  } else if ([elementName isEqualToString:@"host"]) {
    _currentAlarm.host = _currentValue;
  } else if ([elementName isEqualToString:@"logMessage"]) {
    _currentAlarm.logMessage = _currentValue;
  }
  _currentElement = nil;
  _currentValue = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  if (_currentElement) {
    if (_currentValue) {
      _currentValue = [_currentValue stringByAppendingString:string];
    } else {
      _currentValue = string;
    }
  }
}

@end
