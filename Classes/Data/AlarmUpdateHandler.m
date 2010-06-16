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

-(void) requestDidFinish:(ASIHTTPRequest*) request
{
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
	[context lock];
	for (id xmlAlarm in xmlAlarms) {
		Alarm* alarm;

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

		NSFetchRequest *alarmRequest = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *alarmEntity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:context];
		[alarmRequest setEntity:alarmEntity];
		
		NSPredicate *alarmPredicate = [NSPredicate predicateWithFormat:@"alarmId == %@", alarmId];
		[alarmRequest setPredicate:alarmPredicate];
		
		NSError* error = nil;
		NSArray *alarmArray = [context executeFetchRequest:alarmRequest error:&error];
		if (!alarmArray || [alarmArray count] == 0) {
			if (error) {
				NSLog(@"%@: error fetching alarm for ID %@: %@", self, alarmId, [error localizedDescription]);
				[error release];
			}
			alarm = (Alarm*)[NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:context];
		} else {
			alarm = (Alarm*)[alarmArray objectAtIndex:0];
		}

		alarm.alarmId = alarmId;
		alarm.severity = severity;
		alarm.count = count;
		alarm.lastModified = lastModified;

		// UEI
		CXMLElement *ueiElement = [xmlAlarm elementForName:@"uei"];
		if (ueiElement) {
			alarm.uei = [[ueiElement childAtIndex:0] stringValue];
		} else {
			alarm.uei = nil;
		}
		
		// Log Message
		CXMLElement *lmElement = [xmlAlarm elementForName:@"logMessage"];
		if (lmElement) {
			alarm.logMessage = [self cleanUpString:[[lmElement childAtIndex:0] stringValue]];
		} else {
			alarm.logMessage = nil;
		}
		
		// First Event Time
		CXMLElement *ftElement = [xmlAlarm elementForName:@"firstEventTime"];
		if (ftElement) {
			alarm.firstEventTime = [dateFormatter dateFromString:[self stringForDate:[[ftElement childAtIndex:0] stringValue]]];
		} else {
			alarm.firstEventTime = nil;
		}
		
		// Last Event Time
		CXMLElement *ltElement = [xmlAlarm elementForName:@"lastEventTime"];
		if (ltElement) {
			alarm.lastEventTime = [dateFormatter dateFromString:[self stringForDate:[[ltElement childAtIndex:0] stringValue]]];
		} else {
			alarm.lastEventTime = nil;
		}
		
		// Ack Time
		CXMLElement *ackElement = [xmlAlarm elementForName:@"ackTime"];
		if (ackElement) {
			NSString* ackString = [self stringForDate:[[ackElement childAtIndex:0] stringValue]];
			NSDate* ackDate = [dateFormatter dateFromString:ackString];
			alarm.ackTime = ackDate;
		} else {
			alarm.ackTime = nil;
		}
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

	NSError* error = nil;
	if (![context save:&error]) {
		NSLog(@"%@: an error occurred saving the managed object context: %@", self, [error localizedDescription]);
		[error release];
	}
	[context unlock];
	[dateFormatter release];
	[super requestDidFinish:request];
	[self autorelease];
}

@end
