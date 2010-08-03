//
//  TabBarController.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TabBarController.h"
#import "Three20UI/Three20UI+Additions.h"

@implementation TabBarController

- (void)viewDidLoad {
	[self setTabURLs:[NSArray arrayWithObjects:
					  @"onms://outages",
					  @"onms://about",
					  nil]
	 ];
}

@end
