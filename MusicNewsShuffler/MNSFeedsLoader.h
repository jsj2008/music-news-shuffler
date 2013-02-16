//
//  RSSFeedsLoader.h
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^RSSLoaderCompleteBlock)(NSArray* results);

@interface MNSFeedsLoader : NSObject

-(NSMutableArray*)loadTypeAFeedWithURL:(NSString*)url descriptionTag:(NSString*)descTag;
-(NSMutableArray*)loadTypeBFeedWithURL:(NSString*)url;
-(NSMutableArray*)loadTypeCFeedWithURL:(NSString*)url descriptionTag:(NSString*)descTag;

-(void)fetchRSSWithCompletion:(RSSLoaderCompleteBlock)c;


@end
