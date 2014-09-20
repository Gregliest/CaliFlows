//
//  FavoriteRunsTVC.m
//  Dreamflows
//
//  Created by Gregory Lee on 5/9/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "FavoriteRunsTVC.h"
#import <Crashlytics/Crashlytics.h>

@interface FavoriteRunsTVC ()
@property (strong, nonatomic) DFDataController* dfFetcher;
@property (weak, nonatomic) IBOutlet UILabel *levelIndicatorLabel;
@property NSArray * favorites;
@end

@implementation FavoriteRunsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Favorite Runs";
    if(!self.dfFetcher) {
        self.dfFetcher = [DFDataController sharedManager];
    }
    [self findFavorites];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//Need to update favorites every time the controller comes back on
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [self findFavorites];
}

-(void) findFavorites {
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Run"];
    request.predicate = [NSPredicate predicateWithFormat:@"favorite != %d", 0];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"runName" ascending:YES]];
    self.favorites = [self.dfFetcher getEntries:request];
    [self.tableView reloadData];
    //NSLog(@"In findFavorites %@",error);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Fav Run Segue"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setRun:)]) {
                    [segue.destinationViewController performSelector:@selector(setRun:) withObject:self.favorites[indexPath.row]];
                }
                /*
                if ([segue.destinationViewController respondsToSelector:@selector(setGageInfo:)]) {
                    [segue.destinationViewController performSelector:@selector(setGageInfo:) withObject:[self getGageInfo:self.favorites[indexPath.row]]];
                } */
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.favorites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RunFav";
    UITableViewCell *rawCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Run *run = self.favorites[indexPath.row];
    if([rawCell isKindOfClass:[AddFavoritesCell class]]) {
        AddFavoritesCell *cell = (AddFavoritesCell *) rawCell;
        cell.runName.textColor = [UIColor blackColor];
        [cell.runName setFont:[UIFont boldSystemFontOfSize:FONT_SIZE_MEDIUM]];
        cell.runName.text = run.runName;
        cell.runProperties.textColor = [UIColor grayColor];
        [cell.runProperties setFont:[UIFont systemFontOfSize:FONT_SIZE_SMALL]];
        cell.runProperties.alpha = .7;
        cell.runProperties.text = run.lengthClass;
        cell.levelIndicator.color =[InterfaceViewVariables flowColors][run.bestGage.colorCode];
        cell.riverName.textColor = [UIColor blackColor];
        [cell.riverName setFont:[UIFont systemFontOfSize:FONT_SIZE_SMALL]];
         cell.riverName.text = run.riverName;
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
      *detailViewController = [[; alloc] initWithNibName:@";" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
