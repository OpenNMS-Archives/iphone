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

#import "NodeUpdateHandler.h"
#import "Node.h"
#import "ContextService.h"

@implementation NodeUpdateHandler

-(void) requestDidFinish:(ASIHTTPRequest*) request
{
#if DEBUG
	NSLog(@"%@: requestDidFinish called", self);
#endif
	NSManagedObjectContext *moc = [contextService managedObjectContext];
	
	/*
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:true];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
	 */

	CXMLDocument* document = [self getDocumentForRequest:request];

	if (!document) {
		// [dateFormatter release];
		[super requestDidFinish:request];
		[self autorelease];
	}

	NSArray* xmlNodes;
	if ([[[document rootElement] name] isEqual:@"node"]) {
		xmlNodes = [NSArray arrayWithObject:[document rootElement]];
	} else {
		xmlNodes = [[document rootElement] elementsForName:@"node"];
	}
	for (id xmlNode in xmlNodes) {
		Node* node;

		NSNumber* nodeId = nil;
		NSString* label = nil;
		
		for (id attr in [xmlNode attributes]) {
			if ([[attr name] isEqual:@"id"]) {
				nodeId = [NSNumber numberWithInt:[[attr stringValue] intValue]];
			} else if ([[attr name] isEqual:@"label"]) {
				label = [self cleanUpString:[attr stringValue]];
#if DEBUG
			} else {
				NSLog(@"unknown node attribute: %@", [attr name]);
#endif
			}
		}

		NSFetchRequest *nodeRequest = [[[NSFetchRequest alloc] init] autorelease];

		NSEntityDescription *nodeEntity = [NSEntityDescription entityForName:@"Node" inManagedObjectContext:moc];
		[nodeRequest setEntity:nodeEntity];

		NSPredicate *nodePredicate = [NSPredicate predicateWithFormat:@"nodeId == %@", nodeId];
		[nodeRequest setPredicate:nodePredicate];
		
		NSError* error = nil;
		NSArray *nodeArray = [moc executeFetchRequest:nodeRequest error:&error];
		if (!nodeArray || [nodeArray count] == 0) {
			if (error) {
				NSLog(@"error fetching node for ID %@: %@", nodeId, [error localizedDescription]);
				[error release];
			}
			node = (Node*)[NSEntityDescription insertNewObjectForEntityForName:@"Node" inManagedObjectContext:moc];
		} else {
			node = (Node*)[nodeArray objectAtIndex:0];
		}

		node.nodeId = nodeId;
		node.label = label;
		node.lastModified = [NSDate date];
	}

	NSError* error = nil;
	if (![moc save:&error]) {
		NSLog(@"an error occurred saving the managed object context: %@", [error localizedDescription]);
		[error release];
	}
	// [dateFormatter release];
	[super requestDidFinish:request];
	[self autorelease];
}

@end
