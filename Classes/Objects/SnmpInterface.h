//
//  SnmpInterface.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/15/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface SnmpInterface :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * interfaceId;
@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSString * ifDescription;
@property (nonatomic, retain) NSString * ipAddress;
@property (nonatomic, retain) NSNumber * ifStatus;
@property (nonatomic, retain) NSNumber * ifSpeed;
@property (nonatomic, retain) NSNumber * ifIndex;
@property (nonatomic, retain) NSString * physAddr;
@property (nonatomic, retain) NSString * collectFlag;
@property (nonatomic, retain) NSDate * lastModified;

@end



