//
//  OutageListModel.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OutageListModel : TTURLRequestModel {
	NSArray* _outages;
}

@property (nonatomic, copy) NSArray* outages;

+(NSArray*)outagesFromXML:(NSData*)data;

@end
