//
//  WebViewController.h
//  Dreamflows
//
//  Created by Gregory Lee on 5/15/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *cachedWebPage;

- (void)setWebContent:(NSDictionary *)link withCachedPage:(NSString *)cachedPage;

@end
