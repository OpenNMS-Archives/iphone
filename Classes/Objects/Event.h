/*******************************************************************************
 * This file is part of the OpenNMS(R) iPhone Application.
 * OpenNMS(R) is a registered trademark of The OpenNMS Group, Inc.
 *
 * Copyright (C) 2009 The OpenNMS Group, Inc.  All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc.:
 *
 *      51 Franklin Street
 *      5th Floor
 *      Boston, MA 02110-1301
 *      USA
 *
 * For more information contact:
 *
 *      OpenNMS Licensing <license@opennms.org>
 *      http://www.opennms.org/
 *      http://www.opennms.com/
 *
 *******************************************************************************/

#import <CoreData/CoreData.h>


@interface Event :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSString * uei;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSNumber * display;
@property (nonatomic, retain) NSString * severity;
@property (nonatomic, retain) NSString * eventHost;
@property (nonatomic, retain) NSNumber * eventId;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSNumber * log;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * logMessage;

@end



