#import "OnmsXMLElementAdditions.h"

@implementation CXMLElement (OnmsAdditions)

/**
 * This method returns the first child element for the given name.
 * If no child element exists for the given name, returns nil.
**/
- (CXMLElement*)elementForName:(NSString*)name
{
	NSArray* elements = [self elementsForName:name];
	if([elements count] > 0)
	{
		return [elements objectAtIndex:0];
	} else {
		return nil;
	}
}

@end
