#import "Gage.h"

@interface Gage (Dreamflows)
+(Gage *) gageWithName:(NSString *) name usingManagedContext:(NSManagedObjectContext *) context withNumber:(int) number;
+(NSArray *)gagesInRegions:(NSArray *)regions; //Array of Gages
+(NSDictionary *)gagesDictionaryForRegions:(NSArray *)regions; //Dictionary of String, NSArray * of Gages
+(NSArray *)regions; //Array of NSString
@end
