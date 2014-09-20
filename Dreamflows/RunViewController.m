#import "RunViewController.h"
#import "RunCollectionViewCell.h"
#import "GCCustomSectionController.h"
#import "SVWebViewController.h"
#import "DFAppDelegate.h"

@interface RunViewController () 
@property (weak, nonatomic) IBOutlet UILabel *flowLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *riverLabel;
@property (weak, nonatomic) IBOutlet UILabel *runLabel;
@property (weak, nonatomic) IBOutlet LevelIndicatorView *levelIndicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (weak, nonatomic) IBOutlet UILabel *favorite;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Gage * gage;

@end

@implementation RunViewController

-(void)setRun:(Run *)run {
    _run = run;
    self.gage = [Run getHighestGage:run];
}

- (IBAction)refresh:(UIBarButtonItem *)sender {
    DFDataController *dfFetcher = [DFDataController sharedManager];
    [dfFetcher updateFlows];
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender {
    self.run.favorite = [[NSNumber alloc] initWithBool:![self.run.favorite boolValue]];
    [(DFAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    [self updateFavoriteButtonColor];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Run Info"];
    
    [self updateLabels];
    [self updateFavoriteButtonColor];
    
    //Add data notification handlers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:FLOWS_FINISHED_LOADING_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:DESCRIPTION_FINISHED_LOADING_NOTIFICATION object:nil];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

-(void)reloadData {
    [self updateLabels];
    }

-(void)updateFavoriteButtonColor {
    if([self.run.favorite boolValue]) {
        self.favorite.textColor = [InterfaceViewVariables HSBA:FAVORITES_HSB];
        self.favorite.text =@"★";
    } else {
        self.favorite.textColor = [UIColor blackColor];
        self.favorite.text =@"☆";
    }
}
-(void)updateLabels {
    //Set up labels with Run info
    [self.runLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE_LARGE]];
    self.runLabel.textColor = [InterfaceViewVariables HSBA:TITLE_HSB];
    self.runLabel.text = self.run.runName;
    [self.riverLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_MEDIUM]];
    self.riverLabel.text = [NSString stringWithFormat:@"on the %@", self.run.riverName];
    
    [self.flowLabel setFont:[UIFont italicSystemFontOfSize:FONT_SIZE_SMALL]];
    self.flowLabel.text = [NSString stringWithFormat:@"%@ %@", self.gage.flow, self.gage.flowUnit];
    [self.timeLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_SMALL]];
    self.timeLabel.text = self.gage.dateFlowUpdate;
    
    self.levelIndicator.radiusRatio = BIG_RADIUS_RATIO;
    self.levelIndicator.color = [InterfaceViewVariables flowColors][self.gage.colorCode];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Web Segue"]) {
                
                SVWebViewController *webController = [segue destinationViewController];
                NSURL *url = [NSURL URLWithString:[self getLink:indexPath][LINK]];
                webController = [webController initWithWebContent:url withCachedPage:[self getLink:indexPath][CACHE]];
            }
        }
    }
    if ([segue.identifier isEqualToString:@"Graph Segue"]) {
        SVModalWebViewController *webController = [segue destinationViewController];
        NSURL *URL = [NSURL URLWithString:self.gage.graphLink];
        webController = [webController initWithURL:URL];
        webController.modalPresentationStyle = UIModalPresentationPageSheet;
        webController.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsOpenInChrome | SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink;
    }
}
#pragma mark Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; //Description, Map
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Link";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self getLink:indexPath][LINK_NAME];
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
