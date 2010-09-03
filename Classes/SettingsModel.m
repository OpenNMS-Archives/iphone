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

#import "SettingsModel.h"
#import "ONMSConstants.h"

@implementation SettingsModel

@synthesize https      = _https;
@synthesize host       = _host;
@synthesize port       = _port;
@synthesize path       = _path;
@synthesize user       = _user;
@synthesize password   = _password;

@synthesize isLoaded   = _isLoaded;
@synthesize isLoading  = _isLoading;
@synthesize isOutdated = _isOutdated;

- (id)init
{
  if (self = [super init]) {
    _isLoaded = NO;
    _isLoading = NO;
    _isOutdated = NO;
  }
  return self;
}

- (void)dealloc
{
  TT_RELEASE_SAFELY(_host);
  TT_RELEASE_SAFELY(_port);
  TT_RELEASE_SAFELY(_path);
  TT_RELEASE_SAFELY(_user);
  TT_RELEASE_SAFELY(_password);
  [super dealloc];
}

- (void)save
{
  NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
  [def setBool:_https forKey:@"https_preference"];
  [def setValue:_host forKey:@"host_preference"];
  [def setValue:_port forKey:@"port_preference"];
  [def setValue:_path forKey:@"rest_preference"];
  [def setValue:_user forKey:@"user_preference"];
  [def setValue:_password forKey:@"password_preference"];
  [def setValue:@"" forKey:kNodeSearchKey];
  [self invalidate:YES];
}

- (void)invalidate:(BOOL)erase
{
  _isOutdated = YES;
}

- (BOOL)isLoaded { return _isLoaded; }
- (BOOL)isLoading { return _isLoading; }
- (BOOL)isOutdated { return _isOutdated; }

- (void)load
{
  [self load:TTURLRequestCachePolicyNone more:NO];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
  [self didStartLoad];
  _isLoading = YES;
  
  NSString* plist = [[NSBundle mainBundle] pathForResource:@"Root" ofType:@"plist" inDirectory:@"Settings.bundle"];
  NSDictionary* plistData = [[NSDictionary dictionaryWithContentsOfFile:plist] retain];
  
  NSArray* specifiers = [plistData objectForKey:@"PreferenceSpecifiers"];
  
  for (id entry in specifiers) {
    NSDictionary* dict = entry;
    
    NSString* type = [dict valueForKey:@"Type"];
    if ([type isEqualToString:@"PSGroupSpecifier"]) {
      continue;
    }

    NSString* key = [dict valueForKey:@"Key"];
    id value = nil;
    if (key) {
      value = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    }
   if (!value) {
      value = [dict valueForKey:@"DefaultValue"];
    }

    if ([key isEqualToString:@"https_preference"]) {
      _https = [value boolValue];
    } else if ([key isEqualToString:@"host_preference"]) {
      _host = [value copy];
    } else if ([key isEqualToString:@"port_preference"]) {
      _port = [value copy];
    } else if ([key isEqualToString:@"rest_preference"]) {
      _path = [value copy];
    } else if ([key isEqualToString:@"user_preference"]) {
      _user = [value copy];
    } else if ([key isEqualToString:@"password_preference"]) {
      _password = [value copy];
    }
  }

  [plistData release];

  _isLoaded = YES;
  _isLoading = NO;
  _isOutdated = NO;
  
  [self didFinishLoad];
}

- (NSString*)url
{
  return [NSString stringWithFormat:@"%@://%@:%@%@", _https? @"https" : @"http", _host, _port, _path ];
}

- (NSString*)description
{
  return [self url];
}

@end
