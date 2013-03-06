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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    
    
    if (FBSession.activeSession.isOpen){
        NSLog(@"SmartShufflerViewController: Opened session");
        //[appDelegate openSessionWithAllowLoginUI:NO];
        
    } else {
        NSLog(@"SmartShufflerViewController: Closed session");
        [self showLoginView];
    }}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  NSLog(@"Result: %@", [[[result objectForKey:@"data"] objectAtIndex:0] objectForKey:@"music"]);
                                  RKObjectManager *objectManager = [MNSArticleObjectManager createNewManager];
                                  [objectManager postObject:nil
                                                       path:@"/users"
                                                 parameters:@{@"artists": [[[result objectForKey:@"data"] objectAtIndex:0] objectForKey:@"music"]}
                                                    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
                                   {
                                       
                                   } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                       
                                   }];
                                  
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


@end
