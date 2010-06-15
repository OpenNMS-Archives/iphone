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

#import "EventFactory.h"
#import "Event.h"

#import "EventUpdater.h"
#import "EventUpdateHandler.h"

@implementation EventFactory

@synthesize isFinished;
@synthesize factoryLock;

static EventFactory* eventFactorySingleton = nil;
static ContextService* contextService = nil;

// 2 weeks
#define CUTOFF (60.0 * 60.0 * 24.0 * 14.0)

+(void) initialize
{
	static BOOL initialized = NO;
	if (!initialized)
	{
		initialized = YES;
		eventFactorySingleton = [[EventFactory alloc] init];
		contextService        = [[ContextService alloc] init];
	}
}

+(EventFactory*) getInstance
{
	if (eventFactorySingleton == nil) {
		[EventFactory initialize];
	}
	return eventFactorySingleton;
}

-(id) init
{
	if (self = [super init]) {
		isFinished = NO;
		factoryLock = [NSRecursiveLock new];
	}
	return self;
}

-(void) finish
{
	isFinished = YES;
}

-(Event*) getCoreDataEvent:(NSNumber*) eventId
{
	NSManagedObjectContext* context = [contextService managedObjectContext];
    [context lock];
	NSFetchRequest* eventRequest = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
	[eventRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventId == %@", eventId];
	[eventRequest setPredicate:predicate];

    Event* event = nil;
	NSError* error = nil;
	NSArray *results = [context executeFetchRequest:eventRequest error:&error];
	[eventRequest release];
	if (!results || [results count] == 0) {
		if (error) {
			NSLog(@"%@: error fetching event for ID %@: %@", self, eventId, [error localizedDescription]);
			[error release];
		}
	} else {
		event = (Event*)[results objectAtIndex:0];
	}
    [context unlock];
    return event;
}

-(NSArray*) getCoreDataEventsForNode:(NSNumber*) nodeId
{
	NSManagedObjectContext* context = [contextService managedObjectContext];
    [context lock];
	NSFetchRequest* nodeEventRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
	[nodeEventRequest setEntity:entity];

	if (nodeId) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeId == %@", nodeId];
		[nodeEventRequest setPredicate:predicate];
	}

	NSMutableArray* sortDescriptors = [NSMutableArray array];
	[sortDescriptors addObject:[[[NSSortDescriptor alloc] initWithKey:@"eventId" ascending:NO] autorelease]];
	[nodeEventRequest setSortDescriptors:sortDescriptors];

	NSError* error = nil;
	NSArray *results = [context executeFetchRequest:nodeEventRequest error:&error];
	[nodeEventRequest release];
	if (!results) {
		if (error) {
			NSLog(@"%@: error fetching events for node ID %@: %@", self, nodeId, [error localizedDescription]);
			[error release];
		} else {
			NSLog(@"%@: error fetching events for node ID %@", self, nodeId);
		}
	}
    [context unlock];
    return results;
}

-(NSArray*) getEventsForNode:(NSNumber*) nodeId
{
	NSArray* events = [self getCoreDataEventsForNode:nodeId];
	BOOL refreshEvents = (!events || ([events count] == 0));
	
	if (refreshEvents == NO) {
		for (id event in events) {
			if ([((Event*)event).lastModified timeIntervalSinceNow] > CUTOFF) {
				refreshEvents = YES;
				break;
			}
		}
	}
	if (refreshEvents) {
#if DEBUG
		NSLog(@"%@: event(s) not found, or last modified(s) out of date", self);
#endif
		[factoryLock lock];
		EventUpdater* eventUpdater = [[EventUpdater alloc] initWithNodeId:nodeId limit:10];
		EventUpdateHandler* eventHandler = [[EventUpdateHandler alloc] initWithMethod:@selector(finish) target:self];
		eventHandler.nodeId = nodeId;
		eventHandler.clearOldObjects = YES;
		eventUpdater.handler = eventHandler;
		
		[eventUpdater update];
		[eventUpdater release];
		
		NSDate* loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
		while (!isFinished) {
#if DEBUG
			NSLog(@"%@: waiting for getEventsForNode", self);
#endif
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
		}
		events = [self getCoreDataEventsForNode:nodeId];
		[factoryLock unlock];
	}

	isFinished = NO;
	return events;
}

@end
