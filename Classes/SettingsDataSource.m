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

#import "SettingsDataSource.h"
#import "SettingsModel.h"

@implementation SettingsDataSource

- (id)init
{
  if (self = [super init]) {
    _settingsModel = [[SettingsModel alloc] init];
    
    _https = [[[UISwitch alloc] init] autorelease];
    
    _host = [[[UITextField alloc] init] autorelease];
    _host.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _host.keyboardType = UIKeyboardTypeURL;

    _port = [[[UITextField alloc] init] autorelease];
    _port.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _port.keyboardType = UIKeyboardTypeNumbersAndPunctuation;

    _path = [[[UITextField alloc] init] autorelease];
    _path.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _path.keyboardType = UIKeyboardTypeURL;

    _username = [[[UITextField alloc] init] autorelease];
    _username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _username.keyboardType = UIKeyboardTypeEmailAddress;

    _password = [[[UITextField alloc] init] autorelease];
    _password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _password.keyboardType = UIKeyboardTypeAlphabet;
    _password.secureTextEntry = YES;
  }
  return self;
}

- (id<TTModel>)model
{
  return _settingsModel;
}

- (void)saveChanges
{
  _settingsModel.https = _https.on;
  NSString* hostText = [[_host.text stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"http://" withString:@""];
  _settingsModel.host = hostText;
  _settingsModel.port = _port.text;
  NSString* pathText = _path.text;
  if ([pathText hasSuffix:@"/"]) {
    pathText = [pathText substringToIndex:[pathText length]-1];
  }
  _settingsModel.path = pathText;
  _settingsModel.user = _username.text;
  _settingsModel.password = _password.text;
  [_settingsModel save];
#ifdef DEBUG
  [TestFlight passCheckpoint:@"SaveConfiguration"];
#endif
}

- (void)tableViewDidLoadModel:(UITableView*)tableView
{
  NSMutableArray* items = [[NSMutableArray alloc] init];

  _https.on = _settingsModel.https;
  [items addObject:[TTTableControlItem itemWithCaption:@"HTTPS?" control:_https]];
  
  _host.text = _settingsModel.host;
  [items addObject:[TTTableControlItem itemWithCaption:@"Host:" control:_host]];

  _port.text = _settingsModel.port;
  [items addObject:[TTTableControlItem itemWithCaption:@"Port:" control:_port]];

  _path.text = _settingsModel.path;
  [items addObject:[TTTableControlItem itemWithCaption:@"Path:" control:_path]];
  
  _username.text = _settingsModel.user;
  [items addObject:[TTTableControlItem itemWithCaption:@"User:" control:_username]];

  _password.text = _settingsModel.password;
  [items addObject:[TTTableControlItem itemWithCaption:@"Pass:" control:_password]];

  self.sections = [NSArray arrayWithObject:@""];
  self.items = [NSArray arrayWithObject:items];
  
  TT_RELEASE_SAFELY(items);
}

@end
