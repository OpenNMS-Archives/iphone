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
  if ([[string substringWithRange:NSMakeRange([string length] - 3, 1)] isEqualToString:@":"]) {
    string = [[string substringToIndex:[string length] - 3] stringByAppendingString:@"00"];
  }
  return [super dateFromString:string];
}

@end
