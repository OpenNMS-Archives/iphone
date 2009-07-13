#import "FuzzyDate.h"

static double SECONDS_PER_DAY    = 86400.0;
static double SECONDS_PER_HOUR   = 3600.0;
static double SECONDS_PER_MINUTE = 60.0;

@implementation FuzzyDate

-(id) init
{
	if (self = [super init]) {
		now = [[NSDate alloc] init];
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setMaximumFractionDigits:1];
	}
	return self;
}

static NSString* formatNumber(NSTimeInterval time, NSString* singular, NSString* plural, NSNumberFormatter* formatter)
{
	NSNumber* num = [NSNumber numberWithDouble:time];
	NSString* value = [formatter stringFromNumber:num];
	NSString* retVal = @"return";
	if ([value isEqual:@"1"]) {
		retVal = [NSString stringWithFormat:@"%@ %@ ago", value, singular];
	} else {
		retVal = [NSString stringWithFormat:@"%@ %@", value, plural];
	}
	return retVal;
}

-(NSString*) format: (NSDate *)d
{
	NSTimeInterval difference = [now timeIntervalSinceDate: d];

	NSTimeInterval days = (difference / SECONDS_PER_DAY);
	
	if (days < 1.0) {
		NSTimeInterval hours = (difference / SECONDS_PER_HOUR);
		if (hours < 1.0) {
			NSTimeInterval minutes = (difference / SECONDS_PER_MINUTE);
			if (minutes < 1.0) {
				return formatNumber(difference, @"second", @"seconds", numberFormatter);
			} else {
				return formatNumber(minutes, @"minute", @"minutes", numberFormatter);
			}
		} else {
			return formatNumber(hours, @"hour", @"hours", numberFormatter);
		}
	} else if (days >= 365) {
		return formatNumber((days / 365.0), @"year", @"years", numberFormatter);
	} else if (days >= 30) {
		return formatNumber((days / 30.0), @"month", @"months", numberFormatter);
	} else if (days >= 7) {
		return formatNumber((days / 7.0), @"week", @"weeks", numberFormatter);
	} else if (days >= 1.0) {
		return formatNumber(days, @"day", @"days", numberFormatter);
	}

	return [d description];
}

@end
