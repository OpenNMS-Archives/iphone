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

#import "BaseUpdater.h"
#import "UpdateHandler.h"
#import "RegexKitLite.h"

@implementation BaseUpdater

@synthesize url;
@synthesize queue;
@synthesize handler;

-(id) initWithPath:(NSString*)p
{
	if (self = [super init]) {
		queue = [[ASINetworkQueue alloc] init];
		url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self getBaseUrl], p]];
	}
#if DEBUG
	NSLog(@"%@: Initialized using URL: %@", self, url);
#endif
	return self;
}

-(void) dealloc
{
	[url release];
	[queue release];
	
	[super dealloc];
}

-(NSString*) filterDate:(NSString*)date
{
	NSMutableString* string = [NSMutableString stringWithString:date];
	[string replaceOccurrencesOfRegex:@"(\\d\\d:\\d\\d:\\d\\d)\\.\\d\\d\\d" withString:@"$1"];
	return string;
}

-(NSString*) getBaseUrl
{
	NSString* https = [[NSUserDefaults standardUserDefaults] boolForKey:@"https_preference"]? @"https" : @"http";
	NSString* username = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_preference"];
	NSString* password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password_preference"];
	NSString* host = [[NSUserDefaults standardUserDefaults] stringForKey:@"host_preference"];
	NSString* port = [[NSUserDefaults standardUserDefaults] stringForKey:@"port_preference"];
	NSString* path = [[NSUserDefaults standardUserDefaults] stringForKey:@"rest_preference"];
	
	if (username == nil) {
		username = @"admin";
	}
	if (password == nil) {
		password = @"admin";
	}
	if (host == nil) {
		host = @"localhost";
	}
	if (port == nil) {
		port = @"8980";
	}
	if (path == nil) {
		path = @"/opennms/rest";
	}

	return [NSString stringWithFormat:@"%@://%@:%@@%@:%@%@", https, username, password, host, port, path ];
}

-(void) update
{
#if DEBUG
	NSLog(@"%@: Update called.", self);
#endif
	NSURL* requestUrl = [url copy];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:requestUrl] autorelease];
	if (!handler) {
		handler = [[[UpdateHandler alloc] init] autorelease];
	}

	request.timeOutSeconds = 5;
	if ([[requestUrl scheme] isEqual:@"https"]) {
		request.validatesSecureCertificate = NO;
	}
	request.delegate = handler;
	request.didFinishSelector = @selector(requestDidFinish:);
	request.didFailSelector = @selector(requestFailed:);

	[[self queue] addOperation:request];
	[[self queue] setSuspended:NO];
}

@end
