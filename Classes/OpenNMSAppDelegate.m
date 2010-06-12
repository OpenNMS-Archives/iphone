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

#import "config.h"
#import "OpenNMSAppDelegate.h"
#import "SettingsViewController.h"
#import "NullUpdater.h"

@implementation OpenNMSAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize navigationController;
@synthesize contextService;
@synthesize settingsActive;

-(id) init
{
	if (self = [super init]) {
		contextService = [[ContextService alloc] init];
		settingsActive = NO;
	}
	return self;
}

-(void) dealloc
{
    [tabBarController release];
    [window release];
	
    [super dealloc];
}

-(void) applicationDidFinishLaunching:(UIApplication *)application
{
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	
	NSString* username = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_preference"];
	if (username == nil) {
		[self openSettings];
	}
}

- (void) openSettings
{
    if (settingsActive) return;

	settingsActive = YES;
	NSString* plist = [[NSBundle mainBundle] pathForResource:@"Root" ofType:@"plist" inDirectory:@"Settings.bundle"];
#if DEBUG
	NSLog(@"root bundle path = %@", plist);
#endif
	SettingsViewController *settingsviewcontroller = [[SettingsViewController alloc] initWithConfigFile:plist];
	UINavigationController* unc = [[UINavigationController alloc] initWithRootViewController:settingsviewcontroller];
	settingsviewcontroller.title = @"Settings";
	UIBarButtonItem* button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeSettings)] autorelease];
	[button setEnabled:YES];
	settingsviewcontroller.navigationItem.rightBarButtonItem = button;
	[tabBarController presentModalViewController:unc animated:YES];
	[settingsviewcontroller release];
	[unc release];
}

- (void) closeSettings
{
	[tabBarController dismissModalViewControllerAnimated:YES];
	settingsActive = NO;
}

- (ContextService*) contextService
{
	return contextService;
}

- (NSManagedObjectContext *) managedObjectContext
{
	return [contextService managedObjectContext];
}

@end

