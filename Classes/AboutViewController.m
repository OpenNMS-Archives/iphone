//
//  AboutViewController.m
//  OpenNMS
//
//  Created by Benjamin Reed on 7/14/09.
//  Copyright 2009 The OpenNMS Group. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController

- (void)viewDidLoad {
	[textView setFont:[UIFont systemFontOfSize:14]];
    [super viewDidLoad];
}

- (void)dealloc {
	[textView release];
    [super dealloc];
}


@end
