/*******************************************************************************
 * This file is part of the OpenNMS(R) iPhone Application.
 * OpenNMS(R) is a registered trademark of The OpenNMS Group, Inc.
 *
 * Copyright (C) 2009 The OpenNMS Group, Inc.  All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc.:
 *
 *      51 Franklin Street
 *      5th Floor
 *      Boston, MA 02110-1301
 *      USA
 *
 * For more information contact:
 *
 *      OpenNMS Licensing <license@opennms.org>
 *      http://www.opennms.org/
 *      http://www.opennms.com/
 *
 *******************************************************************************/

#import "config.h"
#import "unistd.h"
#import "AlarmDetailController.h"
#import "ColumnarTableViewCell.h"
#import "OnmsSeverity.h"
#import "AckUpdater.h"
#import "UpdateHandler.h"
#import "AlarmFactory.h"
#import "CalculateSize.h"

@implementation AlarmDetailController

@synthesize alarmTable;
@synthesize spinner;
@synthesize contextService;

@synthesize fuzzyDate;
@synthesize defaultFont;
@synthesize clear;
@synthesize white;

@synthesize alarmObjectId;
@synthesize severity;

-(void) loadView
{
	[super loadView];
	self.alarmTable = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
	self.alarmTable.delegate = self;
	self.alarmTable.dataSource = self;
	self.alarmTable.rowHeight = 34.0;
	self.view = self.alarmTable;
	self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	self.spinner.hidesWhenStopped = YES;
	self.spinner.center = self.view.center;
//	self.spinner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.navigationController.view addSubview:self.spinner];
//	[self.view addSubview:self.spinner];
}

-(void) initializeData
{
#if DEBUG
	NSLog(@"initializeData called");
#endif
	[fuzzyDate touch];
	NSManagedObjectContext* managedObjectContext = [contextService managedObjectContext];
	Alarm* a = (Alarm*)[managedObjectContext objectWithID:self.alarmObjectId];
	[managedObjectContext refreshObject:a mergeChanges:NO];
	self.severity = [[[OnmsSeverity alloc] initWithSeverity:a.severity] autorelease];
	self.alarmTable.backgroundColor = [self.severity getDisplayColor];
	self.alarmTable.backgroundView.backgroundColor = [self.severity getDisplayColor];
#if DEBUG
	NSLog(@"setting color for severity %@", self.severity);
#endif
	self.title = [NSString stringWithFormat:@"Alarm #%@", a.alarmId];
	[self.spinner stopAnimating];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self initializeScreenWidth:toInterfaceOrientation];
	[self.alarmTable reloadData];
}

#pragma mark -
#pragma mark Lifecycle methods

-(void) dealloc
{
	[self.alarmTable release];
	[self.contextService release];

	[self.fuzzyDate release];
	[self.defaultFont release];
	[self.clear release];
	[self.white release];
	
	[self.alarmObjectId release];
	[self.severity release];
	
	[super dealloc];
}

-(void) viewWillAppear:(BOOL)animated
{
	[self initializeData];
	[super viewWillAppear:animated];
}

-(void) viewDidLoad
{
	self.contextService = [[ContextService alloc] init];
	self.fuzzyDate = [[FuzzyDate alloc] init];
	self.fuzzyDate.mini = YES;
	self.defaultFont = [UIFont boldSystemFontOfSize:11];
	self.clear = [UIColor colorWithWhite:1.0 alpha:0.0];
	self.white = [UIColor colorWithWhite:1.0 alpha:1.0];

	[self initializeData];
	[super viewDidLoad];
}

-(void) viewDidUnload
{
	[self.contextService release];
	
	[self.fuzzyDate release];
	[self.defaultFont release];
	[self.clear release];
	[self.white release];

	[self.alarmObjectId release];

	[super viewDidUnload];
}

#pragma mark UITableView delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 7;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0;
	CGSize size;
	Alarm* a = (Alarm*)[[contextService managedObjectContext] objectWithID:self.alarmObjectId];
	switch(indexPath.row) {
		case 0:
			size = [CalculateSize calcLabelSize:a.uei font:defaultFont lines:10 width:(orientationHandler.tableWidth - (orientationHandler.cellSeparator * 3) - 60)
										   mode:(UILineBreakModeCharacterWrap|UILineBreakModeTailTruncation)];
			height = size.height;
			break;
		case 3:
			size = [CalculateSize calcLabelSize:a.logMessage font:defaultFont lines:10 width:(orientationHandler.tableWidth - (orientationHandler.cellSeparator * 3) - 60)
										   mode:(UILineBreakModeWordWrap|UILineBreakModeTailTruncation)];
			height = size.height;
			break;
	}
	return MAX(height, tableView.rowHeight);
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
#if DEBUG
	NSLog(@"%@: tableView: %@ cellForRowAtIndexPath: %@", self, tableView, indexPath);
#endif

	ColumnarTableViewCell* cell = [[[ColumnarTableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	cell.backgroundColor = white;
	cell.textLabel.font = defaultFont;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

    CGFloat leftWidth = 60;
    CGFloat rightWidth = orientationHandler.tableWidth - (orientationHandler.cellSeparator * 3) - leftWidth;

#if DEBUG
	NSLog(@"%@: leftWidth: %f, rightWidth: %f", self, leftWidth, rightWidth);
#endif

	CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
	UILabel* leftLabel = [[[UILabel alloc] initWithFrame:CGRectMake(orientationHandler.cellSeparator, 0, leftWidth, height)] autorelease];
	leftLabel.backgroundColor = clear;
	leftLabel.font = defaultFont;
	leftLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
	leftLabel.numberOfLines = 10;
	leftLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;

	UILabel* rightLabel = [[[UILabel alloc] initWithFrame:CGRectMake(orientationHandler.cellSeparator + leftWidth + orientationHandler.cellSeparator, 0, rightWidth, height)] autorelease];
	rightLabel.backgroundColor = clear;
	rightLabel.font = defaultFont;
	rightLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
	rightLabel.numberOfLines = 10;
	rightLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;

	Alarm* a = (Alarm*)[[contextService managedObjectContext] objectWithID:self.alarmObjectId];
	switch(indexPath.row) {
		case 0:
			leftLabel.text = @"UEI";
			rightLabel.text = a.uei;
			rightLabel.lineBreakMode = (UILineBreakModeCharacterWrap | UILineBreakModeTailTruncation);
			break;
		case 1:
			leftLabel.text = @"Severity";
			rightLabel.text = a.severity;
			break;
		case 2:
			leftLabel.text = @"# Events";
			rightLabel.text = [a.count stringValue];
			break;
		case 3:
			leftLabel.text = @"Message";
			rightLabel.text = a.logMessage;
			break;
		case 4:
			leftLabel.text = @"First Event";
			rightLabel.text = [fuzzyDate format:a.firstEventTime];
			break;
		case 5:
			leftLabel.text = @"Last Event";
			rightLabel.text = [fuzzyDate format:a.lastEventTime];
			break;
		case 6:
			leftLabel.text = @"Ack'd";
			rightLabel.text = [fuzzyDate format:a.ackTime];
			break;
	}

	
	[cell addColumn:@"key"];
	[cell.contentView addSubview:leftLabel];
	
	[cell addColumn:@"value"];
	[cell.contentView addSubview:rightLabel];

	cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[cell sizeToFit];
	
	return cell;
}

-(UIView *) tableView: (UITableView *)tableView viewForFooterInSection: (NSInteger)section
{
#if DEBUG
	NSLog(@"%@: tableView: %@ viewForFooterInSection: %@", self, tableView, section);
#endif
	
    UIView* footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, orientationHandler.screenWidth, 44.0)] autorelease];
	footerView.autoresizesSubviews = YES;
	footerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
	footerView.userInteractionEnabled = YES;
	
	footerView.hidden = NO;
	footerView.multipleTouchEnabled = NO;
	footerView.opaque = NO;
	footerView.contentMode = (UIViewContentModeScaleToFill & UIViewContentModeRedraw);

    CGFloat buttonWidth = round((orientationHandler.screenWidth - (orientationHandler.cellBorder * 2) - (orientationHandler.cellSeparator * 2)) / 3);

	UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.titleLabel.font = [button.titleLabel.font fontWithSize:10];
	[button setFrame:CGRectMake(orientationHandler.cellBorder, orientationHandler.cellSeparator, buttonWidth, 40)];
	Alarm* a = (Alarm*)[[contextService managedObjectContext] objectWithID:self.alarmObjectId];
	if (a.ackTime == nil) {
		[button addTarget:self action:@selector(acknowledgeAlarm) forControlEvents:UIControlEventTouchUpInside];
		[button setTitle:@"Acknowledge" forState:UIControlStateNormal];
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	} else {
		[button addTarget:self action:@selector(unacknowledgeAlarm) forControlEvents:UIControlEventTouchUpInside];
		[button setTitle:@"Unacknowledge" forState:UIControlStateNormal];
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	[footerView addSubview:button];
	
	button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.titleLabel.font = [button.titleLabel.font fontWithSize:11];
	[button setFrame:CGRectMake(orientationHandler.cellBorder + buttonWidth + orientationHandler.cellSeparator, orientationHandler.cellSeparator, buttonWidth, 40)];
	[button addTarget:self action:@selector(escalateAlarm) forControlEvents:UIControlEventTouchUpInside];
	[button setTitle:@"Escalate" forState:UIControlStateNormal];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[footerView addSubview:button];
	
	button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.titleLabel.font = [button.titleLabel.font fontWithSize:11];
	[button setFrame:CGRectMake(orientationHandler.cellBorder + buttonWidth + orientationHandler.cellSeparator + buttonWidth + orientationHandler.cellSeparator, orientationHandler.cellSeparator, buttonWidth, 40)];
	[button addTarget:self action:@selector(clearAlarm) forControlEvents:UIControlEventTouchUpInside];
	[button setTitle:@"Clear" forState:UIControlStateNormal];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[footerView addSubview:button];
	
	return footerView;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 45.0f;
}

-(void) refreshData
{
#if DEBUG
	NSLog(@"%@: refreshData called", self);
#endif
	Alarm* a = (Alarm*)[[contextService managedObjectContext] objectWithID:self.alarmObjectId];
	// FIXME: need to know when the ack has gone through
	usleep(4000000);
	a = [[AlarmFactory getInstance] getRemoteAlarm:a.alarmId];
	self.alarmObjectId = [a objectID];
	[self initializeData];
	[self.alarmTable reloadData];
	[self.spinner stopAnimating];
}

-(void) doAck:(NSString*)action
{
	[self.spinner startAnimating];
	Alarm* a = (Alarm*)[[contextService managedObjectContext] objectWithID:self.alarmObjectId];
	NSLog(@"performing action %@ on alarm %@", action, a.alarmId);
	AckUpdater* updater = [[[AckUpdater alloc] initWithAlarmId:a.alarmId action:action] autorelease];
	updater.handler = [[[UpdateHandler alloc] initWithMethod:@selector(refreshData) target:self] autorelease];
	[updater update];
}

-(void) acknowledgeAlarm
{
	[self doAck:@"ack"];
}

-(void) unacknowledgeAlarm
{
	[self doAck:@"unack"];
}

-(void) escalateAlarm
{
	[self doAck:@"esc"];
}

-(void) clearAlarm
{
	[self doAck:@"clear"];
}

@end
