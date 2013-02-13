//
//  RSSArticle.h
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RXMLElement;

@interface RSSArticle : NSObject

@property NSString *title;
@property NSString *description;
@property NSURL *url;
@property NSDate *date;
@property NSString *articleType;
@property NSString *articleAuthor;

+ (RSSArticle *)createRSSArticleWithXMLElement:(RXMLElement *)XMLElement;

@end
