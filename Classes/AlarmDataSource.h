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
}

- (id)initWithAlarmId:(NSString*)alarmId;

@end
