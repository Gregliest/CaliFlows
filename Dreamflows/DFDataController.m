//  Works in the following order:
//  UpdateRuns - parseGages (sends runs finished notification)
//      -> loadDesciptions - parseRunsAndAddToDatabase
//      -> updateFlows - addFlowsToDatabase (sends flows finished notification
//
//  Instructions: Call updateRuns to update everything, updateFlows just to update flows on already loaded gages.

#import "DFDataController.h"
#import "DFAppDelegate.h"
#import <time.h>
@interface DFDataController ()
@property (atomic) BOOL updatingFlows;
@property (atomic) BOOL updatingGages;
@property (atomic) int websitesLoadedCounter;
@property (strong, atomic) NSDate *lastGageUpdate;
@property (strong, atomic) NSDate *lastFlowsUpdate;
@property (strong, nonatomic) NSManagedObjectContext * managedContext;
@end


#define CA_CSV_URL @"http://www.dreamflows.com/realtime.csv"
#define CA_GAGE_URL @"http://www.dreamflows.com/flows.php?page=real&zone=canv&form=norm&mark=All"
#define CA_DESCRIPTION_URL @"http://www.dreamflows.com/xlist-ca.php#Site011"
#define NW_GAGE_URL @"http://www.dreamflows.com/flows.php?page=prod&zone=panw&form=norm"
#define NW_CSV_URL @"http://www.dreamflows.com/flows-panw.csv"
#define OR_DESCRIPTION_URL @"http://www.dreamflows.com/xlist-or.php#Site476"
#define WA_DESCRIPTION_URL @"http://www.dreamflows.com/xlist-wa.php#Site588"
#define ID_DESCRIPTION_URL @"http://www.dreamflows.com/xlist-id.php#Site151"
#define MT_DESCRIPTION_URL @"http://www.dreamflows.com/xlist-mt.php#Site406"
#define WY_DESCRIPTION_URL @"http://www.dreamflows.com/xlist-wy.php#Site404"

#define NUM_WEBSITES 2
#define UPDATE_INTERVAL_GAGE_s 86400 //1 day
#define UPDATE_INTERVAL_FLOWS_s 600 //10 minutes

@implementation DFDataController

#pragma mark Initialization

//Creates a shared instance of the model
+ (id)sharedManager {
    static DFDataController *sharedDreamflowsFetcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDreamflowsFetcher = [[self alloc] init];
    });
    return sharedDreamflowsFetcher;
}

-(id) init {
    self = [super init];
    if(self) {
        self.updatingFlows = NO;
        self.updatingGages = NO;
        self.lastFlowsUpdate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
        self.lastGageUpdate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
        
        // subscribe to change notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_mocDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

#pragma mark Database Methods
-(NSManagedObjectContext *) managedContext {
    if(!_managedContext) {
        _managedContext = [(DFAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    return _managedContext;
}

-(NSArray *) getEntries:(NSFetchRequest *) request {
    return [self.managedContext executeFetchRequest:request error:nil];
}

- (void)saveInBackground:(void(^)(NSManagedObjectContext *context))saveBlock completion:(void(^)(void))completion
{
	dispatch_async([DFDataController background_save_queue], ^{
		[self saveDataInContext:saveBlock];
        
		dispatch_sync(dispatch_get_main_queue(), ^{
			completion();
		});
	});
}

- (void)saveDataInContext:(void(^)(NSManagedObjectContext *context))saveBlock
{
    //Create a new managed object context
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:[(DFAppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator]];	//step 1
    //Set the merge policy
	[context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];				//step 2
	[self.managedContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    
	saveBlock(context);										//step 4
	
    // Save the context.
    NSLog(@"Saving to PSC");
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

+ (dispatch_queue_t) background_save_queue
{
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("background_queue", 0);
    });
    return queue;
}

- (void)_mocDidSaveNotification:(NSNotification *)notification
{
    NSManagedObjectContext *savedContext = [notification object];
    
    // ignore change notifications for the main MOC
    if (self.managedContext == savedContext)
    {
        NSLog(@"Main context did a save! %@", savedContext);
        return;
    }
    
    if (self.managedContext.persistentStoreCoordinator != savedContext.persistentStoreCoordinator)
    {
        NSLog(@"Another database did a save %@", savedContext);
        // that's another database
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"Background context did a save! %@", savedContext);
        [self.managedContext mergeChangesFromContextDidSaveNotification:notification];
    });
}

#pragma mark Update Database

//This function updates runs and flows.
//Loads the website data on another thread, calls parseGages to parse the gages.
-(void) updateGages {
    NSLog(@"Entering updateRuns");
    //Make sure we are not starting multiple threads at once, and that we haven't updated recently
    NSDate *updatePlusInterval = [self.lastGageUpdate dateByAddingTimeInterval:UPDATE_INTERVAL_GAGE_s];
    if(self.updatingGages || [updatePlusInterval compare:[NSDate date]] == NSOrderedDescending) {
        NSLog(@"No need to update runs");
        return;
    }
    self.updatingGages = YES;
    self.websitesLoadedCounter = 0;
    NSLog(@"Actually updating runs");
    
    //Load Gage Pages
    NSArray * queries = [[NSArray alloc] initWithObjects:CA_GAGE_URL, NW_GAGE_URL,nil];
    for(NSString * gageQuery in queries) {
        NSURL * gageUrl = [NSURL URLWithString:gageQuery];
        dispatch_queue_t websiteLoader = dispatch_queue_create("Website Loader", NULL);
        dispatch_async(websiteLoader, ^{
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSString * website = [NSString stringWithContentsOfURL:gageUrl usedEncoding:nil error:nil];
            if(!website) { //Network error
                [self onFinishedUpdatingGages];
                return;
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self saveInBackground:^(NSManagedObjectContext *context) {
                [self addGages:website withContext:context];  //parse the gages
                NSLog(@"Finished loading gages on background");
                self.lastGageUpdate = [NSDate date];
            } completion:^{
                if(self.websitesLoadedCounter >= NUM_WEBSITES) {
                    [self onFinishedUpdatingGages];
                }
            }];
        });
    }
}

#define NUM_UNPARSEABLE_GAGES 4 //The 4 nevada rivers
-(void) addGages:(NSString *) gageWebsite withContext:(NSManagedObjectContext *) context{
    NSLog(@"Entering gages into database %@", [DFParser currentTime]);
    NSArray * splitByGage = [gageWebsite componentsSeparatedByString:@"Gauge and reach info"];
    
    for(int i = 1; i < [splitByGage count]; i++) {
        [self addGageToDB:splitByGage[i] withNumber:i withContext:context];
    }
    
    self.websitesLoadedCounter++;
}

-(void) onFinishedUpdatingGages {
    self.updatingGages = NO;
    self.websitesLoadedCounter = 0;
    NSLog(@"Finished Updating gages, sent notification %@", [DFParser currentTime]);
    [self loadDescriptions];
}

//Loads the website data on another thread, calls addFlowsToDatabase to add the flows to the database, which then sends out a notification
-(void) updateFlows{
    NSLog(@"Entering updateFlows %@", [DFParser currentTime]);
    //Make sure this is only running once at a time
    NSDate *updatePlusInterval = [self.lastFlowsUpdate dateByAddingTimeInterval:UPDATE_INTERVAL_FLOWS_s];
    if(self.updatingFlows || [updatePlusInterval compare:[NSDate date]] == NSOrderedDescending) {
        NSLog(@"No need to update flows");
        return;
    }
    //NSLog(@"In DFFetcher, updating flows");
    self.updatingFlows = YES;
    
    //Load the website
    dispatch_queue_t websiteLoader = dispatch_queue_create("Website Loader", NULL);
    dispatch_async(websiteLoader, ^{
        NSLog(@"OPENING!!!!! flows in websiteLoader thread%@", [DFParser currentTime]);
        
        NSArray * queries = [[NSArray alloc] initWithObjects:CA_CSV_URL, NW_CSV_URL,nil];
        NSMutableArray *results = [[NSMutableArray alloc] init];
        for(NSString * query in queries) {
            NSURL * url = [NSURL URLWithString:query];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSString * csv = [NSString stringWithContentsOfURL:url usedEncoding:nil error:nil];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            if(!csv) { //Network error
                [self onFinishedUpdatingFlows];
                return;
            }
            [results addObject:csv];
        }
        [self saveInBackground:^(NSManagedObjectContext *context) {
            for(NSString *csv in results) {
                NSMutableArray * records = [[csv componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
                NSArray * gageFlows = [DFParser parseFlows:records];
                [self addFlowsToDatabase:gageFlows withContext:context];
            }
            [self onFinishedUpdatingFlows];
            self.lastFlowsUpdate = [NSDate date];
        } completion:^{
            
        }];
    });
}

- (void) addFlowsToDatabase:(NSArray *)gageFlows withContext:(NSManagedObjectContext *) context{
    int needsSyncCounter = 0;
    for(NSDictionary * gageInfo in gageFlows) {
        NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Gage"];
        request.predicate = [NSPredicate predicateWithFormat:@"name == %@", gageInfo[GAGE_NAME_KEY]];
        Gage * thisGage = [[context executeFetchRequest:request error:nil] lastObject];
        
        if(thisGage) {
            [DFDataController enterFlowInfo:gageInfo forGage:thisGage];
        } else {
            needsSyncCounter++;
        }
    }
    
    if(needsSyncCounter >  4) {
        NSLog(@"In %@ %@, error couldn't find enough gages",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    
    [self updateBestGages:context];
}

-(void) onFinishedUpdatingFlows {
    NSLog(@"Finished Updating Flows in main thread, saving background context");
    [[NSNotificationCenter defaultCenter] postNotificationName:FLOWS_FINISHED_LOADING_NOTIFICATION object:nil];
    self.updatingFlows = NO;
}

//called by the gage finished notification, so that we know that all of the gages have loaded before adding the descriptions.
-(void) loadDescriptions {
    //Load Description Page
    NSArray * queries = [[NSArray alloc] initWithObjects:CA_DESCRIPTION_URL, OR_DESCRIPTION_URL, WA_DESCRIPTION_URL, ID_DESCRIPTION_URL, MT_DESCRIPTION_URL, WY_DESCRIPTION_URL, nil]; //CA has to be the first.  This is a hack
    NSMutableArray * websites = [[NSMutableArray alloc] initWithCapacity:6];//Number of websites in the above array, for performance only
    dispatch_queue_t websiteLoader = dispatch_queue_create("Website Loader", NULL);
    dispatch_async(websiteLoader, ^{
        for(NSString * query in queries) {
            NSURL * url = [NSURL URLWithString:query];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSString * website = [NSString stringWithContentsOfURL:url usedEncoding:nil error:nil];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if(!website) { //Network error
                return;
            }
            [websites addObject:website];
        }
        [self saveInBackground:^(NSManagedObjectContext *context) {
            [self parseRunsAndAddToDatabase:websites withContext:context];
            [self updateBestGages:context]; //To force an update of the best gages, in case the flows have already been updated. 
        } completion:^{
            [self updateFlows];
            [[NSNotificationCenter defaultCenter] postNotificationName:DESCRIPTION_FINISHED_LOADING_NOTIFICATION object:nil];
            NSLog(@"Finished Updating Runs in main thread %@", [DFParser currentTime]);
        }];
    });
}

-(void) parseRunsAndAddToDatabase:(NSArray *)descriptionWebsites withContext:(NSManagedObjectContext *) context{
    //NSLog(@"Entering parseRunAndAddToDatabase%@", [self currentTime]);
    NSArray * states = [[NSArray alloc] initWithObjects:@"California", @"Oregon", @"Washington", @"Idaho", @"Montana", @"Wyoming", nil];
    //California is the only state with regions, so only parse for the first site
    NSArray *regions = [DFParser parseRegions:descriptionWebsites[0]];
    
    //Parse info for gages and runs
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Gage"];
    NSArray * allGages = [context executeFetchRequest:request error:nil];
    NSLog(@"Entering runs into database in main thread%@ gages count: %lu", [DFParser currentTime], (unsigned long)allGages.count);
    
    for (Gage *thisGage in allGages) {
        NSRange nameRange;
        int i;
        //Find the gage in one of the description websites.
        for(i = 0; i < descriptionWebsites.count; i++) {
            nameRange = [descriptionWebsites[i] rangeOfString:thisGage.name];
            if(nameRange.length > 0) {
                break;
            }
        }
        if(i >=  descriptionWebsites.count) {
            NSLog(@"ERROR, could not find description for gage %@", thisGage.name);
        } else {  
            //make the runs
            NSArray * runs = [DFParser parseRuns:thisGage.name fromWebsite:descriptionWebsites[i]];
            NSMutableSet *runsFromGage = [[NSMutableSet alloc] init];
            for(int i = 0; i < [runs count]; i++) {
                NSString * thisLine = runs[i];
                if(thisLine) {
                    if([thisLine rangeOfString:@"width='12' border='0'>"].length > 0 && [thisLine rangeOfString:@"<B>Note"].length == 0) {
                        Run * run = [self addRunToDB:thisLine withContext:context];
                        if(run) {
                            [runsFromGage addObject:run];
                        }
                    }
                }
            }
            thisGage.runsFromGage = runsFromGage;
            if(i == 0) {
                thisGage.region = [DFParser findRegion:regions withIndex:nameRange.location];
            } else {
                thisGage.region = states[i];
            }
        }
    }
}

#pragma mark DB changing methods.

-(Gage *) addGageToDB:(NSString *) rawGageString withNumber:(NSUInteger) i withContext:(NSManagedObjectContext *) context{
    //Parse and add to database
    Gage * gage = [Gage gageWithName:[DFParser parseGageName:rawGageString] usingManagedContext:context withNumber:i];
    gage.graphLink = [DFParser parseGraphLink:rawGageString];
    return gage;
}

-(Run *) addRunToDB:(NSString *) rawInfo withContext:(NSManagedObjectContext *) context {
    
    //Parse Name
    NSString * runName = [DFParser stringBetweenStrings:rawInfo startingFrom:@"width='12' border='0'>" endingAt:@"("];
    //Add to DB, or update if it's already there.
    Run * run = [Run runWithName:runName withNewInfo:rawInfo usingManagedContext:context withNumber:0];
    
    return run;
}

+(void) enterFlowInfo:(NSDictionary *) flow forGage:(Gage*) gage {
    gage.flow = flow[@"RiverFlow"];
    gage.flowUnit = flow[@"FlowUnit"];
    gage.dateFlowUpdate = flow[@"FormattedDate"];
    gage.colorCode = flow[@"ColorCode"];
    
}

-(void) updateBestGages:(NSManagedObjectContext *) context {
    NSLog(@"Entering updateBestGage");
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Run"];
    NSArray * allRuns = [context executeFetchRequest:request error:nil];
    
    for(Run * run in allRuns) {
        run.bestGage = [Run getHighestGage:run];
    }
}

-(BOOL) isUpdating {
    return (self.updatingFlows || self.updatingGages);
}
/*
#pragma mark Caching

- (void) updateFavoritesCaching {
    [self.backgroundContext performBlock:^{
        NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Run"];
        NSArray * allRuns = [self.backgroundContext executeFetchRequest:request error:nil];
        for(Run * run in allRuns) {
            [DFDataController updateCache:run];
        }
    }];
}

+(void)updateCache:(Run *)r withContext:(NSManagedObjectContext *) context{
    NSMutableArray * tempDescriptionArray = [r.descriptionsLinks mutableCopy];
    NSMutableArray * tempMapArray = [r.mapLinks mutableCopy];
    dispatch_queue_t websiteLoader = dispatch_queue_create("Cache Loader", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(websiteLoader, ^{
        NSArray * descriptionLinks = [DFDataController cacheArray:tempDescriptionArray addCache:[r.favorite boolValue]];
        [context performBlock:^{
            r.descriptionsLinks = descriptionLinks;
        }];
    });
    dispatch_async(websiteLoader, ^{
        NSArray * mapsLinks = [DFDataController cacheArray:tempMapArray addCache:[r.favorite boolValue]];
        [context performBlock:^{
            r.mapLinks = mapsLinks;
        }];
    });
    
}

+(NSArray *) cacheArray:(NSMutableArray *)linkArray addCache:(BOOL)add{
    NSMutableArray * tempArray = [[NSMutableArray alloc] initWithCapacity:[linkArray count]];
    for(NSDictionary * link in linkArray) {
        NSMutableDictionary *tempLink = [link mutableCopy];
        if(add) {
            NSURL *url = [NSURL URLWithString:link[LINK]];
            NSError *error;
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            //NSLog(@"Set Visible in %@", NSStringFromSelector(_cmd));
            
            NSString *website = [NSString stringWithContentsOfURL:url usedEncoding:nil error:nil];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            //NSLog(@"Set Invisible in %@", NSStringFromSelector(_cmd));
            //AWetState uses a different encoding.
            if(!website) {
                website = [[NSString alloc] initWithContentsOfURL:url encoding:NSWindowsCP1252StringEncoding error:&error];
            }
            //NSString * website = [NSString stringWithContentsOfURL:url usedEncoding:nil error:&error];
            if(website) {
                [tempLink setObject:website forKey:CACHE];
            } else {
                NSLog(@"Cache Error: %@", error);
            }
        } else {
            [tempLink removeObjectForKey:CACHE];
        }
        [tempArray addObject:[NSDictionary dictionaryWithDictionary:tempLink]];
    }
    return tempArray;
}*/

@end
