#import "EventParser.h"

@implementation EventParser

- (void)dealloc
{
	[events release];
	[super dealloc];
}

- (BOOL)parse:(DDXMLElement *)node
{
    // Release the old eventArray
    [events release];
	
    // Create a new, empty itemArray
    events = [[NSMutableArray alloc] init];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:true];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];

	NSArray* xmlEvents = [node elementsForName:@"serviceLostEvent"];
	if ([xmlEvents count] == 0) {
		xmlEvents = [node elementsForName:@"serviceRegainedEvent"];
	}
	if ([xmlEvents count] == 0) {
		xmlEvents = [node elementsForName:@"event"];
	}
	if ([xmlEvents count] == 0) {
		xmlEvents = [[NSArray alloc] initWithObjects:node, nil];
	}
	for (id xmlEvent in xmlEvents) {
		OnmsEvent *event = [[OnmsEvent alloc] init];

		// ID
		for (id attr in [xmlEvent attributes]) {
			if ([[attr name] isEqual:@"id"]) {
				[event setEventId: [[attr stringValue] intValue]];
			} else if ([[attr name] isEqual:@"display"]) {
				[event setEventDisplay: [[attr stringValue] boolValue]];
			} else if ([[attr name] isEqual:@"log"]) {
				[event setEventLog: [[attr stringValue] boolValue]];
			} else if ([[attr name] isEqual:@"severity"]) {
				[event setSeverity: [[attr stringValue] intValue]];
			} else {
				NSLog(@"unknown event attribute: %@", [attr name]);
			}
		}
		
		// Time
		DDXMLElement *timeElement = [xmlEvent elementForName:@"time"];
		if (timeElement) {
			[event setTime: [dateFormatter dateFromString:[[timeElement childAtIndex:0] stringValue]]];
		}

		// CreateTime
		DDXMLElement *ctElement = [xmlEvent elementForName:@"createTime"];
		if (ctElement) {
			[event setCreateTime: [dateFormatter dateFromString:[[ctElement childAtIndex:0] stringValue]]];
		}
		
		// Description
		DDXMLElement *descrElement = [xmlEvent elementForName:@"description"];
		if (descrElement) {
			[event setEventDescr:[[descrElement childAtIndex:0] stringValue]];
		}

		// Host
		DDXMLElement *hostElement = [xmlEvent elementForName:@"host"];
		if (hostElement) {
			[event setEventHost:[[hostElement childAtIndex:0] stringValue]];
		}

		// Log Message
		DDXMLElement *lmElement = [xmlEvent elementForName:@"logMessage"];
		if (lmElement) {
			[event setEventLogMessage:[[lmElement childAtIndex:0] stringValue]];
		}
		
		// Source
		DDXMLElement *sourceElement = [xmlEvent elementForName:@"source"];
		if (sourceElement) {
			[event setSource:[[sourceElement childAtIndex:0] stringValue]];
		}

		// UEI
		DDXMLElement *ueiElement = [xmlEvent elementForName:@"uei"];
		if (ueiElement) {
			[event setUei:[[ueiElement childAtIndex:0] stringValue]];
		}

		// Node ID
		DDXMLElement *nodeElement = [xmlEvent elementForName:@"nodeId"];
		if (nodeElement) {
			[event setNodeId:[[[nodeElement childAtIndex:0] stringValue] intValue]];
		}
		
		// TODO: parms
		
		[events addObject: event];
	}
	return true;
}

- (NSArray*)events
{
	return events;
}

- (OnmsEvent*)event
{
	if ([events count] > 0) {
		return [events objectAtIndex:0];
	} else {
		return nil;
	}
}
@end