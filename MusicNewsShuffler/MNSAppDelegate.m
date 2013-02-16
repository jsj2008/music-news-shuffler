//
//  AppDelegate.m
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import "MNSAppDelegate.h"
#import "FacebookSDK/FacebookSDK.h"
#import "MNSSmartShufflerLoginViewController.h"
#import "MNSSmartShufflerViewController.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

NSString *const FBSessionStateChangedNotification = @"nn.Music-News-Shuffler:FBSessionStateChangedNotification";

@implementation MNSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:3000/"];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
    
    // Enable Activity Indicator Spinner
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Initialize managed object store
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc]
                                                initWithManagedObjectModel:managedObjectModel];
    objectManager.managedObjectStore = managedObjectStore;
    
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
    [FBSession.activeSession close];
}

- (void)showSmartShuffleLoginView
{
    MNSSmartShufflerViewController* smartShuffleViewController = (MNSSmartShufflerViewController*)[[self tabBarController] selectedViewController];
    NSLog(@"AppDelegate: Show the login view");
    [smartShuffleViewController showLoginView];
}

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}


- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            @"user_likes",
                            nil];
    
    NSLog(@"App Delegate: Opening session");

    
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

/*
 * Callback for session changes.
 */

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    
    NSLog(@"AppDelegate: Session state changed");
    
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                NSLog(@"AppDelegate: User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            NSLog(@"App Delegate: Clearing FB token");
            [self showSmartShuffleLoginView];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
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

/*
 * Opens a Facebook session and optionally shows the login UX.
 */

- (void)performLogout
{
    [FBSession.activeSession closeAndClearTokenInformation];
    //NSLog(@"inactive session: %u", FBSession.activeSession.state);

}


@end
