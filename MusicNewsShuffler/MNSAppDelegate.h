//
//  AppDelegate.h
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const FBSessionStateChangedNotification;

@interface MNSAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UITabBarController* tabBarController;
@property (strong, nonatomic) UIWindow *window;

- (void)performLogout;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;


@end
