//
//  AlarmXMLParserDelegate.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmXMLParserDelegate.h"
#import "ONMSDateFormatter.h"

@implementation AlarmXMLParserDelegate

@synthesize alarms = _alarms;

- (id)init
{
  if (self = [super init]) {
    _alarms = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc
{
  TT_RELEASE_SAFELY(_alarms);
  TT_RELEASE_SAFELY(_currentAlarm);
  TT_RELEASE_SAFELY(_currentElement);
  TT_RELEASE_SAFELY(_currentValue);
  TT_RELEASE_SAFELY(_dateFormatter);
  
  [super dealloc];
}

- (NSDateFormatter*) dateFormatter
{
  if (!_dateFormatter) {
    _dateFormatter = [[ONMSDateFormatter alloc] init];
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
  } else if ([elementName isEqualToString:@"uei"]) {
    _currentAlarm.uei = _currentValue;
  } else if ([elementName isEqualToString:@"firstEventTime"]) {
    _currentAlarm.firstEventTime = [[self dateFormatter] dateFromString:_currentValue];
  } else if ([elementName isEqualToString:@"lastEventTime"]) {
    _currentAlarm.lastEventTime = [[self dateFormatter] dateFromString:_currentValue];
  } else if ([elementName isEqualToString:@"ipAddress"]) {
    _currentAlarm.ipAddress = _currentValue;
  } else if ([elementName isEqualToString:@"host"]) {
    _currentAlarm.host = _currentValue;
  } else if ([elementName isEqualToString:@"logMessage"]) {
    _currentAlarm.logMessage = _currentValue;
  } else if ([elementName isEqualToString:@"ackTime"]) {
    _currentAlarm.ackTime = [[self dateFormatter] dateFromString:_currentValue];
  } else if ([elementName isEqualToString:@"ackUser"]) {
    _currentAlarm.ackUser = _currentValue;
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
      _currentValue = [string retain];
    }
  }
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
  NSString* string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
  if (_currentElement) {
    if (_currentValue) {
      _currentValue = [_currentValue stringByAppendingString:string];
    } else {
      _currentValue = [string retain];
    }
  }
  [string release];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
  TTDINFO(@"parse error in parser %@: %@: %@", parser, [parseError localizedDescription], [parseError localizedFailureReason]);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
  TTDINFO(@"validation error in parser %@: %@: %@", parser, [validError localizedDescription], [validError localizedFailureReason]);
}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix {}
- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI {}
- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue {}
- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model {}
- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)entityName publicID:(NSString *)publicID systemID:(NSString *)systemID {}
- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {}
- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value {}
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID {}
- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data {}
- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName {}
- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID { return nil; }
- (void)parserDidEndDocument:(NSXMLParser *)parser {}
- (void)parserDidStartDocument:(NSXMLParser *)parser {}

@end
