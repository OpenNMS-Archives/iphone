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
#import "OpenNMSAppDelegate.h"
#import "Node.h"
#import "RegexKitLite.h"

@implementation NodeUpdateHandler

-(void) requestDidFinish:(ASIHTTPRequest*) request
{
#if DEBUG
	NSLog(@"%@: requestDidFinish called", self);
#endif
#if 0
	[stateLock lock];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:true];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];

	CXMLDocument* document = [self getDocumentForRequest:request];

	if (!document) {
		[stateLock unlock];
		[dateFormatter release];
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
				label = [attr stringValue];
#if DEBUG
			} else {
				NSLog(@"unknown node attribute: %@", [attr name]);
#endif
			}
		}

		NSManagedObjectContext *moc = [(OpenNMSAppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];

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

	/*
	NSError* error = nil;
	if (![moc save:&error]) {
		NSLog(@"an error occurred saving the managed object context: %@", [error localizedDescription]);
		[error release];
	}
	 */

	if (self.objectList) {
		NSFetchRequest* req = [[[NSFetchRequest alloc] init] autorelease];
		[req setResultType:NSManagedObjectIDResultType];

		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Node" inManagedObjectContext:moc];
		[req setEntity:entity];

		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"label" ascending:NO];
		[req setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		[sortDescriptor release];

		error = nil;
		NSArray *array = [moc executeFetchRequest:req error:&error];
		if (array == nil) {
			if (error) {
				NSLog(@"error fetching nodes: %@", [error localizedDescription]);
			} else {
				NSLog(@"error fetching nodes");
			}
		} else {
			[self.objectList removeAllObjects];
			[self.objectList addObjectsFromArray:array];
		}
	}

	[stateLock unlock];

	[dateFormatter release];
	[super requestDidFinish:request];
	[self autorelease];
#endif
}

-(void) requestFailed:(ASIHTTPRequest*) request
{
	[stateLock lock];
	[super requestFailed:request];
	[stateLock unlock];
}

@end
