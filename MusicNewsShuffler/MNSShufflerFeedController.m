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
{
    NSArray *_objects;
    UIRefreshControl *refreshControl;
    MNSArticle *_lastArticle;
    NSString *_lastArictlePubdate;
    RKEntityMapping *_articleMapping;
    RKResponseDescriptor *_responseDescriptor;
    RKManagedObjectStore *_managedObjectStore;
    RKObjectManager *_objectManager;
    NSString *_requestURLString;
}

@end

@implementation MNSShufflerFeedController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"News Shuffler";
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(refreshInvoked:forState:)
             forControlEvents:UIControlEventValueChanged];
    
    NSString* fetchMessage = [NSString stringWithFormat:@"Loading new articles..."];
    refreshControl.attributedTitle = [[NSAttributedString alloc]
                                        initWithString:fetchMessage
                                            attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica"
                                                                                       size:11.0]}];
    
    _articleMapping = [self mapArticle];
    _responseDescriptor = [self responseDescriptorWithMapping:_articleMapping];
    _managedObjectStore = [[MNSDataModel sharedDataModel] objectStore];
    _objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    _objectManager.managedObjectStore = _managedObjectStore;
    [_objectManager addResponseDescriptor:_responseDescriptor];
    _requestURLString = feedBaseURLString;
    _lastArictlePubdate = @"";
    
    [self.tableView addSubview:refreshControl];
    [SVProgressHUD show];
    dispatch_async(kBgQueue, ^{
        [self loadData];
    });
    
}

- (void)loadData
{    
    _requestURLString = [NSString stringWithFormat:@"%@?last_pubdate=%@", _requestURLString,_lastArictlePubdate];
    [_objectManager getObjectsAtPath:_requestURLString
                         parameters:nil
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    {
        if (_objects) {
            NSMutableArray *temp = [NSMutableArray arrayWithArray:_objects];
            [temp addObjectsFromArray:mappingResult.array];
            _objects = [NSArray arrayWithArray:temp];
        } else {
            _objects = mappingResult.array;
        }

        _lastArticle = [_objects objectAtIndex:[_objects count]-1];
        _lastArictlePubdate = _lastArticle.pubdate;
        [refreshControl endRefreshing];
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Yey!"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.tableView reloadData];

    } failure:^(RKObjectRequestOperation *operation, NSError *error)
    {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        [refreshControl endRefreshing];
        [SVProgressHUD showErrorWithStatus:@"Whoops!"];

    }];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc]
//                                                initWithRequest:request
//                                            responseDescriptors:@[responseDescriptor]];
//    
//        
//    RKManagedObjectStore *store = [[MNSDataModel sharedDataModel] objectStore];
//    operation.managedObjectCache = store.managedObjectCache;
//    operation.managedObjectContext = store.mainQueueManagedObjectContext;
//    
//    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//       } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//       }];
//    
//    [operation start];
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
    return [_objects count];
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
    
    MNSArticle *currItem = _objects[indexPath.row];    
    cell.title.text = currItem.title;
    return cell;

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
        MNSArticle* object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
