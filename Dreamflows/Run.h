//
//  Run.h
//  Dreamflows
//
//  Created by Gregory Lee on 7/7/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Gage;

@interface Run : NSManagedObject

@property (nonatomic, retain) NSNumber * deprecated;
@property (nonatomic, retain) id descriptionsLinks;
@property (nonatomic, retain) NSString * difficulty;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * lengthClass;
@property (nonatomic, retain) NSString * longName;
@property (nonatomic, retain) id mapLinks;
@property (nonatomic, retain) id miscLinks;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * riverName;
@property (nonatomic, retain) NSString * runName;
@property (nonatomic, retain) id shuttleLinks;
@property (nonatomic, retain) NSNumber * sortNumber;
@property (nonatomic, retain) Gage *bestGage;
@property (nonatomic, retain) NSSet *gages;
@end

@interface Run (CoreDataGeneratedAccessors)

- (void)addGagesObject:(Gage *)value;
- (void)removeGagesObject:(Gage *)value;
- (void)addGages:(NSSet *)values;
- (void)removeGages:(NSSet *)values;

@end
