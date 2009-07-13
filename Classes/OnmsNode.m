#import "OnmsNode.h"

@implementation OnmsNode

@synthesize nodeId;
@synthesize label;

-(NSString *)description
{
	return [NSString stringWithFormat: @"[id: %d, label: %@]", nodeId, label];
}

@end
