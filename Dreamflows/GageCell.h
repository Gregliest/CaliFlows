#import <UIKit/UIKit.h>
#import "levelIndicatorView.h"
@interface GageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *levelIndicatorLabel;
@property (strong, nonatomic) IBOutlet LevelIndicatorView *levelIndicator;
@property (strong, nonatomic) IBOutlet UILabel *gageName;
@property (strong, nonatomic) IBOutlet UILabel *gageProperties;

@end
