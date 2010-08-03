//
//  OutageDataSource.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NodeDataSource.h"
#import "NodeModel.h"
#import "OutageModel.h"

@implementation NodeDataSource

@synthesize label = _label;

- (id)initWithNodeId:(NSString*)nodeId
{
	TTDINFO(@"init called");
	if (self = [super init]) {
		_nodeModel = [[NodeModel alloc] initWithNodeId:nodeId];
	}
	return self;
}

- (void)dealloc
{
	// Don't do this!  It's done for us.
	// TT_RELEASE_SAFELY(_nodeModel);
	[super dealloc];
}

- (id<TTModel>)model {
	return _nodeModel;
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
	NSMutableArray* items = [[NSMutableArray alloc] init];
	NSMutableArray* sections = [[NSMutableArray alloc] init];

	TTDINFO(@"model loaded");
	
	_label = _nodeModel.label;

	if (_nodeModel.outages && [_nodeModel.outages count] > 0) {
		[sections addObject:@"Outages"];

		NSMutableArray* outageItems = [NSMutableArray arrayWithCapacity:[_nodeModel.outages count]];
		for (id o in _nodeModel.outages) {
			OutageModel* outage = (OutageModel*)o;
			//		NSString* host = outage.host;
			NSString* host = nil;
			if (!host) {
				host = outage.ipAddress;
			}
			TTTableMessageItem* item = [[[TTTableMessageItem alloc] init] autorelease];
			item.title = host;
			item.text = outage.logMessage;
			item.timestamp = outage.ifLostService;
			[outageItems addObject:item];
		}
		[items addObject:outageItems];
	}
	
	self.items = items;
	self.sections = sections;
	
	TT_RELEASE_SAFELY(items);
	TT_RELEASE_SAFELY(sections);
}

@end
