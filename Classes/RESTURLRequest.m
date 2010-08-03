//
//  RESTURLRequest.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RESTURLRequest.h"

@implementation RESTURLRequest

@synthesize modelName = _modelName;

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (RESTURLRequest*)request {
	return [[[RESTURLRequest alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (RESTURLRequest*)requestWithURL:(NSString*)URL delegate:(id /*<TTURLRequestDelegate>*/)delegate {
	return [[[RESTURLRequest alloc] initWithURL:URL delegate:delegate] autorelease];
}

@end
