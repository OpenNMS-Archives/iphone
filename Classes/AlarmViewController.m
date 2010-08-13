//
//  AlarmViewController.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmViewController.h"
#import "AlarmDataSource.h"
#import "Severity.h"

#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/UITableViewAdditions.h"

@implementation AlarmViewController

@synthesize alarmId = _alarmId;

- (id)initWithAlarmId:(NSString*)aid
{
	if (self = [self init]) {
		TTDINFO(@"initialized with alarm ID %@", aid);
		self.alarmId = [aid retain];
		self.title = [@"Alarm #" stringByAppendingString:aid];
	}
	return self;
}

- (void)dealloc
{
  TT_RELEASE_SAFELY(_alarmId);
  TT_RELEASE_SAFELY(_activityItem);
  TT_RELEASE_SAFELY(_refreshButton);
  
  [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (void)didLoadModel:(BOOL)firstTime
{
  [super didLoadModel:firstTime];
  AlarmDataSource* ads = self.dataSource;
  Severity* sev = [[Severity alloc] initWithSeverity:ads.severity];
  self.tableView.backgroundColor = [sev getDisplayColor];
  [sev release];
}

- (void)loadView
{
	self.tableViewStyle = UITableViewStyleGrouped;
	self.variableHeightRows = YES;
	[super loadView];

  UIActivityIndicatorView* spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
  [spinner startAnimating];
  _activityItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
  _refreshButton =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
}

- (void)createModel
{
  self.dataSource = [[[AlarmDataSource alloc] initWithAlarmId:_alarmId] autorelease];
}

@end
