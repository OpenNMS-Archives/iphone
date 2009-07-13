//
//  FuzzyDate.h
//  OpenNMS
//
//  Created by Benjamin Reed on 7/11/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FuzzyDate : NSObject {
	NSDate* now;
	NSNumberFormatter* numberFormatter;
}

-(NSString*) format: (NSDate *)d;

@end
