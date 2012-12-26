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

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) NSURL* link;
@property (strong, nonatomic) NSDate* date;
@property (strong, nonatomic) NSString* articleType;

+ (RSSArticle *)createRSSArticleWithXMLElement:(RXMLElement *)XMLElement;

@end
