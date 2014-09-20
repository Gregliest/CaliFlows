//
//  SearchGageTVC.m
//  Dreamflows
//
//  Created by Gregory Lee on 5/7/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "SearchGageTVC.h"
#import "GageCell.h"

@interface SearchGageTVC () 
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray * filteredGages;
@end

@implementation SearchGageTVC


-(void) filter:(NSString *) searchText withScope:(NSString *)scope {
    [self.filteredGages removeAllObjects];
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Gage"];
    request.predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.filteredGages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Gage";
    UITableViewCell *rawCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if([rawCell isKindOfClass:[GageCell class]]) {
        GageCell * cell = (GageCell *) rawCell;
        NSDictionary * gage = self.filteredGages[indexPath.row];
        
        /*cell.contentView.backgroundColor = [GageTVC flowColors][gage[@"ColorCode"]];
         cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", gage[@"RiverName"], gage[@"PlaceName"]];
         cell.textLabel.backgroundColor = [UIColor clearColor];
         cell.detailTextLabel.textColor = [UIColor blackColor];
         cell.detailTextLabel.backgroundColor = [UIColor clearColor];
         cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", gage[@"RiverFlow"], gage[@"FlowUnit"]]; */
        
        cell.gageName.textColor = [UIColor blackColor];
        [cell.gageName setFont:[UIFont boldSystemFontOfSize:14]];
        cell.gageName.text = [NSString stringWithFormat:@"%@ - %@", gage[@"RiverName"], gage[@"PlaceName"]];
        cell.gageProperties.textColor = [UIColor grayColor];//[GageTVC flowColors][gage[@"ColorCode"]];
        [cell.gageProperties setFont:[UIFont systemFontOfSize:11]];
        cell.gageProperties.alpha = .7;
        cell.gageProperties.text = [NSString stringWithFormat:@"%@ %@", gage[@"RiverFlow"], gage[@"FlowUnit"]];
        //cell.levelIndicator = [[levelIndicatorImageView alloc] initWithFrame:cell.levelIndicator.frame];
        cell.levelIndicator.color =[GageTVC flowColors][gage[@"ColorCode"]];
        return cell;
    }
    
    return nil;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh];
    self.filteredGages = [self.gages mutableCopy];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
