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

#import "Severity.h"

@implementation Severity

@synthesize severity = _severity;

-(id) init
{
  return [self initWithSeverity:nil];
}

-(id) initWithSeverity:(NSString*)sev
{
  if (self = [super init]) {
    _severity = [sev retain];
  }
  return self;
}

- (void)dealloc
{
  TT_RELEASE_SAFELY(_severity);
  [super dealloc];
}

- (UIColor*)getDisplayColor
{
  if (_severity) {
    if ([_severity isEqual:@"INDETERMINATE"]) {
      // #EBEBCD
      return RGBCOLOR(235,235,205);
    } else if ([_severity isEqual:@"CLEARED"]) {
      // #EEEEEE
      return RGBCOLOR(238,238,238);
    } else if ([_severity isEqual:@"NORMAL"]) {
      // #BFE19E
      return RGBCOLOR(191,225,158);
    } else if ([_severity isEqual:@"WARNING"]) {
      // #FFECA0
      return RGBCOLOR(255,236,160);
    } else if ([_severity isEqual:@"MINOR"]) {
      // #FFB57A
      return RGBCOLOR(255,181,122);
    } else if ([_severity isEqual:@"MAJOR"]) {
      // #FFAD98
      return RGBCOLOR(255,173,152);
    } else if ([_severity isEqual:@"CRITICAL"]) {
      // #FF6C6C
      return RGBCOLOR(255,180,180);
    }
  }
  // #FFFFFF
  return [UIColor colorWithWhite:1.0 alpha:1.0];
}

- (UIColor*)getSeparatorColor
{
  if (_severity) {
    if ([_severity isEqual:@"INDETERMINATE"]) {
      // #999900
      return [UIColor colorWithRed:0.6 green:0.6 blue:0.0 alpha:1.0];
    } else if ([_severity isEqual:@"CLEARED"]) {
      // #999999
      return [UIColor colorWithWhite:0.6 alpha:1.0];
    } else if ([_severity isEqual:@"NORMAL"]) {
      // #336600
      return [UIColor colorWithRed:0.2 green:0.4 blue:0.0 alpha:1.0];
    } else if ([_severity isEqual:@"WARNING"]) {
      // #FFCC00
      return [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:1.0];
    } else if ([_severity isEqual:@"MINOR"]) {
      // #FF9900
      return [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:1.0];
    } else if ([_severity isEqual:@"MAJOR"]) {
      // #FF3300
      return [UIColor colorWithRed:1.0 green:0.2 blue:0.0 alpha:1.0];
    } else if ([_severity isEqual:@"CRITICAL"]) {
      // #CC0000
      return [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0];
    }
  }
  // #808080
  return [UIColor colorWithWhite:0.5 alpha:1.0];
}

- (UIColor*)getTextColor
{
  if (_severity) {
    if ([_severity isEqual:@"INDETERMINATE"]) {
      return [UIColor blackColor];
    } else if ([_severity isEqual:@"CLEARED"]) {
      // #999999
      return [UIColor grayColor];
    } else if ([_severity isEqual:@"NORMAL"]) {
      // #336600
      return [UIColor colorWithRed:0.2 green:0.5 blue:0.0 alpha:1.0];
    } else if ([_severity isEqual:@"WARNING"]) {
      // #FFCC00
      return [UIColor colorWithRed:0.5 green:0.5 blue:0.0 alpha:1.0];
    } else if ([_severity isEqual:@"MINOR"]) {
      // #FF9900
      return [UIColor colorWithRed:0.5 green:0.5 blue:0.0 alpha:1.0];
    } else if ([_severity isEqual:@"MAJOR"]) {
      // #FF3300
      return [UIColor orangeColor];
    } else if ([_severity isEqual:@"CRITICAL"]) {
      // #CC0000
      return [UIColor redColor];
    }
  }
  // #808080
  return [UIColor grayColor];
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"Severity[%@]", _severity];
}

@end
