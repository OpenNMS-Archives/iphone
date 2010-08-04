//
//  NodeViewController.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NodeViewController.h"
#import "NodeDataSource.h"

@implementation NodeViewController

@synthesize nodeId = _nodeId;

- (id)initWithNodeId:(NSString*)nid
{
	if (self = [self init]) {
		TTDINFO(@"initialized with node ID %@", nid);
		self.nodeId = nid;
		self.title = [@"Node #" stringByAppendingString:nid];
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (void)loadView
{
	TTDINFO(@"loadView called");
	self.tableViewStyle = UITableViewStyleGrouped;
	self.variableHeightRows = YES;
  self.navigationBarTintColor = [UIColor colorWithRed:(54.0/255.0) green:(105.0/255.0) blue:(3.0/255.0) alpha:1.0];
	[super loadView];
}

- (void)createModel
{
	TTDINFO(@"createModel called");
	self.dataSource = [[[NodeDataSource alloc] initWithNodeId:_nodeId] autorelease];
}

@end
