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
#import "ContextService.h"

@implementation ContextService

static NSManagedObjectModel* managedObjectModel;
static NSPersistentStoreCoordinator* persistentStoreCoordinator;

- (id)init
{
	if (self = [super init]) {
#if DEBUG
		NSLog(@"%@: initializing ContextService", self);
#endif
		NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(mergeContextChanges:) name:NSManagedObjectContextDidSaveNotification object:nil];
	}
	return self;
}

- (void) dealloc
{
	_readContext = nil;
	_writeContext = nil;
	[super dealloc];
}

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"OpenNMS.sqlite"]];
	
	NSError *error = nil;
	NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle: [error localizedDescription]
								   message: [error localizedFailureReason]
								   delegate:self
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
        [errorAlert show];
        [errorAlert autorelease];
		
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *) readContext
{
	if (!_readContext) {
		NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] init];
		[moc setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
		_readContext = moc;
	}
	return _readContext;
}

- (NSManagedObjectContext *) writeContext
{
	if (!_writeContext) {
		NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] init];
		[moc setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
		_writeContext = moc;
	}
	return _writeContext;
}

- (void) mergeContextChanges:(NSNotification *)notification
{
	if ([notification object] == [self readContext]) {
#if DEBUG
		NSLog(@"%@: received changes from the read context; skipping", self);
#endif
		return;
	}

	if (![NSThread isMainThread]) {
#if DEBUG
		NSLog(@"%@: mergeContextChanges called on non-main thread, re-calling", self);
#endif
	    [self performSelectorOnMainThread:@selector(mergeContextChanges:) withObject:notification waitUntilDone:YES];
	    return;
	}

#if DEBUG
	NSLog(@"%@: merging context changes to read context: %@", self, notification);
#endif
	[[self readContext] mergeChangesFromContextDidSaveNotification:notification];
}

@end
