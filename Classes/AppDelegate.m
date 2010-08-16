//
//  OpenNMSAppDelegate.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AppDelegate.h"
#import "TabBarController.h"
#import "OutageListViewController.h"
#import "NodeViewController.h"
#import "AlarmListViewController.h"
#import "AlarmViewController.h"
#import "AboutViewController.h"
#import "ONMSSettingsViewController.h"

#import "ONMSDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation AppDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
  _settingsActive = NO;

  ONMSDefaultStyleSheet* styleSheet = [[ONMSDefaultStyleSheet alloc] init];
  [TTStyleSheet setGlobalStyleSheet:styleSheet];
  [styleSheet release];

	TTNavigator* navigator = [TTNavigator navigator];
//	navigator.persistenceMode = TTNavigatorPersistenceModeAll;
  navigator.persistenceMode = TTNavigatorPersistenceModeNone;
  navigator.supportsShakeToReload = YES;

	TTURLMap* map = navigator.URLMap;

	[map from:@"*" toViewController:[TTWebController class]];

	[map from:@"onms://tabbar" toSharedViewController:[TabBarController class]];
	[map from:@"onms://about" toSharedViewController:[AboutViewController class]];
	[map from:@"onms://outages" toSharedViewController:[OutageListViewController class]];
	[map from:@"onms://alarms" toSharedViewController:[AlarmListViewController class]];
	[map from:@"onms://alarms/(initWithAlarmId:)" toSharedViewController:[AlarmViewController class]];
	[map from:@"onms://nodes/(initWithNodeId:)" toSharedViewController:[NodeViewController class]];
  [map from:@"onms://settings" toSharedViewController:[ONMSSettingsViewController class]];

//	if (![navigator restoreViewControllers]) {
		[navigator openURLAction:[TTURLAction actionWithURLPath:@"onms://outages"]];
		[navigator openURLAction:[TTURLAction actionWithURLPath:@"onms://settings"]];
//	}
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

/*
- (void) openSettings
{
  if (_settingsActive) return;
  
	TTNavigator* navigator = [TTNavigator navigator];
  _settingsActive = YES;
  NSString* plist = [[NSBundle mainBundle] pathForResource:@"Root" ofType:@"plist" inDirectory:@"Settings.bundle"];
  TTDINFO(@"root bundle path = %@", plist);
  SettingsViewController* settingsviewcontroller = [[SettingsViewController alloc] initWithConfigFile:plist];
  UINavigationController* unc = [[UINavigationController alloc] initWithRootViewController:settingsviewcontroller];
  settingsviewcontroller.title = @"Settings";
  UIBarButtonItem* button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeSettings)] autorelease];
  [button setEnabled:YES];
  settingsviewcontroller.navigationItem.rightBarButtonItem = button;
  [[navigator visibleViewController] presentModalViewController:unc animated:YES];
  [settingsviewcontroller release];
  [unc release];
}

- (void) closeSettings
{
	TTNavigator* navigator = [TTNavigator navigator];
  [[navigator visibleViewController] dismissModalViewControllerAnimated:YES];
  _settingsActive = NO;
  
//  [self checkSettingsState];
}
*/

@end
