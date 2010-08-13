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
  NSArray* _ipInterfaces;
  NSArray* _snmpInterfaces;
  NSArray* _events;

	int _inProgressCount;
}

@property (nonatomic, copy) NSString* nodeId;
@property (nonatomic, copy) NSString* label;
@property (nonatomic, copy) NSArray* outages;
@property (nonatomic, copy) NSArray* ipInterfaces;
@property (nonatomic, copy) NSArray* snmpInterfaces;
@property (nonatomic, copy) NSArray* events;

- (id)initWithNodeId:(NSString*)nodeId;

@end
