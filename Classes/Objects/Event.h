//
//  Event.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/15/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Event :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * display;
@property (nonatomic, retain) NSNumber * log;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSNumber * eventId;
@property (nonatomic, retain) NSString * logMessage;
@property (nonatomic, retain) NSString * severity;
@property (nonatomic, retain) NSString * uei;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSString * eventHost;
@property (nonatomic, retain) NSDate * lastModified;

@end



