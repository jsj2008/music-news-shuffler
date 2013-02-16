//
//  SmartShuffleLoginViewController.h
//  Music News Shuffler
//
//  Created by Nick Nikolov on 30/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNSSmartShufflerLoginViewController : UIViewController

- (IBAction)cancelLogin:(id)sender;

- (IBAction)perfomLogin:(id)sender;
- (void)dismissLoginView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end