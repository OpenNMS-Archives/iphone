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

#import "ONMSSeverityItem.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ONMSSeverityItem

@synthesize timestamp = _timestamp;
@synthesize severity = _severity;

- (void)dealloc
{
  TT_RELEASE_SAFELY(_timestamp);
  TT_RELEASE_SAFELY(_severity);
  
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCoding


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder*)decoder
{
  if (self = [super initWithCoder:decoder]) {
    self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
    self.severity = [decoder decodeObjectForKey:@"severity"];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder
{
  [super encodeWithCoder:encoder];
  if (self.timestamp) {
    [encoder encodeObject:self.timestamp forKey:@"timestamp"];
  }
  if (self.severity) {
    [encoder encodeObject:self.severity forKey:@"severity"];
  }
}

@end

