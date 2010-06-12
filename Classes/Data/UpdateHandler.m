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

#import "UpdateHandler.h"
#import "RegexKitLite.h"
#import "OpenNMSAppDelegate.h"

@implementation UpdateHandler

@synthesize spinner;
@synthesize contextService;
@synthesize context;
@synthesize method;
@synthesize methodTarget;
@synthesize clearOldObjects;

-(id) init
{
	if (self = [super init]) {
		self.spinner = nil;
		self.contextService = [[ContextService alloc] init];
		self.clearOldObjects = NO;
	}
	return self;
}

-(id) initWithContext:(NSManagedObjectContext*)c
{
    if (self = [super init]) {
        self.context = c;
    }
    return self;
}

-(id) initWithMethod:(SEL)selector target:(NSObject*)target
{
	if (self = [super init]) {
		self.spinner = nil;
		self.contextService = [[ContextService alloc] init];
		self.method = selector;
		self.methodTarget = target;
		self.clearOldObjects = NO;
		self.context = [self.contextService managedObjectContext];
	}
	return self;
}

-(id) initWithMethod:(SEL)selector target:(NSObject*)target context:(NSManagedObjectContext*)c
{
	if (self = [super init]) {
		self.spinner = nil;
		self.contextService = [[ContextService alloc] init];
		self.method = selector;
		self.methodTarget = target;
		self.clearOldObjects = NO;
		self.context = c;
	}
	return self;
}

-(void) dealloc
{
	[self.spinner release];
	[self.contextService release];
	[self.context release];
	[self.methodTarget release];

	[super dealloc];
}


-(NSString *) cleanUpString:(NSString *)html
{
	NSMutableString* string = [NSMutableString stringWithString:html];
	
	[string replaceOccurrencesOfRegex:@"^\\s*(.*?)\\s*$" withString:@"$1"];
	[string replaceOccurrencesOfRegex:@"<[^>]*>" withString:@""];
	
	return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString*) stringForDate:(NSString*)date
{
	NSMutableString* string = [NSMutableString stringWithString:date];
	[string replaceOccurrencesOfRegex:@"(\\d\\d:\\d\\d:\\d\\d)\\.\\d\\d\\d" withString:@"$1"];
    [string replaceOccurrencesOfRegex:@"-(\\d\\d):(\\d\\d)$" withString:@"-$1$2"];
	return string;
}


-(CXMLDocument*) getDocumentForRequest:(ASIHTTPRequest*) request
{
	NSString* response = [request responseString];
#if DEBUG
	// NSLog(@"response = %@", response);
#endif
	if (!response || [response isEqual:@""]) {
		return nil;
	}

	NSError* error = nil;
	CXMLDocument* document = [[[CXMLDocument alloc] initWithXMLString: response options: 0 error: &error] autorelease];
	if (!document) {
		NSString* title;
		NSString* message;
		if (error) {
			title = [error localizedDescription];
			message = [error localizedFailureReason];
		} else {
			title = @"XML Parse Error";
			message = @"An error occurred parsing the document.";
		}
		
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle: title
								   message: message
								   delegate:self
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert autorelease];
		
		[self autorelease];
		return nil;
	}
	return document;
}

-(void) requestDidFinish:(ASIHTTPRequest*) request
{
#if DEBUG
	NSLog(@"%@: Request finished.", self);
#endif
	if (self.methodTarget && self.method) {
		[self.methodTarget performSelector:self.method];
	}
	[self.spinner stopAnimating];
}

-(void) requestFailed:(ASIHTTPRequest*) request
{
	NSError* error = [request error];
	NSLog(@"%@: Request failed: %@", self, [error localizedDescription]);
	if (methodTarget && method) {
		[methodTarget performSelector:method];
	}
	[self.spinner stopAnimating];

	BOOL settingsActive = ((OpenNMSAppDelegate*)[UIApplication sharedApplication].delegate).settingsActive;
	if (!settingsActive) {
		UIAlertView *errorAlert = [[UIAlertView alloc]
			initWithTitle: [error localizedDescription]
			message: [error localizedFailureReason]
			delegate:self
			cancelButtonTitle:@"OK"
			otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert autorelease];
	}
}

@end
