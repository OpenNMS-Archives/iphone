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

#import "RoundedView.h"

// Private methods for RoundedView
@interface RoundedView() 
-(void) drawRoundedCornersInRect:(CGRect) rect inContext:(CGContextRef) c;
-(void) drawCornerInContext:(CGContextRef)c cornerX:(int) x 
                    cornerY:(int) y arcEndX:(int) endX arcEndY:(int) endY;
@end

@implementation RoundedView

@synthesize radius, cornerColor, roundLowerLeft, roundLowerRight;
@synthesize roundUpperLeft, roundUpperRight;

-(id) initWithFrame:(CGRect) frame {
    if (self=[super initWithFrame:frame]) {
        self.cornerColor=[UIColor clearColor];
        self.backgroundColor=[UIColor clearColor];
        self.opaque=NO;
        radius=5;
        roundUpperLeft = roundUpperRight = YES;
        roundLowerLeft = roundLowerRight = YES;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // We pretend like no points are inside our bounds so the events
    // can continue up the responder chain
    return NO;
}

-(void) drawRect:(CGRect) rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    if (c != nil) {
        CGContextSetFillColorWithColor(c, self.cornerColor.CGColor);
        [self drawRoundedCornersInRect:self.bounds inContext:c];
        CGContextFillPath(c);
    }
}

-(void) drawCornerInContext:(CGContextRef)c cornerX:(int) x cornerY:(int) y
                    arcEndX:(int) endX arcEndY:(int) endY {
    CGContextMoveToPoint(c, x, endY);
    CGContextAddArcToPoint(c, x, y, endX, y, radius);
    CGContextAddLineToPoint(c, x, y);
    CGContextAddLineToPoint(c, x, endY);
}

-(void) drawRoundedCornersInRect:(CGRect) rect inContext:(CGContextRef) c {
    int x_left = rect.origin.x;
    int x_left_center = rect.origin.x + radius;
    int x_right_center = rect.origin.x + rect.size.width - radius;
    int x_right = rect.origin.x + rect.size.width;
    int y_top = rect.origin.y;
    int y_top_center = rect.origin.y + radius;
    int y_bottom_center = rect.origin.y + rect.size.height - radius;
    int y_bottom = rect.origin.y + rect.size.height;
    
    if (roundUpperLeft) {
        [self drawCornerInContext:c cornerX: x_left cornerY: y_top
                          arcEndX: x_left_center arcEndY: y_top_center];
    }
    
    if (roundUpperRight) {
        [self drawCornerInContext:c cornerX: x_right cornerY: y_top
                          arcEndX: x_right_center arcEndY: y_top_center];
    }
    
    if (roundLowerRight) {
        [self drawCornerInContext:c cornerX: x_right cornerY: y_bottom
                          arcEndX: x_right_center arcEndY: y_bottom_center];
    }
    
    if (roundLowerLeft) {
        [self drawCornerInContext:c cornerX: x_left cornerY: y_bottom
                          arcEndX: x_left_center arcEndY: y_bottom_center];
    }
}
@end
