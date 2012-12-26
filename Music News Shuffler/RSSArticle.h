//
//  RSSArticle.h
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSArticle : NSObject

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) NSURL* link;
@property (strong, nonatomic) NSAttributedString* cellMessage;
@property (strong, nonatomic) NSDate* date;
@property (strong, nonatomic) NSString* articleType;

@end
