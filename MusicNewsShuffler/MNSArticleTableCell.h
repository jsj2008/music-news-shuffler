//
//  ArticleTableCell.h
//  ARSSReader
//
//  Created by Nick Nikolov on 03/11/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNSArticleTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *pubdate;

@end
