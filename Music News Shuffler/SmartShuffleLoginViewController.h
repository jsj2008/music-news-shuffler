//
//  SmartShuffleLoginViewController.h
//  Music News Shuffler
//
//  Created by Nick Nikolov on 30/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SmartShuffleLoginViewController : UIViewController


- (IBAction)perfomLogin:(id)sender;
- (void)loginFailed;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end
