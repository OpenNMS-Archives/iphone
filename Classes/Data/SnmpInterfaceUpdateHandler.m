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

#import "SnmpInterfaceUpdateHandler.h"
#import "SnmpInterface.h"

@implementation SnmpInterfaceUpdateHandler

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

	CXMLDocument* document = [self getDocumentForRequest:request];

	if (!document) {
		[super requestDidFinish:request];
		[self autorelease];
		return;
	}

	NSDate* lastModified = [NSDate date];

	NSArray* xmlSnmpInterfaces;
	if ([[[document rootElement] name] isEqual:@"snmpInterface"]) {
		xmlSnmpInterfaces = [NSArray arrayWithObject:[document rootElement]];
	} else {
		xmlSnmpInterfaces = [[document rootElement] elementsForName:@"snmpInterface"];
	}
    [moc lock];
	for (id xmlSnmpInterface in xmlSnmpInterfaces) {
		count++;
		SnmpInterface* snmpInterface;

		NSNumber* snmpInterfaceId = nil;
		NSNumber* ifIndex = nil;
		NSString* collectFlag = nil;
		
		for (id attr in [xmlSnmpInterface attributes]) {
			if ([[attr name] isEqual:@"id"]) {
				snmpInterfaceId = [NSNumber numberWithInt:[[attr stringValue] intValue]];
			} else if ([[attr name] isEqual:@"ifIndex"]) {
				ifIndex = [NSNumber numberWithInt:[[attr stringValue] intValue]];
			} else if ([[attr name] isEqual:@"collectFlag"]) {
				collectFlag = [attr stringValue];
			} else if ([[attr name] isEqual:@"collect"]) {
				// ignore
#if DEBUG
			} else {
				NSLog(@"%@: unknown snmpInterface attribute: %@", self, [attr name]);
#endif
			}
		}

		NSFetchRequest *snmpInterfaceRequest = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *snmpInterfaceEntity = [NSEntityDescription entityForName:@"SnmpInterface" inManagedObjectContext:moc];
		[snmpInterfaceRequest setEntity:snmpInterfaceEntity];
		
		NSPredicate *snmpInterfacePredicate = [NSPredicate predicateWithFormat:@"interfaceId == %@", snmpInterfaceId];
		[snmpInterfaceRequest setPredicate:snmpInterfacePredicate];
		
		NSError* error = nil;
		NSArray *snmpInterfaceArray = [moc executeFetchRequest:snmpInterfaceRequest error:&error];
		if (!snmpInterfaceArray || [snmpInterfaceArray count] == 0) {
			if (error) {
				NSLog(@"%@: error fetching snmpInterface for ID %@: %@", self, snmpInterfaceId, [error localizedDescription]);
				[error release];
			}
			snmpInterface = (SnmpInterface*)[NSEntityDescription insertNewObjectForEntityForName:@"SnmpInterface" inManagedObjectContext:moc];
		} else {
			snmpInterface = (SnmpInterface*)[snmpInterfaceArray objectAtIndex:0];
		}

		snmpInterface.interfaceId = snmpInterfaceId;
		snmpInterface.ifIndex = ifIndex;
		snmpInterface.collectFlag = collectFlag;
		snmpInterface.lastModified = lastModified;

		CXMLElement* nodeElement = [xmlSnmpInterface elementForName:@"nodeId"];
		if (nodeElement) {
			snmpInterface.nodeId = [NSNumber numberWithInt:[[[nodeElement childAtIndex:0] stringValue] intValue]];
		}
		
		CXMLElement* descElement = [xmlSnmpInterface elementForName:@"ifDescr"];
		if (descElement) {
			snmpInterface.ifDescription = [[descElement childAtIndex:0] stringValue];
		}
		
		CXMLElement* statusElement = [xmlSnmpInterface elementForName:@"ifOperStatus"];
		if (statusElement) {
			snmpInterface.ifStatus = [NSNumber numberWithInt:[[[statusElement childAtIndex:0] stringValue] intValue]];
		}
		
		CXMLElement* ipElement = [xmlSnmpInterface elementForName:@"ipAddress"];
		if (ipElement) {
			snmpInterface.ipAddress = [[ipElement childAtIndex:0] stringValue];
		}
		
		CXMLElement* macElement = [xmlSnmpInterface elementForName:@"physAddr"];
		if (macElement) {
			snmpInterface.physAddr = [[macElement childAtIndex:0] stringValue];
		}
		
		CXMLElement* speedElement = [xmlSnmpInterface elementForName:@"ifSpeed"];
		if (speedElement) {
			snmpInterface.ifSpeed = [NSNumber numberWithLongLong:[[[speedElement childAtIndex:0] stringValue] longLongValue]];
		}
	}

#if DEBUG
	NSLog(@"%@: found %d SNMP interfaces", self, count);
#endif

	if (self.clearOldObjects) {
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"SnmpInterface" inManagedObjectContext:moc];
		[request setEntity:entity];
		
		if (nodeId) {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastModified < %@) AND (nodeId == %@)", lastModified, nodeId];
			[request setPredicate:predicate];
		} else{
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastModified < %@", lastModified];
			[request setPredicate:predicate];
		}

		NSError* error = nil;
		NSArray *snmpInterfacesToDelete = [moc executeFetchRequest:request error:&error];
		if (!snmpInterfacesToDelete) {
			if (error) {
				NSLog(@"%@: error fetching snmpInterfaces to delete (older than %@): %@", self, lastModified, [error localizedDescription]);
				[error release];
			} else {
				NSLog(@"%@: error fetching snmpInterfaces to delete (older than %@)", self, lastModified);
			}
		} else {
			for (id snmpInterface in snmpInterfacesToDelete) {
#if DEBUG
				NSLog(@"%@: deleting %@", self, snmpInterface);
#endif
				[moc deleteObject:snmpInterface];
			}
		}
	}

	NSError* error = nil;
	if (![moc save:&error]) {
		NSLog(@"%@: an error occurred saving the managed object context: %@", self, [error localizedDescription]);
		[error release];
	}
    [moc unlock];
	[super requestDidFinish:request];
	[self autorelease];
}

@end
