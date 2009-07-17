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

#import "EventParser.h"

@implementation EventParser

- (void)dealloc
{
	[events release];
	[super dealloc];
}

- (BOOL)parse:(CXMLElement *)node
{
    // Release the old eventArray
    [events release];
	
    // Create a new, empty itemArray
    events = [[NSMutableArray alloc] init];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:true];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];

	NSArray* xmlEvents = [node elementsForName:@"serviceLostEvent"];
	if ([xmlEvents count] == 0) {
		xmlEvents = [node elementsForName:@"serviceRegainedEvent"];
	}
	if ([xmlEvents count] == 0) {
		xmlEvents = [node elementsForName:@"event"];
	}
	if ([xmlEvents count] == 0) {
		xmlEvents = [[NSArray alloc] initWithObjects:node, nil];
	}
	for (id xmlEvent in xmlEvents) {
		OnmsEvent *event = [[OnmsEvent alloc] init];

		// Attributes
		for (id attr in [xmlEvent attributes]) {
			if ([[attr name] isEqual:@"id"]) {
				[event setEventId: [NSNumber numberWithInt:[[attr stringValue] intValue]]];
			} else if ([[attr name] isEqual:@"display"]) {
				[event setEventDisplay: [[attr stringValue] boolValue]];
			} else if ([[attr name] isEqual:@"log"]) {
				[event setEventLog: [[attr stringValue] boolValue]];
			} else if ([[attr name] isEqual:@"severity"]) {
				[event setSeverity: [NSNumber numberWithInt:[[attr stringValue] intValue]]];
			} else {
				NSLog(@"unknown event attribute: %@", [attr name]);
			}
		}
		
		// Time
		CXMLElement *timeElement = [xmlEvent elementForName:@"time"];
		if (timeElement) {
			[event setTime: [dateFormatter dateFromString:[[timeElement childAtIndex:0] stringValue]]];
		}

		// CreateTime
		CXMLElement *ctElement = [xmlEvent elementForName:@"createTime"];
		if (ctElement) {
			[event setCreateTime: [dateFormatter dateFromString:[[ctElement childAtIndex:0] stringValue]]];
		}
		
		// Description
		CXMLElement *descrElement = [xmlEvent elementForName:@"description"];
		if (descrElement) {
			[event setEventDescr:[[descrElement childAtIndex:0] stringValue]];
		}

		// Host
		CXMLElement *hostElement = [xmlEvent elementForName:@"host"];
		if (hostElement) {
			[event setEventHost:[[hostElement childAtIndex:0] stringValue]];
		}

		// Log Message
		CXMLElement *lmElement = [xmlEvent elementForName:@"logMessage"];
		if (lmElement) {
			[event setEventLogMessage:[[lmElement childAtIndex:0] stringValue]];
		}
		
		// Source
		CXMLElement *sourceElement = [xmlEvent elementForName:@"source"];
		if (sourceElement) {
			[event setSource:[[sourceElement childAtIndex:0] stringValue]];
		}

		// UEI
		CXMLElement *ueiElement = [xmlEvent elementForName:@"uei"];
		if (ueiElement) {
			[event setUei:[[ueiElement childAtIndex:0] stringValue]];
		}

		// Node ID
		CXMLElement *nodeElement = [xmlEvent elementForName:@"nodeId"];
		if (nodeElement) {
			[event setNodeId:[NSNumber numberWithInt:[[[nodeElement childAtIndex:0] stringValue] intValue]]];
		}
		
		// TODO: parms
		
		[events addObject: event];
	}
	
	[dateFormatter release];
	return true;
}

- (NSArray*)events
{
	return events;
}

- (OnmsEvent*)event
{
	if ([events count] > 0) {
		return [events objectAtIndex:0];
	} else {
		return nil;
	}
}
@end