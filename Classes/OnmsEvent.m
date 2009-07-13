#import "OnmsEvent.h"

@implementation OnmsEvent

@synthesize eventId;
@synthesize uei;
@synthesize time;
@synthesize createTime;
@synthesize host;
@synthesize nodeId;
@synthesize source;
@synthesize severity;
@synthesize eventDescr;
@synthesize eventLogMessage;
@synthesize eventHost;
@synthesize eventDisplay;
@synthesize eventLog;

-(NSString *)description
{
	return [NSString stringWithFormat: @"[id: %d, node: %d, uei: %@]", eventId, nodeId, uei];
}

@end
