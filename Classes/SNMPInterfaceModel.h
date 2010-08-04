//
//  OutageModel.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNMPInterfaceModel : TTURLRequestModel {
  NSString* _interfaceId;
  NSString* _ipAddress;
  NSString* _ifIndex;
  NSString* _ifSpeed;
  NSString* _ifDescr;
}

@property (nonatomic, copy) NSString* interfaceId;
@property (nonatomic, copy) NSString* ipAddress;
@property (nonatomic, copy) NSString* ifIndex;
@property (nonatomic, copy) NSString* ifSpeed;
@property (nonatomic, copy) NSString* ifDescr;

+(NSArray*)interfacesFromXML:(NSData *)data;

@end
