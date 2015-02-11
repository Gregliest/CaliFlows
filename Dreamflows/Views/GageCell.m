#import "GageCell.h"
@interface GageCell()

@end

@implementation GageCell

-(void)updateWithGage:(Gage *)gage {
    //Setup view
    self.gageName.textColor = [InterfaceViewVariables darkText];
    [self.gageName setFont:[UIFont boldSystemFontOfSize:FONT_SIZE_MEDIUM]];
    self.gageProperties.textColor = [InterfaceViewVariables mediumText];
    [self.gageProperties setFont:[UIFont systemFontOfSize:FONT_SIZE_SMALL]];
    self.gageProperties.alpha = .7;
    
    //Display gage properties.  
    self.gageName.text = gage.name;
    self.gageProperties.text = [NSString stringWithFormat:@"%@ %@", gage.flow, gage.flowUnit];
    self.levelIndicator.color =[InterfaceViewVariables flowColors][gage.colorCode];
}

@end
