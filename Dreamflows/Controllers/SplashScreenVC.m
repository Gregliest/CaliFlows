#import "SplashScreenVC.h"
#import "DFDataController.h"

@interface SplashScreenVC ()
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@end

@implementation SplashScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.continueButton.layer.cornerRadius = 8;
    
    //Start the updating process
    DFDataController *dfFetcher = [DFDataController sharedManager];
    [dfFetcher updateGages];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
