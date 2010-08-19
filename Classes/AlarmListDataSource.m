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

#import "AlarmListDataSource.h"
#import "AlarmListModel.h"
#import "AlarmModel.h"

#import "ONMSSeverityItem.h"
#import "ONMSSeverityItemCell.h"

#import "Three20Core/NSStringAdditions.h"

@implementation AlarmListDataSource

- (id)init
{
	if (self = [super init]) {
		_alarmListModel = [[AlarmListModel alloc] init];
	}
	return self;
}

- (void)dealloc
{
	// Don't do this!  It's done for us.
	// TT_RELEASE_SAFELY(_alarmListModel);
	[super dealloc];
}

- (id<TTModel>)model
{
	return _alarmListModel;
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
	NSArray* alarms = _alarmListModel.alarms;

	for (id o in alarms) {
		AlarmModel* alarm = (AlarmModel*)o;
		NSString* label = alarm.label;
		if (!label) {
			label = alarm.ipAddress;
		}
		ONMSSeverityItem* item = [[[ONMSSeverityItem alloc] init] autorelease];
		item.text = label;
		item.caption = [alarm.logMessage stringByRemovingHTMLTags];
		item.timestamp = alarm.firstEventTime;
    item.severity = alarm.severity;
		item.URL = [@"onms://alarms/" stringByAppendingString:alarm.alarmId];
		[items addObject:item];
	}
	
	self.items = items;
	
	TT_RELEASE_SAFELY(items);
}

@end
