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
#import "ContextService.h"

#import "OutageFactory.h"
#import "Outage.h"

#import "OutageListUpdater.h"
#import "OutageUpdateHandler.h"

#import "OpenNMSAppDelegate.h"

@implementation OutageFactory

static OutageFactory* outageFactorySingleton = nil;

// 2 weeks
#define CUTOFF (60.0 * 60.0 * 24.0 * 14.0)

+(void) initialize
{
	static BOOL initialized = NO;
	if (!initialized)
	{
		initialized = YES;
		outageFactorySingleton = [[OutageFactory alloc] init];
	}
}

+(OutageFactory*) getInstance
{
	if (outageFactorySingleton == nil) {
		[OutageFactory initialize];
	}
	return outageFactorySingleton;
}

-(void) clearData
{
	NSManagedObjectContext* context = [contextService newContext];
	[context lock];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Outage" inManagedObjectContext:context];
	[request setEntity:entity];
	NSError* error = nil;
	NSArray *outagesToDelete = [context executeFetchRequest:request error:&error];
	if (!outagesToDelete) {
		if (error) {
			NSLog(@"%@: error fetching outages to delete (clearData): %@", self, [error localizedDescription]);
			[error release];
		} else {
			NSLog(@"%@: error fetching outages to delete (clearData)", self);
		}
	} else {
		for (id outage in outagesToDelete) {
#if DEBUG
			NSLog(@"deleting %@", outage);
#endif
			[context deleteObject:outage];
		}
	}
	error = nil;
	if (![context save:&error]) {
		NSLog(@"%@: an error occurred saving the managed object context: %@", self, [error localizedDescription]);
		[error release];
	}
	[context unlock];
	[context release];
}

-(Outage*) getCoreDataOutage:(NSNumber*) outageId
{
    Outage* outage = nil;
	NSManagedObjectContext* context = [contextService readContext];
	
	[context lock];
	NSFetchRequest* outageRequest = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Outage" inManagedObjectContext:context];
	[outageRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"outageId == %@", outageId];
	[outageRequest setPredicate:predicate];

	NSError* error = nil;
	NSArray *results = [context executeFetchRequest:outageRequest error:&error];
	[outageRequest release];
	if (!results || [results count] == 0) {
		if (error) {
			NSLog(@"error fetching outage for ID %@: %@", outageId, [error localizedDescription]);
			[error release];
		}
	} else {
		outage = (Outage*)[results objectAtIndex:0];
	}
	[context unlock];
    return outage;
}

-(Outage*) getRemoteOutage:(NSNumber*) outageId
{
	Outage* outage = nil;
	
	if (outageId) {
		OutageListUpdater* outageUpdater = [[OutageListUpdater alloc] initWithOutage:outageId];
		OutageUpdateHandler* outageHandler = [[OutageUpdateHandler alloc] initWithMethod:@selector(finish) target:self];
		outageUpdater.handler = outageHandler;

		[factoryLock lock];
		isFinished = NO;
		[outageUpdater update];
		[outageUpdater release];
		
		while (!isFinished) {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		}
		outage = [self getCoreDataOutage:outageId];
		[factoryLock unlock];
	} else {
		NSLog(@"WARNING: getRemoteOutage called with no outage ID");
	}
	
	return outage;
}

-(NSArray*) getCoreDataOutagesForNode:(NSNumber*) nodeId
{
	NSManagedObjectContext* context = [contextService readContext];
	[context lock];
	NSArray* results = nil;
	if (nodeId) {
		NSFetchRequest* nodeOutageRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Outage" inManagedObjectContext:context];
		[nodeOutageRequest setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeId == %@", nodeId];
		[nodeOutageRequest setPredicate:predicate];
		
		NSError* error = nil;
		NSArray *results = [context executeFetchRequest:nodeOutageRequest error:&error];
		[nodeOutageRequest release];
		if (!results) {
			if (error) {
				NSLog(@"error fetching outages for node ID %@: %@", nodeId, [error localizedDescription]);
				[error release];
			} else {
				NSLog(@"error fetching outages for node ID %@", nodeId);
			}
		}
	}
	[context unlock];
    return results;
}

-(NSArray*) getRemoteOutagesForNode:(NSNumber*) nodeId
{
	NSArray* outages = nil;
	OutageListUpdater* outageUpdater = [[OutageListUpdater alloc] initWithNode:nodeId];
	OutageUpdateHandler* outageHandler = [[OutageUpdateHandler alloc] initWithMethod:@selector(finish) target:self];
	outageUpdater.handler = outageHandler;
	
	[factoryLock lock];
	isFinished = NO;
	[outageUpdater update];
	[outageUpdater release];
	
	while (!isFinished) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	outages = [self getCoreDataOutagesForNode:nodeId];
	[factoryLock unlock];
	return outages;
}

-(NSArray*) getOutagesForNode:(NSNumber*) nodeId
{
	NSArray* outages = [self getCoreDataOutagesForNode:nodeId];
	BOOL refreshOutages = (!outages || ([outages count] == 0));
	
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
		return [self getRemoteOutagesForNode:nodeId];
	}
	return outages;
}

-(Outage*) getOutage:(NSNumber*) outageId
{
	Outage* outage = [self getCoreDataOutage:outageId];

	if (!outage || ([outage.lastModified timeIntervalSinceNow] > CUTOFF)) {
#if DEBUG
		NSLog(@"outage not found, or last modified out of date");
#endif
		outage = [self getRemoteOutage:outageId];
	}
	return outage;
}

@end
