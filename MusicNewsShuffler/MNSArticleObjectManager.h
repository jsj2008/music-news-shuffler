//
//  MNSArticleMapper.h
//  MusicNewsShuffler
//
//  Created by Nick Nikolov on 21/02/2013.
//  Copyright (c) 2013 Nick Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKManagedObjectStore;
@class RKObjectManager;

@interface MNSArticleObjectManager : NSObject

@property RKManagedObjectStore *managedObjectStore;

+ (RKObjectManager *)createNewManager;

@end
