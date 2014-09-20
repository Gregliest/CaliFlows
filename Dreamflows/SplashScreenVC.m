//
//  SplashScreenVC.m
//  Dreamflows
//
//  Created by Gregory Lee on 6/12/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "SplashScreenVC.h"
#import "DFDataController.h"

@interface SplashScreenVC ()
@property (weak, nonatomic) IBOutlet UIButton *continueButton;


@end

@implementation SplashScreenVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.continueButton.layer.cornerRadius = 8;
    
    DFDataController *dfFetcher = [DFDataController sharedManager]; //Start the updating process
    [dfFetcher updateGages];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
@end
