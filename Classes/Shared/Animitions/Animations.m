//
//  Animations.m
//  test
//
//  Created by Pulkit Kathuria on 10/8/12.
//  Copyright (c) 2012 Pulkit Kathuria. All rights reserved.
//

#import "Animations.h"
#import "VoiceDef.h"
#define degreesToRadians(x)(M_PI*x/180.0)

@interface AnimatLabel ()
{
    CFTimeInterval startTime;

}

@end

@implementation AnimatLabel
@synthesize from,to;
@synthesize animationTime;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    self.font = [UIFont fontWithName:@"Arial" size:30];
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    self.layer.cornerRadius = 8;
    self.numberOfLines = 2;
    self.animationTime = 1.0;
    return self;
}

// Create instance variables/properties for: `from`, `to`, and `startTime` (also include the QuartzCore framework in your project)

- (void)animateFrom:(NSNumber *)aFrom toNumber:(NSNumber *)aTo {
    self.from = aFrom; // or from = [aFrom retain] if your not using @properties
    self.to = aTo;     // ditto
    
    self.text = [from stringValue];
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateNumber:)];
    
    startTime = CACurrentMediaTime();
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)animateNumber:(CADisplayLink *)link {
    float dt = ([link timestamp] - startTime) / self.animationTime;
    if (dt >= 1.0) {
        self.text = [to stringValue];
        [link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        return;
    }
    
    float current = ([to floatValue] - [from floatValue]) * dt + [from floatValue];
    self.text = [NSString stringWithFormat:@"%@\r\n%i",STRING_READY_RECORDING, (long)current];
}

@end


@interface Animations ()

@end

@implementation Animations


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


+ (void)zoomIn: (UIView *)view andAnimationDuration: (float) duration andWait:(BOOL) wait{
    __block BOOL done = wait; //wait =  YES wait to finish animation
    view.transform = CGAffineTransformMakeScale(0, 0);
    [UIView animateWithDuration:duration animations:^{
        view.transform = CGAffineTransformIdentity;
        //view.transform = CGAffineTransformMakeScale(0, 0);
        //view.transform = CGAffineTransformIdentity;

    } completion:^(BOOL finished) {
        done = NO;
    }];
    // wait for animation to finish
    while (done == YES)
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
}
+ (void)buttonPressAnimate: (UIView *)view andAnimationDuration: (float) duration andWait:(BOOL) wait{
    //Usually Changes the position
    __block BOOL done = wait; //wait =  YES wait to finish animation
    [UIView animateWithDuration:duration animations:^{
        view.transform = CGAffineTransformMakeScale(1.05, 1.05);
        view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        done = NO;
    }];
    // wait for animation to finish
    while (done == YES)
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
}

+ (void)fadeIn: (UIView *)view andAnimationDuration: (float) duration andWait:(BOOL) wait{
    __block BOOL done = wait; //wait =  YES wait to finish animation
    [view setAlpha:0.0];
    [UIView animateWithDuration:duration animations:^{
        [view setAlpha:1.0];
    } completion:^(BOOL finished) {
        done = NO;
    }];
    // wait for animation to finish
    while (done == YES)
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
}
+ (void)fadeOut: (UIView *)view andAnimationDuration: (float) duration andWait:(BOOL) wait{
    __block BOOL done = wait; //wait =  YES wait to finish animation
    [view setAlpha:1.0];
    [UIView animateWithDuration:duration animations:^{
        [view setAlpha:0.0];
    } completion:^(BOOL finished) {
        done = NO;
    }];
    // wait for animation to finish
    while (done == YES)
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
}
+ (void) moveLeft: (UIView *)view andAnimationDuration: (float) duration andWait:(BOOL) wait andLength:(float) length{
    __block BOOL done = wait; //wait =  YES wait to finish animation
    [UIView animateWithDuration:duration animations:^{
        view.center = CGPointMake(view.center.x - length, view.center.y);
        
    } completion:^(BOOL finished) {
        done = NO;
    }];
    // wait for animation to finish
    while (done == YES)
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
}

+ (void) moveRight: (UIView *)view andAnimationDuration: (float) duration andWait:(BOOL) wait andLength:(float) length{
    __block BOOL done = wait; //wait =  YES wait to finish animation
    [UIView animateWithDuration:duration animations:^{
        view.center = CGPointMake(view.center.x + length, view.center.y);
        
    } completion:^(BOOL finished) {
        done = NO;
    }];
    // wait for animation to finish
    while (done == YES)
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
}

+ (void) moveUp: (UIView *)view andAnimationDuration: (float) duration andWait:(BOOL) wait andLength:(float) length{
    __block BOOL done = wait; //wait =  YES wait to finish animation
    [UIView animateWithDuration:duration animations:^{
        view.center = CGPointMake(view.center.x, view.center.y-length);

    } completion:^(BOOL finished) {
        done = NO;
    }];
    // wait for animation to finish
    while (done == YES)
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
}

+ (void) moveDown: (UIView *)view andAnimationDuration: (float) duration andWait:(BOOL) wait andLength:(float) length{
    __block BOOL done = wait; //wait =  YES wait to finish animation
    [UIView animateWithDuration:duration animations:^{
        view.center = CGPointMake(view.center.x, view.center.y + length);
        
    } completion:^(BOOL finished) {
        done = NO;
    }];
    // wait for animation to finish
    while (done == YES)
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
}

+ (void) rotate: (UIView *)view andAnimationDuration: (float) duration andWait:(BOOL) wait andAngle:(int) angle{
    __block BOOL done = wait; //wait =  YES wait to finish animation
    [UIView animateWithDuration:duration animations:^{
        view.transform = CGAffineTransformMakeRotation(degreesToRadians(angle));
    } completion:^(BOOL finished) {
        done = NO;
    }];
    // wait for animation to finish
    while (done == YES)
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
}

+ (void) frameAndShadow: (UIView *) view
//Shadow is all Over with a white frame
{
    CALayer *layer = view.layer;
    [layer setBorderColor: [[UIColor whiteColor] CGColor]]; //Frame Color
    [layer setBorderWidth:5.0f]; //Frame Border
    [layer setShadowColor: [[UIColor blackColor] CGColor]]; //Shadow Color
    [layer setShadowOpacity:0.80f];
    [layer setShadowOffset: CGSizeMake(1, 3)];
    [layer setShadowRadius:5.0];
    [view setClipsToBounds:NO];
}


+ (void) background: (UIView *) view andImageFileName: (NSString *) filename{
    //Sets the background for a UIView full filename with extension as parameter
    UIGraphicsBeginImageContext(view.frame.size);
    [[UIImage imageNamed:filename] drawInRect:view.bounds];
    UIImage *bubbleImage = UIGraphicsGetImageFromCurrentImageContext();
    view.backgroundColor = [UIColor colorWithPatternImage:bubbleImage];
}

+ (void) roundedCorners: (UIView *) view{
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
}

+ (void)contentOnView:(UIView *)view from:(id)fromValue toValue:(id)toValue andAnimationDuration: (float) duration{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"contents"];
    anim.duration = duration;
    anim.fromValue = fromValue;
    anim.toValue = toValue;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    
    [view.layer addAnimation:anim forKey:nil];
}

+ (void) shadowOnView: (UIView *) view andShadowType: (NSString *) shadowType{
    CGSize size = view.bounds.size;
    if ([shadowType isEqualToString: @"NoShadow"]){
        view.layer.shadowColor = [UIColor clearColor].CGColor;
    }
    else{
        view.layer.shadowColor = [UIColor blackColor].CGColor;
    }

    view.layer.shadowOpacity = 0.7f;
    view.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    view.layer.shadowRadius = 5.0f;
    view.layer.masksToBounds = NO;
 
    if ([shadowType isEqualToString:@"Trapezoidal" ]){
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(size.width * 0.33f, size.height * 0.66f)];
        [path addLineToPoint:CGPointMake(size.width * 0.66f, size.height * 0.66f)];
        [path addLineToPoint:CGPointMake(size.width * 1.15f, size.height * 1.15f)];
        [path addLineToPoint:CGPointMake(size.width * -0.15f, size.height * 1.15f)];
        view.layer.shadowPath = path.CGPath;
        
    }
    else if ([shadowType isEqualToString:@"Elliptical"]){
        CGRect ovalRect = CGRectMake(0.0f, size.height + 5, size.width - 10, 15);
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
        view.layer.shadowPath = path.CGPath;
    }
    //Curl is not working !!
    else if ([shadowType isEqualToString: @"Curl"]){
        CGFloat offset = 10.0;
        CGFloat curve = 5.0;
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        CGRect rect = view.bounds;
        CGPoint topLeft		 = rect.origin;
        CGPoint bottomLeft	 = CGPointMake(0.0, CGRectGetHeight(rect)+offset);
        CGPoint bottomMiddle = CGPointMake(CGRectGetWidth(rect)/2, CGRectGetHeight(rect)-curve);
        CGPoint bottomRight	 = CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect)+offset);
        CGPoint topRight	 = CGPointMake(CGRectGetWidth(rect), 0.0);
            
        [path moveToPoint:topLeft];
        [path addLineToPoint:bottomLeft];
        [path addQuadCurveToPoint:bottomRight
                         controlPoint:bottomMiddle];
        [path addLineToPoint:topRight];
        [path addLineToPoint:topLeft];
        [path closePath];
        view.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        view.layer.borderWidth = 5.0;
        view.layer.shadowOffset = CGSizeMake(0, 3);
        view.layer.shadowOpacity = 0.7;
        view.layer.shouldRasterize = YES;
        view.layer.shadowPath = path.CGPath;
            
    }
        
}
    
@end
