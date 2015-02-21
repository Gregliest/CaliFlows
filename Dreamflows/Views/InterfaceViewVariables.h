#import <Foundation/Foundation.h>

#define FONT_SIZE_SMALL 11
#define FONT_SIZE_MEDIUM 14
#define FONT_SIZE_LARGE 20
#define FONT_SIZE_HUGE 50
#define FONT_SIZE_LABEL 30

#define BIG_RADIUS_RATIO .8

@interface InterfaceViewVariables : NSObject
+ (NSDictionary *) flowColors;
+ (NSArray *) flowKeys;
+ (UIColor *)darkText;
+ (UIColor *)mediumText;
+ (UIColor *)favoritesColor;
+ (UIColor *)titleBarColor;
+ (UIColor *)backgroundColor;

@end
