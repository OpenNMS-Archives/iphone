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

#import "IPInterfaceModel.h"
#import "TTXMLParser.h"

@implementation IPInterfaceModel

@synthesize interfaceId = _interfaceId;
@synthesize hostName    = _hostName;
@synthesize ipAddress   = _ipAddress;
@synthesize managed     = _managed;

+ (NSArray*)interfacesFromXML:(NSData *)data
{
  TTXMLParser* parser = [[TTXMLParser alloc] initWithData:data];
  parser.treatDuplicateKeysAsArrayItems = YES;
  [parser parse];

  NSMutableArray* interfaces = [[[NSMutableArray alloc] init] autorelease];

  NSArray* xmlInterfaces;
  if ([parser.rootObject valueForKey:@"ipInterface"]) {
    if ([[parser.rootObject valueForKey:@"ipInterface"] isKindOfClass:[NSArray class]]) {
      xmlInterfaces = [parser.rootObject valueForKey:@"ipInterface"];
    } else {
      xmlInterfaces = [NSArray arrayWithObject:[parser.rootObject valueForKey:@"ipInterface"]];
    }
    for (id i in xmlInterfaces) {
      IPInterfaceModel* interface = [[[IPInterfaceModel alloc] init] autorelease];
      
      interface.interfaceId = [i valueForKey:@"id"];
      interface.hostName = [[i valueForKey:@"hostName"] valueForKey:@"___Entity_Value___"];
      interface.ipAddress = [[i valueForKey:@"ipAddress"] valueForKey:@"___Entity_Value___"];
      interface.managed = [i valueForKey:@"isManaged"];
      
      [interfaces addObject:interface];
    }
  }
  
  TT_RELEASE_SAFELY(parser);
  
  return interfaces;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"IPInterfaceModel[%@/%@/%@/%@]", _interfaceId, _hostName, _ipAddress, _managed];
}

@end
