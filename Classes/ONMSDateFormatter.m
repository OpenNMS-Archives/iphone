//
//  ONMSDateFormatter.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

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

  TTDINFO(@"converted %@ into %@", string, returnString);
  return [super dateFromString:returnString];
}

@end
