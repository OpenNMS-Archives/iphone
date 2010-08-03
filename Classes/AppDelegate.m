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
#import "AboutViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation AppDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	TTNavigator* navigator = [TTNavigator navigator];
	navigator.persistenceMode = TTNavigatorPersistenceModeAll;

	TTURLMap* map = navigator.URLMap;

	[map from:@"*" toViewController:[TTWebController class]];

	[map from:@"onms://tabbar" toSharedViewController:[TabBarController class]];
	[map from:@"onms://about" toSharedViewController:[AboutViewController class]];
	[map from:@"onms://outages" toViewController:[OutageListViewController class]];
	[map from:@"onms://nodes/(initWithNodeId:)" toViewController:[NodeViewController class]];

//	if (![navigator restoreViewControllers]) {
//		[navigator openURLAction:[TTURLAction actionWithURLPath:@"onms://outages"]];
		[navigator openURLAction:[TTURLAction actionWithURLPath:@"onms://tabbar"]];
//	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)navigator:(TTNavigator*)navigator shouldOpenURL:(NSURL*)URL {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
  return YES;
}


@end
