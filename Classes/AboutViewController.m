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

#import "AboutViewController.h"
#import "ONMSDefaultStyleSheet.h"

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.title = @"About";
    self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"o.png"] tag:0] autorelease];
  }
  return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (void)openSettings
{
  TTNavigator* navigator = [TTNavigator navigator];
  TTURLAction* action = [TTURLAction actionWithURLPath:@"onms://settings"];
  action.animated = YES;
  [navigator openURLAction:action];
}

- (void)loadView
{
  self.navigationBarTintColor = TTSTYLEVAR(navigationBarTintColor);
  [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(openSettings)] autorelease] animated:YES];

  UITextView* view = [[[UITextView alloc] init] autorelease];
  view.autoresizesSubviews = YES;
  view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  view.backgroundColor = TTSTYLEVAR(backgroundColor);
  view.editable = NO;
  view.dataDetectorTypes = UIDataDetectorTypeLink;
  view.font = [UIFont systemFontOfSize:14];
  
  NSString *path = [[NSBundle mainBundle] bundlePath];
  NSString *finalPath = [path stringByAppendingPathComponent:@"Info.plist"];
  NSDictionary *plistData = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
  
  NSString *buildString   = [NSString stringWithFormat:@"%@", [plistData objectForKey:@"CFBundleVersion"]];
  NSString *versionString = [NSString stringWithFormat:@"%@", [plistData objectForKey:@"CFBundleShortVersionString"]];
  
  TT_RELEASE_SAFELY(plistData);
  
  NSString* text = [NSString stringWithFormat:
                    @"OpenNMS %@, build %@\n"
                    @"\n"
                    @"OpenNMS® is a Registered Trademark of The OpenNMS Group, Inc.  Copyright © 2012, The OpenNMS Group, Inc.\n"
                    @"\n"
                    @"3rd-Party Inclusions:\n"
                    @"\n"
                    @"Some icons copyright © Joseph Wain, from http://www.glyphish.com/.\n"
                    @"\n"
                    @"Application framework by Three20, from http://three20.info/.",
                    versionString, buildString];
  
  view.text = text;
  self.view = view;
}

@end
