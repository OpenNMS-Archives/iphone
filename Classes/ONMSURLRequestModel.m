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

#import "ONMSURLRequestModel.h"
#import "SettingsModel.h"

@implementation ONMSURLRequestModel

- (id)init
{
  if (self = [super init]) {
    _inProgress = NO;
  }
  return self;
}

+ (NSString*)getURL:(NSString*)path
{
  SettingsModel* settings = [[SettingsModel alloc] init];
  [settings load];
  NSString* url = [[settings url] stringByAppendingString:path];
  [settings release];
  return url;
}

- (NSString*)stringWithUTF8String:(NSString*)string
{
  // Not all UTF8 characters are valid XML.
  // See:
  // http://www.w3.org/TR/2000/REC-xml-20001006#NT-Char
  // (Also see: http://cse-mjmcl.cse.bris.ac.uk/blog/2007/02/14/1171465494443.html )
  //
  // The ranges of unicode characters allowed, as specified above, are:
  // Char ::= #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF] /* any Unicode character, excluding the surrogate blocks, FFFE, and FFFF. */
  //
  // To ensure the string is valid for XML encoding, we therefore need to remove any characters that
  // do not fall within the above ranges.
  
  // First create a character set containing all invalid XML characters.
  // Create this once and leave it in memory so that we can reuse it rather
  // than recreate it every time we need it.
  static NSCharacterSet *invalidXMLCharacterSet = nil;
  
  if (invalidXMLCharacterSet == nil)
  {
    // First, create a character set containing all valid UTF8 characters.
    NSMutableCharacterSet *XMLCharacterSet = [[NSMutableCharacterSet alloc] init];
    [XMLCharacterSet addCharactersInRange:NSMakeRange(0x9, 1)];
    [XMLCharacterSet addCharactersInRange:NSMakeRange(0xA, 1)];
    [XMLCharacterSet addCharactersInRange:NSMakeRange(0xD, 1)];
    [XMLCharacterSet addCharactersInRange:NSMakeRange(0x20, 0xD7FF - 0x20)];
    [XMLCharacterSet addCharactersInRange:NSMakeRange(0xE000, 0xFFFD - 0xE000)];
    [XMLCharacterSet addCharactersInRange:NSMakeRange(0x10000, 0x10FFFF - 0x10000)];
    
    // Then create and retain an inverted set, which will thus contain all invalid XML characters.
    invalidXMLCharacterSet = [[XMLCharacterSet invertedSet] retain];
    [XMLCharacterSet release];
  }

  return [[string componentsSeparatedByCharactersInSet:invalidXMLCharacterSet] componentsJoinedByString:@""];
}

- (NSString*)stringWithUTF8Data:(NSData*)data
{
  return [[[NSString alloc] initWithData:[NSData dataWithBytes:[data bytes] length:[data length]] encoding:NSUTF8StringEncoding] autorelease];
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

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
  TTDINFO(@"requestDidFinishLoad:%@", request);
  _inProgress = NO;
  [super requestDidFinishLoad:request];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
  TTDINFO(@"request:%@ didFailLoadWithError:%@", request, [error localizedDescription]);
  _inProgress = NO;
  UIAlertView* alert;
  if ([error code] == -1012) {
	alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Authentication Failed"
													  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
  } else {
	alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:[@"An error occurred making the request: " stringByAppendingString:[error localizedDescription]]
													  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
  }
  [alert show];
  [super request:request didFailLoadWithError:error];
}

@end
