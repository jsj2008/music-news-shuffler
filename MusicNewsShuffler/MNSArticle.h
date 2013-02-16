//
//  MNSArticle.h
//  MusicNewsShuffler
//
//  Created by Nick Nikolov on 16/02/2013.
//  Copyright (c) 2013 Nick Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MNSArticle : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * pubdate;
@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * articleID;

@end
