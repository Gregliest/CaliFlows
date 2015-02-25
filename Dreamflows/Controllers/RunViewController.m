#import "RunViewController.h"
#import "WebVC.h"
#import "Gage+Dreamflows.h"
#import "InterfaceViewVariables.h"
#import "LevelIndicatorView.h"
#import "DFDataController.h"

@interface RunViewController () 
@property (weak, nonatomic) IBOutlet UILabel *flowLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *riverLabel;
@property (weak, nonatomic) IBOutlet UILabel *runLabel;
@property (weak, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (weak, nonatomic) IBOutlet LevelIndicatorView *levelIndicator;
@property (weak, nonatomic) IBOutlet UILabel *favorite;
@property (weak, nonatomic) IBOutlet UIButton *graphButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Gage * gage;

@end

@implementation RunViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Run Info"];
    
    [self setupView];
    [self updateView];
    
    //Add data notification handlers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:FLOWS_FINISHED_LOADING_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:DESCRIPTION_FINISHED_LOADING_NOTIFICATION object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)setupView {
    [self.runLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE_LARGE]];
    self.runLabel.textColor = [InterfaceViewVariables darkText];
    [self.riverLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_MEDIUM]];
    self.riverLabel.textColor = [InterfaceViewVariables mediumText];
    [self.difficultyLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_LARGE]];
    self.difficultyLabel.textColor = [InterfaceViewVariables darkText];
    [self.flowLabel setFont:[UIFont italicSystemFontOfSize:FONT_SIZE_SMALL]];
    self.flowLabel.textColor = [InterfaceViewVariables mediumText];
    [self.timeLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_SMALL]];
    self.timeLabel.textColor = [InterfaceViewVariables mediumText];
    
    self.levelIndicator.radiusRatio = BIG_RADIUS_RATIO;
}

- (void)updateView {
    //Set up labels with Run info
    self.runLabel.text = self.run.runName;
    self.riverLabel.text = [NSString stringWithFormat:@"on the%@", self.run.riverName];
    self.difficultyLabel.text = [NSString stringWithFormat:@"Class%@", self.run.difficulty];
    self.flowLabel.text = [NSString stringWithFormat:@"%@ %@", self.gage.flow, self.gage.flowUnit];
    self.timeLabel.text = self.gage.dateFlowUpdate;
    
    self.levelIndicator.color = [InterfaceViewVariables flowColors][self.gage.colorCode];
    
    // Disable the graph button if there's no graph link
    if (self.gage.graphLink.length <= 0) {
        self.graphButton.enabled = NO;
        self.graphButton.hidden = YES;
    }
    
    [self updateFavoriteButtonColor];
}

- (void)updateFavoriteButtonColor {
    if([self.run.favorite boolValue]) {
        self.favorite.textColor = [InterfaceViewVariables favoritesColor];
        self.favorite.text =@"★";
    } else {
        self.favorite.textColor = [InterfaceViewVariables darkText];
        self.favorite.text =@"☆";
    }
}

- (void)setRun:(Run *)run {
    _run = run;
    self.gage = [Run getHighestGage:run];
    [self updateView];
}

# pragma mark - Actions

- (IBAction)refreshFlows:(UIBarButtonItem *)sender {
    [[DFDataController sharedManager] updateFlows];
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender {
    [self.run toggleFavorite];
    [self updateFavoriteButtonColor];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Web Segue"]) {
                
                WebVC *webController = [segue destinationViewController];
                NSURL *url = [NSURL URLWithString:[self getLink:indexPath][LINK]];
                webController.url = url;
            }
        }
    }
    if ([segue.identifier isEqualToString:@"Graph Segue"]) {
        WebVC *webController = [segue destinationViewController];
        NSURL *url = [NSURL URLWithString:self.gage.graphLink];
        webController.url = url;
    }
}

#pragma mark Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; //Description, Map
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return ((NSArray *)self.run.descriptionsLinks).count;
    }
    if (section == 1) {
        return ((NSArray *)self.run.mapLinks).count;
    }
    /*
    if (section == 2) {
        return ((NSArray *)self.run.shuttleLinks).count;
    }*/
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Description Links";
    }
    if (section == 1) {
        return @"Map Links";
    }
    /*if (section == 2) {
        return @"Shuttle Links";
    }*/
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Link";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self getLink:indexPath][LINK_NAME];
    cell.textLabel.textColor = [InterfaceViewVariables darkText];
    return cell;
}

- (NSDictionary *)getLink:(NSIndexPath *) indexPath {
    NSDictionary * link;
    if (indexPath.section == 0) {
        link = self.run.descriptionsLinks[indexPath.row];
    }
    if (indexPath.section == 1) {
        link = self.run.mapLinks[indexPath.row];
    }
    /*if (indexPath.section == 2) {
        link = self.run.shuttleLinks[indexPath.row];
    }*/
    return link;
}

@end
