//
//  InterfaceModel.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SNMPInterfaceModel.h"
#import "extThree20XML/extThree20XML.h"

@implementation SNMPInterfaceModel

@synthesize interfaceId = _interfaceId;
@synthesize ipAddress   = _ipAddress;
@synthesize ifIndex     = _ifIndex;
@synthesize ifSpeed     = _ifSpeed;
@synthesize ifDescr     = _ifDescr;

+(NSArray*)interfacesFromXML:(NSData *)data
{
	TTXMLParser* parser = [[TTXMLParser alloc] initWithData:data];
	parser.treatDuplicateKeysAsArrayItems = YES;
	[parser parse];

	NSMutableArray* interfaces = [[[NSMutableArray alloc] init] autorelease];

	NSArray* xmlInterfaces;
  if ([parser.rootObject valueForKey:@"snmpInterface"]) {
    if ([[parser.rootObject valueForKey:@"snmpInterface"] isKindOfClass:[NSArray class]]) {
      xmlInterfaces = [parser.rootObject valueForKey:@"snmpInterface"];
    } else {
      xmlInterfaces = [NSArray arrayWithObject:[parser.rootObject valueForKey:@"snmpInterface"]];
    }
    for (id i in xmlInterfaces) {
      SNMPInterfaceModel* interface = [[[SNMPInterfaceModel alloc] init] autorelease];
      
      interface.interfaceId = [i valueForKey:@"id"];
      interface.ipAddress = [[i valueForKey:@"ipAddress"] valueForKey:@"___Entity_Value___"];
      interface.ifIndex = [i valueForKey:@"ifIndex"];
      interface.ifSpeed = [[i valueForKey:@"ifSpeed"] valueForKey:@"___Entity_Value___"];
      interface.ifDescr = [[i valueForKey:@"ifDescr"] valueForKey:@"___Entity_Value___"];
      
      [interfaces addObject:interface];
    }
  }
  
	TT_RELEASE_SAFELY(parser);
	
	return interfaces;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"SNMPInterfaceModel[%@/%@/%@/%@/%@]", _interfaceId, _ipAddress, _ifIndex, _ifSpeed, _ifDescr];
}

@end
