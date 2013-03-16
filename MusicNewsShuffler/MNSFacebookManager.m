//
//  MNSFacebookManager.m
//  MusicNewsShuffler
//
//  Created by Nick Nikolov on 16/03/2013.
//  Copyright (c) 2013 Nick Nikolov. All rights reserved.
//

#import "MNSFacebookManager.h"
#import "MNSAppDelegate.h"
#import "KGModal.h"
#import <FacebookSDK/FacebookSDK.h>


@implementation MNSFacebookManager

- (void)addFBObserverToSender:(id)sender WithSelector:(SEL)selector{ 
    [[NSNotificationCenter defaultCenter]
     addObserver:sender
     selector:selector
     name:FBSessionStateChangedNotification
     object:nil];
}

- (void)checkFBSession
{
    if (FBSession.activeSession.isOpen){
        NSLog(@"SmartShufflerViewController: Opened session");
        //[appDelegate openSessionWithAllowLoginUI:NO];
        
    } else {
        NSLog(@"SmartShufflerViewController: Closed session");
        [self showLoginView];
    }

}

- (void)checkFBSessionAndFetchFBInfoWithBlock:(PostLoginBlock)postLoginBlock
{
    
    if (FBSession.activeSession.isOpen){
        NSLog(@"SmartShufflerViewController: Opened session");
        //[appDelegate openSessionWithAllowLoginUI:NO];
        NSString *fqlQuery = @"SELECT music FROM user WHERE uid = me()";
        NSDictionary *queryParam = @{@"q": fqlQuery};
        [FBRequestConnection startWithGraphPath:@"/fql"
                                     parameters:queryParam
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection,
                                                  id fbDictionary,
                                                  NSError *error) {
                                  if (error) {
                                      NSLog(@"Error: %@", [error localizedDescription]);
                                  } else {
                                      self.facebookResultDictionary = fbDictionary;
                                      [postLoginBlock invoke];
                                  }
                              }];

    } else {
        NSLog(@"SmartShufflerViewController: Closed session");
        [self showLoginView];
    }

        

}

- (void)logout
{
    MNSAppDelegate* appDelegate = (MNSAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate performLogout];
    
}

- (void)login
{
    MNSAppDelegate *appDelegate = (MNSAppDelegate*)[[UIApplication sharedApplication] delegate];
    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    [appDelegate openSessionWithAllowLoginUI:YES];
    [[KGModal sharedInstance] hideAnimated:YES];
}

- (void)showLoginView
{
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 360)];
    
    CGRect loginButtonFrame = CGRectInset(contentView.bounds, 5, 5);
    loginButtonFrame.origin.y = 80;
    loginButtonFrame.origin.x = 110;
    loginButtonFrame.size.width = 60;
    loginButtonFrame.size.height = 40;
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    loginButton.frame = loginButtonFrame;
    [contentView addSubview:loginButton];
    
    CGRect cancelButtonFrame = CGRectInset(contentView.bounds, 5, 5);
    cancelButtonFrame.origin.y = 140;
    cancelButtonFrame.origin.x = 110;
    cancelButtonFrame.size.width = 60;
    cancelButtonFrame.size.height = 40;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton addTarget:self action:self.cancelLoginOptionSelector forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.frame = cancelButtonFrame;
    [contentView addSubview:cancelButton];
    
    [[KGModal sharedInstance] showWithContentView:contentView andAnimated:YES];

}




@end
