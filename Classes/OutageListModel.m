//
//  OutageListModel.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OutageListModel.h"
#import "OutageModel.h"
#import "Severity.h"
#import "extThree20XML/extThree20XML.h"

@implementation OutageListModel

@synthesize outages = _outages;

- (void)dealloc
{
	TT_RELEASE_SAFELY(_outages);
	[super dealloc];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	if (!self.isLoading) {
		NSString* url = @"http://admin:admin@sin.local:8980/opennms/rest/outages?limit=50&orderBy=ifLostService&order=desc&ifRegainedService=null";
		
		TTURLRequest* request = [TTURLRequest requestWithURL:url delegate:self];
    request.cachePolicy = cachePolicy;

		id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
		request.response = response;
		TT_RELEASE_SAFELY(response);
		
		[request send];
	}
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
	TTURLDataResponse* response = request.response;
	
	TT_RELEASE_SAFELY(_outages);
	_outages = [[OutageListModel outagesFromXML:response.data withDuplicates:NO] retain];

	[super requestDidFinishLoad:request];
}

+(NSArray*)outagesFromXML:(NSData *)data withDuplicates:(BOOL)duplicates
{
  NSMutableArray* nodeIds = [NSMutableArray array];
  
	TTXMLParser* parser = [[TTXMLParser alloc] initWithData:data];
	parser.treatDuplicateKeysAsArrayItems = YES;
	[parser parse];
	
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterFullStyle];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
	
	int count = [[parser.rootObject valueForKey:@"count"] intValue];
	TTDINFO(@"outage count = %d", count);
	
	NSMutableArray* outages = [[[NSMutableArray alloc] init] autorelease];

	NSArray* xmlOutages;
  if ([parser.rootObject valueForKey:@"outage"]) {
    if ([[parser.rootObject valueForKey:@"outage"] isKindOfClass:[NSArray class]]) {
      xmlOutages = [parser.rootObject valueForKey:@"outage"];
    } else {
      xmlOutages = [NSArray arrayWithObject:[parser.rootObject valueForKey:@"outage"]];
    }
    for (id o in xmlOutages) {
      OutageModel* outage = [[[OutageModel alloc] init] autorelease];

      outage.outageId = [o valueForKey:@"id"];
      outage.ipAddress = [[o valueForKey:@"ipAddress"] valueForKey:@"___Entity_Value___"];
      outage.serviceName = [[[[o valueForKey:@"monitoredService"] valueForKey:@"serviceType"] valueForKey:@"name"] valueForKey:@"___Entity_Value___"];
      
      outage.ifLostService = [dateFormatter dateFromString:[[o valueForKey:@"ifLostService"] valueForKey:@"___Entity_Value___"]];
      NSString* ifRegainedService = [[o valueForKey:@"ifRegainedService"] valueForKey:@"___Entity_Value___"];
      if (ifRegainedService) {
        outage.ifRegainedService = [dateFormatter dateFromString:ifRegainedService];
      }
      
      NSDictionary* serviceLostEvent = [o valueForKey:@"serviceLostEvent"];
      outage.desc = [[serviceLostEvent valueForKey:@"description"] valueForKey:@"___Entity_Value___"];
      outage.host = [[serviceLostEvent valueForKey:@"host"] valueForKey:@"___Entity_Value___"];
      outage.logMessage = [[serviceLostEvent valueForKey:@"logMessage"] valueForKey:@"___Entity_Value___"];
      outage.uei = [[serviceLostEvent valueForKey:@"uei"] valueForKey:@"___Entity_Value___"];
      outage.severity = [serviceLostEvent valueForKey:@"severity"];

      NSString* nodeId = [[serviceLostEvent valueForKey:@"nodeId"] valueForKey:@"___Entity_Value___"];
      outage.nodeId = nodeId;

      if (duplicates) {
        [outages addObject:outage];
      } else if (![nodeIds containsObject:nodeId]) {
        [nodeIds addObject:nodeId];
        [outages addObject:outage];
      }
    }
  }

	TT_RELEASE_SAFELY(dateFormatter);
	TT_RELEASE_SAFELY(parser);
	
	return outages;
}

@end
