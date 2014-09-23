#import <Foundation/Foundation.h>

#define FONT_SIZE_SMALL 11
#define FONT_SIZE_MEDIUM 14
#define FONT_SIZE_LARGE 20
#define FONT_SIZE_LABEL 30

#define TITLE_RGB 137 green:170 blue:221 alpha:1
#define TITLE_HSB 213 saturation:.6 brightness:.2 alpha:1
#define BACKGROUND_RGB 238 green:238 blue:250 alpha:1
#define BACKGROUND_HSB 220 saturation:.05 brightness:.94 alpha:1
#define FAVORITES_HSB 193 saturation:.4 brightness:.9 alpha:1

#define FLOW_BLUE_HSB 191 saturation:.7 brightness:.8 alpha:1
#define FLOW_YELLOW_HSB 55 saturation:.7 brightness:.9 alpha:1
#define FLOW_GREEN_HSB 127 saturation:.7 brightness:.8 alpha:1
#define FLOW_RED_HSB 0 saturation:.7 brightness:.8 alpha:1

#define BIG_RADIUS_RATIO .8

@interface InterfaceViewVariables : NSObject
+ (NSDictionary *) flowColors;
+ (NSArray *) flowKeys;
+ (UIColor *) RGBA:(int)red green:(int)green blue:(int)blue alpha:(float)alpha;  //Make a color in RGB space
+ (UIColor *)HSBA:(int)hue saturation:(CGFloat)sat brightness:(CGFloat)bright alpha:(CGFloat)alpha; //Make a color in HSB space.
@end
