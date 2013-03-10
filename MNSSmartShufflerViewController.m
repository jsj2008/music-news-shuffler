//
//  MNSSmartShufflerViewController.m
//  MusicNewsShuffler
//
//  Created by Nick Nikolov on 21/02/2013.
//  Copyright (c) 2013 Nick Nikolov. All rights reserved.
//

#import "MNSSmartShufflerViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MNSAppDelegate.h"
#import "MNSArticleObjectManager.h"
#import <RestKit/RestKit.h>
#import "KGModal.h"
#import "MNSAppDelegate.h"



@interface MNSSmartShufflerViewController ()

@end

@implementation MNSSmartShufflerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [super setPathToNewerArticles:@"/users/newer_articles.json"];
    [super setPathToOlderArticles:@"/users/older_articles.json"];
    [super setParameterForNewerArticles:@"newest_pubdate"];
    [super setParameterForOlderArticles:@"oldest_pubdate"];
    
    
    self.title = @"Smart Feed";
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    
    
    if (FBSession.activeSession.isOpen){
        NSLog(@"SmartShufflerViewController: Opened session");
        //[appDelegate openSessionWithAllowLoginUI:NO];
        
    } else {
        NSLog(@"SmartShufflerViewController: Closed session");
        [self showLoginView];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if (FBSession.activeSession.isOpen){
        NSLog(@"SmartShufflerViewController: Opened session");
        //[appDelegate openSessionWithAllowLoginUI:NO];
        
    } else {
        NSLog(@"SmartShufflerViewController: Closed session");
        [self showLoginView];
    }
}

- (void)postArtistsToServerWithFacebookDictionary:(id)fbDictionary
{
    //NSLog(@"Result: %@", [[[result objectForKey:@"data"] objectAtIndex:0] objectForKey:@"music"]);
    RKObjectManager *objectManager = [MNSArticleObjectManager createNewManager];
    [[objectManager HTTPClient] postPath:@"/users.json"
                              parameters:@{@"artists": [[[fbDictionary objectForKey:@"data"] objectAtIndex:0] objectForKey:@"music"]}
                                 success:^(AFHTTPRequestOperation *operation, id serverResult)
     {
         [self setUserID:[serverResult objectForKey:@"id"]];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
     }];
}

- (void)fetchFacebookInformation
{
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection,
       NSDictionary<FBGraphUser> *user,
       NSError *error) {
         if (!error) {
             self.title = user.name;
             self.title = [self.title stringByAppendingString:@"\'s Smart Feed"];
             //NSLog(@"%@", user);
             
         }
     }];
    
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
                                  [self postArtistsToServerWithFacebookDictionary:fbDictionary];
                                  [self setupFeed];
                                  [self.tableView reloadData];
                              }
                          }];
}

- (void)performLogout:(id)sender
{
    NSLog(@"SmartShufflerViewController: Logging out");
    self.title = @"Smart Feed";
    MNSAppDelegate* appDelegate = (MNSAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate performLogout];
}

- (void)performLogin
{
    NSLog(@"SmartShuffleLoginVewController: Perform Login");
    MNSAppDelegate *appDelegate = (MNSAppDelegate*)[[UIApplication sharedApplication] delegate];
    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    [appDelegate openSessionWithAllowLoginUI:YES];
    [[KGModal sharedInstance] hideAnimated:YES];

}

- (void)cancelLogin
{
    NSLog(@"SmartShufflerVewController: Cancel login");
    [[KGModal sharedInstance] hideAnimated:YES];
    UITabBarController* tbc = (UITabBarController *)self.parentViewController.parentViewController;
    [tbc setSelectedIndex:0];
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
    [loginButton addTarget:self action:@selector(performLogin) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    loginButton.frame = loginButtonFrame;
    [contentView addSubview:loginButton];
    
    CGRect cancelButtonFrame = CGRectInset(contentView.bounds, 5, 5);
    cancelButtonFrame.origin.y = 140;
    cancelButtonFrame.origin.x = 110;
    cancelButtonFrame.size.width = 60;
    cancelButtonFrame.size.height = 40;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton addTarget:self action:@selector(cancelLogin) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.frame = cancelButtonFrame;
    [contentView addSubview:cancelButton];
    
    [[KGModal sharedInstance] showWithContentView:contentView andAnimated:YES];
    
}



- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        
        [self fetchFacebookInformation];
        
        NSLog(@"SmartShufflerViewController: Logged in");
        //[[KGModal sharedInstance] hideAnimated:YES];

        
    } else {
        NSLog(@"SmartShufflerViewController: Logged out");
        NSLog(@"SmartShufflerViewController: Show the login view");
        [self showLoginView];
        
    }
    
}



@end
