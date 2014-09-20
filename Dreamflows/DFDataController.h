#import <Foundation/Foundation.h>
#import "Gage+Dreamflows.h"
#import "Run+Dreamflows.h"
#import "DFParser.h"

//#define RUN_FINISHED_LOADING_NOTIFICATION @"runsFinishedLoading"
#define FLOWS_FINISHED_LOADING_NOTIFICATION @"flowsFinishedLoading"
#define GAGE_FINISHED_LOADING_NOTIFICATION @"gagesFinishedLoading"
#define DESCRIPTION_FINISHED_LOADING_NOTIFICATION @"descriptionFinishedLoading"


@interface DFDataController : NSObject

+ (id) sharedManager;

-(NSArray *) getEntries:(NSFetchRequest *) request;

-(void) updateGages;  //Updates the entire coreDatabase
-(void) updateFlows; //Updates just the flows for existing gages

-(BOOL) isUpdating;
@end
