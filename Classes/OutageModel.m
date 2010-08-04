//
//  OutageModel.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OutageModel.h"


@implementation OutageModel

@synthesize outageId          = _outageId;
@synthesize nodeId            = _nodeId;
@synthesize ifLostService     = _ifLostService;
@synthesize ifRegainedService = _ifRegainedService;
@synthesize ipAddress         = _ipAddress;
@synthesize host              = _host;
@synthesize serviceName       = _serviceName;
@synthesize severity          = _severity;
@synthesize logMessage        = _logMessage;
@synthesize desc              = _desc;
@synthesize uei               = _uei;

- (NSString*)description
{
  return [NSString stringWithFormat:@"OutageModel[%@/%@/%@/%@/%@]", _outageId, _ifLostService, _ipAddress, _serviceName, _severity];
}

@end
