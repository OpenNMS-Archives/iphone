//
//  OutageListViewController.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OutageListViewController.h"
#import "OutageListDataSource.h"

#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/UITableViewAdditions.h"

@implementation OutageListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Outages";
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"ekg.png"] tag:0] autorelease];
	}
	return self;
}

- (void)dealloc
{
  TT_RELEASE_SAFELY(_activityItem);
  TT_RELEASE_SAFELY(_refreshButton);
  
  [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (void)refreshAction
{
  [self.navigationItem setRightBarButtonItem:_activityItem animated:YES];
  [self reload];
}

- (void)showModel:(BOOL)show
{
  [self.navigationItem setRightBarButtonItem:nil animated:YES];
  [super showModel:show];
}

- (void)showError:(BOOL)show
{
  [self.navigationItem setRightBarButtonItem:nil animated:YES];
  [super showError:show];
}

- (void)showEmpty:(BOOL)show
{
  [self.navigationItem setRightBarButtonItem:nil animated:YES];
  [super showEmpty:show];
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

- (void)viewWillAppear:(BOOL)animated
{
  [self reload];
  [super viewWillAppear:animated];
}

- (void)createModel
{
  self.dataSource = [[[OutageListDataSource alloc] init] autorelease];
}

@end
