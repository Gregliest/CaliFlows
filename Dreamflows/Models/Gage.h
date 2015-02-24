//
//  Gage.h
//  Dreamflows
//
//  Created by Gregory Lee on 2/23/15.
//  Copyright (c) 2015 Gregory Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Region, Run;

@interface Gage : NSManagedObject

@property (nonatomic, retain) NSString * colorCode;
@property (nonatomic, retain) NSString * dateFlowUpdate;
@property (nonatomic, retain) NSString * flow;
@property (nonatomic, retain) NSString * flowUnit;
@property (nonatomic, retain) NSString * graphLink;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * regionString;
@property (nonatomic, retain) NSNumber * sortNumber;
@property (nonatomic, retain) NSString * weatherLink;
@property (nonatomic, retain) NSSet *bestRuns;
@property (nonatomic, retain) NSSet *runsFromGage;
@property (nonatomic, retain) Region *region;
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
