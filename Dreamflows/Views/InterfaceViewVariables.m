#import "InterfaceViewVariables.h"

#define BLUE_COLOR_HEX @"#17B1C0"
#define DARK_BLUE_COLOR_HEX @"#0F6486"
#define GREEN_COLOR_HEX @"#5EB874"
#define RED_COLOR_HEX @"#BE1A12"
#define YELLOW_COLOR_HEX @"#FFB448"
#define DARK_TEXT_HEX @"#546979"
#define MEDIUM_TEXT_HEX @"#9BA5B8"

@implementation InterfaceViewVariables

+ (NSDictionary *) flowColors {
    NSArray * flows = [InterfaceViewVariables flowKeys];
    NSArray * colors = [[NSArray alloc] initWithObjects:[UIColor lightGrayColor], [self blue], [self yellow], [self green], [self green], [self red], nil];
    return [NSDictionary dictionaryWithObjects:colors forKeys:flows];
}

+ (NSArray *) flowKeys {
    return [[NSArray alloc] initWithObjects:@"FlowNa", @"FlowFz",@"FlowLo",@"FlowOk",@"FlowPf",@"FlowHi", nil];
}

+ (UIColor *)red {
    return [InterfaceViewVariables colorFromHexString:RED_COLOR_HEX];
}

+ (UIColor *)green {
    return [InterfaceViewVariables colorFromHexString:GREEN_COLOR_HEX];
}

+ (UIColor *)yellow {
    return [InterfaceViewVariables colorFromHexString:YELLOW_COLOR_HEX];
}

+ (UIColor *)blue {
    return [InterfaceViewVariables colorFromHexString:BLUE_COLOR_HEX];
}

+ (UIColor *)darkBlue {
    return [InterfaceViewVariables colorFromHexString:DARK_BLUE_COLOR_HEX];
}

+ (UIColor *)darkText {
    return [InterfaceViewVariables colorFromHexString:DARK_TEXT_HEX];
}

+ (UIColor *)mediumText {
    return [InterfaceViewVariables colorFromHexString:MEDIUM_TEXT_HEX];
}

+ (UIColor *)favoritesColor {
    return [self blue];
}

+ (UIColor *)titleBarColor {
    return [self blue];
}
+ (UIColor *)backgroundColor {
    return [self darkBlue];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
@end
