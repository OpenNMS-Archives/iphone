#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "OutageParser.h"
#import "NodeParser.h"
#import "OnmsNode.h"

@interface OpenNMSRestAgent : NSObject {
}

-(OnmsNode*) getNode:(int) nodeId;
-(NSArray*) getOutages;

@end
