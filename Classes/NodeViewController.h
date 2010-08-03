//
//  NodeViewController.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NodeViewController : TTTableViewController {
	NSString* _nodeId;
}

@property (nonatomic, copy) NSString* nodeId;

- (id)initWithNodeId:(NSString*)nid;

@end
