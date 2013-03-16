//
//  AnaheimFontLabel.m
//  MusicNewsShuffler
//
//  Created by Nick Nikolov on 11/03/2013.
//  Copyright (c) 2013 Nick Nikolov. All rights reserved.
//

#import "AnaheimFontLabel.h"

@implementation AnaheimFontLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"Anaheim-Regular" size:self.font.pointSize];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
