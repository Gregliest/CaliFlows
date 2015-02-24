#import "SettingsVC.h"
#import "InterfaceViewVariables.h"
#import "RegionChooserCell.h"

@interface SettingsVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *regions;
@end

@implementation SettingsVC

-(NSArray *)regions {
    if (!_regions) {
        _regions = [Region allRegions];
    }
    return _regions;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Regions";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.regions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Region";
    UITableViewCell *rawCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if([rawCell isKindOfClass:[RegionChooserCell class]]) {
        RegionChooserCell *cell = (RegionChooserCell *)rawCell;
        cell.region = self.regions[indexPath.row];
        return cell;
    }
    
    return nil;
}

@end
