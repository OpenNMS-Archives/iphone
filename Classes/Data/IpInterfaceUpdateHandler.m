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

#import "config.h"
#import "IpInterfaceUpdateHandler.h"
#import "IpInterface.h"

@implementation IpInterfaceUpdateHandler

@synthesize nodeId;

-(void) dealloc
{
	[nodeId release];
	[super dealloc];
}

-(void) requestDidFinish:(ASIHTTPRequest*) request
{
	int count = 0;
	NSManagedObjectContext *moc = [contextService managedObjectContext];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:true];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];

	CXMLDocument* document = [self getDocumentForRequest:request];

	if (!document) {
		[dateFormatter release];
		[super requestDidFinish:request];
		[self autorelease];
		return;
	}

	NSDate* lastModified = [NSDate date];

	NSArray* xmlIpInterfaces;
	if ([[[document rootElement] name] isEqual:@"ipInterface"]) {
		xmlIpInterfaces = [NSArray arrayWithObject:[document rootElement]];
	} else {
		xmlIpInterfaces = [[document rootElement] elementsForName:@"ipInterface"];
	}
	for (id xmlIpInterface in xmlIpInterfaces) {
		count++;
		IpInterface* ipInterface;

		NSNumber* ipInterfaceId = nil;
		NSNumber* ifIndex = nil;
		NSString* snmpPrimary = nil;
		NSString* isManaged = nil;
		
		for (id attr in [xmlIpInterface attributes]) {
			if ([[attr name] isEqual:@"id"]) {
				ipInterfaceId = [NSNumber numberWithInt:[[attr stringValue] intValue]];
			} else if ([[attr name] isEqual:@"ifIndex"]) {
				ifIndex = [NSNumber numberWithInt:[[attr stringValue] intValue]];
			} else if ([[attr name] isEqual:@"snmpPrimary"]) {
				snmpPrimary = [attr stringValue];
			} else if ([[attr name] isEqual:@"isManaged"]) {
				isManaged = [attr stringValue];
			} else if ([[attr name] isEqual:@"isDown"]) {
				// ignore
#if DEBUG
			} else {
				NSLog(@"unknown ipInterface attribute: %@", [attr name]);
#endif
			}
		}

		NSFetchRequest *ipInterfaceRequest = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *ipInterfaceEntity = [NSEntityDescription entityForName:@"IpInterface" inManagedObjectContext:moc];
		[ipInterfaceRequest setEntity:ipInterfaceEntity];
		
		NSPredicate *ipInterfacePredicate = [NSPredicate predicateWithFormat:@"interfaceId == %@", ipInterfaceId];
		[ipInterfaceRequest setPredicate:ipInterfacePredicate];
		
		NSError* error = nil;
		NSArray *ipInterfaceArray = [moc executeFetchRequest:ipInterfaceRequest error:&error];
		if (!ipInterfaceArray || [ipInterfaceArray count] == 0) {
			if (error) {
				NSLog(@"error fetching ipInterface for ID %@: %@", ipInterfaceId, [error localizedDescription]);
				[error release];
			}
			ipInterface = (IpInterface*)[NSEntityDescription insertNewObjectForEntityForName:@"IpInterface" inManagedObjectContext:moc];
		} else {
			ipInterface = (IpInterface*)[ipInterfaceArray objectAtIndex:0];
		}

		ipInterface.interfaceId = ipInterfaceId;
		ipInterface.ifIndex = ifIndex;
		ipInterface.snmpPrimaryFlag = snmpPrimary;
		ipInterface.managedFlag = isManaged;
		ipInterface.lastModified = lastModified;
		if (nodeId) {
			ipInterface.nodeId = nodeId;
		}

		CXMLElement* nodeElement = [xmlIpInterface elementForName:@"nodeId"];
		if (nodeElement) {
			ipInterface.nodeId = [NSNumber numberWithInt:[[[nodeElement childAtIndex:0] stringValue] intValue]];
		}
		
		CXMLElement* ipElement = [xmlIpInterface elementForName:@"ipAddress"];
		if (ipElement) {
			ipInterface.ipAddress = [[ipElement childAtIndex:0] stringValue];
		}
		
		CXMLElement* hostElement = [xmlIpInterface elementForName:@"hostName"];
		if (hostElement) {
			ipInterface.hostName = [[hostElement childAtIndex:0] stringValue];
		}
		
		CXMLElement* capsdElement = [xmlIpInterface elementForName:@"lastCapsdPoll"];
		if (capsdElement) {
			ipInterface.lastCapsdPoll = [dateFormatter dateFromString:[self stringForDate:[[capsdElement childAtIndex:0] stringValue]]];
		}
	}

#if DEBUG
	NSLog(@"found %d IP interfaces", count);
#endif

	if (self.clearOldObjects) {
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"IpInterface" inManagedObjectContext:moc];
		[request setEntity:entity];
		
		if (nodeId) {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastModified < %@) AND (nodeId == %@)", lastModified, nodeId];
			[request setPredicate:predicate];
		} else{
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastModified < %@", lastModified];
			[request setPredicate:predicate];
		}

		NSError* error = nil;
		NSArray *ipInterfacesToDelete = [moc executeFetchRequest:request error:&error];
		if (!ipInterfacesToDelete) {
			if (error) {
				NSLog(@"error fetching ipInterfaces to delete (older than %@): %@", lastModified, [error localizedDescription]);
				[error release];
			} else {
				NSLog(@"error fetching ipInterfaces to delete (older than %@)", lastModified);
			}
		} else {
			for (id ipInterface in ipInterfacesToDelete) {
#ifdef DEBUG
				NSLog(@"deleting %@", ipInterface);
#endif
				[moc deleteObject:ipInterface];
			}
		}
	}

	NSError* error = nil;
	if (![moc save:&error]) {
		NSLog(@"an error occurred saving the managed object context: %@", [error localizedDescription]);
		[error release];
	}

	[dateFormatter release];
	[super requestDidFinish:request];
	[self autorelease];
}

@end
