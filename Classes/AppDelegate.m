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

#import "AppDelegate.h"
#import "TabBarController.h"
#import "OutageListViewController.h"
#import "NodeSearchController.h"
#import "NodeViewController.h"
#import "AlarmListViewController.h"
#import "AlarmViewController.h"
#import "AboutViewController.h"
#import "SettingsViewController.h"
#import "IPAddressInputController.h"

#import "ONMSDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation AppDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
#ifdef DEBUG
  [TestFlight takeOff:@"15489123169f361894db6003651532d1_NTQ5NzMyMDEyLTAxLTE5IDEyOjE3OjUxLjk2ODYyNA"];
#endif
  _settingsActive = NO;

  ONMSDefaultStyleSheet* styleSheet = [[ONMSDefaultStyleSheet alloc] init];
  [TTStyleSheet setGlobalStyleSheet:styleSheet];
  [styleSheet release];

  TTNavigator* navigator = [TTNavigator navigator];
  navigator.persistenceMode = TTNavigatorPersistenceModeAll;
//  navigator.persistenceMode = TTNavigatorPersistenceModeNone;
  navigator.supportsShakeToReload = YES;

  TTURLMap* map = navigator.URLMap;

//  [map from:@"*" toSharedViewController:[TabBarController class]];

  [map from:@"onms://tabbar" toSharedViewController:[TabBarController class]];
  [map from:@"onms://about" toSharedViewController:[AboutViewController class]];
  [map from:@"onms://outages/get" toSharedViewController:[OutageListViewController class]];
  [map from:@"onms://alarms/get" toSharedViewController:[AlarmListViewController class]];
  [map from:@"onms://alarms/get/(initWithAlarmId:)" toSharedViewController:[AlarmViewController class]];
  [map from:@"onms://nodes/get" toSharedViewController:[NodeSearchController class]];
  [map from:@"onms://nodes/get/(initWithNodeId:)" toSharedViewController:[NodeViewController class]];
  [map from:@"onms://nodes/add" toModalViewController:[IPAddressInputController class]];
  [map from:@"onms://settings" toModalViewController:[SettingsViewController class]];

  if (![navigator restoreViewControllers]) {
    [navigator beginDelay];
    [navigator openURLAction:[TTURLAction actionWithURLPath:@"onms://tabbar"]];
    NSString* user = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_preference"];
    if (user == nil) {
      [navigator openURLAction:[TTURLAction actionWithURLPath:@"onms://settings"]];
    }
    [navigator endDelay];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)navigator:(TTNavigator*)navigator shouldOpenURL:(NSURL*)URL
{
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL
{
  [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
  return YES;
}

@end
