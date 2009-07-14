#import <Foundation/Foundation.h>

@interface OnmsEvent : NSObject {
	@private int eventId;
	@private NSString* uei;
	@private NSDate* time;
	@private NSDate* createTime;
	@private NSString* host;
	@private int nodeId;
	@private NSString* source;
	@private int severity;
	@private NSString* eventDescr;
	@private NSString* eventHost;
	@private NSString* eventLogMessage;
	@private BOOL eventDisplay;
	@private BOOL eventLog;
}

@property (readwrite,assign) int eventId;
@property (retain) NSString* uei;
@property (retain) NSDate* time;
@property (retain) NSDate* createTime;
@property (retain) NSString* host;
@property (readwrite,assign) int nodeId;
@property (retain) NSString* source;
@property (readwrite,assign) int severity;
@property (retain) NSString* eventDescr;
@property (retain) NSString* eventHost;
@property (retain) NSString* eventLogMessage;
@property (readwrite,assign) BOOL eventDisplay;
@property (readwrite,assign) BOOL eventLog;

-(NSString*) description;

@end
