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

- (void)refreshAction
{
  [self.navigationItem setRightBarButtonItem:_activityItem animated:YES];
  [(TTNavigator*)[TTNavigator navigator] reload];
}

- (void)didLoadModel:(BOOL)firstTime
{
  [super didLoadModel:firstTime];
  [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)loadView
{
	self.tableViewStyle = UITableViewStylePlain;
	self.variableHeightRows = YES;
	[super loadView];

  UIActivityIndicatorView* spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
  [spinner startAnimating];
  _activityItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
  _refreshButton =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];

  [self.navigationItem setLeftBarButtonItem:_refreshButton animated:YES];
  [self.navigationItem setRightBarButtonItem:_activityItem animated:YES];
}

- (void)createModel
{
  self.dataSource = [[[AlarmListDataSource alloc] init] autorelease];
}

@end
