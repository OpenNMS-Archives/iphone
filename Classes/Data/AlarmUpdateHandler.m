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

#import "AlarmUpdateHandler.h"
#import "OpenNMSAppDelegate.h"
#import "Alarm.h"
#import "RegexKitLite.h"

@implementation AlarmUpdateHandler

-(void) requestDidFinish:(ASIHTTPRequest*) request
{
	[stateLock lock];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:true];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];

	CXMLDocument* document = [self getDocumentForRequest:request];

	if (!document) {
		[stateLock unlock];
		[dateFormatter release];
		[super requestDidFinish:request];
		[self autorelease];
		return;
	}
	
	NSArray* xmlAlarms;
	if ([[[document rootElement] name] isEqual:@"alarm"]) {
		xmlAlarms = [NSArray arrayWithObject:[document rootElement]];
	} else {
		xmlAlarms = [[document rootElement] elementsForName:@"alarm"];
	}
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
				NSLog(@"unknown alarm attribute: %@", [attr name]);
#endif
			}
		}

		NSManagedObjectContext *moc = [contextService managedObjectContext];

		NSFetchRequest *alarmRequest = [[[NSFetchRequest alloc] init] autorelease];
		
		NSEntityDescription *alarmEntity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:moc];
		[alarmRequest setEntity:alarmEntity];
		
		NSPredicate *alarmPredicate = [NSPredicate predicateWithFormat:@"alarmId == %@", alarmId];
		[alarmRequest setPredicate:alarmPredicate];
		
		NSError* error = nil;
		NSArray *alarmArray = [moc executeFetchRequest:alarmRequest error:&error];
		if (!alarmArray || [alarmArray count] == 0) {
			if (error) {
				NSLog(@"error fetching alarm for ID %@: %@", alarmId, [error localizedDescription]);
				[error release];
			}
			alarm = (Alarm*)[NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:moc];
		} else {
			alarm = (Alarm*)[alarmArray objectAtIndex:0];
		}

		alarm.alarmId = alarmId;
		alarm.severity = severity;
		alarm.count = count;
		
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
			alarm.ackTime = [dateFormatter dateFromString:[self stringForDate:[[ackElement childAtIndex:0] stringValue]]];
		} else {
			alarm.ackTime = nil;
		}
	}

	NSError* error = nil;
	NSManagedObjectContext *moc = [(OpenNMSAppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
	if (![moc save:&error]) {
		NSLog(@"an error occurred saving the managed object context: %@", [error localizedDescription]);
		[error release];
	}

	if (self.objectList) {
		NSManagedObjectContext *context = [contextService managedObjectContext];
		[context lock];

		NSFetchRequest* req = [[[NSFetchRequest alloc] init] autorelease];
		[req setResultType:NSManagedObjectIDResultType];

		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:context];
		[req setEntity:entity];

		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastEventTime" ascending:NO];
		[req setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		[sortDescriptor release];

		NSError* error = nil;
		NSArray *array = [context executeFetchRequest:req error:&error];
		if (array == nil) {
			if (error) {
				NSLog(@"error fetching alarms: %@", [error localizedDescription]);
			} else {
				NSLog(@"error fetching alarms");
			}
		} else {
			[self.objectList removeAllObjects];
			[self.objectList addObjectsFromArray:array];
		}
		[context unlock];
	}

	[dateFormatter release];
	[stateLock unlock];
	[super requestDidFinish:request];
	[self autorelease];
}

@end