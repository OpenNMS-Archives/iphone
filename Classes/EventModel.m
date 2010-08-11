//
//  EventModel.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventModel.h"
#import "extThree20XML/extThree20XML.h"

@implementation EventModel

@synthesize eventId = _eventId;
@synthesize uei = _uei;
@synthesize severity = _severity;
@synthesize logMessage = _logMessage;
@synthesize timestamp = _timestamp;

- (void)dealloc
{
  TT_RELEASE_SAFELY(_eventId);
  TT_RELEASE_SAFELY(_uei);
  TT_RELEASE_SAFELY(_severity);
  TT_RELEASE_SAFELY(_logMessage);
  TT_RELEASE_SAFELY(_timestamp);
  [super dealloc];
}

- (id)init
{
	if (self = [super init]) {
		TTDINFO(@"init called");
	}
	return self;
}

+(NSArray*)eventsFromXML:(NSData *)data
{
	TTXMLParser* parser = [[TTXMLParser alloc] initWithData:data];
	parser.treatDuplicateKeysAsArrayItems = YES;
	[parser parse];

  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];

	NSMutableArray* events = [[[NSMutableArray alloc] init] autorelease];
  
	NSArray* xmlEvents;
  if ([parser.rootObject valueForKey:@"event"]) {
    if ([[parser.rootObject valueForKey:@"event"] isKindOfClass:[NSArray class]]) {
      xmlEvents = [parser.rootObject valueForKey:@"event"];
    } else {
      xmlEvents = [NSArray arrayWithObject:[parser.rootObject valueForKey:@"event"]];
    }
    for (id e in xmlEvents) {
      EventModel* event = [[[EventModel alloc] init] autorelease];
      
      event.eventId = [e valueForKey:@"id"];
      event.uei = [[e valueForKey:@"uei"] valueForKey:@"___Entity_Value___"];
      event.severity = [e valueForKey:@"severity"];
      event.logMessage = [[e valueForKey:@"logMessage"] valueForKey:@"___Entity_Value___"];
      event.timestamp = [dateFormatter dateFromString:[[e valueForKey:@"time"] valueForKey:@"___Entity_Value___"]];
      
      [events addObject:event];
    }
  }
  
  TT_RELEASE_SAFELY(dateFormatter);
	TT_RELEASE_SAFELY(parser);
	
	return events;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"EventModel[%@/%@/%@/%@]", _eventId, _severity, _timestamp, _logMessage];
}

@end
