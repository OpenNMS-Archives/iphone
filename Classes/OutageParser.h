#import <Foundation/Foundation.h>
#import "OnmsOutage.h"
#import "OnmsEvent.h"
#import "DDXMLDocument.h"
#import "DDXMLElementAdditions.h"

@interface OutageParser : NSObject {
	@private NSMutableArray *outages;
}

-(BOOL)parse:(DDXMLElement *)node skipRegained:(BOOL)skip;
-(NSArray*)outages;
-(OnmsOutage*)outage;

@end
