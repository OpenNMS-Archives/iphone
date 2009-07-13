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

static NSURL* getUrl(NSString* path)
{
	NSString* u = [NSString stringWithFormat:@"%@://%@:%@@%@:%@%@%@",
				   [[NSUserDefaults standardUserDefaults] boolForKey:@"https_preference"]? @"https" : @"http",
				   [[NSUserDefaults standardUserDefaults] stringForKey:@"user_preference"],
				   [[NSUserDefaults standardUserDefaults] stringForKey:@"password_preference"],
				   [[NSUserDefaults standardUserDefaults] stringForKey:@"host_preference"],
				   [[NSUserDefaults standardUserDefaults] stringForKey:@"port_preference"],
				   [[NSUserDefaults standardUserDefaults] stringForKey:@"rest_preference"],
				   path
				   ];
	return [NSURL URLWithString:u];
}

- (OnmsNode*) getNode:(int) nodeId
{
	NodeParser* nodeParser = [[NodeParser alloc] init];
	NSNumber* key = [NSNumber numberWithInt:nodeId];
	OnmsNode* node = [nodes objectForKey:key];
	if (!node) {
		NSURL* nodeUrl = getUrl([NSString stringWithFormat:@"/nodes/%i", nodeId]);
		NSLog(@"fetching un-cached node ID %i from %@", nodeId, nodeUrl);
		ASIHTTPRequest* request = [[[ASIHTTPRequest alloc] initWithURL: nodeUrl] autorelease];
		[request start];
		NSError* error = [request error];
		if (error) {
			NSLog(@"An error occurred making the node request (%@): %@", nodeUrl, error);
			return nil;
		} else {
			NSString* response = [request responseString];
			error = [NSError alloc];
			DDXMLDocument* document = [[DDXMLDocument alloc] initWithXMLString: response options: 0 error: &error];
			if (!document) {
				NSLog(@"An error occurred parsing the outage document: %@", error);
				return nil;
			} else {
				DDXMLElement* rootNode = [document rootElement];
				[nodeParser parse:rootNode];
				node = [nodeParser node];
				if (node != nil) {
					[nodes setObject:node forKey:[NSNumber numberWithInt:nodeId]];
				}
			}
		}
	}
	return node;
}

- (NSArray*) getOutages
{
	OutageParser* outageParser = [[OutageParser alloc] init];
	NSURL* outageUrl = getUrl(@"/outages?limit=20&orderBy=ifLostService&order=desc&ifRegainedService=null");
	ASIHTTPRequest* request = [[[ASIHTTPRequest alloc] initWithURL: outageUrl] autorelease];
	[request start];
	NSError* error = [request error];
	if (error) {
		NSLog(@"An error occurred making the outage request (%@): %@", outageUrl, error);
		return nil;
	} else {
		NSString* response = [request responseString];
		error = [NSError alloc];
		DDXMLDocument* document = [[DDXMLDocument alloc] initWithXMLString: response options: 0 error: &error];
		if (!document) {
			NSLog(@"An error occurred parsing the outage document: %@", error);
			return nil;
		} else {
			DDXMLElement* rootNode = [document rootElement];
			[outageParser parse:rootNode skipRegained:true];
			return [outageParser outages];
		}
	}
	return nil;
}

@end
