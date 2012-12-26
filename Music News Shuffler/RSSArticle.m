//
//  RSSArticle.m
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import "RSSArticle.h"
#import "RXMLElement.h"

@implementation RSSArticle

+ (RSSArticle *)createRSSArticleWithXMLElement:(RXMLElement *)XMLElement
{
    RSSArticle* article = [[RSSArticle alloc] init];
    article.title = [[XMLElement child:@"title" ] text];
    article.link = [NSURL URLWithString:[[XMLElement child:@"link"] text]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZZ"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:[XMLElement child:@"pubDate"].text];
    article.date = dateFromString;
    return article;

}
@end
