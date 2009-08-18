//
//  Outage.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/15/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Outage :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSNumber * outageId;
@property (nonatomic, retain) NSDate * ifLostService;
@property (nonatomic, retain) NSString * ipAddress;
@property (nonatomic, retain) NSDate * ifRegainedService;
@property (nonatomic, retain) NSNumber * serviceRegainedEventId;
@property (nonatomic, retain) NSString * serviceName;
@property (nonatomic, retain) NSNumber * serviceLostEventId;

@end



