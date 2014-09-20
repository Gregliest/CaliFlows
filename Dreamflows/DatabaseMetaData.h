//
//  DatabaseMetaData.h
//  Dreamflows
//
//  Created by Gregory Lee on 7/26/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DatabaseMetaData : NSManagedObject

@property (nonatomic, retain) NSDate * lastUpdate;
@property (nonatomic, retain) NSDate * lastUpdateSpecial;

@end
