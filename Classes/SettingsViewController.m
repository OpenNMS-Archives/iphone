/*******************************************************************************
 * This file is part of the OpenNMS(R) iPhone Application.
 * OpenNMS(R) is a registered trademark of The OpenNMS Group, Inc.
 *
 * Copyright (C) 2010 The OpenNMS Group, Inc.  All rights reserved.
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

#import "SettingsViewController.h"
#import "SettingsDataSource.h"

#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/UITableViewAdditions.h"

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.title = @"Settings";
    self.autoresizesForKeyboard = YES;
    self.variableHeightRows = NO;
  }
  return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
  SettingsDataSource* ds = self.dataSource;
  [ds saveChanges];
  [super viewWillDisappear:animated];
}

- (void)closeView
{
  [self dismissModalViewControllerAnimated:YES];
}

- (void)loadView
{
	self.tableViewStyle = UITableViewStyleGrouped;
  self.autoresizesForKeyboard = YES;
  self.variableHeightRows = NO;
  [super loadView];
  
  [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(closeView)] autorelease] animated:YES];
}

- (void)createModel
{
  self.dataSource = [[[SettingsDataSource alloc] init] autorelease];
}

@end

