//
//  NodeDataSource.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NodeModel;

@interface NodeDataSource : TTSectionedDataSource {
	NodeModel* _nodeModel;
	NSString* _label;
}

@property (nonatomic, copy) NSString* label;

- (id)initWithNodeId:(NSString*)nodeId;

@end
