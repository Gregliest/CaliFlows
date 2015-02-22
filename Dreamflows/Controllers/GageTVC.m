#import "GageTVC.h"
#import "GageCell.h"
#import "DFDataController.h"
#import "LevelIndicatorView.h"
#import "InterfaceViewVariables.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchFiltersViewController.h"
#import "FilterModel.h"

/**
 This table view displays Gages sorted by region, and then geographically within each region.  It supports a filter mode, which currently supports filtering by flow level, but could be extended to include other filters, and a textual search mode.
 */
@interface GageTVC ()
// Regions to be included in all modes
@property (strong, nonatomic) NSArray *regions;

// The full data set, for quick filtering and searching
@property (strong, nonatomic) NSDictionary *gagesByRegion;

// Data for the table view in normal and filtered mode.
@property (strong, nonatomic) NSDictionary *filteredGagesByRegion;
@property (strong, nonatomic) FilterModel * filterModel;

// Data for the table view in search mode
@property (strong, nonatomic) NSArray *searchedGages;

// UI Elements
@property (weak, nonatomic) IBOutlet UISegmentedControl *flowSegmentedControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *segmentedControlBackgroundView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic)UISearchDisplayController * searchController;
@end

@implementation GageTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title) self.title = @"Dreamflows Gages";
    
    //Search bar
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.segmentedControlBackgroundView.layer.borderWidth = .25f;
    self.segmentedControlBackgroundView.layer.borderColor = [InterfaceViewVariables DFDarkGray].CGColor;
    
    //Tab bars
    self.tabBarItem =[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
    UIViewController * firstVC = [self.tabBarController.viewControllers objectAtIndex:1];
    firstVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
    
    self.loadingIndicator.hidesWhenStopped = YES;
    
    //Add data notification handlers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGagesFromDatabase) name:FLOWS_FINISHED_LOADING_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoadingSpinner) name:FLOWS_FINISHED_LOADING_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGagesFromDatabase) name:DESCRIPTION_FINISHED_LOADING_NOTIFICATION object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [self startLoadingSpinner];
    [self refreshGagesFromDatabase];
    [self refreshFlows];
}

- (IBAction)selectedSegmentChanged:(UISegmentedControl *)sender {
    NSMutableArray * boolsArray = [[NSMutableArray alloc] initWithCapacity:self.flowSegmentedControl.numberOfSegments];
    for(int i = 0; i < self.flowSegmentedControl.numberOfSegments; i++) {
        if(self.flowSegmentedControl.selectedSegmentIndex == i) {
            [boolsArray addObject:[[NSNumber alloc] initWithInt:1]];
        } else {
            [boolsArray addObject:[[NSNumber alloc] initWithInt:0]];
        }
    }
    self.filterModel = [[FilterModel alloc] initWithFields:FIELD1ForGage field2:FIELD2ForGage];
    [self.filterModel setArray:boolsArray forKey:FLOW_BUTTON_COLLECTION_KEY];
    
    [self filterGages];
}

- (IBAction)goToSearch:(UIBarButtonItem *)sender {
    [self.searchBar becomeFirstResponder];
}

- (IBAction)refreshPressed:(UIBarButtonItem *)sender {
    [self refreshFlows];
}

- (void)refreshFlows {
    [self startLoadingSpinner];
    [[DFDataController sharedManager] updateFlows];
}

- (void)refreshGagesFromDatabase {
    NSLog(@"Refreshing from database");
    
    self.regions = [self getRegions];
    self.gagesByRegion = [Gage gagesDictionaryForRegions:self.regions];
    [self filterGages];
    
//    [self.loadingIndicator stopAnimating];
    NSLog(@"Refreshed from database");
}

-(void)filterGages {
    self.filteredGagesByRegion = [self.filterModel filterDictionary:self.gagesByRegion];
    [self.tableView reloadData];
}

-(NSArray *)getRegions {
    return [Gage regions];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = nil;
        if(self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];
        } else {
            indexPath = [self.tableView indexPathForCell:sender];
        }
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Gage Segue"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setGage:)]) {
                    Gage * thisGage;
                    if(self.searchDisplayController.active) {
                        thisGage = self.searchedGages[indexPath.row];
                    } else {
                        NSArray * regionGages = self.filteredGagesByRegion[self.regions[indexPath.section]];
                        thisGage = regionGages[indexPath.row];
                    }
                    [segue.destinationViewController performSelector:@selector(setGage:) withObject:thisGage];
                }
            }
        }
    }
}

#pragma mark - View methods

-(void)startLoadingSpinner {
    [self.loadingIndicator startAnimating];
}

-(void)stopLoadingSpinner {
    // If there are no gages, keep spinning!
    if (self.gagesByRegion.count > 0) {
        // Delay for a half second so that it looks like the refresh button is doing something.  
        [self performSelector:@selector(onTick) withObject:nil afterDelay:0.5];
    }
}

-(void)onTick {
    [self.loadingIndicator stopAnimating];
}

#pragma mark - Getters

-(FilterModel *)filterModel {
    if(!_filterModel) {
        _filterModel = [[FilterModel alloc] initWithFields:FIELD1ForGage field2:FIELD2ForGage];
    }
    return _filterModel;
}

-(NSDictionary *)filteredGagesByRegion {
    if(!_filteredGagesByRegion) {
        _filteredGagesByRegion = [NSDictionary new];
    }
    return _filteredGagesByRegion;
}

-(NSArray *)regions {
    if(!_regions) {
        _regions = [self getRegions];
    }
    return _regions;
}

#pragma mark - Search Bar delegate and data source

-(void) filter:(NSString *) searchText withScope:(NSString *)scope {
    //[self.filteredGages removeAllObjects];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.searchedGages = [self gagesFromPredicate:predicate inDictionary:self.gagesByRegion];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filter:searchString withScope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filter:self.searchDisplayController.searchBar.text withScope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.regions.count > section) {
        return self.regions[section];
    } else {
        return @"";
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [InterfaceViewVariables backgroundColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[InterfaceViewVariables DFWhite]];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0.0;
    } else {
        return 50.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return self.regions.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchedGages count];
    } else {
        return [self.filteredGagesByRegion[self.regions[section]] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Gage";
    UITableViewCell *rawCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( rawCell == nil ) {
        rawCell = (GageCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [rawCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    Gage * gage =nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        gage = self.searchedGages[indexPath.row];
    } else {
        NSArray * regionGages = self.filteredGagesByRegion[self.regions[indexPath.section]];
        gage = regionGages[indexPath.row];
    }
    
    if([rawCell isKindOfClass:[GageCell class]]) {
        GageCell * cell = (GageCell *) rawCell;
        [cell updateWithGage:gage];
        return cell;
    }
    
    return nil;
}

#pragma mark - Helpers

-(NSArray *)gagesFromPredicate:(NSPredicate *)predicate inDictionary:(NSDictionary *)dictionary {
    NSMutableArray *gages = [NSMutableArray new];
    for (NSString *key in dictionary) {
        NSArray *array = dictionary[key];
        [gages addObjectsFromArray:[array filteredArrayUsingPredicate:predicate]];
    }
    return gages;
}


@end
