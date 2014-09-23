#import "Gage.h"

@interface Gage (Dreamflows)
+(Gage *) gageWithName:(NSString *) name usingManagedContext:(NSManagedObjectContext *) context withNumber:(int) number;

@end
