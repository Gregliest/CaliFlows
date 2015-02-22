#import "GageViewController.h"
#import "DFDataController.h"
#import "InterfaceViewVariables.h"
#import "LevelIndicatorView.h"
#import "WebVC.h"

@interface GageViewController () <UITableViewDataSource, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *gageLabel;
@property (weak, nonatomic) IBOutlet UILabel *flowLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITableView *runTableView;
@property (weak, nonatomic) IBOutlet UIButton *graphButton;
@property (weak, nonatomic) IBOutlet UIWebView *graphWebView;
@property (strong, nonatomic) NSArray * runs;
@end

@implementation GageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.graphWebView.delegate = self;
    
    [self setTitle:@"Gage Info"];
    [self setupView];
    [self refreshView];
    
    //Add data notification handlers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:FLOWS_FINISHED_LOADING_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:DESCRIPTION_FINISHED_LOADING_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.runTableView deselectRowAtIndexPath:[self.runTableView indexPathForSelectedRow] animated:animated];
}

- (void)setupView {
    [self.gageLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE_LARGE]];
    self.gageLabel.textColor = [InterfaceViewVariables darkText];
    [self.flowLabel setFont:[UIFont italicSystemFontOfSize:FONT_SIZE_HUGE]];
    self.flowLabel.textColor = [InterfaceViewVariables flowColors][self.gage.colorCode];
    [self.timeLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_MEDIUM]];
    self.timeLabel.textColor = [InterfaceViewVariables mediumText];
}

- (void)refreshView {
    self.gageLabel.text = self.gage.name;
    self.flowLabel.text = [NSString stringWithFormat:@"%@ %@", self.gage.flow, self.gage.flowUnit];
    self.timeLabel.text = self.gage.dateFlowUpdate;
    if (self.gage.graphLink.length > 0) {
        self.graphButton.alpha = 1.0;
        self.graphButton.enabled = YES;
    } else {
        self.graphButton.alpha = .7;
        self.graphButton.enabled = NO;
    }
    
    NSURL *url = [NSURL URLWithString:self.gage.graphLink];
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [self.graphWebView loadRequest:request];
    self.graphWebView.scalesPageToFit = YES;
}

#warning todo this should update the view. 
-(void)setGage:(Gage *)gage {
    _gage = gage;
    self.runs = [NSArray arrayWithArray:[gage.runsFromGage allObjects]];
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
