//
//  FilterModel.m
//  Dreamflows
//
//  Created by Gregory Lee on 5/29/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//
//  This class serves as the model for an array of buttons that are used for filtering.  It assumes that there are groups of buttons, of which the first is the "any" button, which causes no filtering to take place for this group.  The rest of the buttons can be selected or not, independently of the others. This class then builds a predicate based on the selections in all of the groups of buttons.
//  For instance, if there are two groups of buttons, class and flow, this class can take in the bool arrays corresponding to the button states, and build a predicate that, say, finds all class 3 and 4 runs that are flowing Low.  

#import "FilterModel.h"
#import "InterfaceViewVariables.h"

@interface FilterModel()
@property (strong, nonatomic) NSMutableDictionary * filterData; //Stores the predicates with their current bool arrays.
@end

@implementation FilterModel

#define NUM_BUTTON_COLLECTIONS 2 //Number of button collections expected
#define FIELD_KEY @"field"
#define PREDICATES_KEY @"keys"
#define BOOLS_KEY @"bools"

//Initialize with the desired fields to be searched with the predicates.  For instance, field1ForRun is "difficulty", so this will filter by class.  
-(id)initWithFields:(NSString *)field1 field2:(NSString *)field2 {
    self = [super init];
    if(self) {
        NSArray * initialBoolArray = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],[NSNumber numberWithInt:0], nil]; //Initial button state, "any" selected
        NSMutableDictionary *mutableFilterData = [[NSMutableDictionary alloc] initWithCapacity:2];
        
        NSMutableDictionary * one = [[NSMutableDictionary alloc] initWithCapacity:3];
        [one setValue:[[NSArray alloc] initWithArray:initialBoolArray]forKey:BOOLS_KEY];
        [one setValue:field1 forKey:FIELD_KEY];
        [one setValue:[self classPredicates:field1] forKey:PREDICATES_KEY];
        [mutableFilterData setObject:one forKey:CLASS_BUTTON_COLLECTION_KEY];
        
        NSMutableDictionary * two = [[NSMutableDictionary alloc] init];
        [two setValue:[[NSArray alloc] initWithArray:initialBoolArray]forKey:BOOLS_KEY];
        [two setValue:field2 forKey:FIELD_KEY];
        [two setValue:[self flowPredicates:field2] forKey:PREDICATES_KEY];
        [mutableFilterData setObject:two forKey:FLOW_BUTTON_COLLECTION_KEY];
        
        self.filterData = mutableFilterData;
    }
    return self;
}

//Returns the current bools array for the key, so that the buttons can be displayed properly.
-(NSArray *) getBoolsArray:(NSString *) key {
    return self.filterData[key][BOOLS_KEY];
}

//Sets the bool array for the key, so that the model matches user or other input.  
-(void)setArray:(NSArray *) boolArray forKey:(NSString *)key{
    //Allocate more data space
    if(!self.filterData[key]) {
        NSLog(@"In FilterModel, model not initialized for key %@!", key);
    } else {
        NSMutableDictionary * modelEntry = self.filterData[key];
        if(modelEntry) {
            if([boolArray count] != ([modelEntry[PREDICATES_KEY] count] + 1)) { //+1 for the any button
                NSLog(@"In Filter Model setArray, inconsistent array size!");
            } else {
                [modelEntry setValue:boolArray forKey:BOOLS_KEY];
                [self.filterData setValue:modelEntry forKey:key];
            }
        } else {
            NSLog(@"In FilterModel, getboolsArray, can't find entry for that key %@", key);
        }
    }
}

//Returns the array of predicates corresponding to the current state of the bool arrays.  
- (NSArray *)getPredicates {
    NSMutableArray * predicates = [[NSMutableArray alloc] initWithCapacity:3];//Number of groups of buttons
    
    //Loop through all entries in filter data
    for(id key in self.filterData) {
        //get the associated predicates.
        NSPredicate * predicate = [self buildPredicate:self.filterData[key]];
        if(predicate) {
            [predicates addObject:predicate];
        }
    }
    
    return predicates;
}

//Builds the predicates for a given entry in filterData.  It takes the bool array and builds the predicate based on what is selected. Assumes that the first element in the outlet collection is the "any" button, so it returns a predicate of nil, which will return all elements.
-(NSPredicate *)buildPredicate:(NSDictionary *)entry{
    NSArray * bools = entry[BOOLS_KEY];
    NSArray * predicates = entry[PREDICATES_KEY];
    
    if(([bools count]- 1) != [predicates count]) {//-1 for the any button
        NSLog(@"In SearchFiltersViewController buildPredicateArrays, array size mismatch");
        return nil;
    }
    
    BOOL firstButton = [[bools objectAtIndex:0] boolValue];
    NSMutableArray *thesePredicates = [[NSMutableArray alloc] initWithCapacity:bools.count];
    if(firstButton) {
        return nil; //Return no predicate for the any button
        
    //Else build a predicate depending on what is selected. 
    } else {
        for (int i = 1; i < [bools count]; i++) {
            BOOL thisButton = [bools[i] boolValue];
            //NSLog(@"%@ is %d", thisButton.titleLabel.text, thisButton.selected);
            if(thisButton) {
                [thesePredicates addObject:predicates[i - 1]];
            }
        }
    }
    
    if(thesePredicates.count <= 0) {
        return nil;
    } else {
        NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:thesePredicates];
        //NSLog(@"Predicate is... %@", predicate.predicateFormat);
        return predicate;
    }
}

//Defines the class predicates.  Edit the desired predicates corresponding to each class here.
-(NSArray *)classPredicates:(NSString *) field {
    NSPredicate * ii = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", field, @"II"];
    NSPredicate * iii = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", field,@"III"];
    NSPredicate * iv = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", field,@"IV"];
    NSPredicate * v = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", field,@" V"];
    
    return [[NSArray alloc] initWithObjects:ii, iii, iv, v, nil];
}

//Defines the flow predicates.  Edit the desired predicates corresponding to each class here
-(NSArray *)flowPredicates:(NSString *) field {
    NSArray * flowKeys = [InterfaceViewVariables flowKeys];
    NSString * na = [NSString stringWithFormat:@"FlowNa"];
    NSString * noReading = [NSString stringWithFormat:@"No Reading"];
    NSString * lo = [NSString stringWithFormat:@"FlowLo"];
    NSString * ok = [NSString stringWithFormat:@"FlowOk"];
    NSString * pf = [NSString stringWithFormat:@"FlowPf"];
    NSString * hi = [NSString stringWithFormat:@"FlowHi"];
    
    //Check that the keys haven't changed
    NSArray * flowStrings = [[NSArray alloc] initWithObjects:na, lo, ok, pf, hi, nil];
    for(NSString * flowString in flowStrings) {
        if(![flowKeys containsObject:flowString]) {
            assert(@"In SearchFiltersViewController, flow keys changed!");
            NSLog(@"In SearchFiltersViewController, flow keys changed! %@ not in keys", flowString);
        }
    }
    
    //Build the predicates here, and add to array. 
    NSMutableArray * flows = [[NSMutableArray alloc] initWithCapacity:[flowStrings count]];
    [flows addObject:[NSPredicate predicateWithFormat:@"%K contains[cd] %@", field, lo]];
    
    NSPredicate * okPred = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", field, ok];
    NSPredicate * pfPred = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", field, pf];
    NSArray * temp = [[NSArray alloc] initWithObjects:okPred, pfPred, nil];
    [flows addObject:[NSCompoundPredicate orPredicateWithSubpredicates:temp]];
    
    [flows addObject:[NSPredicate predicateWithFormat:@"%K contains[cd] %@", field, hi]];
    
    NSPredicate * naPred = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", field, na];
    NSPredicate * noReadPred = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", field, noReading];
    NSArray * temp1 = [[NSArray alloc] initWithObjects:naPred, noReadPred, nil];
    [flows addObject:[NSCompoundPredicate orPredicateWithSubpredicates:temp1]];
    
    return flows;
}

@end
