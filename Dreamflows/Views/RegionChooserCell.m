#import "RegionChooserCell.h"

@implementation RegionChooserCell

-(void)setRegion:(Region *)region {
    _region = region;
    self.titleLabel.text = region.name;
    self.regionSwitch.on = [region.isIncluded boolValue];
}

// In the perfect MVC world, this would call to a delegate, but that seems like overkill here.
- (IBAction)switchPressed:(UISwitch *)sender {
    [self.region toggleIsIncluded];
}

@end
