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

	NSArray* xmlEvents;
	if ([[[document rootElement] name] isEqual:@"event"]) {
		xmlEvents = [NSArray arrayWithObject:[document rootElement]];
	} else {
		xmlEvents = [[document rootElement] elementsForName:@"event"];
	}
	for (id xmlEvent in xmlEvents) {
		count++;
		Event* event;

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
				NSLog(@"unknown event attribute: %@", [attr name]);
#endif
			}
		}

		NSFetchRequest *eventRequest = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *eventEntity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:moc];
		[eventRequest setEntity:eventEntity];
		
		NSPredicate *eventPredicate = [NSPredicate predicateWithFormat:@"eventId == %@", eventId];
		[eventRequest setPredicate:eventPredicate];
		
		NSError* error = nil;
		NSArray *eventArray = [moc executeFetchRequest:eventRequest error:&error];
		if (!eventArray || [eventArray count] == 0) {
			if (error) {
				NSLog(@"error fetching event for ID %@: %@", eventId, [error localizedDescription]);
				[error release];
			}
			event = (Event*)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc];
		} else {
			event = (Event*)[eventArray objectAtIndex:0];
		}

		event.eventId = eventId;
		event.display = [NSNumber numberWithBool:eventDisplay];
		event.log = [NSNumber numberWithBool:eventLog];
		event.severity = eventSeverity;
		event.lastModified = lastModified;
		
		CXMLElement* nodeElement = [xmlEvent elementForName:@"nodeId"];
		if (nodeElement) {
			event.nodeId = [NSNumber numberWithInt:[[[nodeElement childAtIndex:0] stringValue] intValue]];
		}
		
		// Time
		CXMLElement *timeElement = [xmlEvent elementForName:@"time"];
		if (timeElement) {
			event.time = [dateFormatter dateFromString:[self stringForDate:[[timeElement childAtIndex:0] stringValue]]];
		}
		
		// CreateTime
		CXMLElement *ctElement = [xmlEvent elementForName:@"createTime"];
		if (ctElement) {
			event.createTime = [dateFormatter dateFromString:[self stringForDate:[[ctElement childAtIndex:0] stringValue]]];
		}
		
		// Description
		CXMLElement *descrElement = [xmlEvent elementForName:@"description"];
		if (descrElement) {
			event.eventDescription = [self cleanUpString:[[descrElement childAtIndex:0] stringValue]];
		}
		
		// Host
		CXMLElement *hostElement = [xmlEvent elementForName:@"host"];
		if (hostElement) {
			event.eventHost = [[hostElement childAtIndex:0] stringValue];
		}
		
		// Log Message
		CXMLElement *lmElement = [xmlEvent elementForName:@"logMessage"];
		if (lmElement) {
			event.logMessage = [self cleanUpString:[[lmElement childAtIndex:0] stringValue]];
		}
		
		// Source
		CXMLElement *sourceElement = [xmlEvent elementForName:@"source"];
		if (sourceElement) {
			event.source = [[sourceElement childAtIndex:0] stringValue];
		}

		// UEI
		CXMLElement *ueiElement = [xmlEvent elementForName:@"uei"];
		if (ueiElement) {
			event.uei = [[ueiElement childAtIndex:0] stringValue];
		}
	}

#if DEBUG
	NSLog(@"found %d Events", count);
#endif

	if (self.clearOldObjects) {
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:moc];
		[request setEntity:entity];
		
		if (nodeId) {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastModified < %@) AND (nodeId == %@)", lastModified, nodeId];
			[request setPredicate:predicate];
		} else{
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastModified < %@", lastModified];
			[request setPredicate:predicate];
		}

		NSError* error = nil;
		NSArray *eventsToDelete = [moc executeFetchRequest:request error:&error];
		if (!eventsToDelete) {
			if (error) {
				NSLog(@"error fetching events to delete (older than %@): %@", lastModified, [error localizedDescription]);
				[error release];
			} else {
				NSLog(@"error fetching events to delete (older than %@)", lastModified);
			}
		} else {
			for (id event in eventsToDelete) {
#ifdef DEBUG
				NSLog(@"deleting %@", event);
#endif
				[moc deleteObject:event];
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
