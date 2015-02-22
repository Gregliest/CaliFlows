#import "WebVC.h"

@interface WebVC ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebVC

-(void)viewWillAppear:(BOOL)animated {
    self.webView.scalesPageToFit = YES;
    if (self.url) {
        NSURLRequest* request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
        [self.webView loadRequest:request];
    }
}

-(void)setUrl:(NSURL *)url {
    _url = url;
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [self.webView loadRequest:request];
}

@end
