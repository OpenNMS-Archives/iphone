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

@implementation OpenNMSAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize contextService;
@synthesize settingsActive;
@synthesize addInterfaceActive;
@synthesize ipField;
@synthesize ipAlert;

-(id) init
{
	if (self = [super init]) {
		contextService = [[ContextService alloc] init];
		settingsActive = NO;
        addInterfaceActive = NO;
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
    if (addInterfaceActive) return;

	settingsActive = YES;
	NSString* plist = [[NSBundle mainBundle] pathForResource:@"Root" ofType:@"plist" inDirectory:@"Settings.bundle"];
#if DEBUG
	NSLog(@"root bundle path = %@", plist);
#endif
	SettingsViewController *settingsviewcontroller = [[SettingsViewController alloc] initWithConfigFile:plist];
	UINavigationController* unc = [[UINavigationController alloc] initWithRootViewController:settingsviewcontroller];
	settingsviewcontroller.title = @"Settings";
//	unc.navigationBar.tintColor = [UIColor colorWithRed:0.2117647 green:0.4117647 blue:0.0117647 alpha:1.0];
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

- (void) openAddInterface
{
    if (settingsActive) return;
    if (addInterfaceActive) return;

    addInterfaceActive = YES;

    ipAlert = [[UIAlertView alloc] initWithTitle:@"Discover New IP Address" 
                                                     message:@"\n" // IMPORTANT
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel" 
                                           otherButtonTitles:@"Add", nil];
    ipField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50.0, 260.0, 25.0)]; 
    [ipField setBackgroundColor:[UIColor whiteColor]];
    [ipField setPlaceholder:@"IP Address"];
    [ipField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [ipField setEnablesReturnKeyAutomatically:YES];
    [ipField setDelegate:self];
    [ipAlert addSubview:ipField];
    
    // set cursor and show keyboard
    [ipField becomeFirstResponder];
    
    [ipAlert show];
    [ipAlert autorelease];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [ipAlert dismissWithClickedButtonIndex:1 animated:YES];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        UIAlertView *a = [[UIAlertView alloc]
                          initWithTitle: @"IP Address"
                          message: [NSString stringWithFormat:@"You typed %@!", ipField.text]
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        [a show];
        [a autorelease];
    }
    addInterfaceActive = NO;
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

