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
#import "AboutViewController.h"
#import "OpenNMSAppDelegate.h"

@implementation AboutViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidLoad {
	[textView setFont:[UIFont systemFontOfSize:13]];
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"Info.plist"];
    NSDictionary *plistData = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
    
    NSString *buildString   = [NSString stringWithFormat:@"%@", [plistData objectForKey:@"CFBundleVersion"]];
	NSString *versionString = [NSString stringWithFormat:@"%@", [plistData objectForKey:@"CFBundleShortVersionString"]];
    
	textView.text = [NSString stringWithFormat:@"OpenNMS %@, build %@\n\n%@", versionString, buildString, textView.text];
    [plistData release];
}

- (void)dealloc {
	[textView release];
    [super dealloc];
}

- (IBAction) openSettings:(id) sender
{
#if DEBUG
	NSLog(@"opening settings");
#endif
	[((OpenNMSAppDelegate*)[UIApplication sharedApplication].delegate) openSettings];
}

@end
