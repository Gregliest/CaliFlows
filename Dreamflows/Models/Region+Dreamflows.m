#import "Region+Dreamflows.h"
#import "DFDataController.h"
#import "DFAppDelegate.h"
#import <objc/runtime.h>


static void *MyClassResultKey;

@implementation Region (Dreamflows)

+(Region *) regionWithName:(NSString *)name usingManagedContext:(NSManagedObjectContext *)context {
    if (!name) {
        return nil;
    }
    Region * r = nil;
    
    //Make sure region doesn't exist in context
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Region"];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSArray * matches = [context executeFetchRequest:request error:nil];
    //Make sure that there's only 1
    if(!matches || [matches count] > 1) {
        //Error
        NSLog(@"In %@ %@, error finding region %@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), matches);
    } else if ([matches count] == 1) {
        r = [matches lastObject];
    } else {
        NSLog(@"Creating new region %@", name);
        r = [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:context];
        r.name = name;
        r.isIncluded = [NSNumber numberWithBool:YES];
    }
    return r;
}

+(NSArray *)allRegions {
    DFDataController *dfFetcher = [DFDataController sharedManager];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Region"];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    return [dfFetcher getEntries:request];
}

+(NSArray *)includedRegions {
    DFDataController *dfFetcher = [DFDataController sharedManager];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Region"];
    request.predicate = [NSPredicate predicateWithFormat:@"isIncluded = %@", [NSNumber numberWithBool:YES]];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    return [dfFetcher getEntries:request];
}

- (NSArray *)gagesBySortNumber {
    NSArray *result = objc_getAssociatedObject(self, &MyClassResultKey);
    if (result == nil) {
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"sortNumber" ascending:YES];
        result = [self.gage sortedArrayUsingDescriptors:@[sd]];
        objc_setAssociatedObject(self, &MyClassResultKey, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

-(void)toggleIsIncluded {
    self.isIncluded = [[NSNumber alloc] initWithBool:![self.isIncluded boolValue]];
    [(DFAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}
@end
