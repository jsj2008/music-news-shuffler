//
//  SmartShuffleViewController.m
//  Music News Shuffler
//
//  Created by Nick Nikolov on 30/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import "SmartShuffleViewController.h"
#import "SmartShuffleLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"



@interface SmartShuffleViewController ()

@end

@implementation SmartShuffleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Smart Feed";
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (FBSession.activeSession.isOpen){
        NSLog(@"SmartShuffleViewController: Opened session");
        [appDelegate openSessionWithAllowLoginUI:NO];
        
        
    } else {
        NSLog(@"SmartShuffleViewController: Closed session");
        [self showLoginView];
    }
        
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!FBSession.activeSession.isOpen){
        NSLog(@"SmartShuffleViewController: Closed session");
        [self showLoginView];
    } else {
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
                                                  id result,
                                                  NSError *error) {
                                  if (error) {
                                      NSLog(@"Error: %@", [error localizedDescription]);
                                  } else {
                                      NSLog(@"Result: %@", [[[result objectForKey:@"data"] objectAtIndex:0] objectForKey:@"music"]);
                                  }
                              }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


- (IBAction)performLogout:(id)sender
{
    NSLog(@"SmartShuffleViewController: Logging out");
    self.title = @"Smart Feed";
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate performLogout];

}

- (void)showLoginView
{
    [self performSegueWithIdentifier:@"facebookLoginView" sender:self];
}



- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {

        SmartShuffleLoginViewController *loginView = (SmartShuffleLoginViewController*)self.presentedViewController;
        [loginView dismissLoginView];
        
        NSLog(@"SmartShuffleViewController: Logged in");

    } else {
        NSLog(@"SmartShuffleViewController: Logged out");
        NSLog(@"SmartShuffleViewController: Show the login view");
        [self showLoginView];
        
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
