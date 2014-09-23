//  Accurately keeps track of network activity across multiple threads.

#import "UIApplicationNetworkActivityCounter.h"
@interface UIApplicationNetworkActivityCounter ()
@property (nonatomic) int networkCounter;
@property dispatch_queue_t counterQueue;

@end

@implementation UIApplicationNetworkActivityCounter

-(id)init {
    self = [super init];
    if(self) {
        self.networkCounter = 0;
        self.counterQueue = dispatch_queue_create("counter queue", NULL);
    }
    return self;
}

- (void) setNetworkActivityIndicatorVisible:(BOOL)networkActivityIndicatorVisible {
    dispatch_async(self.counterQueue, ^{
        if(networkActivityIndicatorVisible) {
            self.networkCounter++;
            //NSLog(@"Network counter: %d", self.networkCounter);
            if(self.networkCounter >= 1) {
                super.networkActivityIndicatorVisible = YES;
            }
        } else {
            self.networkCounter--;
            //NSLog(@"Network counter: %d", self.networkCounter);
            if(self.networkCounter == 0) {
                super.networkActivityIndicatorVisible = NO;
            } else if (self.networkCounter < 0) {
                NSLog(@"Network Activity counter < 0: No outstanding network activity!");
                self.networkCounter = 0;
            }
        }
    });
}

@end
