//
//  MNSDataModel.h
//  MusicNewsShuffler
//
//  Created by Nick Nikolov on 16/02/2013.
//  Copyright (c) 2013 Nick Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RestKit/RestKit.h>

@interface MNSDataModel : NSObject

@property (nonatomic, strong) RKManagedObjectStore *objectStore;

+ (id)sharedDataModel;
- (void)setup;

@end
