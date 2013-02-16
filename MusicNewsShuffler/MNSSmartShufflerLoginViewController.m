//
//  SmartShuffleLoginViewController.m
//  Music News Shuffler
//
//  Created by Nick Nikolov on 30/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import "MNSSmartShufflerLoginViewController.h"
#import "MNSAppDelegate.h"


@interface MNSSmartShufflerLoginViewController ()

@end

@implementation MNSSmartShufflerLoginViewController

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
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelLogin:(id)sender
{
    NSLog(@"SmartShuffleLoginVewController: Cancel login");
    [self dismissViewControllerAnimated:YES completion:nil];
    UITabBarController* tbc = (UITabBarController *)self.presentingViewController;
    [tbc setSelectedIndex:0];

}

- (void)dismissLoginView
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"SmartShuffleLoginVewController: Dismiss self");
    
}

- (IBAction)perfomLogin:(UIButton *)sender
{
    
    NSLog(@"SmartShuffleLoginVewController: Perform Login");
    [self.spinner startAnimating];
    MNSAppDelegate *appDelegate = (MNSAppDelegate*)[[UIApplication sharedApplication] delegate];
    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    [appDelegate openSessionWithAllowLoginUI:YES];
    [self dismissLoginView];
}


@end
