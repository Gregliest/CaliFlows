//
//  Gage+Dreamflows.m
//  Dreamflows
//
//  Created by Gregory Lee on 5/3/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "Gage+Dreamflows.h"

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


@end
