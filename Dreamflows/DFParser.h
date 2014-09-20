//
//  DFParser.h
//  Dreamflows
//
//  Created by Gregory Lee on 11/2/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GAGE_NAME_KEY @"GageName"
#define LINK_NAME @"name"
#define LINK @"link"
#define CACHE @"cache"

@interface DFParser : NSObject
+(NSArray *) parseFlows:(NSArray *) records;
+(NSArray *) parseRegions:(NSString *) website;
+(NSString *) findRegion:(NSArray *)regions withIndex:(NSUInteger) index;
+(NSArray *) parseRuns:(NSString *) gageName fromWebsite:(NSString *) website;
+(NSString *) parseGageName: (NSString *) rawGageString;
+(NSString *) parseGraphLink:(NSString *) rawGageString;

+(NSArray *) parseMapLinks:(NSString *) newInfo;
+(NSArray *) parseDescriptions:(NSString *) rawRunString;
+(NSString *)parseLengthClass:(NSString *) newInfo;
//Convenience methods
+(NSString *)dateFromString:(NSString *) dateString;
+(NSString *) stringBetweenStrings:(NSString *) string startingFrom:(NSString *) startString endingAt:(NSString *) endString;
+(NSString *)currentTime;
+(NSString *)formatDate:(NSDate *) date;
@end
