//
//  OutageModel.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPInterfaceModel : TTURLRequestModel {
  NSString* _interfaceId;
  NSString* _hostName;
  NSString* _ipAddress;
  NSString* _managed;
}

@property (nonatomic, copy) NSString* interfaceId;
@property (nonatomic, copy) NSString* hostName;
@property (nonatomic, copy) NSString* ipAddress;
@property (nonatomic, copy) NSString* managed;

+(NSArray*)interfacesFromXML:(NSData *)data;

@end
