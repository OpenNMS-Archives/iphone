//
//  Alarm.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/15/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Alarm :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * severity;
@property (nonatomic, retain) NSDate * lastEventTime;
@property (nonatomic, retain) NSNumber * alarmId;
@property (nonatomic, retain) NSDate * firstEventTime;
@property (nonatomic, retain) NSDate * ackTime;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSNumber * lastEventId;
@property (nonatomic, retain) NSString * logMessage;
@property (nonatomic, retain) NSNumber * ifIndex;
@property (nonatomic, retain) NSString * uei;

@end



