//
//  ShufflerFeedController.m
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import "ShufflerFeedController.h"
#import "ArticleTableCell.h"
#import "RSSFeedsLoader.h"
#import "RSSArticle.h"
#import "ArticleViewController.h"



@interface ShufflerFeedController () {
    NSArray *_objects;
    UIRefreshControl *refreshControl;
}
@end


@implementation ShufflerFeedController

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
    
    [self refreshFeed];
        
}

- (void)refreshInvoked:(id)sender forState:(UIControlState)state
{
    [self refreshFeed];
}

-(void)refreshFeed
{
    RSSFeedsLoader* rss = [[RSSFeedsLoader alloc] init];
    
    [rss fetchRSSWithCompletion:^(NSArray* results) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _objects = results;
            [self.tableView reloadData];
            [refreshControl endRefreshing];
            
            
        });
        
    }];
    
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
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
    
    ArticleTableCell *cell = (ArticleTableCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ArticleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    RSSArticle *currItem = _objects[indexPath.row];
    
    cell.title.text = currItem.title;
    
    return cell;
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RSSArticle* object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
