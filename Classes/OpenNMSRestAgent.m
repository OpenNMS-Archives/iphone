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

#import "NodeParser.h"
#import "IpInterfaceParser.h"
#import "SnmpInterfaceParser.h"
#import "AlarmParser.h"
#import "OutageParser.h"

#import "OnmsIpInterface.h"
#import "OnmsNode.h"
#import "OnmsOutage.h"
#import "ViewOutage.h"

#define GET_LIMIT 100

@implementation OpenNMSRestAgent

- (id) init
{
	if (self = [super init]) {
		nodes = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) doError:(NSError*)error message:(NSString*)extra
{
	NSString* errorMessage;
	if (extra) {
		errorMessage = [[NSString stringWithFormat:@"Error: %@: %@", [error localizedDescription], extra] autorelease];
	} else {
		errorMessage = [[NSString stringWithFormat:@"Error: %@", [error localizedDescription]] autorelease];
	}
	NSLog(errorMessage);
}

- (CXMLDocument*) doRequest: (NSString*) path caller: (NSString*) caller
{
	// NSLog(@"requesting path %@: (%@)", path, caller);
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
		[self doError:error message:url];
		return nil;
	} else {
		NSString* response = [[request responseString] copy];
		error = [NSError alloc];
		CXMLDocument* document = [[CXMLDocument alloc] initWithXMLString: response options: 0 error: &error];
		if (!document) {
			[self doError:error message:@"An error occurred parsing the XML document"];
			return nil;
		} else {
			return document;
		}
	}
	return nil;
}

- (OnmsNode*) getNode:(NSNumber*)nodeId
{
	NodeParser* nodeParser = [[NodeParser alloc] init];
	OnmsNode* node = [nodes objectForKey:nodeId];
	if (!node) {
		CXMLDocument* document = [self doRequest: [NSString stringWithFormat:@"/nodes/%@", [nodeId stringValue]] caller: @"getNode"];
		if (document) {
			CXMLElement* rootNode = [document rootElement];
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

-(NSArray*) getNodesForSearch:(NSString*)searchText
{
	NSArray* foundNodes = nil;
	NodeParser* nodeParser = [[NodeParser alloc] init];
	CXMLDocument* document = [self doRequest: [NSString stringWithFormat:@"/nodes?comparator=ilike&match=any&label=%@&ipInterface.ipAddress=%@", searchText, searchText] caller: @"getNodesForSearch"];
	if (document) {
		CXMLElement* rootNode = [document rootElement];
		[nodeParser parse:rootNode];
		foundNodes = [nodeParser nodes];
	} else {
		foundNodes = [[NSArray alloc] init];
	}
	[nodeParser release];
	[document release];
	return foundNodes;
}

- (NSArray*) getAlarms
{
	AlarmParser* alarmParser = [[AlarmParser alloc] init];
	NSArray* alarms = nil;
	CXMLDocument* document = [self doRequest: [NSString stringWithFormat:@"/alarms?limit=%d&orderBy=lastEventTime&order=desc", GET_LIMIT] caller: @"getAlarms"];
	if (document) {
		CXMLElement* rootNode = [document rootElement];
		[alarmParser parse:rootNode];
		alarms = [[alarmParser alarms] copy];
	} else {
		alarms = [[NSArray alloc] init];
	}
	[alarmParser release];
	[document release];
	return alarms;
}

- (NSArray*) getOutages:(NSNumber*)nodeId
{
	OutageParser* outageParser = [[OutageParser alloc] init];
	NSArray* outages = nil;
	CXMLDocument* document;
	if (nodeId == nil) {
		document = [self doRequest: [NSString stringWithFormat:@"/outages?limit=%d&orderBy=ifLostService&order=desc&ifRegainedService=null", GET_LIMIT] caller: @"getOutages without nodeId"];
	} else {
		document = [self doRequest: [NSString stringWithFormat:@"/outages/forNode/%@?limit=%d&orderBy=ifLostService&order=desc", nodeId, GET_LIMIT] caller: @"getOutages with nodeId"];
	}
	if (document) {
		CXMLElement* rootNode = [document rootElement];
		[outageParser parse:rootNode skipRegained:YES];
		outages = [[outageParser outages] copy];
	} else {
		outages = [[NSArray alloc] init];
	}
	[outageParser release];
	[document release];
	return outages;
}

- (NSArray*) getViewOutages:(NSNumber*)nodeId distinct:(BOOL)distinct
{
	OutageParser* outageParser = [[OutageParser alloc] init];
	NSArray* viewOutages = nil;
	CXMLDocument* document;
	if (nodeId == nil) {
		document = [self doRequest: [NSString stringWithFormat:@"/outages?limit=%d&orderBy=ifLostService&order=desc&ifRegainedService=null", GET_LIMIT] caller: @"getViewOutages without nodeId"];
	} else {
		document = [self doRequest: [NSString stringWithFormat:@"/outages/forNode/%@?limit=%d&orderBy=ifLostService&order=desc", nodeId, GET_LIMIT] caller: @"getViewOutages with nodeId"];
	}
	if (document) {
		CXMLElement* rootNode = [document rootElement];
		
		viewOutages = [outageParser getViewOutages:rootNode distinctNodes:distinct];
		
		for (int i = 0; i < [viewOutages count]; i++) {
			ViewOutage* vo = [viewOutages objectAtIndex:i];
			if (vo.nodeId != 0) {
				OnmsNode* node = [self getNode:vo.nodeId];
				if (node) {
					vo.nodeLabel = node.label;
				}
			}
		}
	} else {
		viewOutages = [[NSArray alloc] init];
	}
	[outageParser release];
	[document release];
	return viewOutages;
}

- (NSArray*) getIpInterfaces:(NSNumber*)nodeId
{
	IpInterfaceParser* interfaceParser = [[IpInterfaceParser alloc] init];
	NSArray* interfaces = nil;
	CXMLDocument* document;
	document = [self doRequest: [NSString stringWithFormat:@"/nodes/%@/ipinterfaces?limit=%d", nodeId, GET_LIMIT] caller: @"getIpInterfaces"];
	if (document) {
		CXMLElement* rootNode = [document rootElement];
		[interfaceParser parse:rootNode];
		interfaces = [[interfaceParser interfaces] copy];
	} else {
		interfaces = [[NSArray alloc] init];
	}
	[interfaceParser release];
	[document release];
	return interfaces;
}

- (NSArray*) getSnmpInterfaces:(NSNumber*)nodeId
{
	SnmpInterfaceParser* interfaceParser = [[SnmpInterfaceParser alloc] init];
	NSArray* interfaces = nil;
	CXMLDocument* document;
	document = [self doRequest: [NSString stringWithFormat:@"/nodes/%@/snmpinterfaces?limit=%d&orderBy=ifIndex&order=asc", nodeId, GET_LIMIT] caller: @"getSnmpInterfaces"];
	if (document) {
		CXMLElement* rootNode = [document rootElement];
		[interfaceParser parse:rootNode];
		interfaces = [[interfaceParser interfaces] copy];
	} else {
		interfaces = [[NSArray alloc] init];
	}
	[interfaceParser release];
	[document release];
	return interfaces;
}


@end
