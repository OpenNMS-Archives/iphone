//
//  IPAddressInputController.m
//  OpenNMS
//
//  Created by Benjamin Reed on 6/10/10.
//  Copyright 2010 The OpenNMS Group. All rights reserved.
//

#import "config.h"
#import "IPAddressInputController.h"

@implementation IPAddressInputController

@synthesize ipAddress;
@synthesize addButton;
@synthesize cancelButton;

- (void)loadView {
    [super loadView];
    self.wantsFullScreenLayout = NO;
    
//	[self initializeScreenWidth:[[UIApplication sharedApplication] statusBarOrientation]];

    CGFloat leftOffset = round((self.screenWidth - 270.0) /2);
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(leftOffset, 40, 270, 125)];

    [view setBackgroundColor:[UIColor clearColor]];

    // UIButton handles transparency properly  :P
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 270, 125);
    button.enabled = NO;
    button.userInteractionEnabled = NO;
    [button setBackgroundImage:[UIImage imageNamed:@"ip-dialog-box.png"] forState:UIControlStateDisabled];
    [view addSubview:button];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 250, 21)];
    label.text = @"Discover an Interface:";
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:label.font.pointSize];
    [view addSubview:label];
    [label autorelease];

    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 39, 250, 31)];
    textField.placeholder = @"IP Address";
//    textField.backgroundColor = [UIColor whiteColor];
    textField.backgroundColor = [UIColor clearColor];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.ipAddress = textField;
    [view addSubview:textField];
    [textField autorelease];

    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, 78, 120, 37);
    [button setBackgroundImage:[UIImage imageNamed:@"green-button-default.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"green-button-hilighted.png"] forState:UIControlStateHighlighted];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    self.cancelButton = button;
    [view addSubview:button];

    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(140, 78, 120, 37);
    [button setBackgroundImage:[UIImage imageNamed:@"green-button-default.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"green-button-hilighted.png"] forState:UIControlStateHighlighted];
    [button setTitle:@"Add" forState:UIControlStateNormal];
    [button setHighlighted:YES];
    self.addButton = button;
    [view addSubview:button];
    
    self.view = view;
    [view autorelease];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.ipAddress = nil;
    self.addButton = nil;
    self.cancelButton = nil;
}

- (IBAction) addClicked
{
#if DEBUG
    NSLog(@"addClicked");
#endif
}

- (IBAction) cancelClicked
{
#if DEBUG
    NSLog(@"cancelClicked");
#endif
}

@end
