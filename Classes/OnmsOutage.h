#import <Foundation/Foundation.h>

@class OnmsEvent, OnmsNode;

@interface OnmsOutage : NSObject {

	int outageId;
	NSDate* ifLostService;
	NSDate* ifRegainedService;
	OnmsEvent* serviceLostEvent;
	OnmsEvent* serviceRegainedEvent;
	NSString* serviceName;

}

@property (readwrite,assign) int outageId;
@property (retain) NSDate* ifLostService;
@property (retain) NSDate* ifRegainedService;
@property (retain) OnmsEvent* serviceLostEvent;
@property (retain) OnmsEvent* serviceRegainedEvent;
@property (retain) NSString* serviceName;

-(NSString*)description;

@end
