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

#import <UIKit/UIKit.h>
#import "FuzzyDate.h"
#import "ContextService.h"

@interface AlarmListController : UIViewController <UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource> {
	@private UITableView* alarmTable;
	@private UIActivityIndicatorView* spinner;
	@private FuzzyDate* fuzzyDate;
	@private ContextService* contextService;

	@private NSMutableArray* alarmList;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;
@property (nonatomic, retain) FuzzyDate* fuzzyDate;
@property (retain) IBOutlet UITableView* alarmTable;
@property (retain) ContextService* contextService;

@property (retain) NSMutableArray* alarmList;

@property CGFloat screenWidth;
@property CGFloat tableWidth;
@property CGFloat cellBorder;
@property CGFloat cellSeparator;

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(void) refreshData;
-(IBAction) reload:(id) sender;

@end
