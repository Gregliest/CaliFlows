#import "AddFavoritesCell.h"
#import "Gage+Dreamflows.h"

@implementation AddFavoritesCell

- (void)setupView {
    self.runName.textColor = [UIColor blackColor];
    [self.runName setFont:[UIFont boldSystemFontOfSize:FONT_SIZE_MEDIUM]];
    self.runProperties.textColor = [UIColor grayColor];
    [self.runProperties setFont:[UIFont systemFontOfSize:FONT_SIZE_SMALL]];
    self.runProperties.alpha = .7;
    self.riverName.textColor = [UIColor blackColor];
    [self.riverName setFont:[UIFont systemFontOfSize:FONT_SIZE_SMALL]];
}

- (void)updateWithRun:(Run *)run {
    [self setupView];
    
    self.runName.text = run.runName;
    self.runProperties.text = run.lengthClass;
    self.riverName.text = run.riverName;
    self.levelIndicator.color =[InterfaceViewVariables flowColors][run.bestGage.colorCode];
    self.favoriteStar = [self setFavoriteButtonColor:self.favoriteStar withRun:run];
}

-(UILabel *)setFavoriteButtonColor:(UILabel *)favoriteLabel withRun:(Run *)run {
    if([run.favorite boolValue]) {
        favoriteLabel.textColor = [InterfaceViewVariables HSBA:FAVORITES_HSB];
        favoriteLabel.text =@"★";
    } else {
        favoriteLabel.textColor = [UIColor blackColor];
        favoriteLabel.text =@"☆";
    }
    return favoriteLabel;
}
@end
