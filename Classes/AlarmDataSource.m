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

#import "AlarmDataSource.h"
#import "AlarmModel.h"
#import "OutageModel.h"
#import "IPInterfaceModel.h"
#import "SNMPInterfaceModel.h"
#import "EventModel.h"

#import "ONMSSeverityItem.h"
#import "ONMSSeverityItemCell.h"

#import "Three20Core/NSDateAdditions.h"
#import "Three20Core/NSStringAdditions.h"

@implementation AlarmDataSource

@synthesize severity = _severity;
@synthesize ackDelegate = _ackDelegate;

- (id)initWithAlarmId:(NSString*)alarmId
{
  if (self = [super init]) {
    _alarmModel = [[[AlarmModel alloc] initWithAlarmId:alarmId] retain];
  }
  return self;
}

- (void)dealloc
{
  // Don't do this!  It's done for us.
  // TT_RELEASE_SAFELY(_alarmModel);
  TT_RELEASE_SAFELY(_ackDelegate);
  TT_RELEASE_SAFELY(_severity);
  [super dealloc];
}

- (id<TTModel>)model
{
  return _alarmModel;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object
{
  if ([object isKindOfClass:[ONMSSeverityItem class]]) {
    return [ONMSSeverityItemCell class];
  } else {
    return [super tableView:tableView cellClassForObject:object];
  }
}

- (void)tableViewDidLoadModel:(UITableView*)tableView
{
  NSMutableArray* items = [[NSMutableArray alloc] init];
  NSMutableArray* sections = [[NSMutableArray alloc] init];

  _severity = _alarmModel.severity;

  [sections addObject:@""];
  
  NSMutableArray* alarmItems = [NSMutableArray array];
  
  TTTableSubtextItem* item = [[[TTTableSubtextItem alloc] init] autorelease];
  item.text = @"UEI";
  item.caption = [_alarmModel.uei stringByReplacingOccurrencesOfString:@"uei.opennms.org/" withString:@""];
  [alarmItems addObject:item];
  
  [alarmItems addObject:[TTTableSubtextItem itemWithText:@"Severity" caption:_alarmModel.severity]];
  [alarmItems addObject:[TTTableSubtextItem itemWithText:@"# Events" caption:_alarmModel.eventCount]];
  [alarmItems addObject:[TTTableSubtextItem itemWithText:@"Log Message" caption:_alarmModel.logMessage]];
  [alarmItems addObject:[TTTableSubtextItem itemWithText:@"First Event" caption:[_alarmModel.firstEventTime description]]];
  if (![_alarmModel.lastEventTime isEqualToDate:_alarmModel.firstEventTime]) {
    [alarmItems addObject:[TTTableSubtextItem itemWithText:@"Last Event" caption:[_alarmModel.lastEventTime description]]];
  }
  if (_alarmModel.ackTime) {
    [alarmItems addObject:[TTTableSubtextItem itemWithText:@"Acknowledged" caption:[_alarmModel.ackTime description]]];
  } else {
    [alarmItems addObject:[TTTableSubtextItem itemWithText:@"Acknowledged" caption:@"never"]];
  }

  [items addObject:alarmItems];

  [sections addObject:@""];
  TTTableButton* button = [[[TTTableButton alloc] init] autorelease];
  button.delegate = _ackDelegate;
  if (_alarmModel.ackTime) {
    button.text = @"Unacknowledge";
    button.selector = @selector(unacknowledge);
  } else {
    button.text = @"Acknowledge";
    button.selector = @selector(acknowledge);
  }
  [items addObject:[NSArray arrayWithObject:button]];
   
  [sections addObject:@""];
  button = [TTTableButton itemWithText:@"Escalate"];
  button.delegate = _ackDelegate;
  button.selector = @selector(escalate);
  [items addObject:[NSArray arrayWithObject:button]];
    
  [sections addObject:@""];
  button = [TTTableButton itemWithText:@"Clear"];
  button.delegate = _ackDelegate;
  button.selector = @selector(clear);
  [items addObject:[NSArray arrayWithObject:button]];
  
  self.items = items;
  self.sections = sections;
  
  TT_RELEASE_SAFELY(items);
  TT_RELEASE_SAFELY(sections);
}

@end
