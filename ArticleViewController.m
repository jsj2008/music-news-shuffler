//
//  ArticleViewController.m
//  Music News Shuffler
//
//  Created by Nick Nikolov on 26/12/2012.
//  Copyright (c) 2012 Nick Nikolov. All rights reserved.
//

#import "ArticleViewController.h"
#import "RSSArticle.h"

@interface ArticleViewController () 
- (void)configureView;
@end

@implementation ArticleViewController


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        
        if (([[self.detailItem articleType] isEqual: @"A"]) || ([[self.detailItem articleType] isEqual: @"C"])) {
            
            [self.articleWebView loadHTMLString:[self.detailItem description] baseURL:nil];
            
        } else if ([[self.detailItem articleType] isEqual: @"B"]) {
            
            RSSArticle *item = (RSSArticle*)self.detailItem;
            NSURLRequest *req = [NSURLRequest requestWithURL:item.url];
            [self.articleWebView loadRequest:req];
            
        }
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}


@end
