#import <Foundation/Foundation.h>
#import "OnmsEvent.h"
#import "DDXMLDocument.h"
#import "DDXMLElementAdditions.h"

@interface EventParser : NSObject {
@private NSMutableArray *events;
}

-(BOOL)parse:(DDXMLElement *)node;
-(NSArray *)events;
-(OnmsEvent *)event;
@end
