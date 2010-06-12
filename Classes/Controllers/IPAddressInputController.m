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
#import "IPAddressInputController.h"
#import "BaseUpdater.h"

@implementation IPAddressInputController

@synthesize baseView;
@synthesize label;
@synthesize ipAddress;
@synthesize addButton;
@synthesize cancelButton;

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[ipAddress becomeFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.baseView = nil;
	self.label = nil;
    self.ipAddress = nil;
    self.addButton = nil;
    self.cancelButton = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [ipAddress resignFirstResponder];
    }
}

- (IBAction)addClicked:(id)sender
{
#if DEBUG
    NSLog(@"%@: addClicked called, IP Address = %@", self, ipAddress);
#endif
    NSString* formData = [NSString stringWithFormat:@"ipAddress=%@", ipAddress.text];
    NSData* postData = [formData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString* postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSURL* baseUrl = [NSURL URLWithString:[BaseUpdater getBaseUrl]];
    [request setURL:[NSURL URLWithString:@"admin/addNewInterface" relativeToURL:baseUrl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSHTTPURLResponse* response = nil;
    NSError* error = nil;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString* stringResponseData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
#if DEBUG
    NSLog(@"%@: Sent request %@, received response %@, with error %@", self, request, response, error);
    NSLog(@"%@: headers = %@", self, [response allHeaderFields]);
    NSLog(@"%@: data = %@", self, stringResponseData);
#endif
    if (error) {
        UIAlertView *a = [[UIAlertView alloc]
                          initWithTitle: [error localizedDescription]
                          message: [error localizedFailureReason]
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        [a show];
        [a autorelease];
    }
    [stringResponseData release];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelClicked:(id)sender
{
    NSLog(@"%@: cancel clicked", self);
	[self dismissModalViewControllerAnimated:YES];
}

@end
