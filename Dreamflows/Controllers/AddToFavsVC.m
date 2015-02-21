#import "AddToFavsVC.h"
#import "DFDataController.h"
#import "FilterModel.h"
#import "InterfaceViewVariables.h"
#import <QuartzCore/QuartzCore.h>
#import "RunCell.h"
#import "DFAppDelegate.h"

@interface AddToFavsVC ()

@property (strong, nonatomic) DFDataController * dfFetcher;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray * runs; //kept around for ordering purposes, don't need to if you use fetched results controller
@property (strong, nonatomic) NSArray * filteredRuns; //the filtered subset of gages
@property (strong, nonatomic) NSArray * searchedRuns; //the subset of filteredGages presented in the searchedController.
@property (strong, nonatomic) NSArray * filterPredicates;
@property (strong, nonatomic)UISearchDisplayController * searchController;
@property (strong, nonatomic) FilterModel * filterModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AddToFavsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add Favorites";
    if(!self.dfFetcher) {
        self.dfFetcher = [DFDataController sharedManager];
    }
    
    //Search bar
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    
    //Add data notification handlers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFromDatabase) name:FLOWS_FINISHED_LOADING_NOTIFICATION object:nil];
    
    [self refresh];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshFromDatabase]; //Get what's in Core Data already
}

- (void)refresh {
    [self.dfFetcher updateFlows]; //Start the model updating, it will send a notification back when it is done
}

- (void)refreshFromDatabase {
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Run"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"runName" ascending:YES]];
    self.runs = [self.dfFetcher getEntries:request];
    [self updateFilteredRuns];
    NSLog(@"Refreshed, %lu", (unsigned long)self.runs.count);
    [self.tableView reloadData];
}

- (NSArray*) gages {
    if(!_runs || [_runs count] < 5) {
        [self refresh];
    }
    return _runs;
}

-(FilterModel *)filterModel {
    if(!_filterModel) {
        _filterModel = [[FilterModel alloc] initWithFields:FIELD1ForRun field2:FIELD2ForRun];
    }
    return _filterModel;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Search Filters Segue"]){
        SearchFiltersViewController * SFVC = segue.destinationViewController;
        SFVC.delegate = self;
        SFVC.filterModel = self.filterModel;
    }
}

-(void)filteringComplete:(SearchFiltersViewController *)searchFiltersVC withFilterModel:(FilterModel *) filterModel {
    self.filterPredicates = [filterModel getPredicates];
    self.filterModel = filterModel;
    [searchFiltersVC dismissViewControllerAnimated:YES completion:nil];
    [self refreshFromDatabase];
}

-(void)updateFilteredRuns {
    NSArray *tempArray = self.runs;
    for(NSPredicate *predicate in self.filterPredicates) {
        tempArray = [tempArray filteredArrayUsingPredicate:predicate];
    }
    self.filteredRuns = tempArray;
}

#pragma mark - Search Bar delegate and data source

-(void) filter:(NSString *) searchText withScope:(NSString *)scope {
    //[self.filteredGages removeAllObjects];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"longName contains[c] %@", searchText];
    self.searchedRuns = [self.gages filteredArrayUsingPredicate:predicate];
    
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filter:searchString withScope:nil];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filter:self.searchDisplayController.searchBar.text withScope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchedRuns count];
    } else {
        return [self.filteredRuns count];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RunFav";
    UITableViewCell *rawCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Run *run;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        run = self.searchedRuns[indexPath.row];
    } else {
        run = self.filteredRuns[indexPath.row];
    }
    
    if([rawCell isKindOfClass:[RunCell class]]) {
        RunCell *cell = (RunCell *) rawCell;
        [cell updateWithRun:run];
        return cell;
    }
    
    return nil;
}

//Needed to override this for the searchDisplayController.  This is a hack...  
#define CELL_HEIGHT 58
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Run *run;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        run = self.searchedRuns[indexPath.row];
    } else {
        run = self.filteredRuns[indexPath.row];
    }
    run.favorite = [[NSNumber alloc] initWithBool:![run.favorite boolValue]];
    [(DFAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    [tableView reloadData];
}

@end
