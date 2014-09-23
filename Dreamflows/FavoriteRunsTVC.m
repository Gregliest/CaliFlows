#import "FavoriteRunsTVC.h"
#import <Crashlytics/Crashlytics.h>

@interface FavoriteRunsTVC ()
@property (strong, nonatomic) DFDataController* dfFetcher;
@property NSArray * favorites;
@end

@implementation FavoriteRunsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Favorite Runs";
    
    if(!self.dfFetcher) {
        self.dfFetcher = [DFDataController sharedManager];
    }
    [self updateFavorites];
}

//Need to update favorites every time the controller comes back on
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [self updateFavorites];
}

-(void) updateFavorites {
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Run"];
    request.predicate = [NSPredicate predicateWithFormat:@"favorite != %d", 0];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"runName" ascending:YES]];
    self.favorites = [self.dfFetcher getEntries:request];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Fav Run Segue"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setRun:)]) {
                    [segue.destinationViewController performSelector:@selector(setRun:) withObject:self.favorites[indexPath.row]];
                }
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.favorites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RunFav";
    UITableViewCell *rawCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if([rawCell isKindOfClass:[AddFavoritesCell class]]) {
        AddFavoritesCell *cell = (AddFavoritesCell *) rawCell;
        Run *run = self.favorites[indexPath.row];
        [cell updateWithRun:run];
        return cell;
    }
    
    return nil;
}

@end
