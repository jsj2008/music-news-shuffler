//
//  RSSFeedsLoader.m
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import "RSSFeedsLoader.h"
#import "RXMLElement.h"
#import "RSSArticle.h"


#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


@implementation RSSFeedsLoader


- (NSMutableArray*)loadTypeAFeedWithURL:(NSString *)url descriptionTag:(NSString *)descTag
{
    RXMLElement* rssFeed = [RXMLElement elementFromURL:[NSURL URLWithString:url]];
    
    if (rssFeed) {
        
        NSArray* rawRSSItems = [[rssFeed child:@"channel"] children:@"item"];
        NSMutableArray* articles = [NSMutableArray arrayWithCapacity:rawRSSItems.count];
        
        for (RXMLElement* e in rawRSSItems) {
            RSSArticle *article = [RSSArticle createRSSArticleWithXMLElement:e];
            article.articleType = @"A";
            article.description = [e child:descTag].text;
            [articles addObject:article];
            
        }
        
        return articles;
        
    }
    
    return nil;
    
}

- (NSMutableArray *)loadTypeBFeedWithURL:(NSString *)url
{
    RXMLElement* rssFeed = [RXMLElement elementFromURL:[NSURL URLWithString:url]];
    
    if (rssFeed) {
        
        NSArray* rawRSSItems = [[rssFeed child:@"channel"] children:@"item"];
        NSMutableArray* articles = [NSMutableArray arrayWithCapacity:rawRSSItems.count];
        
        for (RXMLElement* e in rawRSSItems) {
            RSSArticle *article = [RSSArticle createRSSArticleWithXMLElement:e];
            article.articleType = @"B";
            [articles addObject:article];
            
        }
        
        return articles;
        
    }
    
    return nil;
}


- (NSMutableArray *)loadTypeCFeedWithURL:(NSString *)url descriptionTag:(NSString *)descTag
{
    RXMLElement* rssFeed = [RXMLElement elementFromURL:[NSURL URLWithString:url]];
    
    if (rssFeed) {
        
        NSArray* rawRSSItems = [[rssFeed child:@"channel"] children:@"item"];
        NSMutableArray* articles = [NSMutableArray arrayWithCapacity:rawRSSItems.count];
        
        for (RXMLElement* e in rawRSSItems) {
            RSSArticle *article = [RSSArticle createRSSArticleWithXMLElement:e];
            NSString* fullDesc = [[e child:descTag].text
                                  stringByAppendingFormat:@"<p> To read full article go to: %@", article.link];
            article.description = fullDesc;
            article.articleType = @"C";
            [articles addObject:article];
            
        }
        
        return articles;
        
    }
    
    return nil;
}


- (void)fetchRSSWithCompletion:(RSSLoaderCompleteBlock)c
{
    dispatch_async(kBgQueue, ^{
        
        NSMutableArray* shufflerFeedArray = [[NSMutableArray alloc] init];
        
        [shufflerFeedArray addObjectsFromArray:[self loadTypeAFeedWithURL:@"http://feeds.feedburner.com/i-donline.com"
                                                descriptionTag:@"encoded"]];
        [shufflerFeedArray addObjectsFromArray:[self loadTypeBFeedWithURL:@"http://www.dazeddigital.com/rss"]];
        [shufflerFeedArray addObjectsFromArray:[self loadTypeCFeedWithURL:@"http://noisey.vice.com/rss"
                                                descriptionTag:@"description"]];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        [shufflerFeedArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        c(shufflerFeedArray);
        
        
    });
    
}


@end
