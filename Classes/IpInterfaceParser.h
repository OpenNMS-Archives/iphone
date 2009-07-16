//
//  IpInterfaceParser.h
//  OpenNMS
//
//  Created by Benjamin Reed on 7/15/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnmsIpInterface.h"

@interface IpInterfaceParser : NSObject {
	@private NSMutableArray *interfaces;
}

-(BOOL)parse:(CXMLElement*)node;
-(NSArray*)interfaces;
-(OnmsIpInterface*)interface;

@end
