//
//  BuyButton.m
//  Partners
//
//  Created by JiaLi on 13-8-9.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "BuyButton.h"

@implementation BuyButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *darkGreenButtonImage = [UIImage imageNamed:@"buttonblue_pressed.png"];
        UIImage *stretchabledarkGreenButton = [darkGreenButtonImage stretchableImageWithLeftCapWidth:6 topCapHeight:6];
        [self setBackgroundImage:stretchabledarkGreenButton forState:UIControlStateHighlighted];
       
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)start
{
    if (_indicatior == nil) {
        _indicatior = [[UIActivityIndicatorView alloc] initWithFrame:self.frame];
        [self addSubview:_indicatior];
        [_indicatior release];
    }
    [_indicatior startAnimating];
}

- (void)setShowText:(NSString*)t forBlue:(BOOL)isBlue;
{
    [_indicatior stopAnimating];
    [_indicatior removeFromSuperview];
    _indicatior = nil;
    [self setTitle:t forState:UIControlStateNormal];
    if (isBlue) {
        UIImage *blueButtonImage = [UIImage imageNamed:@"buttonblue_normal.png"];
        UIImage *stretchableBlueButton = [blueButtonImage stretchableImageWithLeftCapWidth:6 topCapHeight:6];
        [self setBackgroundImage:stretchableBlueButton forState:UIControlStateNormal];
    } else {
        UIImage *greenButtonImage = [UIImage imageNamed:@"button_green_normal.png"];
        UIImage *stretchableGreenButton = [greenButtonImage stretchableImageWithLeftCapWidth:6 topCapHeight:6];
        [self setBackgroundImage:stretchableGreenButton forState:UIControlStateNormal];
    }
}

@end
