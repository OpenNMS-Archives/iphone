/*******************************************************************************
 * This file is part of the OpenNMS(R) iPhone Application.
 * OpenNMS(R) is a registered trademark of The OpenNMS Group, Inc.
 *
 * Copyright (C) 2009 The OpenNMS Group, Inc.  All rights reserved.
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

#import "SnmpInterfaceParser.h"

@implementation SnmpInterfaceParser

-(NSArray*)parse:(CXMLElement*)node
{
	NSMutableArray* interfaces = [NSMutableArray array];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:true];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
	
	NSArray* xmlInterfaces = [node elementsForName:@"snmpInterface"];
	for (id xmlInterface in xmlInterfaces) {
		OnmsSnmpInterface* iface = [[[OnmsSnmpInterface alloc] init] autorelease];
		
		for (id attr in [xmlInterface attributes]) {
			if ([[attr name] isEqual:@"id"]) {
				[iface setInterfaceId:[NSNumber numberWithInt:[[attr stringValue] intValue]]];
			} else if ([[attr name] isEqual:@"ifIndex"]) {
				[iface setIfIndex:[NSNumber numberWithInt:[[attr stringValue] intValue]]];
			} else if ([[attr name] isEqual:@"collectFlag"]) {
				[iface setCollect:[attr stringValue]];
			}
		}
		
		CXMLElement* nodeElement = [xmlInterface elementForName:@"nodeId"];
		if (nodeElement) {
			[iface setNodeId:[NSNumber numberWithInt:[[[nodeElement childAtIndex:0] stringValue] intValue]]];
		}

		CXMLElement* descElement = [xmlInterface elementForName:@"ifDescr"];
		if (descElement) {
			[iface setIfDescription:[[descElement childAtIndex:0] stringValue]];
		}
		
		CXMLElement* statusElement = [xmlInterface elementForName:@"ifOperStatus"];
		if (statusElement) {
			[iface setIfStatus:[NSNumber numberWithInt:[[[statusElement childAtIndex:0] stringValue] intValue]]];
		}
		
		CXMLElement* ipElement = [xmlInterface elementForName:@"ipAddress"];
		if (ipElement) {
			[iface setIpAddress:[[ipElement childAtIndex:0] stringValue]];
		}

		CXMLElement* macElement = [xmlInterface elementForName:@"physAddr"];
		if (macElement) {
			[iface setPhysAddr:[[macElement childAtIndex:0] stringValue]];
		}
		
		CXMLElement* speedElement = [xmlInterface elementForName:@"ifSpeed"];
		if (speedElement) {
			[iface setIfStatus:[NSNumber numberWithLongLong:[[[speedElement childAtIndex:0] stringValue] longLongValue]]];
		}
		
		[interfaces addObject:iface];
	}
	
	[dateFormatter release];
	return interfaces;
}

@end
