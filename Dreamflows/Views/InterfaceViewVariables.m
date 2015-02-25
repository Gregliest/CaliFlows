#import "InterfaceViewVariables.h"

#define LIGHT_GRAY_COLOR_HEX @"#e0e0e0"
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
    NSArray * colors = [[NSArray alloc] initWithObjects:[self DFGray], [self DFBlue], [self DFYellow], [self DFGreen], [self DFGreen], [self DFRed], nil];
    return [NSDictionary dictionaryWithObjects:colors forKeys:flows];
}

+ (NSArray *) flowKeys {
    return [[NSArray alloc] initWithObjects:@"FlowNa", @"FlowFz",@"FlowLo",@"FlowOk",@"FlowPf",@"FlowHi", nil];
}

# pragma mark - Basic colors

+ (UIColor *)DFWhite {
    return [UIColor whiteColor];
}

+ (UIColor *)DFLightGray {
    return [InterfaceViewVariables colorFromHexString:LIGHT_GRAY_COLOR_HEX];
}

+ (UIColor *)DFGray {
    return [UIColor lightGrayColor];
}

+ (UIColor *)DFDarkGray {
    return [UIColor darkGrayColor];
}

+ (UIColor *)DFRed {
    return [InterfaceViewVariables colorFromHexString:RED_COLOR_HEX];
}

+ (UIColor *)DFGreen {
    return [InterfaceViewVariables colorFromHexString:GREEN_COLOR_HEX];
}

+ (UIColor *)DFYellow {
    return [InterfaceViewVariables colorFromHexString:YELLOW_COLOR_HEX];
}

+ (UIColor *)DFBlue {
    return [InterfaceViewVariables colorFromHexString:BLUE_COLOR_HEX];
}

+ (UIColor *)DFDarkBlue {
    return [InterfaceViewVariables colorFromHexString:DARK_BLUE_COLOR_HEX];
}

# pragma mark - Colors for specific tasks.

+ (UIColor *)darkText {
    return [InterfaceViewVariables colorFromHexString:DARK_TEXT_HEX];
}

+ (UIColor *)mediumText {
    return [InterfaceViewVariables colorFromHexString:MEDIUM_TEXT_HEX];
}

+ (UIColor *)favoritesColor {
    return [self DFBlue];
}

+ (UIColor *)titleBarColor {
    return [self DFBlue];
}
+ (UIColor *)backgroundColor {
    return [self DFDarkBlue];
}

# pragma mark - Helpers

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
@end
