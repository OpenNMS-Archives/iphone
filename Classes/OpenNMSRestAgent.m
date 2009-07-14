//
//  OpenNMSRestAgent.m
//  OpenNMS
//
//  Created by Benjamin Reed on 3/24/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

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
