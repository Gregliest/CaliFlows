//  This class shows buttons to sort by class and flow.  It uses a FilterModel to store the user input and generate a predicate.

#import "SearchFiltersViewController.h"

@interface SearchFiltersViewController ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *classButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *flowButtons;
@end

@implementation SearchFiltersViewController

//Filtering complete.
- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    [self.delegate filteringComplete:self withFilterModel: self.filterModel];
}

- (IBAction)buttonPressed:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    //NSLog(@"Button %@ pressed, states is %d", sender.titleLabel.text, sender.selected);
    
    [self updateButtonModel];
    [self highLightButtons:sender];
    
    [self.filterModel getPredicates];
}

-(void)updateButtonModel {
    NSMutableArray * one = [[NSMutableArray alloc] initWithCapacity:self.classButtons.count];
    for(int i = 0; i < self.classButtons.count; i++) {
        BOOL selected = ((UIButton *)self.classButtons[i]).selected;
        [one addObject:[[NSNumber alloc] initWithBool:selected]];
    }
    [self.filterModel setArray:one forKey:CLASS_BUTTON_COLLECTION_KEY];
    
    NSMutableArray * two = [[NSMutableArray alloc] initWithCapacity:self.flowButtons.count];
    for(int i = 0; i < self.flowButtons.count; i++) {
        BOOL selected = ((UIButton *)self.flowButtons[i]).selected;
        [two addObject:[[NSNumber alloc] initWithBool:selected]];
    }
    [self.filterModel setArray:two forKey:FLOW_BUTTON_COLLECTION_KEY];
    
}

-(void)updateButtonsFromModel {
    NSArray * one = [self.filterModel getBoolsArray:CLASS_BUTTON_COLLECTION_KEY];
    for(int i = 0; i < self.classButtons.count; i++) {
        ((UIButton *)self.classButtons[i]).selected = [one[i] boolValue];
        [self performSelector:@selector(highlight:) withObject:self.classButtons[i] afterDelay:0];
        //NSLog(@"Button number %d is %d", i, [one[i] boolValue]);
    }
    
    NSArray * two = [self.filterModel getBoolsArray:FLOW_BUTTON_COLLECTION_KEY];
    for(int i = 0; i < self.flowButtons.count; i++) {
        ((UIButton *)self.flowButtons[i]).selected = [two[i] boolValue];[self performSelector:@selector(highlight:) withObject:self.flowButtons[i] afterDelay:0];
        //NSLog(@"Button number %d is %d", i, [two[i] boolValue]);
    }
    //[self performSelector:@selector(updateEnabled) withObject:nil afterDelay:0];
}

//Highlights the correct buttons.
-(void)highLightButtons: (UIButton *) button {
    [self performSelector:@selector(highlight:) withObject:button afterDelay:0];
    
    //This is why this should be in a UICollectionView
    NSArray *buttonCollection;
    if([self.classButtons containsObject:button]) {
        buttonCollection = self.classButtons;
    } else if ([self.flowButtons containsObject:button]) {
        buttonCollection = self.flowButtons;
    }
    int index = [buttonCollection indexOfObject:button];
    if(index == 0) {
        for(int i = 1; i < buttonCollection.count; i++) {
            UIButton *thisButton = buttonCollection[i];
            thisButton.selected = NO;
            [self performSelector:@selector(highlight:) withObject:thisButton afterDelay:0];
        }
    } else if (index < 0) {
        NSLog(@"Error in SearchFiltersViewController, buttonPressed, index less than 0");
    } else {
        UIButton * anyButton = buttonCollection[0];
        anyButton.selected = NO;
        [self performSelector:@selector(highlight:) withObject:anyButton afterDelay:0];
    }
    [self updateButtonModel];
}

//Highlights a single button.
-(void)highlight:(UIButton *) button {
    [button setHighlighted:button.selected];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [InterfaceViewVariables HSBA:BACKGROUND_HSB];
	// Do any additional setup after loading the view.
    [self sortButtonCollections];
    
    [self updateButtonsFromModel];
    
    
}
/*
- (BOOL)shouldAutorotate
{
    return NO;
}*/

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

//Makes sure the buttons are shown on screen in the correct order.  
- (void)sortButtonCollections {
    NSComparator compareTags = ^(id a, id b) {
        NSInteger aTag = [a tag];
        NSInteger bTag = [b tag];
        return aTag > bTag ? NSOrderedDescending
        : aTag < bTag ? NSOrderedAscending
        : NSOrderedSame;
    };
    self.classButtons = [self.classButtons sortedArrayUsingComparator:compareTags];
    self.flowButtons = [self.flowButtons sortedArrayUsingComparator:compareTags];
}


@end
