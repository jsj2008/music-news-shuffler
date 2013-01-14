//
//  AppDelegate.m
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import "AppDelegate.h"
#import "FacebookSDK/FacebookSDK.h"
#import "SmartShuffleLoginViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSLog(@"Root: %@", self.window.rootViewController);
    _tabBarController = (UITabBarController *)self.window.rootViewController;
    _tabBarController.delegate = self;
    //NSLog(@"Selected tab index %u", tabController.selectedIndex);

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // We need to properly handle activation of the application with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)showSmartShuffleLoginView
{

        [_tabBarController performSegueWithIdentifier:@"smartShuffleLogin" sender:_tabBarController];

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"%u", tabBarController.selectedIndex);
    
    if (tabBarController.selectedIndex == 1)
    {
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            NSLog(@"active session: %u", FBSession.activeSession.state);
            [self openSession];
        } else {
            NSLog(@"inactive session: %u", FBSession.activeSession.state);
            [self showSmartShuffleLoginView];
        }
        
    }
    
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    
    
    switch (state) {
        case FBSessionStateOpen: {
//            UIViewController *topViewController =
//            [self.navController topViewController];
//            if ([[topViewController modalViewController]
//                 isKindOfClass:[SCLoginViewController class]]) {
//                [topViewController dismissModalViewControllerAnimated:YES];
//            }
        
            [_tabBarController dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"dismissing login view controller");
            

        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
        
            [FBSession.activeSession closeAndClearTokenInformation];
            
            NSLog(@"clearing token");
            
            [self showSmartShuffleLoginView];
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }    
}

- (void)openSession
{
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
    
}


@end
