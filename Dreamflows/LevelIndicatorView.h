//
//  LevelIndicatorView.h
//  Dreamflows
//
//  Created by Gregory Lee on 5/17/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelIndicatorView : UIView
@property (strong, nonatomic) UIColor * color;
//The ratio of the radius to the bounds of the view
@property (nonatomic) CGFloat radiusRatio;

@end
