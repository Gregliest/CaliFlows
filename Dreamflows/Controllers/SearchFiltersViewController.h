#import <UIKit/UIKit.h>
#import "InterfaceViewVariables.h"
#import "FilterModel.h"

@class SearchFiltersViewController;
@protocol SearchFiltersDelegate <NSObject>

-(void)filteringComplete:(SearchFiltersViewController *)searchFiltersVC withFilterModel:(FilterModel *) filterModel;

@end
@interface SearchFiltersViewController : UIViewController
@property (nonatomic, weak) id <SearchFiltersDelegate> delegate; //pointer to the delegate, so we can send the filter data.
@property (strong, nonatomic) FilterModel * filterModel;
@end