//
//  Gage+Dreamflows.h
//  Dreamflows
//
//  Created by Gregory Lee on 5/3/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "Gage.h"

@interface Gage (Dreamflows)
+(Gage *) gageWithName:(NSString *) name usingManagedContext:(NSManagedObjectContext *) context withNumber:(int) number;

@end
