//
//  RSSArticle.m
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import "RSSArticle.h"

@implementation RSSArticle

-(NSAttributedString *)cellMessage
{
    if (_cellMessage) return _cellMessage;
    
    NSDictionary* boldStyle = @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:16.0]};
    NSDictionary* normalStyle = @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:16.0]};
    
    NSMutableAttributedString* articleAbstract = [[NSMutableAttributedString alloc] initWithString:self.title];
    
    [articleAbstract setAttributes:boldStyle range:NSMakeRange(0, self.title.length)];
    
    [articleAbstract appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
    
    int startIndex = [articleAbstract length];
    
    NSString* desciption = [NSString stringWithFormat:@"%@... ", [self.description substringToIndex:self.description.length * 0.1]];
    //desciption = [desciption gtm_stringByEscapingForHTML];
    
    [articleAbstract appendAttributedString:[[NSAttributedString alloc] initWithString: desciption]];
    
    [articleAbstract setAttributes:normalStyle range:NSMakeRange(startIndex, articleAbstract.length - startIndex)];
    
    _cellMessage = articleAbstract;
    
    return _cellMessage;
    
}

@end
