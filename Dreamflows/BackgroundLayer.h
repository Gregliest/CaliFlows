//
//  BackgroundLayer.h
//
//  Created by  on 2/02/12.
//  Copyright (c) 2012 AFG. All rights reserved.
//
//  Creates a gradient background layer.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface BackgroundLayer : NSObject

+(CAGradientLayer*) greyGradient;
+ (CAGradientLayer*) blueGradient:(CGFloat) brightnessMultiplier;

@end
