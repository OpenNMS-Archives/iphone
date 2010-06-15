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

#import "SnmpInterfaceFactory.h"
#import "SnmpInterface.h"

#import "SnmpInterfaceUpdater.h"
#import "SnmpInterfaceUpdateHandler.h"

@implementation SnmpInterfaceFactory

@synthesize isFinished;
@synthesize factoryLock;

static SnmpInterfaceFactory* snmpInterfaceFactorySingleton = nil;
static ContextService* contextService = nil;

// 2 weeks
#define CUTOFF (60.0 * 60.0 * 24.0 * 14.0)

+(void) initialize
{
	static BOOL initialized = NO;
	if (!initialized)
	{
		initialized = YES;
		snmpInterfaceFactorySingleton = [[SnmpInterfaceFactory alloc] init];
		contextService         = [[ContextService alloc] init];
	}
}

+(SnmpInterfaceFactory*) getInstance
{
	if (snmpInterfaceFactorySingleton == nil) {
		[SnmpInterfaceFactory initialize];
	}
	return snmpInterfaceFactorySingleton;
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

-(SnmpInterface*) getCoreDataSnmpInterface:(NSNumber*) snmpInterfaceId
{
    SnmpInterface* iface = nil;
	NSManagedObjectContext* context = [contextService managedObjectContext];
    [context lock];
	NSFetchRequest* snmpInterfaceRequest = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"SnmpInterface" inManagedObjectContext:context];
	[snmpInterfaceRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"snmpInterfaceId == %@", snmpInterfaceId];
	[snmpInterfaceRequest setPredicate:predicate];

	NSError* error = nil;
	NSArray *results = [context executeFetchRequest:snmpInterfaceRequest error:&error];
	[snmpInterfaceRequest release];
	if (!results || [results count] == 0) {
		if (error) {
			NSLog(@"%@: error fetching snmpInterface for ID %@: %@", self, snmpInterfaceId, [error localizedDescription]);
			[error release];
		}
	} else {
		iface = (SnmpInterface*)[results objectAtIndex:0];
	}
    [context unlock];
    return iface;
}

-(NSArray*) getCoreDataSnmpInterfacesForNode:(NSNumber*) nodeId
{
	NSManagedObjectContext* context = [contextService managedObjectContext];
    [context lock];
	NSFetchRequest* nodeSnmpInterfaceRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"SnmpInterface" inManagedObjectContext:context];
	[nodeSnmpInterfaceRequest setEntity:entity];

	if (nodeId) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeId == %@", nodeId];
		[nodeSnmpInterfaceRequest setPredicate:predicate];
	}

	NSMutableArray* sortDescriptors = [NSMutableArray array];
	[sortDescriptors addObject:[[[NSSortDescriptor alloc] initWithKey:@"interfaceId" ascending:YES] autorelease]];
	[sortDescriptors addObject:[[[NSSortDescriptor alloc] initWithKey:@"ipAddress" ascending:YES] autorelease]];

	[nodeSnmpInterfaceRequest setSortDescriptors:sortDescriptors];
	
	NSError* error = nil;
	NSArray *results = [context executeFetchRequest:nodeSnmpInterfaceRequest error:&error];
	[nodeSnmpInterfaceRequest release];
	if (!results) {
		if (error) {
			NSLog(@"%@: error fetching snmpInterfaces for node ID %@: %@", self, nodeId, [error localizedDescription]);
			[error release];
		} else {
			NSLog(@"%@: error fetching snmpInterfaces for node ID %@", self, nodeId);
		}
	}
    [context unlock];
    return results;
}

-(NSArray*) getSnmpInterfacesForNode:(NSNumber*) nodeId
{
	NSArray* snmpInterfaces = [self getCoreDataSnmpInterfacesForNode:nodeId];
	BOOL refreshSnmpInterfaces = (!snmpInterfaces || ([snmpInterfaces count] == 0));
	
	if (refreshSnmpInterfaces == NO) {
		for (id snmpInterface in snmpInterfaces) {
			if ([((SnmpInterface*)snmpInterface).lastModified timeIntervalSinceNow] > CUTOFF) {
				refreshSnmpInterfaces = YES;
				break;
			}
		}
	}
	if (refreshSnmpInterfaces) {
#if DEBUG
		NSLog(@"%@: snmpInterface(s) not found, or last modified(s) out of date", self);
#endif
		[factoryLock lock];
		SnmpInterfaceUpdater* snmpInterfaceUpdater = [[SnmpInterfaceUpdater alloc] initWithNodeId:nodeId];
		SnmpInterfaceUpdateHandler* snmpInterfaceHandler = [[SnmpInterfaceUpdateHandler alloc] initWithMethod:@selector(finish) target:self];
		snmpInterfaceHandler.nodeId = nodeId;
		snmpInterfaceHandler.clearOldObjects = YES;
		snmpInterfaceUpdater.handler = snmpInterfaceHandler;
		
		[snmpInterfaceUpdater update];
		[snmpInterfaceUpdater release];
		
		NSDate* loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
		while (!isFinished) {
#if DEBUG
			NSLog(@"%@: waiting for getSnmpInterfacesForNode", self);
#endif
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
		}
		snmpInterfaces = [self getCoreDataSnmpInterfacesForNode:nodeId];
		[factoryLock unlock];
	}
	
	isFinished = NO;
	return snmpInterfaces;
}

@end
