//
//  OutageListViewController.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OutageListViewController.h"
#import "OutageListDataSource.h"

@implementation OutageListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Outages";
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"ekg.png"] tag:0] autorelease];
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (void)loadView
{
	[super loadView];
	TTDINFO(@"init called");
	self.tableViewStyle = UITableViewStylePlain;
	self.variableHeightRows = YES;
//  self.navigationBarTintColor = [UIColor colorWithRed:(54.0/255.0) green:(105.0/255.0) blue:(3.0/255.0) alpha:1.0];
}

- (void)createModel
{
	self.dataSource = [[[OutageListDataSource alloc] init] autorelease];
}

@end
