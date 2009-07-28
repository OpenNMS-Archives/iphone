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

#import "OutageParser.h"
#import "EventParser.h"
#import "FuzzyDate.h"

@implementation OutageParser

- (id) init
{
	if (self = [super init]) {
		fuzzyDate = [[FuzzyDate alloc] init];
		fuzzyDate.mini = NO;
		miniDate = [[FuzzyDate alloc] init];
		miniDate.mini = YES;
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLenient:true];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
	}
	return self;
}

- (void)dealloc
{
	[fuzzyDate release];
	[miniDate release];
	[dateFormatter release];

	[super dealloc];
}

- (OnmsOutage*) getOutage:(CXMLElement*)xmlOutage
{
	OnmsOutage* outage = [[[OnmsOutage alloc] init] autorelease];

	// ID
	for (id attr in [xmlOutage attributes]) {
		if ([[attr name] isEqual:@"id"]) {
			outage.outageId = [NSNumber numberWithInt:[[attr stringValue] intValue]];
		}
	}

	// Service Name
	CXMLElement* msElement = [xmlOutage elementForName:@"monitoredService"];
	if (msElement) {
		CXMLElement* stElement = [msElement elementForName:@"serviceType"];
		if (stElement) {
			CXMLElement* snElement = [stElement elementForName:@"name"];
			if (snElement) {
				[outage setServiceName:[[snElement childAtIndex:0] stringValue]];
			}
		}
	}

	// IP Address
	CXMLElement* ipElement = [xmlOutage elementForName:@"ipAddress"];
	if (ipElement) {
		[outage setIpAddress:[[ipElement childAtIndex:0] stringValue]];
	}

	// Service Lost Date
	CXMLElement* slElement = [xmlOutage elementForName:@"ifLostService"];
	if (slElement) {
		[outage setIfLostService:[dateFormatter dateFromString:[[slElement childAtIndex:0] stringValue]]];
	}
	
	// Service Regained Date
	CXMLElement* srElement = [xmlOutage elementForName:@"ifRegainedService"];
	if (srElement) {
		[outage setIfRegainedService:[dateFormatter dateFromString:[[srElement childAtIndex:0] stringValue]]];
	}
	
	EventParser* eParser = [[EventParser alloc] init];
	
	// Service Lost Event
	CXMLElement* sleElement = [xmlOutage elementForName:@"serviceLostEvent"];
	if (sleElement) {
		NSArray* events = [eParser parse:sleElement];
		if (events) {
			[outage setServiceLostEvent: [events objectAtIndex:0]];
		} else {
			NSLog(@"warning: unable to parse %@", sleElement);
		}
	}
	
	// Service Regained Event
	CXMLElement* sreElement = [xmlOutage elementForName:@"serviceRegainedEvent"];
	if (sreElement) {
		NSArray* events = [eParser parse:sreElement];
		if (events) {
			[outage setServiceRegainedEvent: [events objectAtIndex:0]];
		} else {
			NSLog(@"warning: unable to parse %@", sreElement);
		}
	}

	[eParser release];
	return outage;
}

- (NSArray*)getViewOutages:(CXMLElement*)node distinctNodes:(BOOL)distinct mini:(BOOL)doMini
{
	NSCountedSet* labelCount;
	if (distinct) {
		labelCount = [NSCountedSet set];
	}

	NSMutableArray* viewOutages = [NSMutableArray array];
	for (id xmlOutage in [node elementsForName:@"outage"]) {
		ViewOutage* viewOutage = [[[ViewOutage alloc] init] autorelease];
		OnmsOutage* outage = [self getOutage:xmlOutage];

		viewOutage.outageId = [outage.outageId copy];
		if (doMini) {
			viewOutage.serviceLostDate = [miniDate format:outage.ifLostService];
			viewOutage.serviceRegainedDate = [miniDate format:outage.ifRegainedService];
		} else {
			viewOutage.serviceLostDate = [fuzzyDate format:outage.ifLostService];
			viewOutage.serviceRegainedDate = [fuzzyDate format:outage.ifRegainedService];
		}
		viewOutage.serviceName = [outage.serviceName copy];
		viewOutage.nodeId = [outage.serviceLostEvent.nodeId copy];
		viewOutage.ipAddress = [outage.ipAddress copy];

		if (distinct) {
			if ([labelCount countForObject:outage.serviceLostEvent.nodeId] == 0) {
				[viewOutages addObject:viewOutage];
			}
			[labelCount addObject:[outage.serviceLostEvent.nodeId autorelease]];
		} else {
			[viewOutages addObject:viewOutage];
		}
	}

	return viewOutages;
}

- (NSArray*)parse:(CXMLElement*)node skipRegained:(BOOL)skipRegained
{
    // Create a new, empty itemArray
    NSMutableArray* outages = [NSMutableArray array];

	NSArray* xmlOutages = [node elementsForName:@"outage"];
	for (id xmlOutage in xmlOutages) {
		OnmsOutage* outage = [self getOutage:xmlOutage];
		if (!skipRegained || outage.serviceRegainedEvent == nil) {
			[outages addObject: outage];
		}
	}
	return outages;
}

@end
