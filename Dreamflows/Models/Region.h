//
//  Region.h
//  Dreamflows
//
//  Created by Gregory Lee on 2/23/15.
//  Copyright (c) 2015 Gregory Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Gage;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * isIncluded;
@property (nonatomic, retain) NSSet *gage;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addGageObject:(Gage *)value;
- (void)removeGageObject:(Gage *)value;
- (void)addGage:(NSSet *)values;
- (void)removeGage:(NSSet *)values;

@end
