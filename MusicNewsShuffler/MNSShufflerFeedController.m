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



@interface MNSShufflerFeedController () <NSFetchedResultsControllerDelegate>
{
    NSArray *_objects;
    UIRefreshControl *refreshControl;
    MNSArticle *_lastArticle;
    NSString *_lastArictlePubdate;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end


@implementation MNSShufflerFeedController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"News Shuffler";
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(refreshInvoked:forState:)
             forControlEvents:UIControlEventValueChanged];
    
    NSString* fetchMessage = [NSString stringWithFormat:@"Fetching news..."];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:fetchMessage attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:11.0]}];
    
    [self.tableView addSubview: refreshControl];
    
    
    [SVProgressHUD show];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
            [self refreshFeed];
    });
    
    //[self refreshFeed];
        
}

- (void)loadData
{    
    RKEntityMapping *articleMapping = [RKEntityMapping
                                       mappingForEntityForName:@"MNSArticle"
                                       inManagedObjectStore:[[MNSDataModel sharedDataModel] objectStore]];
    
    [articleMapping addAttributeMappingsFromDictionary:@{
     @"id"  :   @"articleID",
     @"url" :   @"urlString"
     }];
    [articleMapping addAttributeMappingsFromArray:@[@"title", @"author", @"content", @"pubdate"]];
    
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor
                                                responseDescriptorWithMapping:articleMapping
                                                pathPattern:@"/rss_feed_loader/get_feed.json"
                                                keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSString *baseURLString = @"http://localhost:3000/rss_feed_loader/get_feed.json";
    NSString *requestURLString;
    if (_lastArictlePubdate) {
        requestURLString = [NSString stringWithFormat:@"%@?last_pubdate=%@", baseURLString,_lastArictlePubdate];
    } else {
        requestURLString = baseURLString;
    }
    
    NSLog(@"requestURLString: %@", requestURLString);

    //NSURL *url = [NSURL URLWithString:@"http://localhost:3000/rss_feed_loader/get_feed.json"];
    NSURL *url = [NSURL URLWithString:requestURLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc]
                                                initWithRequest:request
                                            responseDescriptors:@[responseDescriptor]];
    
    RKManagedObjectStore *store = [[MNSDataModel sharedDataModel] objectStore];
    operation.managedObjectCache = store.managedObjectCache;
    operation.managedObjectContext = store.mainQueueManagedObjectContext;
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        if (_objects) {
            //_objects = @[_objects, mappingResult.array];
            //_objects = [NSArray ]
            NSMutableArray *temp = [NSMutableArray arrayWithArray:_objects];
            [temp addObjectsFromArray:mappingResult.array];
            _objects = [NSArray arrayWithArray:temp];
            NSLog(@"Objects count: %lu", (unsigned long)[_objects count]);
        } else {
            _objects = mappingResult.array;
        }
        
        
        _lastArticle = [_objects objectAtIndex:[_objects count]-1];
        _lastArictlePubdate = _lastArticle.pubdate;
        NSLog(@"Last pubdate is: %@", _lastArictlePubdate);
//        NSLog(@"Result mapped: %@", mappingResult);
        [SVProgressHUD dismiss];
        [refreshControl endRefreshing];
        [SVProgressHUD showSuccessWithStatus:@"Yey!"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
    
    [operation start];
}


- (void)refreshInvoked:(id)sender forState:(UIControlState)state
{
    [self refreshFeed];
}

-(void)refreshFeed
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




//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    RSSItem *item = [_objects objectAtIndex:indexPath.row];
//    CGRect cellMessageRect = [item.cellMessage boundingRectWithSize:CGSizeMake(200, 1000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
//
//    return cellMessageRect.size.height;
//}


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
    
//    MNSArticle *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    NSLog(@"This is my article: %@", currItem);
//    cell.title.text = article.title;
    return cell;

    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

//- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
//    CGPoint offset = aScrollView.contentOffset;
//    CGRect bounds = aScrollView.bounds;
//    CGSize size = aScrollView.contentSize;
//    UIEdgeInsets inset = aScrollView.contentInset;
//    float y = offset.y + bounds.size.height - inset.bottom;
//    float h = size.height;
//    // NSLog(@"offset: %f", offset.y);
//    // NSLog(@"content.height: %f", size.height);
//    // NSLog(@"bounds.height: %f", bounds.size.height);
//    // NSLog(@"inset.top: %f", inset.top);
//    // NSLog(@"inset.bottom: %f", inset.bottom);
//    // NSLog(@"pos: %f of %f", y, h);
//    
//    float reload_distance = 50;
//    if(y > h + reload_distance) {
//        NSLog(@"load more rows");
//        [self refreshFeed];
//    }
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    NSArray *visibleRows = [self.tableView visibleCells];
    UITableViewCell *lastVisibleCell = [visibleRows lastObject];
    NSIndexPath *path = [self.tableView indexPathForCell:lastVisibleCell];
    
    // First figure out how many sections there are
    NSInteger lastSectionIndex = [self.tableView numberOfSections] - 1;
    
    // Then grab the number of rows in the last section
    NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex] - 1;
    
    // Now just construct the index path
    NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
    
    if(path.row == pathToLastRow.row)
    {
        NSLog(@"PLZ RELOAD ME");
        [self refreshFeed];
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
