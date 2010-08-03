//
//  RESTURLRequest.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RESTURLRequest : TTURLRequest {
	NSString* _modelName;
}

@property (retain) NSString* modelName;

+ (RESTURLRequest*)request;
+ (RESTURLRequest*)requestWithURL:(NSString*)URL delegate:(id /*<TTURLRequestDelegate>*/)delegate;

@end
