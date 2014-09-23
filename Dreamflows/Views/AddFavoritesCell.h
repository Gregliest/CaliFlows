#import <UIKit/UIKit.h>
#import "LevelIndicatorView.h"
#import "InterfaceViewVariables.h"
#import "Run+Dreamflows.h"

@interface AddFavoritesCell : UITableViewCell
@property (strong, nonatomic) IBOutlet LevelIndicatorView *levelIndicator;
@property (strong, nonatomic) IBOutlet UILabel *runName;
@property (strong, nonatomic) IBOutlet UILabel *runProperties;
@property (weak, nonatomic) IBOutlet UILabel *favoriteStar;
@property (weak, nonatomic) IBOutlet UILabel *riverName;

- (void)updateWithRun:(Run *)run;

@end
