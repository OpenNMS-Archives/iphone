/*******************************************************************************
 * This file is part of the OpenNMS(R) Application.
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


#import "OpenNMSRestAgent.h"
#import "DDXMLDocument.h"
#import "OutageParser.h"
#import "OnmsOutage.h"
#import <stdio.h>

@implementation OpenNMSRestAgent

@class ViewOutage;

static NSDateFormatter* dateFormatter;
static NSMutableDictionary* nodes;

- (id) init
{
	if (self = [super init]) {
		if (!dateFormatter) {
			dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
		}
		if (!nodes) {
			nodes = [[NSMutableDictionary alloc] init];
		}
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (OnmsNode*) getNode:(int) nodeId
{
	NodeParser* nodeParser = [[NodeParser alloc] init];
	NSNumber* key = [NSNumber numberWithInt:nodeId];
	OnmsNode* node = [nodes objectForKey:key];
	if (!node) {
		NSLog(@"fetching un-cached node ID %i", nodeId);
		DDXMLDocument* document = [self doRequest: [NSString stringWithFormat:@"/nodes/%i", nodeId]];
		if (document) {
			DDXMLElement* rootNode = [document rootElement];
			[nodeParser parse:rootNode];
			node = [nodeParser node];
			if (node != nil) {
				[nodes setObject:node forKey:[NSNumber numberWithInt:nodeId]];
			}
		}
	}
	return node;
}

- (NSArray*) getViewOutages
{
	OutageParser* outageParser = [[OutageParser alloc] init];
	DDXMLDocument* document = [self doRequest: @"/outages?limit=20&orderBy=ifLostService&order=desc&ifRegainedService=null"];
	if (document) {
		DDXMLElement* rootNode = [document rootElement];

		NSArray* viewOutages = [outageParser getViewOutages:rootNode distinctNodes:true];

		for (int i = 0; i < [viewOutages count]; i++) {
			ViewOutage* vo = [viewOutages objectAtIndex:i];
			if (vo.nodeId != 0) {
				OnmsNode* node = [self getNode:vo.nodeId];
				if (node) {
					vo.nodeLabel = node.label;
				}
			}
		}
		return viewOutages;
	} else {
		return nil;
	}
}

- (NSArray*) getOutages
{
	OutageParser* outageParser = [[OutageParser alloc] init];
	DDXMLDocument* document = [self doRequest: @"/outages?limit=20&orderBy=ifLostService&order=desc&ifRegainedService=null"];
	if (document) {
		DDXMLElement* rootNode = [document rootElement];
		[outageParser parse:rootNode skipRegained:true];
		return [outageParser outages];
	} else {
		return nil;
	}
}

- (DDXMLDocument*) doRequest: (NSString*) path
{
	NSString* url = [NSString stringWithFormat:@"%@://%@:%@@%@:%@%@%@",
		[[NSUserDefaults standardUserDefaults] boolForKey:@"https_preference"]? @"https" : @"http",
		[[NSUserDefaults standardUserDefaults] stringForKey:@"user_preference"],
		[[NSUserDefaults standardUserDefaults] stringForKey:@"password_preference"],
		[[NSUserDefaults standardUserDefaults] stringForKey:@"host_preference"],
		[[NSUserDefaults standardUserDefaults] stringForKey:@"port_preference"],
		[[NSUserDefaults standardUserDefaults] stringForKey:@"rest_preference"],
		path
	];

	ASIHTTPRequest* request = [[[ASIHTTPRequest alloc] initWithURL: [NSURL URLWithString:url]] autorelease];
	[request start];
	NSError* error = [request error];
	if (error) {
		NSLog(@"An error occurred making the request (%@): %@", url, error);
		return nil;
	} else {
		NSString* response = [request responseString];
		error = [NSError alloc];
		DDXMLDocument* document = [[DDXMLDocument alloc] initWithXMLString: response options: 0 error: &error];
		if (!document) {
			NSLog(@"An error occurred parsing the XML document: %@", error);
			return nil;
		} else {
			return document;
		}
	}
	return nil;
}

@end
