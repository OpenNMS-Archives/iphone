//
//  Alarm.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/6/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Alarm :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * alarmId;
@property (nonatomic, retain) NSString * uei;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSDate * firstEventTime;
@property (nonatomic, retain) NSDate * lastEventTime;
@property (nonatomic, retain) NSDate * ackTime;
@property (nonatomic, retain) NSNumber * ifIndex;
@property (nonatomic, retain) NSString * severity;
@property (nonatomic, retain) NSString * logMessage;

@end



