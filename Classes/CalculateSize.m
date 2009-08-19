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

#include "CalculateSize.h"

@implementation CalculateSize

+(CGSize) calcLabelSize:(NSString*)string font:(UIFont*)font lines:(int)lines width:(float)lineWidth
{
	return [CalculateSize calcLabelSize:string font:font lines:lines width:lineWidth mode:(UILineBreakModeTailTruncation|UILineBreakModeWordWrap)];
}

+(CGSize) calcLabelSize:(NSString*)string font:(UIFont*)font lines:(int)lines width:(float)lineWidth mode:(UILineBreakMode)mode
{
    [string retain];
    [font retain];
    float lineHeight = [ @"Fake line" sizeWithFont: font ].height; // Calculate the height of one line.

	// Get the total height, divide by the height of one line to get the # of lines.
    int numLines = [ string sizeWithFont: font constrainedToSize: CGSizeMake(lineWidth, lineHeight*1000.0f) lineBreakMode: mode ].height / lineHeight;
    if (numLines > lines) {
        numLines = lines; // Set the number of lines to the maximum allowed if it goes over.
	}
	[string release];
    [font release];
	
    return CGSizeMake(lineWidth, ((lineHeight*(float)numLines) + 10));
}

@end
