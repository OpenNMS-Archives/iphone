//
//  Node.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/15/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Node :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSDate * lastModified;

@end



