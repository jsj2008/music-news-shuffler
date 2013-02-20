//
//  ShufflerFeedController.m
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import "MNSShufflerFeedController.h"
#import "MNSArticleTableCell.h"
#import "MNSFeedsLoader.h"
#import "MNSArticle.h"
#import "ArticleViewController.h"
#import <RestKit/RestKit.h>
#import "MNSDataModel.h"
#import "SVProgressHUD.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define feedBaseURLString @"/rss_feed_loader/get_feed.json"

@interface MNSShufflerFeedController () <NSFetchedResultsControllerDelegate>

@property NSArray *objects;
@property UIRefreshControl *refreshControl;
@property MNSArticle *lastArticle;
@property NSString *lastArticlePubdate;
@property RKEntityMapping *articleMapping;
@property RKResponseDescriptor *responseDescriptor;
@property RKManagedObjectStore *managedObjectStore;
@property RKObjectManager *objectManager;
@property NSFetchedResultsController *fetchedResultsController;

@end


@implementation MNSShufflerFeedController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"News Shuffler";
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                       action:@selector(refreshInvoked:forState:)
             forControlEvents:UIControlEventValueChanged];
    
    NSString* fetchMessage = [NSString stringWithFormat:@"Loading new articles..."];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]
                                        initWithString:fetchMessage
                                            attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica"
                                                                                       size:11.0]}];
    
    self.articleMapping = [self mapArticle];
    self.responseDescriptor = [self responseDescriptorWithMapping:_articleMapping];
    self.managedObjectStore = [[MNSDataModel sharedDataModel] objectStore];
    self.objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    self.objectManager.managedObjectStore = self.managedObjectStore;
    [self.objectManager addResponseDescriptor:self.responseDescriptor];
    self.lastArticlePubdate = @"";
    
    [self.tableView addSubview:self.refreshControl];
    [SVProgressHUD show];
    
    
    // new core data stuff
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MNSArticle"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"pubdate" ascending:NO];
    fetchRequest.sortDescriptors = @[descriptor];
    NSError *error = nil;
    
    // Setup fetched results
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[self.objectManager managedObjectStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [self.fetchedResultsController setDelegate:self];
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    if (! fetchSuccessful) {
        [SVProgressHUD showErrorWithStatus:@"Dang! :("];
    }
    self.objects = [self.fetchedResultsController fetchedObjects];

    // new core data stuff
    
    [self loadData];
    
}

- (void)loadData
{    
    NSLog(@"LOADING DATA");
    [_objectManager getObjectsAtPath:feedBaseURLString
                          parameters:@{@"last_pubdate": self.lastArticlePubdate}
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    {
//        if (_objects) {
//            NSMutableArray *temp = [NSMutableArray arrayWithArray:self.objects];
//            [temp addObjectsFromArray:mappingResult.array];
//            self.objects = [NSArray arrayWithArray:temp];
//        } else {
//            self.objects = mappingResult.array;
//        }

        NSLog(@"MAPPING RESULT: %@", mappingResult.array);
        self.lastArticle = [self.objects objectAtIndex:[self.objects count]-1];
        self.lastArticlePubdate = self.lastArticle.pubdate;
        NSLog(@"last pubdate: %@", self.lastArticlePubdate);
        [self.refreshControl endRefreshing];
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Yey!"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
//        [self.tableView reloadData];

    } failure:^(RKObjectRequestOperation *operation, NSError *error)
    {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [self.refreshControl endRefreshing];
        [SVProgressHUD showErrorWithStatus:@"Whoops!"];

    }];

}

- (RKEntityMapping *)mapArticle
{
    RKEntityMapping *articleMapping = [RKEntityMapping
                                       mappingForEntityForName:@"MNSArticle"
                                       inManagedObjectStore:[[MNSDataModel sharedDataModel] objectStore]];
    
    [articleMapping addAttributeMappingsFromDictionary:@{
                                                        @"id"  :   @"articleID",
                                                        @"url" :   @"urlString"
     }];
    [articleMapping addAttributeMappingsFromArray:@[@"title", @"author", @"content", @"pubdate"]];
    
    articleMapping.identificationAttributes = @[@"title", @"articleID"];
    
    return articleMapping;
}

- (RKResponseDescriptor *)responseDescriptorWithMapping:(RKEntityMapping *)mapping
{
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor
                                                responseDescriptorWithMapping:mapping
                                                pathPattern:@"/rss_feed_loader/get_feed.json"
                                                keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    return responseDescriptor;
}

- (void)refreshInvoked:(id)sender forState:(UIControlState)state
{
    [self loadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    NSLog(@"rows: %lu", (unsigned long)[sectionInfo numberOfObjects]);
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *tableIdentifier = @"ArticleTableCell";
    
    MNSArticleTableCell *cell = (MNSArticleTableCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MNSArticleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    MNSArticle *currItem = self.objects[indexPath.row];
    cell.title.text = currItem.title;
    return cell;

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"NEW CONTENT YEY");
    
//    NSArray *fetchedObjects = [self.fetchedResultsController fetchedObjects];
//    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.objects];
//    [temp addObjectsFromArray:fetchedObjects];
//    self.objects = [NSArray arrayWithArray:temp];
    
//    [self.tableView reloadData];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
    
    self.objects = [self.fetchedResultsController fetchedObjects];
    [self.tableView beginUpdates];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    

   // [self.tableView scrollTo]
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

        [self loadData];
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MNSArticle* object = self.objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
