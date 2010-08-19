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

#import "NodeDataSource.h"
#import "NodeModel.h"
#import "OutageModel.h"
#import "IPInterfaceModel.h"
#import "SNMPInterfaceModel.h"
#import "EventModel.h"

#import "ONMSSeverityItem.h"
#import "ONMSSeverityItemCell.h"

#import "Three20Core/NSDateAdditions.h"
#import "Three20Core/NSStringAdditions.h"

@implementation NodeDataSource

@synthesize label = _label;

- (id)initWithNodeId:(NSString*)nodeId
{
	if (self = [super init]) {
		_nodeModel = [[[NodeModel alloc] initWithNodeId:nodeId] retain];
	}
	return self;
}

- (void)dealloc
{
	// Don't do this!  It's done for us.
	// TT_RELEASE_SAFELY(_nodeModel);
	[super dealloc];
}

- (id<TTModel>)model
{
	return _nodeModel;
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

	_label = _nodeModel.label;

//  [sections addObject:_label];
//  [items addObject:[NSArray array]];
  [sections addObject:@""];
  [items addObject:[NSArray arrayWithObject:[TTTableSummaryItem itemWithText:_label]]];

	if (_nodeModel.outages && [_nodeModel.outages count] > 0) {
		[sections addObject:@"Outages"];

		NSMutableArray* outageItems = [NSMutableArray arrayWithCapacity:[_nodeModel.outages count]];
		for (id o in _nodeModel.outages) {
			OutageModel* outage = (OutageModel*)o;
//		NSString* host = outage.host;
			NSString* host = nil;
			if (!host) {
				host = outage.ipAddress;
			}
      ONMSSeverityItem* item = [[[ONMSSeverityItem alloc] init] autorelease];
			item.text = [host stringByAppendingFormat:@"/%@", outage.serviceName];
      item.caption = [outage.logMessage stringByRemovingHTMLTags];
			item.timestamp = outage.ifLostService;
      item.severity = outage.severity;
			[outageItems addObject:item];
		}
		[items addObject:outageItems];
	}
	
	if (_nodeModel.ipInterfaces && [_nodeModel.ipInterfaces count] > 0) {
		[sections addObject:@"IP Interfaces"];

		NSMutableArray* interfaceItems = [NSMutableArray arrayWithCapacity:[_nodeModel.ipInterfaces count]];
		for (id i in _nodeModel.ipInterfaces) {
			IPInterfaceModel* interface = (IPInterfaceModel*)i;
      TTTableSubtitleItem* item = [[[TTTableSubtitleItem alloc] init] autorelease];
      item.text = interface.hostName;
      item.subtitle = [NSString stringWithFormat:@"%@ (%@)", interface.ipAddress, [interface.managed isEqual:@"M"]? @"Managed" : @"Unmanaged"];
      [interfaceItems addObject:item];
		}
		[items addObject:interfaceItems];
	}
	
	if (_nodeModel.snmpInterfaces && [_nodeModel.snmpInterfaces count] > 0) {
		[sections addObject:@"SNMP Interfaces"];
    
		NSMutableArray* interfaceItems = [NSMutableArray arrayWithCapacity:[_nodeModel.snmpInterfaces count]];
		for (id s in _nodeModel.snmpInterfaces) {
			SNMPInterfaceModel* interface = s;
      TTTableSubtitleItem* item = [[[TTTableSubtitleItem alloc] init] autorelease];
      NSString* text;
      if (TTIsStringWithAnyText(interface.ifDescr)) {
        text = [NSString stringWithFormat:@"%@: %@", interface.ifIndex, interface.ifDescr];
      } else {
        text = interface.ifIndex;
      }
      item.text = text;
      item.subtitle = [NSString stringWithFormat:@"%@ (%@)", interface.ipAddress, interface.ifSpeed];
      [interfaceItems addObject:item];
		}
		[items addObject:interfaceItems];
	}
	
	if (_nodeModel.events && [_nodeModel.events count] > 0) {
		[sections addObject:@"Events"];
    
		NSMutableArray* eventItems = [NSMutableArray arrayWithCapacity:[_nodeModel.events count]];
		for (id e in _nodeModel.events) {
			EventModel* event = e;
      ONMSSeverityItem* item = [[[ONMSSeverityItem alloc] init] autorelease];
			item.text = [event.uei stringByReplacingOccurrencesOfString:@"uei.opennms.org/" withString:@""];
      item.caption = [event.logMessage stringByRemovingHTMLTags];
			item.timestamp = event.timestamp;
      item.severity = event.severity;
      
      [eventItems addObject:item];
		}
		[items addObject:eventItems];
	}
	
	self.items = items;
	self.sections = sections;
	
	TT_RELEASE_SAFELY(items);
	TT_RELEASE_SAFELY(sections);
}

@end
