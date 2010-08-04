//
//  OutageModel.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Severity.h"

@interface OutageModel : TTURLRequestModel {
	NSString* _outageId;
	NSString* _nodeId;
	NSDate*   _ifLostService;
	NSDate*   _ifRegainedService;
	NSString* _ipAddress;
	NSString* _host;
	NSString* _serviceName;
	NSString* _severity;
	NSString* _logMessage;
	NSString* _desc;
	NSString* _uei;
}

@property (nonatomic, copy) NSString* outageId;
@property (nonatomic, copy) NSString* nodeId;
@property (nonatomic, copy) NSDate*   ifLostService;
@property (nonatomic, copy) NSDate*   ifRegainedService;
@property (nonatomic, copy) NSString* ipAddress;
@property (nonatomic, copy) NSString* host;
@property (nonatomic, copy) NSString* serviceName;
@property (nonatomic, copy) NSString* severity;
@property (nonatomic, copy) NSString* logMessage;
@property (nonatomic, copy) NSString* desc;
@property (nonatomic, copy) NSString* uei;

@end
