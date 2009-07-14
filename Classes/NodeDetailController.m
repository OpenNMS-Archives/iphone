//
//  NodeDetailController.m
//  OpenNMS
//
//  Created by Benjamin Reed on 7/14/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

#import "NodeDetailController.h"


@implementation NodeDetailController

@synthesize nodeId;

#pragma mark UIViewController delegates

-(void) viewWillAppear:(BOOL)animated
{
	NSLog(@"view will appear, node id = %@", nodeId);
}

@end
