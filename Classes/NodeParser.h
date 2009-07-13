#import <Foundation/Foundation.h>
#import "OnmsNode.h"
#import "DDXMLDocument.h"
#import "DDXMLElementAdditions.h"

@interface NodeParser : NSObject {
	@private NSMutableArray *nodes;
}

-(BOOL)parse:(DDXMLElement*)node;
-(NSArray*)nodes;
-(OnmsNode*)node;

@end
