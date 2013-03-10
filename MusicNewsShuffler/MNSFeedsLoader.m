//
//  ShufflerFeedController.m
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import "MNSFeedsLoader.h"
#import "MNSArticleTableCell.h"
#import "MNSArticle.h"
#import <RestKit/RestKit.h>
#import "MNSDataModel.h"
#import "SVProgressHUD.h"
#import "MNSArticleObjectManager.h"


@interface MNSFeedsLoader () <NSFetchedResultsControllerDelegate>

@property UIRefreshControl *refreshControl;
@property NSString *oldestArticlePubdate;
@property NSString *newestArticlePubdate;
@property RKObjectManager *objectManager;

@end


@implementation MNSFeedsLoader

- (void)createRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshInvoked:forState:)
                  forControlEvents:UIControlEventValueChanged];
    
    NSString* fetchMessage = [NSString stringWithFormat:@"Loading new articles..."];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]
                                           initWithString:fetchMessage
                                           attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica"
                                                                                            size:11.0]}];
    [self.tableView addSubview:self.refreshControl];

}

- (void)setupFeed {
    [self createRefreshControl];
    self.objectManager = [MNSArticleObjectManager createNewManager];
    self.oldestArticlePubdate = @"";
    self.newestArticlePubdate = @"";
    self.userParameter = @"user_id";
    
    [SVProgressHUD show];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MNSArticle"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"pubdate" ascending:NO];
    fetchRequest.sortDescriptors = @[descriptor];
    NSError *error = nil;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[self.objectManager managedObjectStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
    
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSLog(@"FETCHED OBJECTS COUNT: %lu", (unsigned long)[[self.fetchedResultsController fetchedObjects] count]);

    if (! fetchSuccessful) {
        [SVProgressHUD showErrorWithStatus:@"Dang! :("];
    }
    
    [self fetchNewerArticles];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    //[self setupFeed]; should be called by inherited class when appropriate
    
}


- (void)fetchNewerArticles
{
    [_objectManager getObjectsAtPath:self.pathToNewerArticles
                          parameters:[self updatedParametersForNewerArticlesRequest]
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         
         [self setPubdates];
         [self.refreshControl endRefreshing];
         [SVProgressHUD dismiss];
         [SVProgressHUD showSuccessWithStatus:@"Yey!"];
         [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
         [[NSUserDefaults standardUserDefaults] synchronize];
         
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         NSLog(@"ERROR: %@", error);
         NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
         [self.refreshControl endRefreshing];
         [SVProgressHUD showErrorWithStatus:@"Whoops!"];
         
     }];
    
}

- (void)fetchOlderArticles
{
    
    [_objectManager getObjectsAtPath:self.pathToOlderArticles
                          parameters:[self updatedParametersForOlderArticlesRequest]
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         
         [self setPubdates];
         [self.refreshControl endRefreshing];
         [SVProgressHUD dismiss];
         [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
         [[NSUserDefaults standardUserDefaults] synchronize];
         
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         NSLog(@"ERROR: %@", error);
         NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
         [self.refreshControl endRefreshing];
         [SVProgressHUD showErrorWithStatus:@"Whoops!"];
         
     }];
    
    
}

- (NSDictionary *)updatedParametersForNewerArticlesRequest
{
    if (self.userID)
        return @{self.parameterForNewerArticles: self.newestArticlePubdate, self.userParameter: self.userID};
    return @{self.parameterForNewerArticles: self.newestArticlePubdate};
    
}

- (NSDictionary *)updatedParametersForOlderArticlesRequest
{
    if (self.userID)
        return @{self.parameterForOlderArticles: self.oldestArticlePubdate, self.userParameter: self.userID};
    return @{self.parameterForOlderArticles: self.oldestArticlePubdate};

}

- (void)setPubdates
{
    MNSArticle *firstArticle = [[_fetchedResultsController fetchedObjects]  objectAtIndex:0];
    self.newestArticlePubdate = firstArticle.pubdate;
    
    MNSArticle *lastArticle = [[_fetchedResultsController fetchedObjects] lastObject];
    self.oldestArticlePubdate = lastArticle.pubdate;
    
}

- (void)refreshInvoked:(id)sender forState:(UIControlState)state
{
    [self fetchNewerArticles];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    NSLog(@"NUMBER OF ROWS, %lu",(unsigned long)[sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDate *lastUpdatedAt = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastUpdatedAt"];
    NSString *dateString = [NSDateFormatter
                            localizedStringFromDate:lastUpdatedAt
                            dateStyle:NSDateFormatterShortStyle
                            timeStyle:NSDateFormatterMediumStyle];
    
    if (nil == dateString) { dateString = @"Never"; }
    
    return [NSString stringWithFormat:@"Last Load: %@", dateString];
    
}

- (void)configureCell:(MNSArticleTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MNSArticle *art = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.title.text = art.title;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *tableIdentifier = @"ArticleTableCell";
    
    MNSArticleTableCell *cell = (MNSArticleTableCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MNSArticleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [self configureCell:(MNSArticleTableCell *)cell atIndexPath:indexPath];
    return cell;
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(MNSArticleTableCell *)[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    NSIndexPath *path = [NSIndexPath indexPathForRow:([[_fetchedResultsController fetchedObjects] count] - 4) inSection:0];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    NSArray *visibleRows = [self.tableView visibleCells];
    UITableViewCell *lastVisibleCell = [visibleRows lastObject];
    NSIndexPath *path = [self.tableView indexPathForCell:lastVisibleCell];
    NSInteger lastSectionIndex = [self.tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex] - 1;
    NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
    
    if(path.row == pathToLastRow.row)
    {
        [self fetchOlderArticles];
    }
}


@end
