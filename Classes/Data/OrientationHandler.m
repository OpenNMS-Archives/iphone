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
#import "OrientationHandler.h"

@implementation OrientationHandler

@synthesize screenWidth;
@synthesize tableWidth;
@synthesize cellBorder;
@synthesize cellSeparator;
@synthesize iPad;

-(id)init
{
#if DEBUG
    NSLog(@"%@: init", self);
#endif
    if (self = [super init]) {
        [self updateWithOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    }
    return self;
}

-(id)initWithOrientation:(UIInterfaceOrientation)orientation
{
#if DEBUG
    NSLog(@"%@: initWithOrientation:%d", self, orientation);
#endif
    if (self = [super init]) {
        [self updateWithOrientation:orientation];
    }
    return self;
}

-(void)updateWithOrientation:(UIInterfaceOrientation)orientation
{
    CGRect screenArea = [[UIScreen mainScreen] bounds];
	if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
		screenWidth = screenArea.size.width;
	} else {
		screenWidth = screenArea.size.height;
	}
    if (screenWidth == 768 || screenWidth == 1024) {
        tableWidth = screenWidth - 88;
		cellBorder = 44;
		cellSeparator = 10;
        iPad = YES;
    } else {
		tableWidth = screenWidth - 20;
		cellBorder = 10;
		cellSeparator = 5;
        iPad = NO;
	}
#if DEBUG
	NSLog(@"%@: updateWithOrientation screenArea = %@, screenWidth = %f, tableWidth = %f, cellBorder = %f, cellSeparator = %f", self, NSStringFromCGRect(screenArea), screenWidth, tableWidth, cellBorder, cellSeparator);
#endif
}

@end
