#import "Region.h"

@interface Region (Dreamflows)

+(Region *)regionWithName:(NSString *)name usingManagedContext:(NSManagedObjectContext *)context;
+(NSArray *)allRegions;

@property (strong, nonatomic, readonly) NSArray *gagesBySortNumber; // Array of Gage, caches the sorted array.
@end
