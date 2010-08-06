//
//  AlarmModel.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmModel.h"


@implementation AlarmModel

@synthesize alarmId       = _alarmId;
@synthesize ifLostService = _ifLostService;
@synthesize ipAddress     = _ipAddress;
@synthesize host          = _host;
@synthesize severity      = _severity;
@synthesize logMessage    = _logMessage;

- (NSString*)description
{
  return [NSString stringWithFormat:@"AlarmModel[%@/%@/%@/%@/%@]", _alarmId, _ifLostService, _ipAddress, _severity, _logMessage];
}

@end
