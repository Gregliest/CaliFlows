#import <Foundation/Foundation.h>

#define GAGE_NAME_KEY @"GageName"
#define LINK_NAME @"name"
#define LINK @"link"
#define CACHE @"cache"

/**
 This is the dumping ground for all sorts of horrendous code dealing with parsing the dreamflows website.  It is very specific, poorly written, fragile, and I was unaware of the existence of parsing libraries when I wrote it.  Hopefully it will be rendered obselete when I get around to creating my own database on Parse.  For now, touch at your own risk.  
 */
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
