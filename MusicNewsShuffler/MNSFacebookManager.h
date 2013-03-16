//
//  MNSFacebookManager.h
//  MusicNewsShuffler
//
//  Created by Nick Nikolov on 16/03/2013.
//  Copyright (c) 2013 Nick Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ PostLoginBlock)(void);


@interface MNSFacebookManager : NSObject

@property id facebookResultDictionary;
@property SEL cancelLoginOptionSelector;

- (void)addFBObserverToSender:(id)sender WithSelector:(SEL) selector;
- (void)checkFBSession;
- (void)checkFBSessionAndFetchFBInfoWithBlock:(PostLoginBlock)postLoginBlock;
- (void)logout;
- (void)login;
- (void)showLoginView;


@end
