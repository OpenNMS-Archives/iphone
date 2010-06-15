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

#import "IpInterfaceFactory.h"
#import "IpInterface.h"

#import "IpInterfaceUpdater.h"
#import "IpInterfaceUpdateHandler.h"

@implementation IpInterfaceFactory

@synthesize isFinished;
@synthesize factoryLock;

static IpInterfaceFactory* ipInterfaceFactorySingleton = nil;
static ContextService* contextService = nil;

// 2 weeks
#define CUTOFF (60.0 * 60.0 * 24.0 * 14.0)

+(void) initialize
{
	static BOOL initialized = NO;
	if (!initialized)
	{
		initialized = YES;
		ipInterfaceFactorySingleton = [[IpInterfaceFactory alloc] init];
		contextService         = [[ContextService alloc] init];
	}
}

+(IpInterfaceFactory*) getInstance
{
	if (ipInterfaceFactorySingleton == nil) {
		[IpInterfaceFactory initialize];
	}
	return ipInterfaceFactorySingleton;
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

-(void) clearData
{
	NSManagedObjectContext* context = [contextService writeContext];
	[context lock];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"IpInterface" inManagedObjectContext:context];
	[request setEntity:entity];
	NSError* error = nil;
	NSArray *ifacesToDelete = [context executeFetchRequest:request error:&error];
	if (!ifacesToDelete) {
		if (error) {
			NSLog(@"%@: error fetching ifaces to delete (clearData): %@", self, [error localizedDescription]);
			[error release];
		} else {
			NSLog(@"%@: error fetching ifaces to delete (clearData)", self);
		}
	} else {
		for (id iface in ifacesToDelete) {
#if DEBUG
			NSLog(@"deleting %@", iface);
#endif
			[context deleteObject:iface];
		}
	}
	error = nil;
	if (![context save:&error]) {
		NSLog(@"%@: an error occurred saving the managed object context: %@", self, [error localizedDescription]);
		[error release];
	}
	[context unlock];
}

-(IpInterface*) getCoreDataIpInterface:(NSNumber*) ipInterfaceId
{
    IpInterface* iface = nil;
	NSManagedObjectContext* context = [contextService readContext];
	NSFetchRequest* ipInterfaceRequest = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"IpInterface" inManagedObjectContext:context];
	[ipInterfaceRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ipInterfaceId == %@", ipInterfaceId];
	[ipInterfaceRequest setPredicate:predicate];

	NSError* error = nil;
	NSArray *results = [context executeFetchRequest:ipInterfaceRequest error:&error];
	[ipInterfaceRequest release];
	if (!results || [results count] == 0) {
		if (error) {
			NSLog(@"%@: error fetching ipInterface for ID %@: %@", self, ipInterfaceId, [error localizedDescription]);
			[error release];
		}
	} else {
		iface = (IpInterface*)[results objectAtIndex:0];
	}
    return iface;
}

-(NSArray*) getCoreDataIpInterfacesForNode:(NSNumber*) nodeId
{
	NSManagedObjectContext* context = [contextService readContext];
	NSFetchRequest* nodeIpInterfaceRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"IpInterface" inManagedObjectContext:context];
	[nodeIpInterfaceRequest setEntity:entity];

	if (nodeId) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeId == %@", nodeId];
		[nodeIpInterfaceRequest setPredicate:predicate];
	}

	NSMutableArray* sortDescriptors = [NSMutableArray array];
	[sortDescriptors addObject:[[[NSSortDescriptor alloc] initWithKey:@"interfaceId" ascending:YES] autorelease]];
	[sortDescriptors addObject:[[[NSSortDescriptor alloc] initWithKey:@"ipAddress" ascending:YES] autorelease]];
	[nodeIpInterfaceRequest setSortDescriptors:sortDescriptors];

	NSError* error = nil;
	NSArray *results = [context executeFetchRequest:nodeIpInterfaceRequest error:&error];
	[nodeIpInterfaceRequest release];
	if (!results) {
		if (error) {
			NSLog(@"%@: error fetching ipInterfaces for node ID %@: %@", self, nodeId, [error localizedDescription]);
			[error release];
		} else {
			NSLog(@"%@: error fetching ipInterfaces for node ID %@", self, nodeId);
		}
	}
    return results;
}

-(NSArray*) getIpInterfacesForNode:(NSNumber*) nodeId
{
	NSArray* ipInterfaces = [self getCoreDataIpInterfacesForNode:nodeId];
	BOOL refreshIpInterfaces = (!ipInterfaces || ([ipInterfaces count] == 0));
	
	if (refreshIpInterfaces == NO) {
		for (id ipInterface in ipInterfaces) {
			if ([((IpInterface*)ipInterface).lastModified timeIntervalSinceNow] > CUTOFF) {
				refreshIpInterfaces = YES;
				break;
			}
		}
	}
	if (refreshIpInterfaces) {
#if DEBUG
		NSLog(@"%@: ipInterface(s) not found, or last modified(s) out of date", self);
#endif
		[factoryLock lock];
		IpInterfaceUpdater* ipInterfaceUpdater = [[IpInterfaceUpdater alloc] initWithNodeId:nodeId];
		IpInterfaceUpdateHandler* ipInterfaceHandler = [[IpInterfaceUpdateHandler alloc] initWithMethod:@selector(finish) target:self];
		ipInterfaceHandler.nodeId = nodeId;
		ipInterfaceHandler.clearOldObjects = YES;
		ipInterfaceUpdater.handler = ipInterfaceHandler;
		
		[ipInterfaceUpdater update];
		[ipInterfaceUpdater release];
		
		NSDate* loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
		while (!isFinished) {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
		}
		ipInterfaces = [self getCoreDataIpInterfacesForNode:nodeId];
		[factoryLock unlock];
	}

	isFinished = NO;
	return ipInterfaces;
}

@end
