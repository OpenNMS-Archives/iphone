#import <Foundation/Foundation.h>
#import "DDXMLDocument.h"
#import "DDXMLElementAdditions.h"

#import "OnmsOutage.h"
#import "ViewOutage.h"
#import "OnmsEvent.h"
#import "FuzzyDate.h"

@interface OutageParser : NSObject {
	@private NSMutableArray* outages;
	@private FuzzyDate* fuzzyDate;
}

-(BOOL)parse:(DDXMLElement*)node skipRegained:(BOOL)skip;
-(NSArray*)getViewOutages: (DDXMLElement*)node distinctNodes:(BOOL)distinct;
-(NSArray*)outages;
-(OnmsOutage*)outage;

@end
