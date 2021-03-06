//
//  ShufflerFeedController.m
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import "MNSBasicShufflerViewController.h"
#import "MNSArticleViewController.h"

@implementation MNSBasicShufflerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"The Basic Shuffler";
    [self setPathToNewerArticles:@"/rss_feed_loader/newer_articles.json"];
    [self setPathToOlderArticles:@"/rss_feed_loader/older_articles.json"];
    [self setParameterForNewerArticles:@"newest_pubdate"];
    [self setParameterForOlderArticles:@"oldest_pubdate"];
    [self setupFeed];
    [self startLoading];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        id object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
