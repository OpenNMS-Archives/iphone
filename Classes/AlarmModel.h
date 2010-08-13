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
  NSString* _uei;
	NSDate*   _firstEventTime;
  NSDate*   _lastEventTime;
	NSString* _ipAddress;
	NSString* _host;
	NSString* _severity;
	NSString* _logMessage;
  NSDate*   _ackTime;
  NSString* _ackUser;
}

@property (nonatomic, copy) NSString* alarmId;
@property (nonatomic, copy) NSString* uei;
@property (nonatomic, copy) NSDate*   firstEventTime;
@property (nonatomic, copy) NSDate*   lastEventTime;
@property (nonatomic, copy) NSString* ipAddress;
@property (nonatomic, copy) NSString* host;
@property (nonatomic, copy) NSString* severity;
@property (nonatomic, copy) NSString* logMessage;
@property (nonatomic, copy) NSDate*   ackTime;
@property (nonatomic, copy) NSString* ackUser;

@end
