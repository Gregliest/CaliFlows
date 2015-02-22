#import <UIKit/UIKit.h>
#import "Run+Dreamflows.h"

@interface RunViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic)Run * run;
- (IBAction)handleTap:(UITapGestureRecognizer *)sender;

@end
