//
//  ArticleTableCell.m
//  ARSSReader
//
//  Created by Nick Nikolov on 03/11/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import "MNSArticleTableCell.h"

@implementation MNSArticleTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
