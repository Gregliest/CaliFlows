#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface BackgroundLayer : NSObject

+(CAGradientLayer*) greyGradient;
+ (CAGradientLayer*) blueGradient:(CGFloat) brightnessMultiplier;

@end
