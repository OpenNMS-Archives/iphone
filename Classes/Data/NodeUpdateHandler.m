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

#import "NodeUpdateHandler.h"
#import "Node.h"

@implementation NodeUpdateHandler

-(void) handleRequest:(ASIHTTPRequest*) request
{
	[super handleRequest:request];

	CXMLDocument* document = [self getDocumentForRequest:request];
	NSDate* lastModified = [NSDate date];

	if (!document) {
		[super requestDidFinish:request];
		[self autorelease];
	}

	NSArray* xmlNodes;
	if ([[[document rootElement] name] isEqual:@"node"]) {
		xmlNodes = [NSArray arrayWithObject:[document rootElement]];
	} else {
		xmlNodes = [[document rootElement] elementsForName:@"node"];
	}
	
	NSMutableArray* nodes = [NSMutableArray arrayWithCapacity:[xmlNodes count]];

	for (id xmlNode in xmlNodes) {
		NSMutableDictionary* node = [NSMutableDictionary dictionary];

		NSNumber* nodeId = nil;
		NSString* label = nil;
		
		for (id attr in [xmlNode attributes]) {
			if ([[attr name] isEqual:@"id"]) {
				nodeId = [NSNumber numberWithInt:[[attr stringValue] intValue]];
			} else if ([[attr name] isEqual:@"label"]) {
				label = [self cleanUpString:[attr stringValue]];
			} else if ([[attr name] isEqual:@"type"]) {
				// ignore
#if DEBUG
			} else {
				NSLog(@"unknown node attribute: %@", [attr name]);
#endif
			}
		}

		[node setValue:nodeId forKey:@"nodeId"];
		[node setValue:label forKey:@"label"];
		
		[nodes addObject:node];
	}
	
	NSError* error = nil;
	Node* dbNode = nil;

	NSManagedObjectContext* context = [contextService newContext];
	[context lock];
	
	for (id node in nodes) {
		NSNumber* nodeId = [node valueForKey:@"nodeId"];
		
		NSFetchRequest *nodeRequest = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *nodeEntity = [NSEntityDescription entityForName:@"Node" inManagedObjectContext:context];
		[nodeRequest setEntity:nodeEntity];
		
		NSPredicate *nodePredicate = [NSPredicate predicateWithFormat:@"nodeId == %@", nodeId];
		[nodeRequest setPredicate:nodePredicate];
		
		NSArray *nodeArray = [context executeFetchRequest:nodeRequest error:&error];
		if (!nodeArray || [nodeArray count] == 0) {
			if (error) {
				NSLog(@"error fetching node for ID %@: %@", nodeId, [error localizedDescription]);
				[error release];
			}
			dbNode = (Node*)[NSEntityDescription insertNewObjectForEntityForName:@"Node" inManagedObjectContext:context];
		} else {
			dbNode = (Node*)[nodeArray objectAtIndex:0];
		}

		dbNode.nodeId = nodeId;
		dbNode.label = [node valueForKey:@"label" ];
		dbNode.lastModified = lastModified;
	}
	
	if (![context save:&error]) {
		NSLog(@"an error occurred saving the managed object context: %@", [error localizedDescription]);
		[error release];
	}

	[context unlock];
	[context release];
	[self autorelease];
	
	[super finished];
}

@end
