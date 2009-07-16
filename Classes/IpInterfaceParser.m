//
//  IpInterfaceParser.m
//  OpenNMS
//
//  Created by Benjamin Reed on 7/15/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

#import "IpInterfaceParser.h"


@implementation IpInterfaceParser

- (void)dealloc
{
	[interfaces release];
	[super dealloc];
}

-(BOOL)parse:(CXMLElement*)node
{
	[interfaces release];
	interfaces = [[NSMutableArray alloc] init];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:true];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
	
	NSArray* xmlInterfaces = [node elementsForName:@"ipInterface"];
	for (id xmlInterface in xmlInterfaces) {
		OnmsIpInterface* iface = [[OnmsIpInterface alloc] init];
		
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
	return true;
}

-(NSArray*)interfaces
{
	return interfaces;
}

-(OnmsIpInterface*)interface
{
	if ([interfaces count] > 0) {
		return [interfaces objectAtIndex:0];
	} else {
		return nil;
	}
}

@end
