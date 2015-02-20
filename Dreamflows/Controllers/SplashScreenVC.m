#import "SplashScreenVC.h"
#import "DFDataController.h"
#import "InterfaceViewVariables.h"

@interface SplashScreenVC ()
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@end

@implementation SplashScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.continueButton.layer.cornerRadius = 8;
    [self.continueButton setBackgroundColor:[InterfaceViewVariables titleBarColor]];
    
    //Start the updating process
    [[DFDataController sharedManager] updateGages];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
