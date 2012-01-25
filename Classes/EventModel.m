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

#import "EventModel.h"
#import "TTXMLParser.h"
#import "ONMSDateFormatter.h"

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

  NSDateFormatter* dateFormatter = [[ONMSDateFormatter alloc] init];

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
