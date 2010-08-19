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

#import "NodeXMLParserDelegate.h"
#import "ONMSDateFormatter.h"

@implementation NodeXMLParserDelegate

@synthesize nodes = _nodes;

- (id)init
{
  if (self = [super init]) {
    _nodes = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc
{
  TT_RELEASE_SAFELY(_nodes);
  TT_RELEASE_SAFELY(_currentNode);
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
  if ([elementName isEqualToString:@"node"]) {
    NSString* nodeId = [attributeDict valueForKey:@"id"];
    if (nodeId) {
      _currentNode = [[[NodeModel alloc] init] autorelease];
      _currentNode.nodeId = [attributeDict valueForKey:@"id"];
      _currentNode.label = [attributeDict valueForKey:@"label"];
      TTDINFO(@"found a node: %@", _currentNode);
    }
  } else {
    _currentElement = elementName;
  }
}

- (void)parser:        (NSXMLParser *)parser
 didEndElement: (NSString *)elementName
  namespaceURI: (NSString *)namespaceURI
 qualifiedName: (NSString *)qName
{
  if ([elementName isEqualToString:@"node"]) {
    if (_currentNode) {
      TTDINFO(@"current node = %@", _currentNode);
      [_nodes addObject:_currentNode];
      _currentNode = nil;
    }
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
  TTDERROR(@"parse error in parser %@: %@: %@", parser, [parseError localizedDescription], [parseError localizedFailureReason]);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
  TTDERROR(@"validation error in parser %@: %@: %@", parser, [validError localizedDescription], [validError localizedFailureReason]);
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
