//
//  MNSArticle.m
//  MusicNewsShuffler
//
//  Created by Nick Nikolov on 19/02/2013.
//  Copyright (c) 2013 Nick Nikolov. All rights reserved.
//

#import "MNSArticle.h"


@implementation MNSArticle

@dynamic articleID;
@dynamic author;
@dynamic content;
@dynamic pubdate;
@dynamic title;
@dynamic type;
@dynamic urlString;

- (void)setContent:(NSString *)content
{
    if (!content) {
        self.type = @"B";
    } else {
        self.type = @"A";
    }
}

@end
