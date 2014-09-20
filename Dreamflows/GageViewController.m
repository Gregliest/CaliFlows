//
//  GageViewController.m
//  Dreamflows
//
//  Created by Gregory Lee on 5/2/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "GageViewController.h"

@interface GageViewController () <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *gageLabel;
@property (weak, nonatomic) IBOutlet UILabel *flowLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITableView *runTableView;
@property (weak, nonatomic) IBOutlet LevelIndicatorView *levelIndicator;
@property (weak, nonatomic) IBOutlet UIButton *graphButton;
@property (strong, nonatomic) NSArray * runs;
@end

@implementation GageViewController

-(void)setGage:(Gage *)gage {
    _gage = gage;
    self.runs = [NSArray arrayWithArray:[gage.runsFromGage allObjects]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Gage Info"];
    
    [self.gageLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE_LARGE]];
    self.gageLabel.textColor = [InterfaceViewVariables HSBA:TITLE_HSB];
    [self.flowLabel setFont:[UIFont italicSystemFontOfSize:FONT_SIZE_MEDIUM]];
    [self.timeLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_MEDIUM]];
    self.levelIndicator.radiusRatio = BIG_RADIUS_RATIO;
    
    [self refreshFromDatabase];
    
    //Add data notification handlers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFromDatabase) name:FLOWS_FINISHED_LOADING_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFromDatabase) name:DESCRIPTION_FINISHED_LOADING_NOTIFICATION object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.runTableView deselectRowAtIndexPath:[self.runTableView indexPathForSelectedRow] animated:animated];
}
- (void)refreshFromDatabase {
    self.gageLabel.text = self.gage.name;
    self.flowLabel.text = [NSString stringWithFormat:@"%@ %@", self.gage.flow, self.gage.flowUnit];
    self.timeLabel.text = self.gage.dateFlowUpdate;
    self.levelIndicator.color = [InterfaceViewVariables flowColors][self.gage.colorCode];
    if (self.gage.graphLink.length > 0) {
        self.graphButton.alpha = 1.0;
        self.graphButton.enabled = YES;
    } else {
        self.graphButton.alpha = .7;
        self.graphButton.enabled = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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
        SVModalWebViewController *webController = [segue destinationViewController];
        NSURL *URL = [NSURL URLWithString:self.gage.graphLink];
        webController = [webController initWithURL:URL];
        webController.modalPresentationStyle = UIModalPresentationPageSheet;
        webController.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsOpenInChrome | SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink;
    }
}

/*
- (IBAction)presentGraphModally:(UIButton *)sender {
    NSURL *URL = [NSURL URLWithString:self.gage.graphLink];
	SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
	webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    webViewController.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsOpenInChrome | SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink;
	[self presentViewController:webViewController animated:YES completion:NULL];
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.runs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Run";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Parse title from run info
    Run * run = self.runs[indexPath.row];
    cell.textLabel.text = run.runName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"   %@",run.lengthClass];
    return cell;
}

@end
