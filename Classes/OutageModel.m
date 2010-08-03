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

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
	if (!self.isLoading && TTIsStringWithAnyText(_outageId)) {
		NSString* url = [@"http://admin:admin@sin.local:8980/opennms/rest/outages/" stringByAppendingString:_outageId];

		TTURLRequest* request = [TTURLRequest requestWithURL: url delegate: self];

		id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
		request.response = response;
		TT_RELEASE_SAFELY(response);
		
		[request send];
	}
}

@end
