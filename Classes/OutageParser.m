#import "OutageParser.h"
#import "EventParser.h"
#import "FuzzyDate.h"

@implementation OutageParser

static NSDateFormatter* dateFormatter;

- (id) init
{
	if (self = [super init]) {
		fuzzyDate = [[FuzzyDate alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[outages release];
	[super dealloc];
}

static NSDateFormatter* getFormatter() {
	if (!dateFormatter) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLenient:true];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
	}
	return dateFormatter;
}

static OnmsOutage* getOutage(DDXMLElement* xmlOutage) {
	OnmsOutage* outage = [[OnmsOutage alloc] init];
	NSDateFormatter* formatter = getFormatter();

	// ID
	for (id attr in [xmlOutage attributes]) {
		if ([[attr name] isEqual:@"id"]) {
			outage.outageId = [[attr stringValue] intValue];
		}
	}
	
	// Service Name
	DDXMLElement* msElement = [xmlOutage elementForName:@"monitoredService"];
	if (msElement) {
		DDXMLElement* stElement = [msElement elementForName:@"serviceType"];
		if (stElement) {
			DDXMLElement* snElement = [stElement elementForName:@"name"];
			if (snElement) {
				[outage setServiceName:[[snElement childAtIndex:0] stringValue]];
			}
		}
	}
	
	// Service Lost Date
	DDXMLElement* slElement = [xmlOutage elementForName:@"ifLostService"];
	if (slElement) {
		[outage setIfLostService:[formatter dateFromString:[[slElement childAtIndex:0] stringValue]]];
	}
	
	// Service Regained Date
	DDXMLElement* srElement = [xmlOutage elementForName:@"ifRegainedService"];
	if (srElement) {
		[outage setIfRegainedService:[formatter dateFromString:[[srElement childAtIndex:0] stringValue]]];
	}
	
	EventParser* eParser = [[EventParser alloc] init];
	
	// Service Lost Event
	DDXMLElement* sleElement = [xmlOutage elementForName:@"serviceLostEvent"];
	if (sleElement) {
		if ([eParser parse:sleElement]) {
			[outage setServiceLostEvent: [eParser event]];
		} else {
			NSLog(@"warning: unable to parse %@", sleElement);
		}
	}
	
	// Service Regained Event
	DDXMLElement* sreElement = [xmlOutage elementForName:@"serviceRegainedEvent"];
	if (sreElement) {
		if ([eParser parse:sreElement]) {
			[outage setServiceRegainedEvent: [eParser event]];
		} else {
			NSLog(@"warning: unable to parse %@", sreElement);
		}
	}
	
	return outage;
}

- (NSArray*)getViewOutages:(DDXMLElement*)node distinctNodes:(BOOL)distinct
{
	NSCountedSet* labelCount;
	if (distinct) {
		labelCount = [[NSCountedSet alloc] init];
	}

	NSMutableArray* viewOutages = [[NSMutableArray alloc] init];
	for (id xmlOutage in [node elementsForName:@"outage"]) {
		ViewOutage* viewOutage = [[ViewOutage alloc] init];
		OnmsOutage* outage = getOutage(xmlOutage);
		viewOutage.outageId = outage.outageId;
		viewOutage.serviceLostDate = [fuzzyDate format:outage.ifLostService];
		viewOutage.serviceLost = outage.serviceName;
		viewOutage.nodeId = outage.serviceLostEvent.nodeId;
		
		if (distinct) {
			NSNumber* nodeId = [NSNumber numberWithInt:outage.serviceLostEvent.nodeId];
			if ([labelCount countForObject:nodeId] == 0) {
				[viewOutages addObject:viewOutage];
			}
			[labelCount addObject:nodeId];
		} else {
			[viewOutages addObject:viewOutage];
		}
	}
	return viewOutages;
}

- (BOOL)parse:(DDXMLElement*)node skipRegained:(BOOL)skip
{
    // Release the old outageArray
    [outages release];
	
    // Create a new, empty itemArray
    outages = [[NSMutableArray alloc] init];

	NSArray* xmlOutages = [node elementsForName:@"outage"];
	for (id xmlOutage in xmlOutages) {
		OnmsOutage* outage = getOutage(xmlOutage);
		if (!skip || outage.serviceRegainedEvent == nil) {
			NSLog(@"adding outage %@", outage);
			[outages addObject: outage];
		} else {
			NSLog(@"skipping outage %@", outage);
		}
	}
	return true;
}

- (NSArray*)outages
{
	return outages;
}

- (OnmsOutage*)outage
{
	if ([outages count] > 0) {
		return [outages objectAtIndex:0];
	} else {
		return nil;
	}
}

@end
