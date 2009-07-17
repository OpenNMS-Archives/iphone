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

#import <Foundation/Foundation.h>

@interface ViewOutage : NSObject {
	@private NSNumber* outageId;
	@private NSString* serviceName;
	@private NSString* serviceLostDate;
	@private NSString* serviceRegainedDate;
	@private NSNumber* nodeId;
	@private NSString* nodeLabel;
	@private NSString* ipAddress;
}

@property (nonatomic,retain) NSNumber* outageId;
@property (nonatomic,retain) NSString* serviceName;
@property (nonatomic,retain) NSString* serviceLostDate;
@property (nonatomic,retain) NSString* serviceRegainedDate;
@property (nonatomic,retain) NSNumber* nodeId;
@property (nonatomic,retain) NSString* nodeLabel;
@property (nonatomic,retain) NSString* ipAddress;

-(NSString*) getCellText;
-(NSString*) description;

@end
