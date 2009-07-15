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


#import "OpenNMSRestAgent.h"
#import "ASIHTTPRequest.h"
#import "OutageParser.h"
#import "OnmsOutage.h"
#import "NodeParser.h"
#import "OnmsNode.h"
#import "IpInterfaceParser.h"
#import "OnmsIpInterface.h"

@implementation OpenNMSRestAgent

@class ViewOutage;

- (void) initialize
{
	nodes = [[NSMutableDictionary alloc] init];
}

- (void) dealloc
{
	[super dealloc];
}

- (OnmsNode*) getNode:(NSNumber*)nodeId
{
	NodeParser* nodeParser = [[NodeParser alloc] init];
	OnmsNode* node = [nodes objectForKey:nodeId];
	if (!node) {
		DDXMLDocument* document = [self doRequest: [NSString stringWithFormat:@"/nodes/%@", [nodeId stringValue]]];
		if (document) {
			DDXMLElement* rootNode = [document rootElement];
			[nodeParser parse:rootNode];
			node = [nodeParser node];
			if (node != nil) {
				[nodes setObject:node forKey:nodeId];
			}
		}
	}
	[nodeParser release];
	return node;
}

- (NSArray*) getViewOutages
{
	return [self getViewOutagesForNode:nil];
}

- (NSArray*) getViewOutagesForNode:(NSNumber*)nodeId
{
	OutageParser* outageParser = [[OutageParser alloc] init];
	NSArray* viewOutages = nil;
	DDXMLDocument* document;
	if (nodeId == nil) {
		document = [self doRequest: @"/outages?limit=0&orderBy=ifLostService&order=desc&ifRegainedService=null"];
	} else {
		document = [self doRequest: [NSString stringWithFormat:@"/outages/forNode/%@?limit=0&orderBy=ifLostService&order=desc", nodeId]];
	}
	if (document) {
		DDXMLElement* rootNode = [document rootElement];
		
		viewOutages = [outageParser getViewOutages:rootNode distinctNodes:true];
		
		for (int i = 0; i < [viewOutages count]; i++) {
			ViewOutage* vo = [viewOutages objectAtIndex:i];
			if (vo.nodeId != 0) {
				OnmsNode* node = [self getNode:vo.nodeId];
				if (node) {
					vo.nodeLabel = node.label;
				}
			}
		}
	}
	[outageParser release];
	[document release];
	return viewOutages;
}

- (NSArray*) getIpInterfaces:(NSNumber*)nodeId
{
	IpInterfaceParser* interfaceParser = [[IpInterfaceParser alloc] init];
	NSArray* interfaces = nil;
	DDXMLDocument* document;
	document = [self doRequest: [NSString stringWithFormat:@"/nodes/%@/ipinterfaces", nodeId]];
	if (document) {
		DDXMLElement* rootNode = [document rootElement];
		[interfaceParser parse:rootNode];
		interfaces = [[interfaceParser interfaces] copy];
	} else {
		interfaces = [[NSArray alloc] init];
	}
	[interfaceParser release];
	[document release];
	return interfaces;
}

- (NSArray*) getOutages
{
	return [self getOutagesForNode:nil];
}

- (NSArray*) getOutagesForNode:(NSNumber*)nodeId
{
	OutageParser* outageParser = [[OutageParser alloc] init];
	NSArray* outages = nil;
	DDXMLDocument* document;
	if (nodeId == nil) {
		document = [self doRequest: @"/outages?limit=0&orderBy=ifLostService&order=desc&ifRegainedService=null"];
	} else {
		document = [self doRequest: [NSString stringWithFormat:@"/outages/forNode/%@?limit=0&orderBy=ifLostService&order=desc", nodeId]];
	}
	if (document) {
		DDXMLElement* rootNode = [document rootElement];
		[outageParser parse:rootNode skipRegained:true];
		outages = [[outageParser outages] copy];
	} else {
		outages = [[NSArray alloc] init];
	}
	[outageParser release];
	[document release];
	return outages;
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

	NSLog(@"requesting %@", url);
	ASIHTTPRequest* request = [[[ASIHTTPRequest alloc] initWithURL: [NSURL URLWithString:url]] autorelease];
	[request start];
	NSError* error = [request error];
	if (error) {
		[self doError:error message:url];
		return nil;
	} else {
		NSString* response = [request responseString];
		error = [NSError alloc];
		DDXMLDocument* document = [[DDXMLDocument alloc] initWithXMLString: response options: 0 error: &error];
		if (!document) {
			[self doError:error message:@"An error occurred parsing the XML document"];
			return nil;
		} else {
			return document;
		}
	}
	return nil;
}

-(void) doError:(NSError*)error message:(NSString*)extra
{
	NSString* errorMessage;
	if (extra) {
		errorMessage = [NSString stringWithFormat:@"Error: %@: %@", [error localizedDescription], extra];
	} else {
		errorMessage = [NSString stringWithFormat:@"Error: %@", [error localizedDescription]];
	}
	NSLog(errorMessage);
	UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Error"
		message:errorMessage
		delegate:self
		cancelButtonTitle:@"OK"
		otherButtonTitles:nil
	];
	[errorView show];
	[errorView release];
	[errorMessage release];
}

@end
