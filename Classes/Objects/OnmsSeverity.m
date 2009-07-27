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

#import "OnmsSeverity.h"

@implementation OnmsSeverity

@synthesize severity;

-(id) init
{
	return [self initWithSeverity:nil];
}

-(id) initWithSeverity:(NSString*)sev
{
	if (self = [super init]) {
		self.severity = sev;
	}
	return self;
}

-(UIColor*) getDisplayColor
{
	if ([self.severity isEqual:@"INDETERMINATE"]) {
		// #EBEBCD
		return [UIColor colorWithRed:0.92157 green:0.92157 blue:0.80392 alpha:1.0];
	} else if ([self.severity isEqual:@"CLEARED"]) {
		// #EEEEEE
		return [UIColor colorWithWhite:0.93333 alpha:1.0];
	} else if ([self.severity isEqual:@"NORMAL"]) {
		// #D7E1CD
		return [UIColor colorWithRed:0.843134 green:0.88235 blue:0.80392 alpha:1.0];
	} else if ([self.severity isEqual:@"WARNING"]) {
		// #FFF5CD
		return [UIColor colorWithRed:1.0 green:0.96078 blue:0.80392 alpha:1.0];
	} else if ([self.severity isEqual:@"MINOR"]) {
		// #FFEBCD
		return [UIColor colorWithRed:1.0 green:0.92157 blue:0.80392 alpha:1.0];
	} else if ([self.severity isEqual:@"MAJOR"]) {
		// #FFD7CD
		return [UIColor colorWithRed:1.0 green:0.843134 blue:0.80392 alpha:1.0];
	} else if ([self.severity isEqual:@"CRITICAL"]) {
		// #F5CDCD
		return [UIColor colorWithRed:0.96078 green:0.80392 blue:0.80392 alpha:1.0];
	} else {
		// #FFFFFF
		return [UIColor colorWithWhite:1.0 alpha:1.0];
	}
}

-(UIColor*) getSeparatorColor
{
	if ([self.severity isEqual:@"INDETERMINATE"]) {
		// #999900
		return [UIColor colorWithRed:0.6 green:0.6 blue:0.0 alpha:1.0];
	} else if ([self.severity isEqual:@"CLEARED"]) {
		// #999999
		return [UIColor colorWithWhite:0.6 alpha:1.0];
	} else if ([self.severity isEqual:@"NORMAL"]) {
		// #336600
		return [UIColor colorWithRed:0.2 green:0.4 blue:0.0 alpha:1.0];
	} else if ([self.severity isEqual:@"WARNING"]) {
		// #FFCC00
		return [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:1.0];
	} else if ([self.severity isEqual:@"MINOR"]) {
		// #FF9900
		return [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:1.0];
	} else if ([self.severity isEqual:@"MAJOR"]) {
		// #FF3300
		return [UIColor colorWithRed:1.0 green:0.2 blue:0.0 alpha:1.0];
	} else if ([self.severity isEqual:@"CRITICAL"]) {
		// #CC0000
		return [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0];
	} else {
		// #808080
		return [UIColor colorWithWhite:0.5 alpha:1.0];
	}
}

@end
