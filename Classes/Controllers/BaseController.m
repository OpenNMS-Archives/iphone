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

#import "config.h"
#import "BaseController.h"

@implementation BaseController

@synthesize orientationHandler;

-(void)initializeScreenWidth:(UIInterfaceOrientation)interfaceOrientation
{
    if (!orientationHandler) {
        orientationHandler = [[OrientationHandler alloc] init];
    }
    [orientationHandler updateWithOrientation:interfaceOrientation];
}

-(void)loadView
{
#if DEBUG
	NSLog(@"%@: loadView", self);
#endif
	[self initializeScreenWidth:[[UIApplication sharedApplication] statusBarOrientation]];
	[super loadView];
}

-(void)viewWillAppear:(BOOL)animated
{
	[self initializeScreenWidth:[[UIApplication sharedApplication] statusBarOrientation]];
    [super viewWillAppear:animated];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
#if DEBUG
    NSLog(@"%@: willRotateToInterfaceOrientation:%d", self, orientation);
#endif
    [super willRotateToInterfaceOrientation:orientation duration:duration];
    [orientationHandler updateWithOrientation:orientation];
}

@end
