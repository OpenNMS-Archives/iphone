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

#import "AlarmParser.h"
#import "EventParser.h"

@implementation AlarmParser

- (NSArray*)parse:(CXMLElement*)node
{
	NSMutableArray* alarms = [NSMutableArray array];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:true];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];

	NSArray* xmlAlarms = [node elementsForName:@"alarm"];
	if ([xmlAlarms count] == 0 && ![[node name] isEqual:@"alarms"]) {
		xmlAlarms = [[[NSArray alloc] initWithObjects:node, nil] autorelease];
	}

	[xmlAlarms retain];
	for (id xmlAlarm in xmlAlarms) {
		OnmsAlarm* alarm = [[[OnmsAlarm alloc] init] autorelease];
		
		// Attributes
		for (id attr in [xmlAlarm attributes]) {
			if ([[attr name] isEqual:@"id"]) {
				[alarm setAlarmId: [NSNumber numberWithInt:[[attr stringValue] intValue]]];
			} else if ([[attr name] isEqual:@"severity"]) {
				[alarm setSeverity:[attr stringValue]];
			} else if ([[attr name] isEqual:@"count"]) {
				[alarm setCount: [NSNumber numberWithInt:[[attr stringValue] intValue]]];
			} else if ([[attr name] isEqual:@"type"]) {
				// ignore
			} else {
				NSLog(@"unknown alarm attribute: %@", [attr name]);
			}
		}
		
		// UEI
		CXMLElement *ueiElement = [xmlAlarm elementForName:@"uei"];
		if (ueiElement) {
			[alarm setUei:[[ueiElement childAtIndex:0] stringValue]];
		}

		// Log Message
		CXMLElement *lmElement = [xmlAlarm elementForName:@"logMessage"];
		if (lmElement) {
			[alarm setLogMessage:[self cleanUpString:[[lmElement childAtIndex:0] stringValue]]];
		}

		// First Event Time
		CXMLElement *ftElement = [xmlAlarm elementForName:@"firstEventTime"];
		if (ftElement) {
			[alarm setFirstEventTime: [dateFormatter dateFromString:[[ftElement childAtIndex:0] stringValue]]];
		}

		
		// Last Event Time
		CXMLElement *ltElement = [xmlAlarm elementForName:@"lastEventTime"];
		if (ltElement) {
			[alarm setLastEventTime: [dateFormatter dateFromString:[[ltElement childAtIndex:0] stringValue]]];
		}
		
		// Last Event
		CXMLElement *leElement = [xmlAlarm elementForName:@"lastEvent"];
		if (leElement) {
			EventParser* eParser = [[EventParser alloc] init];
			NSArray* events = [eParser parse:leElement];
			if (events) {
				OnmsEvent* event = [events objectAtIndex:0];
				if (event) {
					[alarm setLastEvent:event];
				}
			}
			[eParser release];
		}
		
		[alarms addObject:alarm];
	}
	[xmlAlarms release];
	[dateFormatter release];
	return alarms;
}

@end
