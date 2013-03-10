//
//  ShufflerFeedController.h
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNSDataModel.h"

@interface MNSFeedsLoader : UITableViewController <NSFetchedResultsControllerDelegate>

@property NSFetchedResultsController *fetchedResultsController;


// Need to be set in the inheriting class
@property NSString *pathToNewerArticles;
@property NSString *pathToOlderArticles;
@property NSString *parameterForNewerArticles;
@property NSString *parameterForOlderArticles;
@property NSString *userParameter;
@property NSNumber *userID;
// ...

- (void)setupFeed;

@end
