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
#import "ONMSURLRequestModel.h"

@interface AlarmModel : ONMSURLRequestModel {
  NSString* _alarmId;
  NSString* _uei;
  NSDate*   _firstEventTime;
  NSDate*   _lastEventTime;
  NSString* _eventCount;
  NSString* _ipAddress;
  NSString* _host;
  NSString* _label;
  NSString* _severity;
  NSString* _logMessage;
  NSDate*   _ackTime;
  NSString* _ackUser;
}

@property (nonatomic, copy) NSString* alarmId;
@property (nonatomic, copy) NSString* uei;
@property (nonatomic, copy) NSDate*   firstEventTime;
@property (nonatomic, copy) NSDate*   lastEventTime;
@property (nonatomic, copy) NSString* eventCount;
@property (nonatomic, copy) NSString* ipAddress;
@property (nonatomic, copy) NSString* host;
@property (nonatomic, copy) NSString* label;
@property (nonatomic, copy) NSString* severity;
@property (nonatomic, copy) NSString* logMessage;
@property (nonatomic, copy) NSDate*   ackTime;
@property (nonatomic, copy) NSString* ackUser;

- (id)initWithAlarmId:(NSString*)alarmId;

@end
