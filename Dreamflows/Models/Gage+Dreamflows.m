#import "Gage+Dreamflows.h"
#import "DFDataController.h"

@implementation Gage (Dreamflows)
+(Gage *) gageWithName:(NSString *) name usingManagedContext:(NSManagedObjectContext *) context withNumber:(int) number{
    Gage * g = nil;
    
    //Make sure gage doesn't exist in context
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Gage"];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSArray * matches = [context executeFetchRequest:request error:nil];
    //Make sure that there's only 1
    if(!matches || [matches count] > 1) {
        //Error
        NSLog(@"In %@ %@, error finding gage %@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), matches);
    } else if ([matches count] == 1) {
        g = [matches lastObject];
    } else {
        g = [NSEntityDescription insertNewObjectForEntityForName:@"Gage" inManagedObjectContext:context];
        g.name = name;
        g = [Gage setDefaultFlowInfo:g]; //Set default flow for new gages.  
    }
    
    g.sortNumber = [[NSNumber alloc] initWithInt:number];
    
    return g;
}


+(Gage *) setDefaultFlowInfo:(Gage *) gage {
    
    //Default flow info.
    gage.flow = @"No reading at this time";
    gage.flowUnit = @"";
    gage.dateFlowUpdate = @"";
    gage.colorCode = @"FlowNa";
    
    return gage;
}


+(NSArray *)gagesInRegions:(NSArray *)regions {
    NSMutableArray *gages = [NSMutableArray new];
    for(NSString * region in self.regions) {
        NSArray *gagesForRegion = [Gage gagesForRegion:region];
        [gages addObjectsFromArray:gagesForRegion];
    }
    return gages;
}

+(NSDictionary *)gagesDictionaryForRegions:(NSArray *)regions {
    NSMutableDictionary *gagesByRegion = [[NSMutableDictionary alloc] initWithCapacity:regions.count];
    for(NSString * region in self.regions) {
        NSArray *gagesForRegion = [Gage gagesForRegion:region];
        [gagesByRegion setObject:gagesForRegion forKey:region];
    }
    return gagesByRegion;
}

+(NSArray *)regions {
    NSMutableArray * temp = [[NSMutableArray alloc] initWithCapacity:10];
    for(Gage * gage in [Gage allGages]) {
        if(gage.region && ![temp containsObject:gage.region]) {//If region have been added to database and temp does not contain the region.
            [temp addObject:gage.region];
        }
    }
    return temp;
}

//Returns all gages, sorted by sort number
+(NSArray *)allGages {
    DFDataController *dfFetcher = [DFDataController sharedManager];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Gage"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortNumber" ascending:YES]];
    return [dfFetcher getEntries:request];
}

+(NSArray *)gagesForRegion:(NSString *)region {
    DFDataController *dfFetcher = [DFDataController sharedManager];
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Gage"];
    request.predicate = [NSPredicate predicateWithFormat:@"region contains[c] %@", region];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortNumber" ascending:YES]];
    return[dfFetcher getEntries:request];
}

@end
