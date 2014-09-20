#import <UIKit/UIKit.h>
#import "LevelIndicatorView.h"
@interface AddFavoritesCell : UITableViewCell
@property (strong, nonatomic) IBOutlet LevelIndicatorView *levelIndicator;
@property (strong, nonatomic) IBOutlet UILabel *runName;
@property (strong, nonatomic) IBOutlet UILabel *runProperties;
@property (weak, nonatomic) IBOutlet UILabel *favoriteStar;
@property (weak, nonatomic) IBOutlet UILabel *riverName;
@end
