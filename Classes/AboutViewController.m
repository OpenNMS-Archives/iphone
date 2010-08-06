//
//  AboutViewController.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "ONMSDefaultStyleSheet.h"

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"About";
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"o.png"] tag:0] autorelease];
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (void)loadView {
  self.navigationBarTintColor = TTSTYLEVAR(navigationBarTintColor);
  UITextView* view = [[[UITextView alloc] init] autorelease];
	view.autoresizesSubviews = YES;
  view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  view.backgroundColor = TTSTYLEVAR(backgroundColor);
	view.editable = NO;
	view.dataDetectorTypes = UIDataDetectorTypeLink;
	view.font = [UIFont systemFontOfSize:14];
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
  NSString *finalPath = [path stringByAppendingPathComponent:@"Info.plist"];
  NSDictionary *plistData = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
  
  NSString *buildString   = [NSString stringWithFormat:@"%@", [plistData objectForKey:@"CFBundleVersion"]];
	NSString *versionString = [NSString stringWithFormat:@"%@", [plistData objectForKey:@"CFBundleShortVersionString"]];
  
	TT_RELEASE_SAFELY(plistData);
	
	NSString* text = [NSString stringWithFormat:
                    @"OpenNMS %@, build %@\n"
                    @"\n"
                    @"OpenNMS® is a Registered Trademark of The OpenNMS Group, Inc.  Copyright © 2010, The OpenNMS Group, Inc.\n"
                    @"\n"
                    @"http://www.opennms.org/\n"
                    @"\n"
                    @"This program is open source.  For more details, see:\n"
                    @"\n"
                    @"http://www.opennms.org/wiki/IPhone_Client\n"
                    @"\n"
                    @"3rd-Party Inclusions:\n"
                    @"\n"
                    @"Some icons copyright © Joseph Wain, from http://www.glyphish.com/.\n"
                    @"\n"
                    @"Application framework by Three20, from http://three20.info/.\n"
                    @"\n"
                    @"Configuration panel code mySettings copyright © Kåre Morstøl, from http://bitbucket.org/karemorstol/mysettings/.",
                    versionString, buildString];
  
	view.text = text;
	self.view = view;
}

@end
