#import "GageViewController.h"
#import "DFDataController.h"
#import "InterfaceViewVariables.h"
#import "LevelIndicatorView.h"
#import "WebVC.h"

@interface GageViewController () <UITableViewDataSource, UIWebViewDelegate>
@property (strong, nonatomic) NSArray * runs;

@property (weak, nonatomic) IBOutlet UILabel *gageLabel;
@property (weak, nonatomic) IBOutlet UILabel *flowLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITableView *runTableView;
@property (weak, nonatomic) IBOutlet UIWebView *graphWebView;
@property (weak, nonatomic) IBOutlet UIButton *graphButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *graphLoadingIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineBreakTimeLabelConstraint;
@end

@implementation GageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.graphWebView.delegate = self;
    
    [self setTitle:@"Gage Info"];
    [self setupView];
    [self updateView];
    
    //Add data notification handlers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:FLOWS_FINISHED_LOADING_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:DESCRIPTION_FINISHED_LOADING_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.runTableView deselectRowAtIndexPath:[self.runTableView indexPathForSelectedRow] animated:animated];
}

// Style the UI.
- (void)setupView {
    [self.gageLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE_LARGE]];
    self.gageLabel.textColor = [InterfaceViewVariables darkText];
    [self.flowLabel setFont:[UIFont italicSystemFontOfSize:FONT_SIZE_HUGE]];
    self.flowLabel.textColor = [InterfaceViewVariables flowColors][self.gage.colorCode];
    [self.timeLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_MEDIUM]];
    self.timeLabel.textColor = [InterfaceViewVariables mediumText];
    
    self.graphLoadingIndicator.hidesWhenStopped = YES;
    self.graphWebView.scalesPageToFit = YES;
}

// Display the current gage.
- (void)updateView {
    self.gageLabel.text = self.gage.name;
    self.flowLabel.text = [self flowText:self.gage];
    self.timeLabel.text = self.gage.dateFlowUpdate;
    
    // Load the graph if there's a graph link.
    if (self.gage.graphLink.length > 0) {
        NSURL *url = [NSURL URLWithString:self.gage.graphLink];
        NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
        [self.graphWebView loadRequest:request];
    } else {
        [self collapseGraph];
    }
}

// Collapses and disables the graph web view.  
- (void)collapseGraph {
    self.graphButton.userInteractionEnabled = NO;
    self.graphButton.frame = CGRectMake(0, 0, 0, 0);
    
    //Collapse the web view.
    self.graphWebView.hidden = YES;
    self.lineBreakTimeLabelConstraint.constant = 10;
}

- (NSString *)flowText:(Gage*)gage {
    NSString *flow = self.gage.flow;
    // If the flow string contains "No reading"
    if ([flow rangeOfString:@"No reading"].length != 0) {
        return @"- - cfs";
    } else {
        return [NSString stringWithFormat:@"%@ %@", self.gage.flow, self.gage.flowUnit];
    }
}

-(void)setGage:(Gage *)gage {
    _gage = gage;
    self.runs = [NSArray arrayWithArray:[gage.runsFromGage allObjects]];
    [self updateView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.runTableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Run Segue"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setRun:)]) {
                    [segue.destinationViewController performSelector:@selector(setRun:) withObject:self.runs[indexPath.row]];
                }
            } 
        }
    }
    if ([segue.identifier isEqualToString:@"Graph Segue"]) {
        WebVC *webController = [segue destinationViewController];
        NSURL *url = [NSURL URLWithString:self.gage.graphLink];
        webController.url = url;
    }
}

# pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.runs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Run";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Parse title from run info
    Run * run = self.runs[indexPath.row];
    cell.textLabel.text = run.runName;
    cell.textLabel.textColor = [InterfaceViewVariables darkText];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"   %@",run.lengthClass];
    cell.detailTextLabel.textColor = [InterfaceViewVariables mediumText];
    return cell;
}

# pragma mark - Web View Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.graphLoadingIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.graphLoadingIndicator stopAnimating];
}

@end
