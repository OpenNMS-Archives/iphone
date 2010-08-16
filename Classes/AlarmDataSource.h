//
//  AlarmDataSource.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AlarmModel;

@interface AlarmDataSource : TTSectionedDataSource {
	AlarmModel* _alarmModel;
  NSString* _severity;
  id<NSObject> _ackDelegate;
}

@property (nonatomic, copy) NSString* severity;
@property (nonatomic, retain) id<NSObject> ackDelegate;

- (id)initWithAlarmId:(NSString*)alarmId;

@end
