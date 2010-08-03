//
//  OutageModel.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NodeModel : TTURLRequestModel {
	NSString* _nodeId;
	NSString* _label;
	NSArray* _outages;

	int _inProgressCount;
	
	NSDateFormatter* _dateFormatter;
}

@property (nonatomic, copy) NSString* nodeId;
@property (nonatomic, copy) NSString* label;
@property (nonatomic, copy) NSArray* outages;

- (id)initWithNodeId:(NSString*)nodeId;

@end
