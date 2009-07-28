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

#import "FuzzyDate.h"

static double SECONDS_PER_DAY    = 86400.0;
static double SECONDS_PER_HOUR   = 3600.0;
static double SECONDS_PER_MINUTE = 60.0;

@implementation FuzzyDate

@synthesize mini;

-(id) init
{
	if (self = [super init]) {
		now = [[NSDate alloc] init];
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setMaximumFractionDigits:0];
		mini = NO;
	}
	return self;
}

-(void) dealloc
{
	[now release];
	[numberFormatter release];
	[super dealloc];
}

-(NSString*) formatInterval:(NSTimeInterval)time small:(NSString*)small singular:(NSString*)singular plural:(NSString*)plural
{
	NSNumber* num = [NSNumber numberWithDouble:time];
	NSString* value = [numberFormatter stringFromNumber:num];
	NSString* retVal = nil;
	if (mini) {
		retVal = [NSString stringWithFormat:@"%@%@", value, small];
	} else if ([value isEqual:@"1"]) {
		retVal = [NSString stringWithFormat:@"%@ %@", value, singular];
	} else {
		retVal = [NSString stringWithFormat:@"%@ %@", value, plural];
	}
	return retVal;
}

-(NSString*) format: (NSDate *)d
{
	NSTimeInterval difference = [now timeIntervalSinceDate: d];

	NSTimeInterval days = (difference / SECONDS_PER_DAY);
	
	if (days < 1.0) {
		NSTimeInterval hours = (difference / SECONDS_PER_HOUR);
		if (hours < 1.0) {
			NSTimeInterval minutes = (difference / SECONDS_PER_MINUTE);
			if (minutes < 1.0) {
				return [self formatInterval:difference small:@"s" singular:@"second" plural:@"seconds"];
			} else {
				return [self formatInterval:minutes small:@"m" singular:@"minute" plural:@"minutes"];
			}
		} else {
			return [self formatInterval:hours small:@"h" singular:@"hour" plural:@"hours"];
		}
	} else if (days >= 365) {
		return [self formatInterval:(days / 365.0) small:@"y" singular:@"year" plural:@"years"];
	} else if (days >= 30) {
		return [self formatInterval:(days / 30.0) small:@"mon" singular:@"month" plural:@"months"];
	} else if (days >= 7) {
		return [self formatInterval:(days / 7.0) small:@"w" singular:@"week" plural:@"weeks"];
	} else if (days >= 1.0) {
		return [self formatInterval:days small:@"d" singular:@"day" plural:@"days"];
	}

	return [d description];
}

@end
