#import "OnmsOutage.h"
#import "OnmsEvent.h"

@implementation OnmsOutage

@synthesize outageId;
@synthesize ifLostService;
@synthesize ifRegainedService;
@synthesize serviceLostEvent;
@synthesize serviceRegainedEvent;
@synthesize serviceName;

-(NSString *)description
{
	return [NSString stringWithFormat: @"[id: %d, service %@ (lost: %@ at %@, regained: %@ at %@)]", outageId, serviceName, serviceLostEvent, ifLostService, serviceRegainedEvent, ifRegainedService];
}

@end
