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

#import "ONMSDateFormatter.h"


@implementation ONMSDateFormatter

- (id)init
{
  if (self = [super init]) {
    [self setTimeStyle:NSDateFormatterFullStyle];
    [self setLenient:YES];
    [self setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
  }
  return self;
}

- (NSDate*)dateFromString:(NSString*)string
{
  NSString* date;
  NSString* time;
  NSString* zoneHour;
  NSString* zoneMinute;
  
  NSScanner *scanner = [NSScanner scannerWithString:string];
  scanner.caseSensitive = YES;
  if (![scanner scanUpToString:@"T" intoString:&date]) {
    TTDINFO(@"unable to scan date portion of %@", string);
    return [super dateFromString:string];
  }
  if (![scanner scanString:@"T" intoString:NULL]) {
    TTDINFO(@"unable to scan T separator of %@", string);
    return [super dateFromString:string];
  }
  if (![scanner scanUpToString:@"-" intoString:&time]) {
    TTDINFO(@"unable to scan time portion of %@", string);
    return [super dateFromString:string];
  }
  if (![scanner scanString:@"-" intoString:NULL]) {
    TTDINFO(@"unable to scan - separator of %@", string);
    return [super dateFromString:string];
  }
  if (![scanner scanUpToString:@":" intoString:&zoneHour]) {
    TTDINFO(@"unable to scan time zone hour portion of %@", string);
    return [super dateFromString:string];
  }
  if (![scanner scanString:@":" intoString:NULL]) {
    TTDINFO(@"unable to scan : separator of %@", string);
    return [super dateFromString:string];
  }
  zoneMinute = [string substringFromIndex:[scanner scanLocation]];
  
  NSArray* splitTime = [time componentsSeparatedByString:@"."];
  time = [splitTime objectAtIndex:0];
  NSString* returnString = [NSString stringWithFormat:@"%@T%@-%@%@", date, time, zoneHour, zoneMinute];

//  TTDINFO(@"converted %@ into %@", string, returnString);
  return [super dateFromString:returnString];
}

@end
