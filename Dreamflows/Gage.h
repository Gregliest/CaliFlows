//
//  Gage.h
//  Dreamflows
//
//  Created by Gregory Lee on 7/7/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Run;

@interface Gage : NSManagedObject

@property (nonatomic, retain) NSString * colorCode;
@property (nonatomic, retain) NSString * graphLink;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSNumber * sortNumber;
@property (nonatomic, retain) NSString * weatherLink;
@property (nonatomic, retain) NSString * dateFlowUpdate;
@property (nonatomic, retain) NSString * flowUnit;
@property (nonatomic, retain) NSString * flow;
@property (nonatomic, retain) NSSet *bestRuns;
@property (nonatomic, retain) NSSet *runsFromGage;
@end

@interface Gage (CoreDataGeneratedAccessors)

- (void)addBestRunsObject:(Run *)value;
- (void)removeBestRunsObject:(Run *)value;
- (void)addBestRuns:(NSSet *)values;
- (void)removeBestRuns:(NSSet *)values;

- (void)addRunsFromGageObject:(Run *)value;
- (void)removeRunsFromGageObject:(Run *)value;
- (void)addRunsFromGage:(NSSet *)values;
- (void)removeRunsFromGage:(NSSet *)values;

@end
