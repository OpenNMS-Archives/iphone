/*******************************************************************************
 * This file is part of the OpenNMS(R) iPhone Application.
 * OpenNMS(R) is a registered trademark of The OpenNMS Group, Inc.
 *
 * Copyright (C) 2010 The OpenNMS Group, Inc.  All rights reserved.
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
#import "Severity.h"

@interface OutageModel : TTURLRequestModel {
	NSString* _outageId;
	NSString* _nodeId;
	NSDate*   _ifLostService;
	NSDate*   _ifRegainedService;
	NSString* _ipAddress;
	NSString* _host;
	NSString* _serviceName;
	NSString* _severity;
	NSString* _logMessage;
	NSString* _desc;
	NSString* _uei;
}

@property (nonatomic, copy) NSString* outageId;
@property (nonatomic, copy) NSString* nodeId;
@property (nonatomic, copy) NSDate*   ifLostService;
@property (nonatomic, copy) NSDate*   ifRegainedService;
@property (nonatomic, copy) NSString* ipAddress;
@property (nonatomic, copy) NSString* host;
@property (nonatomic, copy) NSString* serviceName;
@property (nonatomic, copy) NSString* severity;
@property (nonatomic, copy) NSString* logMessage;
@property (nonatomic, copy) NSString* desc;
@property (nonatomic, copy) NSString* uei;

@end
