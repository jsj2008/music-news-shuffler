//
//  MNSArticle.m
//  MusicNewsShuffler
//
//  Created by Nick Nikolov on 16/02/2013.
//  Copyright (c) 2013 Nick Nikolov. All rights reserved.
//

#import "MNSArticle.h"


@implementation MNSArticle

@dynamic author;
@dynamic content;
@dynamic pubdate;
@dynamic urlString;
@dynamic title;
@dynamic type;
@dynamic articleID;

- (void)setContent:(NSString *)content
{
    if (!content) {
        self.type = @"B";
    } else {
        self.type = @"A";
    }
}
@end
