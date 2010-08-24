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

#import "IPAddressInputController.h"
#import "IPAddressInputDataSource.h"
#import "ONMSURLRequestModel.h"
#import "RESTURLRequest.h"
#import "SettingsModel.h"

#import <CFNetwork/CFNetwork.h>
#import <netinet/in.h>
#import <netdb.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/ethernet.h>
#import <net/if_dl.h>

@implementation IPAddressInputController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    _inProgress = NO;
    self.title = @"Add Host";
    self.autoresizesForKeyboard = YES;
    self.variableHeightRows = NO;
    self.tableViewStyle = UITableViewStyleGrouped;
  }
  return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (void)cancelClicked
{
  [self dismissModalViewControllerAnimated:YES];
}

- (void)loadView
{
  [super loadView];
  
  self.navigationBarTintColor = TTSTYLEVAR(navigationBarTintColor);
  [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelClicked)] autorelease] animated:YES];
}

- (void)createModel
{
  IPAddressInputDataSource* ids = [[[IPAddressInputDataSource alloc] init] autorelease];
  ids.submitDelegate = self;
  self.dataSource = ids;
}

+ (NSArray *)addressesForHostname:(NSString *)hostname {
	// Get the addresses for the given hostname.
	CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (CFStringRef)hostname);
	BOOL isSuccess = CFHostStartInfoResolution(hostRef, kCFHostAddresses, nil);
	if (!isSuccess) return nil;
	CFArrayRef addressesRef = CFHostGetAddressing(hostRef, nil);
	if (addressesRef == nil) return nil;
  
	// Convert these addresses into strings.
	char ipAddress[INET6_ADDRSTRLEN];
	NSMutableArray *addresses = [NSMutableArray array];
	CFIndex numAddresses = CFArrayGetCount(addressesRef);
	for (CFIndex currentIndex = 0; currentIndex < numAddresses; currentIndex++) {
		struct sockaddr *address = (struct sockaddr *)CFDataGetBytePtr(CFArrayGetValueAtIndex(addressesRef, currentIndex));
		if (address == nil) return nil;
		getnameinfo(address, address->sa_len, ipAddress, INET6_ADDRSTRLEN, nil, 0, NI_NUMERICHOST);
		if (ipAddress == nil) return nil;
		[addresses addObject:[NSString stringWithCString:ipAddress encoding:NSASCIIStringEncoding]];
	}
  
	return addresses;
}

+ (NSString *)addressForHostname:(NSString *)hostname {
	NSArray *addresses = [IPAddressInputController addressesForHostname:hostname];
	if ([addresses count] > 0)
		return [addresses objectAtIndex:0];
	else
		return nil;
}

- (void)submitAddress
{
  IPAddressInputDataSource* ds = self.dataSource;
  NSString* host = [ds getHost];
  NSScanner* scanner = [NSScanner scannerWithString:host];
  scanner.caseSensitive = NO;
  if ([scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:NULL]) {
    // it has characters, use NSHost to find the IP address
    host = [IPAddressInputController addressForHostname:host];
  }
  NSString* url = [[ONMSURLRequestModel getURL:@"/../admin/addNewInterface"] stringByAppendingFormat:@"?ipAddress=%@", host];

  RESTURLRequest* request = [RESTURLRequest requestWithURL:url delegate:self];
  request.cachePolicy = TTURLRequestCachePolicyNone;
  request.httpMethod = @"POST";
//  request.httpBody = [@"" dataUsingEncoding:NSUTF8StringEncoding];
  [request.parameters setValue:host forKey:@"ipAddress"];
  request.contentType = @"application/x-www-form-urlencoded";
  
  id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
  request.response = response;
  TT_RELEASE_SAFELY(response);
  
  [request send];
}

- (void)request:(TTURLRequest*)request didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
  if (_inProgress) {
    TTDINFO(@"got a 2nd auth challenge, password is wrong");
    [[challenge sender] cancelAuthenticationChallenge:challenge];
  } else {
    _inProgress = YES;
    SettingsModel* settings = [[SettingsModel alloc] init];
    [settings load];
    NSURLCredential *cred = [NSURLCredential credentialWithUser:settings.user
                                                       password:settings.password persistence:NSURLCredentialPersistenceForSession];
    [settings release];
    [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
  }
} 

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
  _inProgress = NO;
  [self.navigationItem setRightBarButtonItem:nil animated:YES];
  TTDWARNING(@"failed to add host %@: %@", request.urlPath, [error localizedDescription]);
  UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:[@"An error occurred adding the host: " stringByAppendingString:[error localizedDescription]]
                                                  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
  [alert show];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
  _inProgress = NO;
  [self dismissModalViewControllerAnimated:YES];
}

@end
