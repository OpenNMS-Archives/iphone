//
//  AlarmModel.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Severity.h"

@interface AlarmModel : TTURLRequestModel {
	NSString* _alarmId;
	NSDate*   _ifLostService;
	NSString* _ipAddress;
	NSString* _host;
	NSString* _severity;
	NSString* _logMessage;
}

@property (nonatomic, copy) NSString* alarmId;
@property (nonatomic, copy) NSDate*   ifLostService;
@property (nonatomic, copy) NSString* ipAddress;
@property (nonatomic, copy) NSString* host;
@property (nonatomic, copy) NSString* severity;
@property (nonatomic, copy) NSString* logMessage;

@end
