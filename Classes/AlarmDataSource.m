//
//  OutageDataSource.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmDataSource.h"
#import "AlarmModel.h"
#import "OutageModel.h"
#import "IPInterfaceModel.h"
#import "SNMPInterfaceModel.h"
#import "EventModel.h"

#import "ONMSSeverityItem.h"
#import "ONMSSeverityItemCell.h"

#import "Three20Core/NSDateAdditions.h"
#import "Three20Core/NSStringAdditions.h"

@implementation AlarmDataSource

@synthesize severity = _severity;

- (id)initWithAlarmId:(NSString*)alarmId
{
	if (self = [super init]) {
		_alarmModel = [[[AlarmModel alloc] initWithAlarmId:alarmId] retain];
	}
	return self;
}

- (void)dealloc
{
	// Don't do this!  It's done for us.
	// TT_RELEASE_SAFELY(_alarmModel);
  TT_RELEASE_SAFELY(_severity);
	[super dealloc];
}

- (id<TTModel>)model
{
	return _alarmModel;
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

  _severity = _alarmModel.severity;

  [sections addObject:@""];
  
  NSMutableArray* alarmItems = [NSMutableArray array];
  
  TTTableSubtextItem* item = [[[TTTableSubtextItem alloc] init] autorelease];
  item.text = @"UEI";
  item.caption = [_alarmModel.uei stringByReplacingOccurrencesOfString:@"uei.opennms.org/" withString:@""];
  [alarmItems addObject:item];
  
  [alarmItems addObject:[TTTableSubtextItem itemWithText:@"Severity" caption:_alarmModel.severity]];
  [alarmItems addObject:[TTTableSubtextItem itemWithText:@"# Events" caption:_alarmModel.eventCount]];
  [alarmItems addObject:[TTTableSubtextItem itemWithText:@"Log Message" caption:_alarmModel.logMessage]];
  [alarmItems addObject:[TTTableSubtextItem itemWithText:@"First Event" caption:[_alarmModel.firstEventTime description]]];
  if (![_alarmModel.lastEventTime isEqualToDate:_alarmModel.firstEventTime]) {
    [alarmItems addObject:[TTTableSubtextItem itemWithText:@"Last Event" caption:[_alarmModel.lastEventTime description]]];
  }
  if (_alarmModel.ackTime) {
    [alarmItems addObject:[TTTableSubtextItem itemWithText:@"Acknowledged" caption:[_alarmModel.ackTime description]]];
  } else {
    [alarmItems addObject:[TTTableSubtextItem itemWithText:@"Acknowledged" caption:@"never"]];
  }

  [items addObject:alarmItems];

  [sections addObject:@""];
  if (_alarmModel.ackTime) {
    [items addObject:[NSArray arrayWithObject:[TTTableButton itemWithText:@"Unacknowledge" URL:@"onms://alarms/1/unack"]]];
  } else {
    [items addObject:[NSArray arrayWithObject:[TTTableButton itemWithText:@"Acknowledge" URL:@"onms://alarms/1/ack"]]];
  }
   
  [sections addObject:@""];
  [items addObject:[NSArray arrayWithObject:[TTTableButton itemWithText:@"Escalate" URL:@"onms://alarms/1/escalate"]]];
    
  [sections addObject:@""];
  [items addObject:[NSArray arrayWithObject:[TTTableButton itemWithText:@"Clear" URL:@"onms://alarms/1/clear"]]];

  self.items = items;
	self.sections = sections;
	
	TT_RELEASE_SAFELY(items);
	TT_RELEASE_SAFELY(sections);
}

@end
