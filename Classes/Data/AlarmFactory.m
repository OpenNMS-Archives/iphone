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

#import "AlarmFactory.h"

#import "ALarmUpdater.h"
#import "AlarmUpdateHandler.h"

#import "ContextService.h"

@implementation AlarmFactory

@synthesize isFinished;
@synthesize factoryLock;

static AlarmFactory* alarmFactorySingleton = nil;
static ContextService* contextService = nil;

// 2 weeks
#define CUTOFF (60.0 * 60.0 * 24.0 * 14.0)

+(void) initialize
{
	static BOOL initialized = NO;
	if (!initialized)
	{
		initialized = YES;
		alarmFactorySingleton = [[AlarmFactory alloc] init];
		contextService = [[ContextService alloc] init];
	}
}

+(AlarmFactory*) getInstance
{
	if (alarmFactorySingleton == nil) {
		[AlarmFactory initialize];
	}
	return alarmFactorySingleton;
}

-(id) init
{
	if (self = [super init]) {
		isFinished = NO;
		factoryLock = [NSRecursiveLock new];
	}
	return self;
}

-(void) finish
{
	isFinished = YES;
}

-(Alarm*) getCoreDataAlarm:(NSNumber*) alarmId
{
	Alarm* alarm = nil;
	NSManagedObjectContext* context = [contextService managedObjectContext];
	
	NSFetchRequest* request = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:context];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"alarmId == %@", alarmId];
	[request setPredicate:predicate];
	
	NSError* error = nil;
	NSArray* results = [context executeFetchRequest:request error:&error];
	[request release];
	if (!results || [results count] == 0) {
		if (error) {
			NSLog(@"error fetching alarm for ID %@: %@", alarmId, [error localizedDescription]);
			[error release];
		}
		return nil;
	} else {
		alarm = (Alarm*)[results objectAtIndex:0];
		[context refreshObject:alarm mergeChanges:NO];
	}
	return alarm;
}

-(Alarm*) getRemoteAlarm:(NSNumber*) alarmId
{
	Alarm* alarm = nil;

	if (alarmId) {
		[factoryLock lock];
		AlarmUpdater* alarmUpdater = [[AlarmUpdater alloc] initWithAlarmId:alarmId];
		AlarmUpdateHandler* alarmHandler = [[AlarmUpdateHandler alloc] initWithMethod:@selector(finish) target:self];
		alarmUpdater.handler = alarmHandler;
		[alarmUpdater update];
		[alarmUpdater release];
		
		NSDate* loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
		while (!isFinished) {
#if DEBUG
			NSLog(@"waiting for getRemoteAlarm");
#endif
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
		}
		alarm = [self getCoreDataAlarm:alarmId];
		[factoryLock unlock];
	}

	return alarm;
}


-(Alarm*) getAlarm:(NSNumber*) alarmId
{
	Alarm* alarm = [self getCoreDataAlarm:alarmId];

	if (!alarm || ([alarm.lastModified timeIntervalSinceNow] > CUTOFF)) {
#if DEBUG
		NSLog(@"alarm %@ not found, or last modified out of date", alarmId);
#endif
		alarm = [self getRemoteAlarm:alarmId];
	}

	NSLog(@"returning alarm: %@", alarm);
	return alarm;
}

@end
