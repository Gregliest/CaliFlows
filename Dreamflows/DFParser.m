//
//  DFParser.m
//  Dreamflows
//
//  Created by Gregory Lee on 11/2/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "DFParser.h"

@implementation DFParser

#pragma mark Parsing

//Returns an array of NSDictionary to 
+(NSArray *) parseFlows:(NSArray *) records {
    NSMutableArray * gageFlows = [[NSMutableArray alloc] init];
    
    //Parse the info from the csv file
    NSArray *keys = [records[6] componentsSeparatedByString:@","];
    for(int i = 7; i < [records count]; i++) { //7 is the line of first flow
        NSString * rawGage = [records[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSArray *thisGage = [rawGage componentsSeparatedByString:@","];
        if([thisGage count] == [keys count]) { //If it has the right number of keys
            NSMutableDictionary *gageInfo = [[NSMutableDictionary alloc] initWithObjects:thisGage forKeys:keys];
            NSString *gageName = [NSString stringWithFormat:@"%@ - %@", gageInfo[@"RiverName"], gageInfo[@"PlaceName"]];
            [gageInfo setObject:gageName forKey:GAGE_NAME_KEY];
            NSString *newDate  = [self dateFromString:[NSString stringWithFormat:@"%@ %@", gageInfo[@"Date"], gageInfo[@"Time"]]];
            if(newDate) {
                [gageInfo setObject:newDate forKey:@"FormattedDate"];
            }
            
            [gageFlows addObject:[NSDictionary dictionaryWithDictionary:gageInfo]];
        }
    }
    return gageFlows;
}

//Returns an array of NSDictionaries with a region name and a range.  
+ (NSArray *) parseRegions:(NSString *) website {
    NSArray * temp = [website componentsSeparatedByString:@"<H2><U><A NAME"];
    int rangeCount = 0;
    NSMutableArray * regions = [[NSMutableArray alloc] initWithCapacity:[temp count]];
    for(int i = 0; i < [temp count]; i++) {
        
        NSString* regionName = [self stringBetweenStrings:temp[i] startingFrom:@"California " endingAt:@"<"];
        if(regionName.length > 0) {
            NSMutableDictionary * regionDict = [[NSMutableDictionary alloc] initWithCapacity:2];
            [regionDict setObject:regionName forKey:@"region"];
            [regionDict setObject:[[NSNumber alloc] initWithInt:rangeCount] forKey:@"range"];
            [regions addObject:regionDict];
        }
        rangeCount += ((NSString *)temp[i]).length;
        
    }
    return regions;
}

+ (NSString *) findRegion:(NSArray *)regions withIndex:(NSUInteger) index {
    NSDictionary * region;
    for(NSDictionary * dict in regions) {
        if(!region) {
            region = dict;
        } else {
            if(((NSNumber *)dict[@"range"]).intValue > ((NSNumber *)region[@"range"]).intValue &&  ((NSNumber *)dict[@"range"]).intValue < index) {
                region = dict;
            }
        }
    }
    return region[@"region"];
}

+ (NSArray *) parseRuns:(NSString *) gageName fromWebsite:(NSString *) website {
    NSString *tempGageDescriptionString = [self stringBetweenStrings:website startingFrom:gageName endingAt:@"<p>"];
    
    NSArray *gageDescriptions = [tempGageDescriptionString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    return gageDescriptions;
}

+(NSString *) parseGageName: (NSString *) rawGageString {
    //Parse Gage Name
    NSString * riverName = [self stringBetweenStrings:rawGageString startingFrom:@"class='River'>" endingAt:@"</a>"];
    NSString * placeName = [self stringBetweenStrings:rawGageString startingFrom:@"class='Place'>" endingAt:@"</a>"];
    if(!placeName) {
        placeName = [self stringBetweenStrings:rawGageString startingFrom:@"</a></td><td>&nbsp;&nbsp;</td><td>" endingAt:@"<"];
    }
    return [NSString stringWithFormat:@"%@ - %@", riverName, placeName];
}

+(NSString *) parseGraphLink:(NSString *) rawGageString {
    //Parse Graph Link
    NSRange graphRange = [rawGageString rangeOfString:@"http://www.dreamflows.com/graphs/"];  //Split by this graph link base string
    NSString * graphLink = @"";
    if(graphRange.length > 0) {
        NSString * tempGraphLink = [rawGageString substringFromIndex:graphRange.location];
        graphLink = [tempGraphLink substringToIndex:[tempGraphLink rangeOfString:@"'"].location];
    } else {
        NSLog(@"In %@ %@, error no graph link for %@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [self parseGageName:rawGageString]);
    }
    return graphLink;
}

+(NSArray *) parseMapLinks:(NSString *) rawRunString {
    NSString * reachMapString = [self stringBetweenStringsIncludingStart:rawRunString startingFrom:@"/reachMap" endingAt:@">"];
    if(reachMapString == nil) {
        return [[NSArray alloc] init];
    }
    NSDictionary * mapDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"http://www.dreamflows.com%@", reachMapString],LINK, @"Dreamflows Map", LINK_NAME, nil];  //Hard coded, do not need to catch invalid argument exception
    NSArray * mapLinks = [[NSArray alloc] initWithObjects:mapDict, nil];
    return mapLinks;
}

+(NSArray *) parseDescriptions:(NSString *) rawRunString {
    NSRange descriptionRange = [rawRunString rangeOfString:@"http"];
    if(descriptionRange.length > 0) {
        
        NSString * descriptionsSubstring = [rawRunString substringFromIndex:descriptionRange.location];
        NSArray * descriptionArray = [descriptionsSubstring componentsSeparatedByString:@"</a> &nbsp;<a href='"];
        NSMutableArray * parsedArray = [[NSMutableArray alloc] init];
        for(NSString * link in descriptionArray) {
            NSDictionary * linkDict = [self parseLink:link];
            if(linkDict) {
                [parsedArray addObject:linkDict];
            }
        }
        return parsedArray;
    }else {
        return nil;
    }
}

+(NSDictionary *) parseLink:(NSString *)rawLink {
    NSMutableDictionary * link = [[NSMutableDictionary alloc] init];
    NSRange startRange = [rawLink rangeOfString:@"'>"];
    
    if(startRange.length > 0) {
        NSString * truncated = [rawLink substringToIndex:(startRange.location)];
        [link setObject:truncated forKey:LINK];
        NSString * name = [rawLink substringFromIndex:(startRange.location + startRange.length)];
        NSRange endRange = [name rangeOfString:@"</a>"];
        if(endRange.length >0) {
            name = [name substringToIndex:endRange.location];
        }
        [link setObject:name forKey:LINK_NAME];
        return link;
    } else {
        NSLog(@"In %@ %@, error parsing %@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), rawLink);
        return nil;
    }
}

//Assumes that the run class length information is always in the last set of parentheses in the line
+(NSString *)parseLengthClass:(NSString *) newInfo {
    NSMutableArray * parensArray = [[NSMutableArray alloc] init];
    NSString *temp = [NSString stringWithString:newInfo];
    NSRange nextParen = [temp rangeOfString:@"("];
    
    while (nextParen.length >0) {
        [parensArray addObject:[self stringBetweenStrings:temp startingFrom:@"(" endingAt:@")"]];
        temp = [temp substringFromIndex:(nextParen.location + 1)];
        nextParen = [temp rangeOfString:@"("];
    }
    
    return [parensArray lastObject];
}

#pragma mark Convenience Methods

+(NSString *)dateFromString:(NSString *) dateString {
    // If the date formatters aren't already set up, create them and cache them for reuse.
    static NSDateFormatter *sRFC3339DateFormatter = nil;
    if (sRFC3339DateFormatter == nil) {
        sRFC3339DateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
        [sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm'"];
        [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    
    // Convert the RFC 3339 date time string to an NSDate.
    NSDate *date = [sRFC3339DateFormatter dateFromString:dateString];
    static NSDateFormatter *sUserVisibleDateFormatter = nil;
    NSString *userVisibleDateTimeString;
    if (date != nil) {
        if (sUserVisibleDateFormatter == nil) {
            sUserVisibleDateFormatter = [[NSDateFormatter alloc] init];
            [sUserVisibleDateFormatter setDateStyle:NSDateFormatterShortStyle];
            [sUserVisibleDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
        // Convert the date object to a user-visible date string.
        userVisibleDateTimeString = [sUserVisibleDateFormatter stringFromDate:date];
    }
    return userVisibleDateTimeString;
}

+(NSString *) stringBetweenStrings:(NSString *) string startingFrom:(NSString *) startString endingAt:(NSString *) endString {
    
    NSRange startRange = [string rangeOfString:startString];
    if(startRange.length == 0) {
        return nil;
    }
    NSString * truncated = [string substringFromIndex:(startRange.location +startRange.length)];
    NSRange endRange = [truncated rangeOfString:endString];
    if(endRange.length == 0) {
        return nil;
    } else {
        return [truncated substringToIndex:endRange.location];
    }
}

+(NSString *) stringBetweenStringsIncludingStart:(NSString *) string startingFrom:(NSString *) startString endingAt:(NSString *) endString {
    
    NSRange startRange = [string rangeOfString:startString];
    if(startRange.length == 0) {
        return nil;
    }
    NSString * truncated = [string substringFromIndex:(startRange.location)];
    NSRange endRange = [truncated rangeOfString:endString];
    if(endRange.length == 0) {
        return nil;
    } else {
        return [truncated substringToIndex:endRange.location -1];
    }
}

+(NSString *)currentTime {
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss.SS"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    return dateString;
}

+(NSString *)formatDate:(NSDate *) date {
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss.SS"];
    
    dateString = [formatter stringFromDate:date];
    return dateString;
}

@end
