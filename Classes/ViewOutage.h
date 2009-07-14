#import <Foundation/Foundation.h>
#import "FuzzyDate.h"

@interface ViewOutage : NSObject {
	@private int outageId;
	@private NSString* serviceLostDate;
	@private NSString* serviceLost;
	@private int nodeId;
	@private NSString* nodeLabel;
}

@property (readwrite,assign) int outageId;
@property (retain) NSString* serviceLostDate;
@property (retain) NSString* serviceLost;
@property (readwrite,assign) int nodeId;
@property (retain) NSString* nodeLabel;

-(NSString*) getCellText;
-(NSString*) description;

@end
