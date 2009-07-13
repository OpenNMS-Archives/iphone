//
//  OpenNMSAppDelegate.h
//  OpenNMS
//
//  Created by Benjamin Reed on 7/10/09.
//  Copyright The OpenNMS Group 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenNMSAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
