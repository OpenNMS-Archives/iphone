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
		self.nodeId = [nid retain];
		self.title = [@"Node #" stringByAppendingString:nid];
	}
	return self;
}

- (void)dealloc
{
  TT_RELEASE_SAFELY(_nodeId);

  [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

// Hmm, no good with large node labels
/*
- (void)modelDidFinishLoad:(id <TTModel>)model
{
  if (_model == model) {
    NSString* label = ((NodeDataSource*)self.dataSource).label;
    if (label) {
      self.title = [label stringByAppendingFormat:@" (%@)", _nodeId];
    }
  }
  [super modelDidFinishLoad:model];
}
*/

- (void)loadView
{
	self.tableViewStyle = UITableViewStyleGrouped;
	self.variableHeightRows = YES;
	[super loadView];
}

- (void)createModel
{
	self.dataSource = [[[NodeDataSource alloc] initWithNodeId:_nodeId] autorelease];
}

@end
