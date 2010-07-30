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

#import "EventUpdateHandler.h"
#import "Event.h"

@implementation EventUpdateHandler

@synthesize nodeId;

-(void) dealloc
{
	[nodeId release];
	[super dealloc];
}

-(void) handleRequest:(ASIHTTPRequest*) request
{
	[super handleRequest:request];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:true];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];

	CXMLDocument* document = [self getDocumentForRequest:request];

	if (!document) {
		[dateFormatter release];
		[super handleRequest:request];
		[self autorelease];
		return;
	}

	NSDate* lastModified = [NSDate date];

	NSArray* xmlEvents;
	if ([[[document rootElement] name] isEqual:@"event"]) {
		xmlEvents = [NSArray arrayWithObject:[document rootElement]];
	} else {
		xmlEvents = [[document rootElement] elementsForName:@"event"];
	}

	NSMutableArray* events = [NSMutableArray arrayWithCapacity:[xmlEvents count]];

	for (id xmlEvent in xmlEvents) {
		NSMutableDictionary* event = [NSMutableDictionary dictionary];

		NSNumber* eventId = nil;
		BOOL eventDisplay = YES;
		BOOL eventLog = YES;
		NSString* eventSeverity = nil;

		for (id attr in [xmlEvent attributes]) {
			if ([[attr name] isEqual:@"id"]) {
				eventId = [NSNumber numberWithInt:[[attr stringValue] intValue]];
			} else if ([[attr name] isEqual:@"display"]) {
				eventDisplay = [[attr stringValue] boolValue];
			} else if ([[attr name] isEqual:@"log"]) {
				eventLog = [[attr stringValue] boolValue];
			} else if ([[attr name] isEqual:@"severity"]) {
				eventSeverity = [attr stringValue];
#if DEBUG
			} else {
				NSLog(@"%@: unknown event attribute: %@", self, [attr name]);
#endif
			}
		}

		[event setValue:eventId forKey:@"eventId"];
		[event setValue:[NSNumber numberWithBool:eventDisplay] forKey:@"distplay"];
		[event setValue:[NSNumber numberWithBool:eventLog] forKey:@"log"];
		[event setValue:eventSeverity forKey:@"severity"];
		
		CXMLElement* nodeElement = [xmlEvent elementForName:@"nodeId"];
		if (nodeElement) {
			[event setValue:[NSNumber numberWithInt:[[[nodeElement childAtIndex:0] stringValue] intValue]] forKey:@"nodeId"];
		}
		
		// Time
		CXMLElement *timeElement = [xmlEvent elementForName:@"time"];
		if (timeElement) {
			[event setValue:[dateFormatter dateFromString:[self stringForDate:[[timeElement childAtIndex:0] stringValue]]] forKey:@"time"];
		}
		
		// CreateTime
		CXMLElement *ctElement = [xmlEvent elementForName:@"createTime"];
		if (ctElement) {
			[event setValue:[dateFormatter dateFromString:[self stringForDate:[[ctElement childAtIndex:0] stringValue]]] forKey:@"createTime"];
		}
		
		// Description
		CXMLElement *descrElement = [xmlEvent elementForName:@"description"];
		if (descrElement) {
			[event setValue:[self cleanUpString:[[descrElement childAtIndex:0] stringValue]] forKey:@"eventDescription"];
		}
		
		// Host
		CXMLElement *hostElement = [xmlEvent elementForName:@"host"];
		if (hostElement) {
			[event setValue:[[hostElement childAtIndex:0] stringValue] forKey:@"eventHost"];
		}
		
		// Log Message
		CXMLElement *lmElement = [xmlEvent elementForName:@"logMessage"];
		if (lmElement) {
			[event setValue:[self cleanUpString:[[lmElement childAtIndex:0] stringValue]] forKey:@"logMessage"];
		}
		
		// Source
		CXMLElement *sourceElement = [xmlEvent elementForName:@"source"];
		if (sourceElement) {
			[event setValue:[[sourceElement childAtIndex:0] stringValue] forKey:@"source"];
		}

		// UEI
		CXMLElement *ueiElement = [xmlEvent elementForName:@"uei"];
		if (ueiElement) {
			[event setValue:[[ueiElement childAtIndex:0] stringValue] forKey:@"uei"];
		}
		
		[events addObject:event];
	}

#if DEBUG
	NSLog(@"found %d Events", [events count]);
#endif

	NSError* error = nil;
	Event* dbEvent = nil;

	NSManagedObjectContext* context = [contextService newContext];
	[context lock];
	
	for (id event in events) {
		NSNumber* eventId = [event valueForKey:@"eventId"];
		
		NSFetchRequest *eventRequest = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *eventEntity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
		[eventRequest setEntity:eventEntity];
		
		NSPredicate *eventPredicate = [NSPredicate predicateWithFormat:@"eventId == %@", eventId];
		[eventRequest setPredicate:eventPredicate];
		
		NSError* error = nil;
		NSArray *eventArray = [context executeFetchRequest:eventRequest error:&error];
		if (!eventArray || [eventArray count] == 0) {
			if (error) {
				NSLog(@"%@: error fetching event for ID %@: %@", self, eventId, [error localizedDescription]);
				[error release];
			}
			dbEvent = (Event*)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
		} else {
			dbEvent = (Event*)[eventArray objectAtIndex:0];
		}
		
		dbEvent.createTime = [event valueForKey:@"createTime"];
		dbEvent.display = [event valueForKey:@"display"];
		dbEvent.eventDescription = [event valueForKey:@"eventDescription"];
		dbEvent.eventHost = [event valueForKey:@"eventHost"];
		dbEvent.eventId = eventId;
		dbEvent.lastModified = lastModified;
		dbEvent.log = [event valueForKey:@"log"];
		dbEvent.logMessage = [event valueForKey:@"logMessage"];
		dbEvent.nodeId = [event valueForKey:@"nodeId"];
		dbEvent.severity = [event valueForKey:@"severity"];
		dbEvent.source = [event valueForKey:@"source"];
		dbEvent.time = [event valueForKey:@"time"];
		dbEvent.uei = [event valueForKey:@"uei"];
		
#if DEBUG
		NSLog(@"%@: event = %@", self, dbEvent);
#endif
	}

	if (self.clearOldObjects) {
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
		[request setEntity:entity];
		
		if (nodeId) {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastModified < %@) AND (nodeId == %@)", lastModified, nodeId];
			[request setPredicate:predicate];
		} else{
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastModified < %@", lastModified];
			[request setPredicate:predicate];
		}

		NSError* error = nil;
		NSArray *eventsToDelete = [context executeFetchRequest:request error:&error];
		if (!eventsToDelete) {
			if (error) {
				NSLog(@"%@: error fetching events to delete (older than %@): %@", self, lastModified, [error localizedDescription]);
				[error release];
			} else {
				NSLog(@"%@: error fetching events to delete (older than %@)", self, lastModified);
			}
		} else {
			for (id event in eventsToDelete) {
#if DEBUG
				NSLog(@"deleting %@", event);
#endif
				[context deleteObject:event];
			}
		}
	}

	if (![context save:&error]) {
		NSLog(@"%@: an error occurred saving the managed object context: %@", self, [error localizedDescription]);
		[error release];
	}
	[context unlock];
	[context release];
	[dateFormatter release];
	[self autorelease];
	
	[super finished];
}

@end
