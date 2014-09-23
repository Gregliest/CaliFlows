#import "Run.h"
#import "DFParser.h"


@interface Run (Dreamflows)

+(Run *) runWithName:(NSString *) name
         withNewInfo:(NSString *) newInfo
 usingManagedContext:(NSManagedObjectContext *) context
          withNumber:(int) number;

+(Gage *)getHighestGage:(Run *) run;
@end
