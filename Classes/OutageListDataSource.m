//
//  OutageDataSource.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OutageListDataSource.h"
#import "OutageListModel.h"
#import "OutageModel.h"

#import "ONMSSeverityItem.h"
#import "ONMSSeverityItemCell.h"

#import "Three20Core/NSStringAdditions.h"

@implementation OutageListDataSource

- (id)init
{
	if (self = [super init]) {
		_outageListModel = [[OutageListModel alloc] init];
	}
	return self;
}

- (void)dealloc
{
	// Don't do this!  It's done for us.
	// TT_RELEASE_SAFELY(_outageListModel);
	[super dealloc];
}

- (id<TTModel>)model
{
	return _outageListModel;
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
	NSArray* outages = _outageListModel.outages;

	for (id o in outages) {
		OutageModel* outage = (OutageModel*)o;
//		NSString* host = outage.host;
		NSString* host = nil;
		if (!host) {
			host = outage.ipAddress;
		}
    ONMSSeverityItem* item = [[[ONMSSeverityItem alloc] init] autorelease];
    item.text = [host stringByAppendingFormat:@"/%@", outage.serviceName];
    item.caption = [outage.logMessage stringByRemovingHTMLTags];
    item.timestamp = outage.ifLostService;
    item.severity = outage.severity;
		item.URL = [@"onms://nodes/" stringByAppendingString:outage.nodeId];
		[items addObject:item];
	}
	
	self.items = items;
	
	TT_RELEASE_SAFELY(items);
}

@end
