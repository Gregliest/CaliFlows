//
//  Run+Dreamflows.h
//  Dreamflows
//
//  Created by Gregory Lee on 5/3/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "Run.h"
#import "DFParser.h"


@interface Run (Dreamflows)

+(Run *) runWithName:(NSString *) name
         withNewInfo:(NSString *) newInfo
 usingManagedContext:(NSManagedObjectContext *) context
          withNumber:(int) number;

+(Gage *)getHighestGage:(Run *) run;
@end
