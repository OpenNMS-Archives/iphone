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

#import "NodeFactory.h"
#import "OutageFactory.h"

#import "NodeUpdater.h"
#import "NodeUpdateHandler.h"

#import "IpInterface.h"

#import "OpenNMSAppDelegate.h"

@implementation NodeFactory

@synthesize isFinished;
@synthesize factoryLock;

static NodeFactory* nodeFactorySingleton = nil;
static ContextService* contextService = nil;

// 2 weeks
#define CUTOFF (60.0 * 60.0 * 24.0 * 14.0)

+(void) initialize
{
	static BOOL initialized = NO;
	if (!initialized)
	{
		initialized = YES;
		nodeFactorySingleton = [[NodeFactory alloc] init];
		contextService = [((OpenNMSAppDelegate*)[UIApplication sharedApplication].delegate) contextService];
	}
}

+(NodeFactory*) getInstance
{
	if (nodeFactorySingleton == nil) {
		[NodeFactory initialize];
	}
	return nodeFactorySingleton;
}

-(id) init
{
	if (self = [super init]) {
		isFinished = YES;
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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Node" inManagedObjectContext:context];
	[request setEntity:entity];
	NSError* error = nil;
	NSArray *nodesToDelete = [context executeFetchRequest:request error:&error];
	if (!nodesToDelete) {
		if (error) {
			NSLog(@"%@: error fetching nodes to delete (clearData): %@", self, [error localizedDescription]);
			[error release];
		} else {
			NSLog(@"%@: error fetching nodes to delete (clearData)", self);
		}
	} else {
		for (id node in nodesToDelete) {
#if DEBUG
			NSLog(@"deleting %@", node);
#endif
			[context deleteObject:node];
		}
	}
	error = nil;
	if (![context save:&error]) {
		NSLog(@"%@: an error occurred saving the managed object context: %@", self, [error localizedDescription]);
		[error release];
	}
	[context unlock];
}

NSInteger sortNodeObjectId(id obj1, id obj2, void* nothing)
{
	NSManagedObjectContext* context = [contextService readContext];
	Node* node1 = (Node*)[context objectWithID:obj1];
	Node* node2 = (Node*)[context objectWithID:obj2];
	
	return [node1.label localizedCaseInsensitiveCompare:node2.label];
}

-(NSArray*) getCoreDataNodeObjectIDs:(NSString*) searchTerm
{
	NSMutableSet* nodes = [NSMutableSet set];
	
	NSManagedObjectContext* context = [contextService readContext];
	NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Node" inManagedObjectContext:context];
	[request setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label CONTAINS[cd] %@", searchTerm];
	[request setPredicate:predicate];
	NSError* error = nil;
	NSArray* results = [context executeFetchRequest:request error:&error];
	[request release];
	if (!results || [results count] == 0) {
		if (error) {
			NSLog(@"error fetching node for search term  %@: %@", searchTerm, [error localizedDescription]);
			[error release];
		}
	} else {
		for (id node in results) {
			[nodes addObject:[node objectID]];
		}
	}

	NSFetchRequest* interfaceRequest = [[NSFetchRequest alloc] init];
	entity = [NSEntityDescription entityForName:@"IpInterface" inManagedObjectContext:context];
	[interfaceRequest setEntity:entity];
	predicate = [NSPredicate predicateWithFormat:@"(ipAddress CONTAINS[cd] %@) OR (hostName CONTAINS[cd] %@)", searchTerm, searchTerm];
	[interfaceRequest setPredicate:predicate];
	error = nil;
	NSArray* interfaceResults = [context executeFetchRequest:interfaceRequest error:&error];
	[interfaceRequest release];
	if (!interfaceResults || [interfaceResults count] == 0) {
		if (error) {
			NSLog(@"error fetching IP interfaces for search term %@: %@", searchTerm, [error localizedDescription]);
			[error release];
		}
	} else {
		for (id interface in interfaceResults) {
			IpInterface* iface = interface;
			Node* n = [self getNode:iface.nodeId];
			[nodes addObject:[n objectID]];
		}
	}
	
	return [[nodes allObjects] sortedArrayUsingFunction:sortNodeObjectId context:nil];
}

-(Node*) getCoreDataNode:(NSNumber*) nodeId
{
	Node* node = nil;
	NSManagedObjectContext* context = [contextService readContext];
	NSFetchRequest* request = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Node" inManagedObjectContext:context];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeId == %@", nodeId];
	[request setPredicate:predicate];
	
	NSError* error = nil;
	NSArray* results = [context executeFetchRequest:request error:&error];
	[request release];
	if (!results || [results count] == 0) {
		if (error) {
			NSLog(@"error fetching node for ID %@: %@", nodeId, [error localizedDescription]);
			[error release];
		}
		return nil;
	} else {
		node = (Node*)[results objectAtIndex:0];
	}
	return node;
}

-(Node*) getRemoteNode:(NSNumber*) nodeId
{
	Node* node = nil;
	
	if (nodeId) {
		NodeUpdater* nodeUpdater = [[NodeUpdater alloc] initWithNode:nodeId];
		NodeUpdateHandler* nodeHandler = [[NodeUpdateHandler alloc] initWithMethod:@selector(finish) target:self];
		nodeUpdater.handler = nodeHandler;

		[factoryLock lock];
		isFinished = NO;
		[nodeUpdater update];
		[nodeUpdater release];
		
		while (!isFinished) {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		}
		node = [self getCoreDataNode:nodeId];
		[factoryLock unlock];
	} else {
		NSLog(@"WARNING: getRemoteNode called with no node ID");
	}

	return node;
}

-(Node*) getNode:(NSNumber*) nodeId
{
	Node* node = [self getCoreDataNode:nodeId];

	if (!node || ([node.lastModified timeIntervalSinceNow] > CUTOFF)) {
#if DEBUG
		NSLog(@"node %@ not found, or last modified out of date", nodeId);
#endif
		node = [self getRemoteNode:nodeId];
	}

#if DEBUG
//	NSLog(@"returning node: %@", node);
#endif
	return node;
}

@end
