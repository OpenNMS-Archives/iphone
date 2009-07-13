#import <Foundation/Foundation.h>

@interface OnmsNode : NSObject {

	@private int nodeId;
	@private NSString* label;

}

@property (readwrite,assign) int nodeId;
@property (retain) NSString* label;

-(NSString*)description;

@end
