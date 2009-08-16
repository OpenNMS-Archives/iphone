//
//  IpInterface.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/15/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface IpInterface :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * interfaceId;
@property (nonatomic, retain) NSString * hostName;
@property (nonatomic, retain) NSString * managedFlag;
@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSString * ipAddress;
@property (nonatomic, retain) NSDate * lastCapsdPoll;
@property (nonatomic, retain) NSNumber * ifIndex;
@property (nonatomic, retain) NSString * snmpPrimaryFlag;

@end



