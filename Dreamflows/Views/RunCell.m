#import "RunCell.h"
#import "Gage+Dreamflows.h"

@implementation RunCell

- (void)setupView {
    self.runName.textColor = [InterfaceViewVariables darkText];
    [self.runName setFont:[UIFont boldSystemFontOfSize:FONT_SIZE_MEDIUM]];
    self.runProperties.textColor = [InterfaceViewVariables mediumText];
    [self.runProperties setFont:[UIFont systemFontOfSize:FONT_SIZE_SMALL]];
    self.runProperties.alpha = .7;
    self.riverName.textColor = [InterfaceViewVariables darkText];
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
        favoriteLabel.textColor = [InterfaceViewVariables favoritesColor];
        favoriteLabel.text =@"★";
    } else {
        favoriteLabel.textColor = [InterfaceViewVariables darkText];
        favoriteLabel.text =@"☆";
    }
    return favoriteLabel;
}
@end
