//
//  AlarmListModel.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlarmModel.h"

@interface AlarmListModel : TTURLRequestModel {
	NSMutableArray* _alarms;
}

@property (nonatomic, copy) NSArray* alarms;

@end
