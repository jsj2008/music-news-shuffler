//
//  RSSArticle.h
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RXMLElement;

@interface MNSArticle : NSObject

@property NSString *author;
@property NSString *content;
@property NSDate *pubdate;
@property NSURL *url;
@property NSString *title;
@property NSString *articleType;


+ (MNSArticle *)createRSSArticleWithXMLElement:(RXMLElement *)XMLElement;

@end
