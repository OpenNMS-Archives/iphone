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

		DDXMLElement* idElement = [xmlNode elementForName:@"nodeId"];
		if (idElement) {
			node.nodeId = [[[idElement childAtIndex:0] stringValue] intValue];
		}
		
		DDXMLElement* labelElement = [xmlNode elementForName:@"label"];
		if (labelElement) {
			node.label = [[labelElement childAtIndex:0] stringValue];
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
