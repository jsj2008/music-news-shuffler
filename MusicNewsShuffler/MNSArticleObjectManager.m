//
//  MNSArticleMapper.m
//  MusicNewsShuffler
//
//  Created by Nick Nikolov on 21/02/2013.
//  Copyright (c) 2013 Nick Nikolov. All rights reserved.
//

#import "MNSArticleObjectManager.h"
#import "MNSArticle.h"
#import <RestKit/RestKit.h>
#import "MNSDataModel.h"

#define feedBaseURLString @"/rss_feed_loader/newer_articles"

@interface MNSArticleObjectManager ()
@end

@implementation MNSArticleObjectManager

+ (RKObjectManager *)createNewManager
{
    
    static RKObjectManager *__sharedObjectManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RKEntityMapping *articleMapping = [self mapArticle];
        RKManagedObjectStore *managedObjectStore = [[MNSDataModel sharedDataModel] objectStore];
        __sharedObjectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
        __sharedObjectManager.managedObjectStore = managedObjectStore;
        [__sharedObjectManager addResponseDescriptorsFromArray: @[
                    [self responseDescriptorWithMapping:articleMapping andPathPattern:@"/rss_feed_loader/newer_articles.json"],
                    [self responseDescriptorWithMapping:articleMapping andPathPattern:@"/rss_feed_loader/older_articles.json"],
                    [self responseDescriptorWithMapping:articleMapping andPathPattern:@"/users/newer_articles.json"],
                    [self responseDescriptorWithMapping:articleMapping andPathPattern:@"/users/older_articles.json"]]];
    });
    
    return __sharedObjectManager;
//    RKEntityMapping *articleMapping = [self mapArticle];
//    RKManagedObjectStore *managedObjectStore = [[MNSDataModel sharedDataModel] objectStore];
//    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
//    objectManager.managedObjectStore = managedObjectStore;
//    [objectManager addResponseDescriptorsFromArray: @[
//                [self responseDescriptorWithMapping:articleMapping andPathPattern:@"/rss_feed_loader/newer_articles.json"],
//                [self responseDescriptorWithMapping:articleMapping andPathPattern:@"/rss_feed_loader/older_articles.json"],
//                [self responseDescriptorWithMapping:articleMapping andPathPattern:@"/users/newer_articles.json"],
//                [self responseDescriptorWithMapping:articleMapping andPathPattern:@"/users/older_articles.json"]]];
//    
//    return objectManager;
//    
    

}

+ (RKEntityMapping *)mapArticle
{
    RKEntityMapping *articleMapping = [RKEntityMapping
                                       mappingForEntityForName:@"MNSArticle"
                                       inManagedObjectStore:[[MNSDataModel sharedDataModel] objectStore]];
    
    [articleMapping addAttributeMappingsFromDictionary:@{
     @"id"  :   @"articleID",
     @"url" :   @"urlString"
     }];
    [articleMapping addAttributeMappingsFromArray:@[@"title", @"author", @"content", @"pubdate"]];
    
    articleMapping.identificationAttributes = @[@"title", @"articleID"];
    
    return articleMapping;
}


+ (RKResponseDescriptor *)responseDescriptorWithMapping:(RKEntityMapping *)mapping andPathPattern:(NSString *)pathPattern
{
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor
                                                responseDescriptorWithMapping:mapping
                                                pathPattern:pathPattern
                                                keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    return responseDescriptor;
}



@end
