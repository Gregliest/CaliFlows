#import "GageTVC.h"
#import "GageCell.h"
#import "BackgroundLayer.h"

@interface GageTVC ()
@property (strong, nonatomic) DFDataController * dfFetcher;
@property (strong, nonatomic) NSArray * regions;
@property (strong, nonatomic) NSMutableDictionary * gagesByRegion;
@property (strong, nonatomic) NSMutableDictionary * filteredGagesByRegion;
@property (strong, nonatomic) NSArray * gages; //kept around for ordering purposes, don't need to if you use fetched results controller
@property (strong, nonatomic) NSArray * searchedGages; //the subset of filteredGages presented in the searchedController.
@property (strong, nonatomic) NSArray * filterPredicates;
@property (strong, nonatomic) FilterModel * filterModel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *flowSegmentedControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *segmentedControlBackgroundView;
//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic)UISearchDisplayController * searchController;
@end

@implementation GageTVC

-(FilterModel *)filterModel {
    if(!_filterModel) {
        _filterModel = [[FilterModel alloc] initWithFields:FIELD1ForGage field2:FIELD2ForGage];
    }
    return _filterModel;
}

-(NSMutableDictionary *)gagesByRegion {
    if(!_gagesByRegion) {
        _gagesByRegion = [[NSMutableDictionary alloc] initWithCapacity:self.regions.count];
    }
    return _gagesByRegion;
}

-(NSMutableDictionary *) filteredGagesByRegion {
    if(!_filteredGagesByRegion) {
        _filteredGagesByRegion = [[NSMutableDictionary alloc] initWithCapacity:self.regions.count];
    }
    return _filteredGagesByRegion;
}

-(NSArray *) regions {
    if(!_regions) {
        _regions = [self updateRegions];
    }
    return _regions;
}

-(DFDataController *) dfFetcher {
    if(!_dfFetcher) {
        _dfFetcher = [DFDataController sharedManager];
    }
    return _dfFetcher;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title) self.title = @"Dreamflows Gages";
    
    //Search bar
    //self.searchBar = [[UISearchBar alloc] init];
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.segmentedControlBackgroundView.layer.borderWidth = .25f;
    self.segmentedControlBackgroundView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    
    //Tab bars
    self.tabBarItem =[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
    UIViewController * firstVC = [self.tabBarController.viewControllers objectAtIndex:1];
    firstVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
    
    //self.loadingIndicator.hidesWhenStopped = YES;
    self.tableView.backgroundColor = [InterfaceViewVariables HSBA:BACKGROUND_HSB];
    self.searchDisplayController.searchResultsTableView.backgroundColor = [InterfaceViewVariables HSBA:BACKGROUND_HSB];
    
    //Add data notification handlers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFromDatabase) name:FLOWS_FINISHED_LOADING_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFromDatabase) name:DESCRIPTION_FINISHED_LOADING_NOTIFICATION object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [self refreshFromDatabase];
    [self refresh];
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
    [self.filterModel setArray:boolsArray forKey:FLOW_BUTTON_COLLECTION_KEY];
    self.filterPredicates = [self.filterModel getPredicates];
    [self refreshFromDatabase];
    
}
- (IBAction)goToSearch:(UIBarButtonItem *)sender {
    [self.searchBar becomeFirstResponder];
}

- (IBAction)refresh {
    NSLog(@"Refresh");
    [self.dfFetcher updateFlows]; //Start the model updating, it will send a notification back when it is done.  Or, if it has updated recently, this will do nothing.
    
//    if(self.dfFetcher.isUpdating && self.gages.count == 0) {
//        [self.loadingIndicator startAnimating];
//    } else {
//        [self.loadingIndicator stopAnimating];
//    }
}

- (void)refreshFromDatabase {
    NSLog(@"Refreshing from database");
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Gage"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortNumber" ascending:YES]];
    self.gages = [self.dfFetcher getEntries:request];
    self.regions = [self updateRegions];
    [self updateGages];
    [self.tableView reloadData];
//    [self.loadingIndicator stopAnimating];
    NSLog(@"Refreshed from database");
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


-(void)updateGages {
    for(NSString * region in self.regions) {
        NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Gage"];
        request.predicate = [NSPredicate predicateWithFormat:@"region contains[c] %@", region];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortNumber" ascending:YES]];
        NSArray *tempArray =[self.dfFetcher getEntries:request];
        [self.gagesByRegion setObject:tempArray forKey:region];
        NSArray *tempFilteredArray = [self filterArray:tempArray];
        [self.filteredGagesByRegion setObject:tempFilteredArray forKey:region];
    }
    [self.tableView reloadData];
}

-(NSArray *) updateRegions {
    NSMutableArray * temp = [[NSMutableArray alloc] initWithCapacity:10];
    for(Gage * gage in self.gages) {
        if(gage.region && ![temp containsObject:gage.region]) {//If region have been added to database and temp does not contain the region. 
            [temp addObject:gage.region];
        }
    }
    return temp;
}

-(NSArray *)filterArray:(NSArray *) array {
    NSArray *tempArray = array;
    for(NSPredicate *predicate in self.filterPredicates) {
        tempArray = [tempArray filteredArrayUsingPredicate:predicate];
    }
    return tempArray;
}

#pragma mark - Search Bar delegate and data source
-(void) filter:(NSString *) searchText withScope:(NSString *)scope {
    //[self.filteredGages removeAllObjects];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.searchedGages = [self.gages filteredArrayUsingPredicate:predicate];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return self.regions.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchedGages count];
    } else {
        return [self.filteredGagesByRegion[self.regions[section]] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Gage";
    UITableViewCell *rawCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];// forIndexPath:indexPath
    if ( rawCell == nil ) {
        rawCell = (GageCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [rawCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        //rawCell = [[GageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
        
        cell.gageName.textColor = [InterfaceViewVariables HSBA:TITLE_HSB];
        [cell.gageName setFont:[UIFont boldSystemFontOfSize:FONT_SIZE_MEDIUM]];
        cell.gageName.text = gage.name;
        cell.gageProperties.textColor = [UIColor grayColor];//[GageTVC flowColors][gage[@"ColorCode"]];
        [cell.gageProperties setFont:[UIFont systemFontOfSize:FONT_SIZE_SMALL]];
         cell.gageProperties.alpha = .7;
        cell.gageProperties.text = [NSString stringWithFormat:@"%@ %@", gage.flow, gage.flowUnit];
        cell.levelIndicator.color =[InterfaceViewVariables flowColors][gage.colorCode];
        return cell;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
