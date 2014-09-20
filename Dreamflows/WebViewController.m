//
//  WebViewController.m
//  Dreamflows
//
//  Created by Gregory Lee on 5/15/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "WebViewController.h"
#import "Run+Dreamflows.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)setWebContent:(NSDictionary *)link withCachedPage:(NSString *)cachedPage {
    self.cachedWebPage = cachedPage;
    self.url = [NSURL URLWithString:link[LINK]];
    /*
    NSRange startRange = [link rangeOfString:@"'>"];
    if(startRange.length != 0) {
        NSString * truncated = [link substringToIndex:(startRange.location)];
        self.url = [NSURL URLWithString:truncated]; 
    }*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.webView loadHTMLString:self.cachedWebPage baseURL:nil];
    NSLog(@"LOading page: %@", self.url);
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
	// Do any additional setup after loading the view.
}

@end
