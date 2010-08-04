//
//  InterfaceModel.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IPInterfaceModel.h"
#import "extThree20XML/extThree20XML.h"

@implementation IPInterfaceModel

@synthesize interfaceId = _interfaceId;
@synthesize hostName    = _hostName;
@synthesize ipAddress   = _ipAddress;
@synthesize managed     = _managed;

+ (NSArray*)interfacesFromXML:(NSData *)data
{
	TTXMLParser* parser = [[TTXMLParser alloc] initWithData:data];
	parser.treatDuplicateKeysAsArrayItems = YES;
	[parser parse];

	NSMutableArray* interfaces = [[[NSMutableArray alloc] init] autorelease];

	NSArray* xmlInterfaces;
  if ([parser.rootObject valueForKey:@"ipInterface"]) {
    if ([[parser.rootObject valueForKey:@"ipInterface"] isKindOfClass:[NSArray class]]) {
      xmlInterfaces = [parser.rootObject valueForKey:@"ipInterface"];
    } else {
      xmlInterfaces = [NSArray arrayWithObject:[parser.rootObject valueForKey:@"ipInterface"]];
    }
    for (id i in xmlInterfaces) {
      IPInterfaceModel* interface = [[[IPInterfaceModel alloc] init] autorelease];
      
      interface.interfaceId = [i valueForKey:@"id"];
      interface.hostName = [[i valueForKey:@"hostName"] valueForKey:@"___Entity_Value___"];
      interface.ipAddress = [[i valueForKey:@"ipAddress"] valueForKey:@"___Entity_Value___"];
      interface.managed = [i valueForKey:@"isManaged"];
      
      [interfaces addObject:interface];
    }
  }
  
	TT_RELEASE_SAFELY(parser);
	
	return interfaces;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"IPInterfaceModel[%@/%@/%@/%@]", _interfaceId, _hostName, _ipAddress, _managed];
}

@end
