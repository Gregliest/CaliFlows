#import <UIKit/UIKit.h>
#import "levelIndicatorView.h"
#import "Gage+Dreamflows.h"
#import "InterfaceViewVariables.h"

@interface GageCell : UITableViewCell
//@property (weak, nonatomic) IBOutlet UILabel *levelIndicatorLabel;
@property (strong, nonatomic) IBOutlet LevelIndicatorView *levelIndicator;
@property (strong, nonatomic) IBOutlet UILabel *gageName;
@property (strong, nonatomic) IBOutlet UILabel *gageProperties;

-(void)updateWithGage:(Gage *)gage;
@end
