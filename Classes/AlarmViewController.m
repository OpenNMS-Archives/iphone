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
#import "RESTURLRequest.h"

#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/UITableViewAdditions.h"

@implementation AlarmViewController

@synthesize alarmId = _alarmId;

- (id)initWithAlarmId:(NSString*)aid
{
	if (self = [self init]) {
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

- (void)showModel:(BOOL)show
{
  [self.navigationItem setRightBarButtonItem:nil animated:YES];
  [super showModel:show];

  AlarmDataSource* ads = self.dataSource;
  Severity* sev = [[Severity alloc] initWithSeverity:ads.severity];
  self.tableView.backgroundColor = [sev getDisplayColor];
  [sev release];
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
  AlarmDataSource* ads = [[[AlarmDataSource alloc] initWithAlarmId:_alarmId] autorelease];
  ads.ackDelegate = self;
  self.dataSource = ads;
}

- (void)sendAckEvent:(NSString*)action
{
  [self.navigationItem setRightBarButtonItem:_activityItem animated:YES];

  NSString* url = [@"http://admin:admin@sin.local:8980/opennms/rest/acks" stringByAppendingFormat:@"?alarmId=%@&action=%@", _alarmId, action];
  RESTURLRequest* request = [RESTURLRequest requestWithURL:url delegate:self];
  request.cachePolicy = TTURLRequestCachePolicyNone;
  request.httpMethod = @"POST";
  request.httpBody = [@"" dataUsingEncoding:NSUTF8StringEncoding];
  request.contentType = @"application/x-www-form-urlencoded";
  
  id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
  request.response = response;
  TT_RELEASE_SAFELY(response);

  [request send];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
  [self.navigationItem setRightBarButtonItem:nil animated:YES];
  TTDWARNING(@"failed ack event %@: %@", request.urlPath, [error description]);
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
  TTDINFO(@"requestDidFinishLoad:%@ responded from cache: %@", request, request.respondedFromCache? @"YES":@"NO");

  TTURLDataResponse* response = request.response;
	NSString* string = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
  TTDINFO(@"response = %@", string);

  [self.navigationItem setRightBarButtonItem:nil animated:YES];
  [self invalidateModel];
  [self invalidateView];
  [self.model invalidate:YES];
  [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[@"onms://alarms/" stringByAppendingString:_alarmId]]];
}

- (void)acknowledge
{
  [self sendAckEvent:@"ack"];
}

- (void)unacknowledge
{
  [self sendAckEvent:@"unack"];
}

- (void)escalate
{
  [self sendAckEvent:@"esc"];
}

- (void)clear
{
  [self sendAckEvent:@"clear"];
}

@end
