//
//  FilterModel.h
//  Dreamflows
//
//  Created by Gregory Lee on 5/29/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterModel : NSObject

#define CLASS_BUTTON_COLLECTION_KEY @"class"
#define FLOW_BUTTON_COLLECTION_KEY @"flow"

#define FIELD1ForRun @"difficulty"
#define FIELD2ForRun @"bestGage.colorCode"
#define FIELD1ForGage @"difficulty"
#define FIELD2ForGage @"colorCode"

- (NSArray *)getPredicates;
-(void)setArray:(NSArray *) boolArray forKey:(NSString *)key;  //NSNumbers, initWithInt
-(NSArray *) getBoolsArray:(NSString *) key;
-(id)initWithFields:(NSString *)field1 field2:(NSString *)field2;

@end
