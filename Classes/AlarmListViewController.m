//
//  AlarmListViewController.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmListViewController.h"
#import "AlarmListDataSource.h"

@implementation AlarmListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Alarms";
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"clock.png"] tag:0] autorelease];
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
}

- (void)createModel
{
	self.dataSource = [[[AlarmListDataSource alloc] init] autorelease];
}

@end
