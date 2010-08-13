//
//  AlarmDataSource.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmListDataSource.h"
#import "AlarmListModel.h"
#import "AlarmModel.h"

#import "ONMSSeverityItem.h"
#import "ONMSSeverityItemCell.h"

#import "Three20Core/NSStringAdditions.h"

@implementation AlarmListDataSource

- (id)init
{
	TTDINFO(@"init called");
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
//		NSString* host = alarm.host;
		NSString* host = nil;
		if (!host) {
			host = alarm.ipAddress;
		}
		ONMSSeverityItem* item = [[[ONMSSeverityItem alloc] init] autorelease];
		item.text = host;
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
