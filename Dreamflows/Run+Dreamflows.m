//
//  Run+Dreamflows.m
//  Dreamflows
//
//  Created by Gregory Lee on 5/3/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "Run+Dreamflows.h"
#import "Gage.h"

@implementation Run (Dreamflows)

//NewInfo is a single line from http://www.dreamflows.com/xlist-ca.php#Site163 that describes a run.

//Finds the gage with the highest reported flow.  This is a hack to find the most relevant gage for a given run.
+(Gage *)getHighestGage:(Run *) run{
    Gage* coreDataGage =[run.gages anyObject];;
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    if(run.gages.count > 1) {
        NSArray * gages = [run.gages allObjects];
        NSNumber * flow = [formatter numberFromString:coreDataGage.flow];
        for(Gage * thisGage in gages) {
            NSNumber * thisFlow = [formatter numberFromString:thisGage.flow];
            if([thisFlow intValue] > [flow intValue]) {
                flow = thisFlow;
                coreDataGage = thisGage;
            }
        }
    }
    return coreDataGage;
}

+(Run *) runWithName:(NSString *) name
         withNewInfo:(NSString *) newInfo
 usingManagedContext:(NSManagedObjectContext *) context
          withNumber:(int) number{
    
    //Check that we are creating a valid run
    if(!name) {
        return nil;
    }
    Run * r = [Run findThisRun:name usingManagedContext:context];
    
    //Populate fields
    NSArray *names = [name componentsSeparatedByString:@"-"];
    r.riverName = names[0];
    if([names count] == 1) {
        r.runName = names[0];
    } else if ([names count] == 2) {
        r.runName = names[1];
    } else {
        NSString *temp = names[1];
        for(int i = 2; i< [names count]; i++) {
            temp = [NSString stringWithFormat:@"%@-%@", temp, names[i]];
        }
        r.runName = temp;
        //NSLog(@"Error in Run+Dreamflows, couldn't parse name, too many dashes for gage %@", name);
    }
    
    r.lengthClass = [DFParser parseLengthClass:newInfo];
    
    NSArray *lengthClassInfo = [r.lengthClass componentsSeparatedByString:@","];
    if(lengthClassInfo.count != 3) {
        //NSLog(@"In Run %@,  parsing length class failed %@", r.longName, r.lengthClass);
    } else {
        r.difficulty = lengthClassInfo[1];
    }
    r.deprecated = NO;
    
    //Parse map links
    r.mapLinks = [DFParser parseMapLinks:newInfo];
    
    //Parse description links
    r.descriptionsLinks = [DFParser parseDescriptions:newInfo];
    
    r.miscLinks = nil;
    r.shuttleLinks = nil;
    
    if(!r.notes) {
        r.notes = @"";
    }
    
    r.sortNumber = [[NSNumber alloc] initWithInt:number];
    
    return r;
}

+(Run *) findThisRun:(NSString *) name usingManagedContext:(NSManagedObjectContext *) context{
    Run *r = nil;
    //Look for the run in the context
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Run"];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"longName" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"longName = %@", name];
    NSError * error;
    
    NSArray * matches = [context executeFetchRequest:request error:&error];
    //Make sure that there's only 1
    if(!matches || [matches count] > 1) {
        NSLog(@"%@:%s Error on fetch request: %@", [self class], nil, [error localizedDescription]);
        return r;
    } else if ([matches count] == 1) {
        r = [matches lastObject];
        if([r.favorite boolValue]) {
            NSLog(@"Found a run with a favorite");
        }
    } else {
        //Make a new run
        r = [NSEntityDescription insertNewObjectForEntityForName:@"Run" inManagedObjectContext:context];
        r.longName = name;
        r.favorite = [[NSNumber alloc] initWithBool:NO];
    }
    return r;
}







@end
