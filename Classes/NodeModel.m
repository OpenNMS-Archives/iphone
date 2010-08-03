//
//  OutageModel.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NodeModel.h"
#import "OutageListModel.h"
#import "extThree20XML/extThree20XML.h"
#import "RESTURLRequest.h"

@implementation NodeModel

@class RESTURLRequest;

@synthesize nodeId  = _nodeId;
@synthesize label   = _label;
@synthesize outages = _outages;

- (id)initWithNodeId:(NSString*)nodeId
{
	if (self = [super init]) {
		TTDINFO(@"init called");
		self.nodeId = nodeId;
		_inProgressCount = 0;

		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setTimeStyle:NSDateFormatterFullStyle];
		[_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
	}
	return self;
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_dateFormatter);
	TT_RELEASE_SAFELY(_outages);
	TT_RELEASE_SAFELY(_nodeId);
	TT_RELEASE_SAFELY(_label);
	[super dealloc];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
	TTDINFO(@"load called");
	if (!self.isLoading && _nodeId != nil) {
		TTDINFO(@"sending requests for node %@", _nodeId);
		_inProgressCount = 2;

		RESTURLRequest* request = [RESTURLRequest requestWithURL:[@"http://admin:admin@sin.local:8980/opennms/rest/nodes/" stringByAppendingString:_nodeId] delegate:self];
		request.modelName = @"nodes";

		id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
		request.response = response;
		TT_RELEASE_SAFELY(response);

		[request send];

		request = [RESTURLRequest requestWithURL:[@"http://admin:admin@sin.local:8980/opennms/rest/outages/forNode/" stringByAppendingFormat:@"%@?limit=%d&orderBy=ifLostService&order=desc", _nodeId, 50] delegate:self];
		request.modelName = @"outages";

		response = [[TTURLDataResponse alloc] init];
		request.response = response;
		TT_RELEASE_SAFELY(response);

		[request send];
	}
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	TTURLDataResponse* response = request.response;
	NSString* modelName = ((RESTURLRequest*)request).modelName;

	_inProgressCount--;

	TTDINFO(@"Got response for model %@", modelName);

	NSString* string = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
	TTDINFO(@"URL response: %@", string);

	if (TTIsStringWithAnyText(string)) {
		TTXMLParser* parser = [[TTXMLParser alloc] initWithData:response.data];
		parser.treatDuplicateKeysAsArrayItems = YES;
		[parser parse];

		TTDINFO(@"parsed xml: %@", parser.rootObject);

		if ([modelName isEqualToString:@"nodes"]) {
			TT_RELEASE_SAFELY(_nodeId);
			TT_RELEASE_SAFELY(_label);

			_nodeId = [parser.rootObject valueForKey:@"id"];
			_label  = [[parser.rootObject valueForKey:@"label"] copy];
		} else if ([modelName isEqualToString:@"outages"]) {
			TT_RELEASE_SAFELY(_outages);
			_outages = [OutageListModel outagesFromXML:response.data];
		} else {
			TTDWARNING(@"unmatched model name: %@", modelName);
		}

		TT_RELEASE_SAFELY(parser);
		TTDINFO(@"finished parsing xml");
	}
	TT_RELEASE_SAFELY(string);

	TTDINFO(@"finished loading");

	if (_inProgressCount == 0) {
		[super requestDidFinishLoad:request];
	}
}

@end
