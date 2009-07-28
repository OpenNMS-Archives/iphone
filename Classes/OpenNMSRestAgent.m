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
#import "EventParser.h"
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
		nodes = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) doError:(NSError*)error message:(NSString*)extra
{
	if (extra) {
		NSLog(@"Error: %@: %@", [error localizedDescription], extra);
	} else {
		NSLog(@"Error: %@", [error localizedDescription]);
	}
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

	NSLog(@"%@: requesting %@", caller, url);
	ASIHTTPRequest* request = [[[ASIHTTPRequest alloc] initWithURL: [NSURL URLWithString:url]] autorelease];
	[request start];
	NSError* error = [request error];
	if (error) {
		[self doError:error message:url];
		return nil;
	} else {
		NSString* response = [request responseString];
		error = [NSError alloc];
		CXMLDocument* document = [[[CXMLDocument alloc] initWithXMLString: response options: 0 error: &error] autorelease];
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
	OnmsNode* node = nil;
	if (nodeId) {
		NodeParser* nodeParser = [[NodeParser alloc] init];
		node = [nodes objectForKey:nodeId];
		if (!node) {
			CXMLDocument* document = [self doRequest: [NSString stringWithFormat:@"/nodes/%@", nodeId] caller: @"getNode"];
			if (document) {
				[document retain];
				NSArray* parsedNodes = [nodeParser parse:[document rootElement]];
				[document release];
				node = [parsedNodes objectAtIndex:0];
				if (node != nil) {
					[nodes setObject:node forKey:nodeId];
				}
			}
		}
		[nodeParser release];
	}
	return node;
}

-(NSArray*) getNodesForSearch:(NSString*)searchText
{
	NSArray* foundNodes = [NSArray array];
	if (searchText) {
		NodeParser* nodeParser = [[NodeParser alloc] init];
		CXMLDocument* document = [self doRequest: [NSString stringWithFormat:@"/nodes?comparator=contains&match=any&label=%@&ipInterface.ipAddress=%@", searchText, searchText] caller: @"getNodesForSearch"];
		if (document) {
			foundNodes = [nodeParser parse:[document rootElement]];
		}
		[nodeParser release];
	}
	return foundNodes;
}

- (NSArray*) getEvents:(NSNumber*)nodeId limit:(NSNumber*)limit
{
	NSArray* events = [NSArray array];
	EventParser* eventParser = [[EventParser alloc] init];
	CXMLDocument* document = nil;
	if (limit == nil) {
		limit = [NSNumber numberWithInt:GET_LIMIT];
	}
	if (nodeId) {
		document = [self doRequest: [NSString stringWithFormat:@"/events?limit=%@&node.id=%@", limit, nodeId] caller: @"getEvents"];
	} else {
		document = [self doRequest: [NSString stringWithFormat:@"/events?limit=%@", limit] caller: @"getEvents"];
	}
	if (document) {
		events = [eventParser parse:[document rootElement]];
	}
	[eventParser release];
	return events;
}

- (NSArray*) getAlarms
{
	NSArray* alarms = [NSArray array];
	AlarmParser* alarmParser = [[AlarmParser alloc] init];
	CXMLDocument* document = [self doRequest: [NSString stringWithFormat:@"/alarms?limit=%d&orderBy=lastEventTime&order=desc", GET_LIMIT] caller: @"getAlarms"];
	if (document) {
		alarms = [alarmParser parse:[document rootElement]];
	}
	[alarmParser release];
	return alarms;
}

- (NSArray*) getOutages:(NSNumber*)nodeId
{
	NSArray* outages = [NSArray array];
	OutageParser* outageParser = [[OutageParser alloc] init];
	CXMLDocument* document;
	if (nodeId) {
		document = [self doRequest: [NSString stringWithFormat:@"/outages/forNode/%@?limit=%d&orderBy=ifLostService&order=desc", nodeId, GET_LIMIT] caller: @"getOutages with nodeId"];
	} else {
		document = [self doRequest: [NSString stringWithFormat:@"/outages?limit=%d&orderBy=ifLostService&order=desc&ifRegainedService=null", GET_LIMIT] caller: @"getOutages without nodeId"];
	}
	if (document) {
		outages = [outageParser parse:[document rootElement] skipRegained:YES];
	}
	[outageParser release];
	return outages;
}

- (NSArray*) getViewOutages:(NSNumber*)nodeId distinct:(BOOL)distinct mini:(BOOL)doMini
{
	NSArray* viewOutages = [NSArray array];
	OutageParser* outageParser = [[OutageParser alloc] init];
	CXMLDocument* document;
	if (nodeId) {
		document = [self doRequest: [NSString stringWithFormat:@"/outages/forNode/%@?limit=%d&orderBy=ifLostService&order=desc", nodeId, GET_LIMIT] caller: @"getViewOutages with nodeId"];
	} else {
		document = [self doRequest: [NSString stringWithFormat:@"/outages?limit=%d&orderBy=ifLostService&order=desc&ifRegainedService=null", GET_LIMIT] caller: @"getViewOutages without nodeId"];
	}
	if (document) {
		viewOutages = [outageParser getViewOutages:[document rootElement] distinctNodes:distinct mini:doMini];
		
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
	return viewOutages;
}

- (NSArray*) getIpInterfaces:(NSNumber*)nodeId
{
	NSArray* interfaces = [NSArray array];
	if (nodeId) {
		IpInterfaceParser* interfaceParser = [[IpInterfaceParser alloc] init];
		CXMLDocument* document;
		document = [self doRequest: [NSString stringWithFormat:@"/nodes/%@/ipinterfaces?limit=%d", nodeId, GET_LIMIT] caller: @"getIpInterfaces"];
		if (document) {
			interfaces = [interfaceParser parse:[document rootElement]];
		}
		[interfaceParser release];
	}
	return interfaces;
}

- (NSArray*) getSnmpInterfaces:(NSNumber*)nodeId
{
	NSArray* interfaces = [NSArray array];
	if (nodeId) {
		SnmpInterfaceParser* interfaceParser = [[SnmpInterfaceParser alloc] init];
		CXMLDocument* document;
		document = [self doRequest: [NSString stringWithFormat:@"/nodes/%@/snmpinterfaces?limit=%d&orderBy=ifIndex&order=asc", nodeId, GET_LIMIT] caller: @"getSnmpInterfaces"];
		if (document) {
			interfaces = [interfaceParser parse:[document rootElement]];
		}
		[interfaceParser release];
	}
	return interfaces;
}


@end
