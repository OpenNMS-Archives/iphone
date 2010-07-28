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

#import "OutageUpdateHandler.h"
#import "Outage.h"
#import "Node.h"
#import "NodeFactory.h"

@implementation OutageUpdateHandler

-(void) requestDidFinish:(ASIHTTPRequest*) request
{
	NSError* error = nil;
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

	NSMutableArray* nodeIds = [NSMutableArray array];
	NSDate* lastModified = [NSDate date];
	NSArray* xmlOutages;
	if ([[[document rootElement] name] isEqual:@"outage"]) {
		xmlOutages = [NSArray arrayWithObject:[document rootElement]];
	} else {
		xmlOutages = [[document rootElement] elementsForName:@"outage"];
	}
	
	NSMutableArray* outages = [NSMutableArray arrayWithCapacity:[xmlOutages count]];

	for (id xmlOutage in xmlOutages) {
		NSMutableDictionary* outage = [NSMutableDictionary dictionary];

		NSNumber* outageId = nil;
		NSNumber* nodeId = nil;

		// ID
		for (id attr in [xmlOutage attributes]) {
			if ([[attr name] isEqual:@"id"]) {
				outageId = [NSNumber numberWithInt:[[attr stringValue] intValue]];
			}
		}

#if DEBUG
        NSLog(@"%@: got outageId = %@", self, outageId);
#endif

        [outage setValue:outageId forKey:@"outageId"];
		[outage setValue:lastModified forKey:@"lastModified"];

		// Service Name
		CXMLElement* msElement = [xmlOutage elementForName:@"monitoredService"];
		if (msElement) {
			CXMLElement* stElement = [msElement elementForName:@"serviceType"];
			if (stElement) {
				CXMLElement* snElement = [stElement elementForName:@"name"];
				if (snElement) {
					[outage setValue:[[snElement childAtIndex:0] stringValue] forKey:@"serviceName"];
				}
			}
		}
		
		// IP Address
		CXMLElement* ipElement = [xmlOutage elementForName:@"ipAddress"];
		if (ipElement) {
			[outage setValue:[[ipElement childAtIndex:0] stringValue] forKey:@"ipAddress"];
		}

		// Service Lost Date
		CXMLElement* slElement = [xmlOutage elementForName:@"ifLostService"];
		if (slElement) {
			[outage setValue:[dateFormatter dateFromString:[self stringForDate:[[slElement childAtIndex:0] stringValue]]] forKey:@"ifLostService"];
		}
		
		// Service Regained Date
		CXMLElement* srElement = [xmlOutage elementForName:@"ifRegainedService"];
		if (srElement) {
			[outage setValue:[dateFormatter dateFromString:[self stringForDate:[[srElement childAtIndex:0] stringValue]]] forKey:@"ifRegainedService"];
		}
		
		// Service Lost Event
		CXMLElement* sleElement = [xmlOutage elementForName:@"serviceLostEvent"];
		if (sleElement) {
			for (id attr in [sleElement attributes]) {
				if ([[attr name] isEqual:@"id"]) {
					[outage setValue:[NSNumber numberWithInt:[[attr stringValue] intValue]] forKey:@"serviceLostEventId"];
					break;
				}
			}
			CXMLElement* nodeElement = [sleElement elementForName:@"nodeId"];
			if (nodeElement) {
				nodeId = [NSNumber numberWithInt:[[[nodeElement childAtIndex:0] stringValue] intValue]];
				[outage setValue:nodeId forKey:@"nodeId"];
				if (nodeId != nil) {
					[[NodeFactory getInstance] getNode:nodeId];
				}
			}
		}
		
		// Service Regained Event
		CXMLElement* sreElement = [xmlOutage elementForName:@"serviceRegainedEvent"];
		if (sreElement) {
			for (id attr in [sreElement attributes]) {
				if ([[attr name] isEqual:@"id"]) {
					[outage setValue:[NSNumber numberWithInt:[[attr stringValue] intValue]] forKey:@"serviceRegainedEventId"];
					break;
				}
			}
		}
		
		if (nodeId) {
			// only add if we haven't already seen an outage with the same node ID
			if (![nodeIds containsObject:nodeId]) {
				[nodeIds addObject:nodeId];
				[outages addObject:outage];
			}
		}
	}

	Outage* dbOutage = nil;

	context = [contextService newContext];
	[context lock];
	for (id o in outages) {
		NSDictionary* outage = (NSDictionary*)o;
		NSNumber* outageId = [outage valueForKey:@"outageId"];
		error = nil;
		dbOutage = nil;

		NSFetchRequest *outageRequest = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *outageEntity = [NSEntityDescription entityForName:@"Outage" inManagedObjectContext:context];
		[outageRequest setEntity:outageEntity];
		
		NSPredicate *outagePredicate = [NSPredicate predicateWithFormat:@"outageId == %@", outageId];
		[outageRequest setPredicate:outagePredicate];
	
		NSArray *outageArray = [context executeFetchRequest:outageRequest error:&error];
		if (!outageArray || [outageArray count] == 0) {
			if (error) {
				NSLog(@"error fetching outage for ID %@: %@", outageId, [error localizedDescription]);
				[error release];
			}
			dbOutage = (Outage*)[NSEntityDescription insertNewObjectForEntityForName:@"Outage" inManagedObjectContext:context];
		} else {
			dbOutage = (Outage*)[outageArray objectAtIndex:0];
		}
		
		dbOutage.nodeId                 = [outage valueForKey:@"nodeId"];
		dbOutage.lastModified           = [outage valueForKey:@"lastModified"];
		dbOutage.outageId               = [outage valueForKey:@"outageId"];
		dbOutage.ifLostService          = [outage valueForKey:@"ifLostService"];
		dbOutage.ipAddress              = [outage valueForKey:@"ipAddress"];
		dbOutage.ifRegainedService      = [outage valueForKey:@"ifRegainedService"];
		dbOutage.serviceRegainedEventId = [outage valueForKey:@"serviceRegainedEventId"];
		dbOutage.serviceName            = [outage valueForKey:@"serviceName"];
		dbOutage.serviceLostEventId     = [outage valueForKey:@"serviceLostEventId"];
#if DEBUG
		NSLog(@"%@: dbOutage = %@", self, dbOutage);
#endif
	}
	
	if (self.clearOldObjects) {
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Outage" inManagedObjectContext:context];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastModified < %@", lastModified];
		[request setPredicate:predicate];
		
		NSError* error = nil;
		NSArray *outagesToDelete = [context executeFetchRequest:request error:&error];
		if (!outagesToDelete) {
			if (error) {
				NSLog(@"error fetching outages to delete (older than %@): %@", lastModified, [error localizedDescription]);
				[error release];
			} else {
				NSLog(@"error fetching outages to delete (older than %@)", lastModified);
			}
		} else {
			for (id outage in outagesToDelete) {
#if DEBUG
				NSLog(@"deleting %@", outage);
#endif
				[context deleteObject:outage];
			}
		}
	}
	[context unlock];

	if (![context save:&error]) {
		NSLog(@"an error occurred saving the managed object context: %@ (%@)", [error localizedDescription], [error localizedFailureReason]);
	}
	
	[context release];
	[dateFormatter release];
	[super requestDidFinish:request];
	[self autorelease];
}

@end
