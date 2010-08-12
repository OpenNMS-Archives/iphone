//
//  AlarmViewController.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmViewController : TTTableViewController {
	NSString* _alarmId;
  UIBarButtonItem* _activityItem;
  UIBarButtonItem* _refreshButton;
}

@property (nonatomic, copy) NSString* alarmId;

- (id)initWithAlarmId:(NSString*)aid;

@end
