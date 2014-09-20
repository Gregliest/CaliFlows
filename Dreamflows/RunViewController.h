#import <UIKit/UIKit.h>
#import "Gage+Dreamflows.h"
#import "Run+Dreamflows.h"
#import "InterfaceViewVariables.h"
#import "LevelIndicatorView.h"
#import "DFDataController.h"
#import "WebViewController.h"

@interface RunViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic)Run * run;
- (IBAction)handleTap:(UITapGestureRecognizer *)sender;

@end
