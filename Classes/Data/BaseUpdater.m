/*******************************************************************************
 * This file is part of the OpenNMS(R) iPhone Application.
 * OpenNMS(R) is a registered trademark of The OpenNMS Group, Inc.
 *
 * Copyright (C) 2010 The OpenNMS Group, Inc.  All rights reserved.
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
#import "BaseUpdater.h"
#import "UpdateHandler.h"

@implementation BaseUpdater

@synthesize url;
@synthesize queue;
@synthesize handler;
@synthesize requestData;
@synthesize requestMethod;

-(id) initWithPath:(NSString*)p
{
	if (self = [super init]) {
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
		url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BaseUpdater getBaseUrl], p]];
#if DEBUG
        NSLog(@"%@: Initialized using URL: %@", self, url);
#endif
	}
	return self;
}

-(void) dealloc
{
	[url release];
    [queue release];
	
	[super dealloc];
}

+(NSString*) getBaseUrl
{
	NSString* https = [[NSUserDefaults standardUserDefaults] boolForKey:@"https_preference"]? @"https" : @"http";
	NSString* host = [[NSUserDefaults standardUserDefaults] stringForKey:@"host_preference"];
	NSString* port = [[NSUserDefaults standardUserDefaults] stringForKey:@"port_preference"];
	NSString* path = [[NSUserDefaults standardUserDefaults] stringForKey:@"rest_preference"];
	
	if (host == nil) {
		host = @"localhost";
	}
	if (port == nil) {
		port = @"8980";
	}
	if (path == nil) {
		path = @"/opennms/rest";
	}

//	return [NSString stringWithFormat:@"%@://%@:%@@%@:%@%@", https, username, password, host, port, path ];
	return [NSString stringWithFormat:@"%@://%@:%@%@", https, host, port, path ];
}

-(void) update
{
#if DEBUG
	NSLog(@"%@: Update called.", self);
#endif
	NSString* host = [[NSUserDefaults standardUserDefaults] stringForKey:@"host_preference"];
	if (host == nil || host == @"localhost") {
#if DEBUG
		NSLog(@"%@: Host is unconfigured or set to localhost, skipping update.", self);
#endif
		return;
	}

	NSURL* requestUrl = [url copy];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:requestUrl] autorelease];
    [request setUsername:[[NSUserDefaults standardUserDefaults] stringForKey:@"user_preference"]];
    [request setPassword:[[NSUserDefaults standardUserDefaults] stringForKey:@"password_preference"]];
	if (self.requestData) {
		[request appendPostData:self.requestData];
	}
	if (self.requestMethod) {
		[request setRequestMethod:self.requestMethod];
	}
	if (!self.handler) {
		NSLog(@"WARNING: creating a default handler");
		self.handler = [[[UpdateHandler alloc] init] autorelease];
	}

#if DEBUG
	NSLog(@"handler = %@", self.handler);
#endif

	request.timeOutSeconds = 5;
	if ([[requestUrl scheme] isEqual:@"https"]) {
		request.validatesSecureCertificate = NO;
	}
	request.delegate = self.handler;
	request.didFinishSelector = @selector(requestDidFinish:);
	request.didFailSelector = @selector(requestFailed:);

#if DEBUG
    NSLog(@"queue = %@", queue);
#endif
    [queue addOperation:request];
    [queue setSuspended:NO];
#if DEBUG
	NSLog(@"%@: finished.", self);
#endif
}

@end
