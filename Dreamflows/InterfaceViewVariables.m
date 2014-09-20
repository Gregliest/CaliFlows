#import "InterfaceViewVariables.h"

@implementation InterfaceViewVariables

+ (NSDictionary *) flowColors {
    NSArray * flows = [InterfaceViewVariables flowKeys];
    NSArray * colors = [[NSArray alloc] initWithObjects:[UIColor lightGrayColor], [self HSBA:FLOW_BLUE_HSB], [self HSBA:FLOW_YELLOW_HSB], [self HSBA:FLOW_GREEN_HSB], [self HSBA:FLOW_GREEN_HSB], [self HSBA:FLOW_RED_HSB], nil];
    return [NSDictionary dictionaryWithObjects:colors forKeys:flows];
}

+ (NSArray *) flowKeys {
    return [[NSArray alloc] initWithObjects:@"FlowNa", @"FlowFz",@"FlowLo",@"FlowOk",@"FlowPf",@"FlowHi", nil];
}


+ (UIColor *) RGBA:(int)red green:(int)green blue:(int)blue alpha:(float)alpha {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

+ (UIColor *)HSBA:(int)hue saturation:(CGFloat)sat brightness:(CGFloat)bright alpha:(CGFloat)alpha {
    CGFloat hueFloat = ((CGFloat)(hue)/360);
    return [UIColor colorWithHue:hueFloat saturation:sat brightness:bright alpha:alpha];
}
@end
