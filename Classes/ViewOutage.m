#import "ViewOutage.h"

@implementation ViewOutage

@synthesize outageId;
@synthesize serviceLostDate;
@synthesize serviceLost;
@synthesize nodeId;
@synthesize nodeLabel;

-(NSString*) getCellText
{
	return [NSString stringWithFormat: @"%@ Down %@", nodeLabel, serviceLostDate];
}

-(NSString*) description
{
	return [NSString stringWithFormat: @"[outage id: %d, node id: %d, node: %@, service: %@, lost: %@]", outageId, nodeId, nodeLabel, serviceLost, serviceLostDate];
}

@end
