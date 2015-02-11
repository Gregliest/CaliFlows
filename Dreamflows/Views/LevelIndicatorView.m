//  Generates the circular level indicator
#import "LevelIndicatorView.h"

@implementation LevelIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

#define CIRCLE_SPACING 3
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    //    //Draw white border
    CGFloat outsideRadius = (rect.size.width *self.radiusRatio)/2;
//    [self fillCircleOfRadius:outsideRadius centeredInRect:rect withColor:[UIColor whiteColor]];
//    
//    //Draw outside circle
//    outsideRadius = outsideRadius - CIRCLE_SPACING;
//    [self fillCircleOfRadius:outsideRadius centeredInRect:rect withColor:self.color];
//    
//    //Draw white spacer
//    outsideRadius = outsideRadius - CIRCLE_SPACING +1;
//    [self fillCircleOfRadius:outsideRadius centeredInRect:rect withColor:[UIColor whiteColor]];
    
    
    //Draw inside circle
    outsideRadius = rect.size.width/8;
    [self fillCircleOfRadius:outsideRadius centeredInRect:rect withColor:self.color];
    
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

- (void) fillCircleOfRadius:(CGFloat)radius centeredInRect:(CGRect)rect withColor:(UIColor *)color {
    UIBezierPath *outsidePath = [self circleInCenter:rect withRadius:radius];
    [color setStroke];
    [outsidePath stroke];
    [color setFill];
    [outsidePath fill];
}

- (UIBezierPath *)circleInCenter:(CGRect)rect withRadius:(CGFloat)radius {
    
    CGFloat originX = rect.origin.x + rect.size.width/2 - radius;
    CGFloat originY = rect.origin.y + rect.size.height/2 - radius;
    CGRect newRect = CGRectMake(originX, originY, radius*2, radius*2);
    
    return [UIBezierPath bezierPathWithOvalInRect:newRect];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}

@synthesize radiusRatio = _radiusRatio;

-(CGFloat)radiusRatio {
    if(!_radiusRatio || _radiusRatio <=0) {
        _radiusRatio = .67; //Default
    }
    return _radiusRatio;
}

-(void)setRadiusRatio:(CGFloat)radiusRatio {
    _radiusRatio = radiusRatio;
    [self setNeedsDisplay];
}
@end
