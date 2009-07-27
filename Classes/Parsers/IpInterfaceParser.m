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

#import "IpInterfaceParser.h"


@implementation IpInterfaceParser

-(NSArray*)parse:(CXMLElement*)node
{
	NSMutableArray* interfaces = [NSMutableArray array];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:true];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
	
	NSArray* xmlInterfaces = [node elementsForName:@"ipInterface"];
	for (id xmlInterface in xmlInterfaces) {
		OnmsIpInterface* iface = [[[OnmsIpInterface alloc] init] autorelease];
		
		for (id attr in [xmlInterface attributes]) {
			if ([[attr name] isEqual:@"id"]) {
				[iface setInterfaceId:[NSNumber numberWithInt:[[attr stringValue] intValue]]];
			} else if ([[attr name] isEqual:@"ifIndex"]) {
				[iface setIfIndex:[NSNumber numberWithInt:[[attr stringValue] intValue]]];
			} else if ([[attr name] isEqual:@"isDown"]) {
				// ignore for now, we come from outages
			} else if ([[attr name] isEqual:@"snmpPrimary"]) {
				[iface setSnmpPrimary:[attr stringValue]];
			} else if ([[attr name] isEqual:@"isManaged"]) {
				[iface setIsManaged:[attr stringValue]];
			}
		}
		
		CXMLElement* ipElement = [xmlInterface elementForName:@"ipAddress"];
		if (ipElement) {
			[iface setIpAddress:[[ipElement childAtIndex:0] stringValue]];
		}
		
		CXMLElement* hostElement = [xmlInterface elementForName:@"hostName"];
		if (hostElement) {
			[iface setHostName:[[hostElement childAtIndex:0] stringValue]];
		}
		
		CXMLElement* capsdElement = [xmlInterface elementForName:@"lastCapsdPoll"];
		if (capsdElement) {
			[iface setLastCapsdPoll:[dateFormatter dateFromString:[[capsdElement childAtIndex:0] stringValue]]];
		}
		
		[interfaces addObject:iface];
	}
	
	[dateFormatter release];
	return interfaces;
}

@end
