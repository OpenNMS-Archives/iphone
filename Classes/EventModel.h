//
//  EventModel.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EventModel : TTURLRequestModel {
  NSString* _eventId;
  NSString* _uei;
  NSString* _severity;
  NSString* _logMessage;
  NSDate*   _timestamp;
}

@property (nonatomic, copy) NSString* eventId;
@property (nonatomic, copy) NSString* uei;
@property (nonatomic, copy) NSString* severity;
@property (nonatomic, copy) NSString* logMessage;
@property (nonatomic, copy) NSDate* timestamp;

+(NSArray*)eventsFromXML:(NSData *)data;

@end
