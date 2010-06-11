//
//  IPAddressInputController.h
//  OpenNMS
//
//  Created by Benjamin Reed on 6/10/10.
//  Copyright 2010 The OpenNMS Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface IPAddressInputController : BaseController {
    IBOutlet UITextField* ipAddress;
    IBOutlet UIButton* addButton;
    IBOutlet UIButton* cancelButton;
}

@property (nonatomic, retain) UITextField* ipAddress;
@property (nonatomic, retain) UIButton* addButton;
@property (nonatomic, retain) UIButton* cancelButton;

- (IBAction) addClicked;
- (IBAction) cancelClicked;

@end
