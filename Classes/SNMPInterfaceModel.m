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

#import "SNMPInterfaceModel.h"
#import "extThree20XML/extThree20XML.h"

@implementation SNMPInterfaceModel

@synthesize interfaceId = _interfaceId;
@synthesize ipAddress   = _ipAddress;
@synthesize ifIndex     = _ifIndex;
@synthesize ifSpeed     = _ifSpeed;
@synthesize ifDescr     = _ifDescr;

+(NSArray*)interfacesFromXML:(NSData *)data
{
  TTXMLParser* parser = [[TTXMLParser alloc] initWithData:data];
  parser.treatDuplicateKeysAsArrayItems = YES;
  [parser parse];

  NSMutableArray* interfaces = [[[NSMutableArray alloc] init] autorelease];

  NSArray* xmlInterfaces;
  if ([parser.rootObject valueForKey:@"snmpInterface"]) {
    if ([[parser.rootObject valueForKey:@"snmpInterface"] isKindOfClass:[NSArray class]]) {
      xmlInterfaces = [parser.rootObject valueForKey:@"snmpInterface"];
    } else {
      xmlInterfaces = [NSArray arrayWithObject:[parser.rootObject valueForKey:@"snmpInterface"]];
    }
    for (id i in xmlInterfaces) {
      SNMPInterfaceModel* interface = [[[SNMPInterfaceModel alloc] init] autorelease];
      
      interface.interfaceId = [i valueForKey:@"id"];
      interface.ipAddress = [[i valueForKey:@"ipAddress"] valueForKey:@"___Entity_Value___"];
      interface.ifIndex = [i valueForKey:@"ifIndex"];
      interface.ifSpeed = [[i valueForKey:@"ifSpeed"] valueForKey:@"___Entity_Value___"];
      interface.ifDescr = [[i valueForKey:@"ifDescr"] valueForKey:@"___Entity_Value___"];
      
      [interfaces addObject:interface];
    }
  }
  
  TT_RELEASE_SAFELY(parser);
  
  return interfaces;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"SNMPInterfaceModel[%@/%@/%@/%@/%@]", _interfaceId, _ipAddress, _ifIndex, _ifSpeed, _ifDescr];
}

@end
