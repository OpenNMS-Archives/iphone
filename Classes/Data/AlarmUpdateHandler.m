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

#import "config.h"

#import "AlarmUpdateHandler.h"
#import "Alarm.h"

@implementation AlarmUpdateHandler

-(void) handleRequest:(ASIHTTPRequest*) request
{
	[super handleRequest:request];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:true];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];

	CXMLDocument* document = [self getDocumentForRequest:request];

	if (!document) {
		[dateFormatter release];
		[super requestDidFinish:request];
		[self autorelease];
		return;
	}

	NSDate* lastModified = [NSDate date];

	NSArray* xmlAlarms;
	if ([[[document rootElement] name] isEqual:@"alarm"]) {
		xmlAlarms = [NSArray arrayWithObject:[document rootElement]];
	} else {
		xmlAlarms = [[document rootElement] elementsForName:@"alarm"];
	}

	NSMutableArray* alarms = [NSMutableArray arrayWithCapacity:[xmlAlarms count]];

	for (id xmlAlarm in xmlAlarms) {
		NSMutableDictionary* alarm = [NSMutableDictionary dictionary];

		NSNumber* alarmId = nil;
		NSString* severity = nil;
		NSNumber* count = nil;

		for (id attr in [xmlAlarm attributes]) {
			if ([[attr name] isEqual:@"id"]) {
				alarmId = [NSNumber numberWithInt:[[attr stringValue] intValue]];
			} else if ([[attr name] isEqual:@"severity"]) {
				severity = [attr stringValue];
			} else if ([[attr name] isEqual:@"count"]) {
				count = [NSNumber numberWithInt:[[attr stringValue] intValue]];
			} else if ([[attr name] isEqual:@"ifIndex"]) {
				// ignore
			} else if ([[attr name] isEqual:@"type"]) {
				// ignore
#if DEBUG
			} else {
				NSLog(@"%@: unknown alarm attribute: %@", self, [attr name]);
#endif
			}
		}

		[alarm setValue:alarmId forKey:@"alarmId"];
		[alarm setValue:severity forKey:@"severity"];
		[alarm setValue:count forKey:@"count"];

		// UEI
		CXMLElement *ueiElement = [xmlAlarm elementForName:@"uei"];
		if (ueiElement) {
			[alarm setValue:[[ueiElement childAtIndex:0] stringValue] forKey:@"uei"];
		}
		
		// Log Message
		CXMLElement *lmElement = [xmlAlarm elementForName:@"logMessage"];
		if (lmElement) {
			[alarm setValue:[self cleanUpString:[[lmElement childAtIndex:0] stringValue]] forKey:@"logMessage"];
		}
		
		// First Event Time
		CXMLElement *ftElement = [xmlAlarm elementForName:@"firstEventTime"];
		if (ftElement) {
			[alarm setValue:[dateFormatter dateFromString:[self stringForDate:[[ftElement childAtIndex:0] stringValue]]] forKey:@"firstEventTime"];
		}
		
		// Last Event Time
		CXMLElement *ltElement = [xmlAlarm elementForName:@"lastEventTime"];
		if (ltElement) {
			[alarm setValue:[dateFormatter dateFromString:[self stringForDate:[[ltElement childAtIndex:0] stringValue]]] forKey:@"lastEventTime"];
		}
		
		// Ack Time
		CXMLElement *ackElement = [xmlAlarm elementForName:@"ackTime"];
		if (ackElement) {
			NSString* ackString = [self stringForDate:[[ackElement childAtIndex:0] stringValue]];
			NSDate* ackDate = [dateFormatter dateFromString:ackString];
			[alarm setValue:ackDate forKey:@"ackTime"];
		}
		[alarms addObject:alarm];
	}

	NSError* error = nil;
	Alarm* dbAlarm = nil;

	NSManagedObjectContext* context = [contextService newContext];
	[context lock];
	for (id a in alarms) {
		NSDictionary* alarm = (NSDictionary*)a;
		NSNumber* alarmId = [alarm valueForKey:@"alarmId"];

		NSFetchRequest *alarmRequest = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *alarmEntity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:context];
		[alarmRequest setEntity:alarmEntity];
		
		NSPredicate *alarmPredicate = [NSPredicate predicateWithFormat:@"alarmId == %@", alarmId];
		[alarmRequest setPredicate:alarmPredicate];
	
		error = nil;
		dbAlarm = nil;

		NSArray *alarmArray = [context executeFetchRequest:alarmRequest error:&error];
		if (!alarmArray || [alarmArray count] == 0) {
			if (error) {
				NSLog(@"%@: error fetching alarm for ID %@: %@", self, alarmId, [error localizedDescription]);
				error = nil;
			}
			dbAlarm = (Alarm*)[NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:context];
		} else {
			dbAlarm = (Alarm*)[alarmArray objectAtIndex:0];
		}
		dbAlarm.alarmId = alarmId;
		dbAlarm.lastModified = lastModified;

		dbAlarm.severity = [alarm valueForKey:@"severity"];
		dbAlarm.lastEventTime = [alarm valueForKey:@"lastEventTime"];
		dbAlarm.firstEventTime = [alarm valueForKey:@"firstEventTime"];
		dbAlarm.ackTime = [alarm valueForKey:@"ackTime"];
		dbAlarm.count = [alarm valueForKey:@"count"];
		dbAlarm.logMessage = [alarm valueForKey:@"logMessage"];
		dbAlarm.ifIndex = [alarm valueForKey:@"ifIndex"];
		dbAlarm.uei = [alarm valueForKey:@"uei"];

#if DEBUG
		NSLog(@"%@: dbAlarm = %@", self, dbAlarm);
#endif
	}

	if (self.clearOldObjects) {
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:context];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastModified < %@", lastModified];
		[request setPredicate:predicate];
		
		NSError* error = nil;
		NSArray *alarmsToDelete = [context executeFetchRequest:request error:&error];
		if (!alarmsToDelete) {
			if (error) {
				NSLog(@"%@: error fetching alarms to delete (older than %@): %@", self, lastModified, [error localizedDescription]);
				[error release];
			} else {
				NSLog(@"%@: error fetching alarms to delete (older than %@)", self, lastModified);
			}
		} else {
			for (id alarm in alarmsToDelete) {
#if DEBUG
				NSLog(@"deleting %@", alarm);
#endif
				[context deleteObject:alarm];
			}
		}
	}

	if (![context save:&error]) {
		NSLog(@"%@: an error occurred saving the managed object context: %@", self, [error localizedDescription]);
		[error release];
	}

	[context unlock];
	[context release];
	[dateFormatter release];
	[self autorelease];
	
	[super finished];
}

@end
