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

#import "OutageFactory.h"
#import "Outage.h"
#import "OpenNMSAppDelegate.h"

#import "OutageListUpdater.h"
#import "OutageUpdateHandler.h"

@implementation OutageFactory

@synthesize isFinished;

static OutageFactory* outageFactorySingleton = nil;
static NSManagedObjectContext* managedObjectContext = nil;

// 2 weeks
#define CUTOFF (60.0 * 60.0 * 24.0 * 14.0)

+(void) initialize
{
	static BOOL initialized = NO;
	if (!initialized)
	{
		initialized = YES;
		outageFactorySingleton = [[OutageFactory alloc] init];
		managedObjectContext =  [(OpenNMSAppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
	}
}

+(OutageFactory*) getInstance
{
	if (outageFactorySingleton == nil) {
		[OutageFactory initialize];
	}
	return outageFactorySingleton;
}

-(id) init
{
	if (self = [super init]) {
		isFinished = NO;
	}
	return self;
}

-(void) finish
{
	isFinished = YES;
}

-(Outage*) getCoreDataOutage:(NSNumber*) outageId
{
	NSFetchRequest* outageRequest = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Outage" inManagedObjectContext:managedObjectContext];
	[outageRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"outageId == %@", outageId];
	[outageRequest setPredicate:predicate];

	NSError* error = nil;
	NSArray *results = [managedObjectContext executeFetchRequest:outageRequest error:&error];
	if (!results || [results count] == 0) {
		if (error) {
			NSLog(@"error fetching outage for ID %@: %@", outageId, [error localizedDescription]);
			[error release];
		}
		return nil;
	} else {
		return (Outage*)[results objectAtIndex:0];
	}
}

-(NSArray*) getCoreDataOutagesForNode:(NSNumber*) nodeId
{
	NSFetchRequest* nodeOutageRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Outage" inManagedObjectContext:managedObjectContext];
	[nodeOutageRequest setEntity:entity];

	if (nodeId) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeId == %@", nodeId];
		[nodeOutageRequest setPredicate:predicate];
	}

	NSError* error = nil;
	NSArray *results = [managedObjectContext executeFetchRequest:nodeOutageRequest error:&error];
	if (!results) {
		if (error) {
			NSLog(@"error fetching outages for node ID %@: %@", nodeId, [error localizedDescription]);
			[error release];
		} else {
			NSLog(@"error fetching outages for node ID %@", nodeId);
		}
		return nil;
	} else {
		return results;
	}
}

-(NSArray*) fetchOutages
{
	return [self getCoreDataOutagesForNode:nil];
}

-(NSArray*) getOutagesForNode:(NSNumber*) nodeId
{
	NSArray* outages = [self getCoreDataOutagesForNode:nodeId];
	BOOL refreshOutages = (DEBUG == 1 || !outages || ([outages count] == 0));
	
	if (refreshOutages == NO) {
		for (id outage in outages) {
			if ([((Outage*)outage).lastModified timeIntervalSinceNow] > CUTOFF) {
				refreshOutages = YES;
				break;
			}
		}
	}
	if (refreshOutages) {
#if DEBUG
		NSLog(@"outage(s) not found, or last modified(s) out of date");
#endif
		OutageListUpdater* outageUpdater = [[OutageListUpdater alloc] initWithNode:nodeId];
		OutageUpdateHandler* outageHandler = [[OutageUpdateHandler alloc] initWithMethod:@selector(finish) target:self];
		outageHandler.nodeId = nodeId;
		outageUpdater.handler = outageHandler;
		
		[outageUpdater update];
		[outageUpdater release];
		
		NSDate* loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
		while (!isFinished) {
#if DEBUG
			NSLog(@"waiting for getOutagesForNode");
#endif
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
		}
		outages = [self getCoreDataOutagesForNode:nodeId];
	}
	
	isFinished = NO;
	return outages;
}

-(Outage*) getOutage:(NSNumber*) outageId
{
	Outage* outage = [self getCoreDataOutage:outageId];

	if (DEBUG == 1 || !outage || ([outage.lastModified timeIntervalSinceNow] > CUTOFF)) {
#if DEBUG
		NSLog(@"outage not found, or last modified out of date");
#endif
		OutageListUpdater* outageUpdater = [[OutageListUpdater alloc] initWithOutage:outageId];
		OutageUpdateHandler* outageHandler = [[OutageUpdateHandler alloc] init];
		outageUpdater.handler = outageHandler;

		[outageUpdater update];
		[outageUpdater release];

		NSDate* loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
		while (!isFinished) {
#if DEBUG
			NSLog(@"waiting for getOutage");
#endif
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
		}
	}

	isFinished = NO;
	return outage;
}

@end
