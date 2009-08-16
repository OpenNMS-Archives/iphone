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

#import "AlarmDetailController.h"
#import "ColumnarTableViewCell.h"
#import "OpenNMSRestAgent.h"
#import "OnmsSeverity.h"
#import "AlarmUpdater.h"
#import "AlarmUpdateHandler.h"

@implementation AlarmDetailController

@synthesize alarmTable;
@synthesize contextService;

@synthesize fuzzyDate;
@synthesize defaultFont;
@synthesize clear;
@synthesize white;

@synthesize alarmObjectId;
@synthesize alarm;
@synthesize severity;

-(void) loadView
{
	[super loadView];
	alarmTable = [[AlarmTableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
	alarmTable.alarmDetailController = self;
	alarmTable.delegate = self;
	alarmTable.dataSource = self;
	alarmTable.rowHeight = 34.0;
	self.view = alarmTable;
}

-(void) initializeData
{
	[fuzzyDate touch];
	NSManagedObjectContext* managedObjectContext = [contextService managedObjectContext];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self == %@", alarmObjectId];
	[request setPredicate:predicate];
	
	NSError *error;
	NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
	if (array && [array count] > 0) {
		self.alarm = (Alarm*)[array objectAtIndex:0];
		
		self.title = [NSString stringWithFormat:@"Alarm #%@", self.alarm.alarmId];

		if (self.severity) {
			[self.severity release];
		}
		self.severity = [[OnmsSeverity alloc] initWithSeverity:self.alarm.severity];
	} else {
		if (error) {
			NSLog(@"error retrieving object %@: %@", alarmObjectId, [error localizedDescription]);
		} else {
			NSLog(@"error retrieving object %@", alarmObjectId);
		}
	}
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
	[self.alarm release];
	[self.severity release];
	
	[super dealloc];
}

-(void) viewWillAppear:(BOOL)animated
{
	[self initializeData];
	[super viewWillAppear:animated];
	
	self.alarmTable.backgroundColor = [self.severity getDisplayColor];
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
	[self.alarm release];

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
	CGFloat height = tableView.rowHeight;
	CGSize size;
	switch(indexPath.row) {
		case 0:
			size = [alarm.uei sizeWithFont:defaultFont
					constrainedToSize:CGSizeMake(280.0, 1000.0)
					lineBreakMode:UILineBreakModeCharacterWrap];
			height = (size.height + 10.0);
			break;
		case 3:
			size = [alarm.logMessage sizeWithFont:defaultFont
					constrainedToSize:CGSizeMake(280.0, 1000.0)
					lineBreakMode:UILineBreakModeWordWrap];
			height = (size.height + 10.0);
			break;
	}
	return MAX(height, tableView.rowHeight);
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ColumnarTableViewCell* cell = [[[ColumnarTableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	cell.backgroundColor = white;
	cell.textLabel.font = defaultFont;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	UILabel* leftLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, 60.0, tableView.rowHeight)] autorelease];
	leftLabel.backgroundColor = clear;
	leftLabel.font = defaultFont;
	leftLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
	leftLabel.numberOfLines = 0;
	leftLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	// leftLabel.textAlignment = UITextAlignmentRight;

	UILabel* rightLabel = [[[UILabel alloc] initWithFrame:CGRectMake(75.0, 0, 225.0, tableView.rowHeight)] autorelease];
	rightLabel.backgroundColor = clear;
	rightLabel.font = defaultFont;
	rightLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
	rightLabel.numberOfLines = 0;
	rightLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;

	switch(indexPath.row) {
		case 0:
			leftLabel.text = @"UEI";
			rightLabel.text = alarm.uei;
			break;
		case 1:
			leftLabel.text = @"Severity";
			rightLabel.text = alarm.severity;
			break;
		case 2:
			leftLabel.text = @"# Events";
			rightLabel.text = [alarm.count stringValue];
			break;
		case 3:
			leftLabel.text = @"Message";
			rightLabel.text = alarm.logMessage;
			rightLabel.lineBreakMode = UILineBreakModeCharacterWrap | UILineBreakModeTailTruncation;
			break;
		case 4:
			leftLabel.text = @"First Event";
			rightLabel.text = [fuzzyDate format:alarm.firstEventTime];
			break;
		case 5:
			leftLabel.text = @"Last Event";
			rightLabel.text = [fuzzyDate format:alarm.lastEventTime];
			break;
		case 6:
			leftLabel.text = @"Acknowledged";
			rightLabel.text = [fuzzyDate format:alarm.ackTime];
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

-(UIView *) tableView: (UITableView *) tableView viewForFooterInSection: (NSInteger) section
{
    UIView* footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, alarmTable.bounds.size.width, 44.0)] autorelease];
	footerView.autoresizesSubviews = YES;
	footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	footerView.userInteractionEnabled = YES;
	
	footerView.hidden = NO;
	footerView.multipleTouchEnabled = NO;
	footerView.opaque = NO;
	footerView.contentMode = UIViewContentModeScaleToFill;
	
	UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.titleLabel.font = [button.titleLabel.font fontWithSize:10];
	[button setFrame:CGRectMake(10, 5, 90, 40)];
	if (alarm.ackTime == nil) {
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
	[button setFrame:CGRectMake(115, 5, 90, 40)];
	[button addTarget:self action:@selector(escalateAlarm) forControlEvents:UIControlEventTouchUpInside];
	[button setTitle:@"Escalate" forState:UIControlStateNormal];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[footerView addSubview:button];
	
	button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.titleLabel.font = [button.titleLabel.font fontWithSize:11];
	[button setFrame:CGRectMake(220, 5, 90, 40)];
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

-(void) doAck:(NSString*)action
{
#if DEBUG
	NSLog(@"performing action %@ on alarm %@", action, alarm.alarmId);
#endif
	OpenNMSRestAgent* agent = [[OpenNMSRestAgent alloc] init];
	[agent acknowledgeAlarm:alarm.alarmId action:action];
	[agent release];

	AlarmUpdater* updater = [[[AlarmUpdater alloc] initWithAlarmId:alarm.alarmId] autorelease];
	updater.handler = [[AlarmUpdateHandler alloc] initWithMethod:@selector(initializeData) target:self];
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
