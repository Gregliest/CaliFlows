#import <UIKit/UIKit.h>
#import "Region+Dreamflows.h"

@interface RegionChooserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *regionSwitch;
@property (strong, nonatomic) Region *region;

@end
