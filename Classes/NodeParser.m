#import "NodeParser.h"

@implementation NodeParser

- (void)dealloc
{
	[nodes release];
	[super dealloc];
}

- (BOOL)parse:(DDXMLElement*)n
{
	// Reinitialize the node array
	[nodes release];
	nodes = [[NSMutableArray alloc] init];
	
	NSArray* xmlNodes = [n elementsForName:@"node"];
	if ([xmlNodes count] == 0) {
		xmlNodes = [[NSArray alloc] initWithObjects:n, nil];
	}
	for (id xmlNode in xmlNodes) {
		OnmsNode* node = [[OnmsNode alloc] init];

		for (id attr in [xmlNode attributes]) {
			if ([[attr name] isEqual:@"id"]) {
				node.nodeId = [[attr stringValue] intValue];
			} else if ([[attr name] isEqual:@"label"]) {
				node.label = [attr stringValue];
			}
		}
		
		[nodes addObject: node];
	}
	return true;
}

- (NSArray*)nodes
{
	return nodes;
}

- (OnmsNode*)node
{
	if ([nodes count] > 0) {
		return [nodes objectAtIndex:0];
	} else {
		return nil;
	}
}

@end
