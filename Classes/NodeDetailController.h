//
//  NodeDetailController.h
//  OpenNMS
//
//  Created by Benjamin Reed on 7/14/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NodeDetailController : UIViewController {
	NSNumber* nodeId;
}

@property (retain) NSNumber* nodeId;

@end
