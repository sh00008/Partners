//
//  StoreNetworkConnectionView.m
//  Sanger
//
//  Created by JiaLi on 12-9-20.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#import "StoreNetworkConnectionView.h"
#import "VoiceDef.h"
@implementation StoreNetworkConnectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:_indicatorView];
        [_indicatorView release];
        CGPoint pt = self.center;
        _indicatorView.center = CGPointMake(pt.x - 30, pt.y);
        _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_indicatorView setHidden:YES];
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(_indicatorView.frame.origin.x + _indicatorView.frame.size.width + 2, _indicatorView.frame.origin.y, 100, _indicatorView.frame.size.height)];
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_textLabel setFont:[UIFont systemFontOfSize:14]];
        [_textLabel setBackgroundColor:[UIColor clearColor]];
        _textLabel.shadowColor = [UIColor darkGrayColor];
        _textLabel.textColor = [UIColor whiteColor];
       [self addSubview:_textLabel];
        [_textLabel setHidden:YES];
        _textLabel.text = STRING_LOADINGDATA_WAITING;
        [_textLabel release];
    }
    return self;
}

- (void)start
{
    if (_indicatorView != nil) {
        [_indicatorView startAnimating];
        [_indicatorView setHidden:NO];
    }
    
    if (_textLabel != nil) {
        [_textLabel setHidden:NO];
    }
}

- (void)stop
{
    if (_indicatorView != nil) {
        _textLabel.frame = CGRectMake(_textLabel.frame.origin.x - _indicatorView.frame.size.width, _textLabel.frame.origin.y, _textLabel.frame.size.width, _textLabel.frame.size.height);

        [_indicatorView stopAnimating];
        [_indicatorView removeFromSuperview];
        _indicatorView = nil;
        
    }
}

- (void)setLabelText:(NSString*)text
{
    if (_textLabel != nil) {
        _textLabel.text = text;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (void)startAnimation:(UIView*)addToView
{
    StoreNetworkConnectionView* connectionView = [[StoreNetworkConnectionView alloc] initWithFrame:CGRectMake(0, 0, addToView.frame.size.width, addToView.frame.size.height)];
    addToView.tag = TAG_OF_NETWORKCONNECTIONVIEW;
    connectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [addToView addSubview:connectionView];
    [connectionView start];
    [connectionView release];
}

+ (void)stopAnimation:(NSString*)text withSuperView:(UIView*)addToView
{
    for (StoreNetworkConnectionView* connectionView in [addToView subviews])
    {
        if ([connectionView isKindOfClass:[StoreNetworkConnectionView class]])
        {
            [connectionView stop];
            [connectionView setLabelText:text];
            break;
        }
    }

    /*
    StoreNetworkConnectionView* sView = (StoreNetworkConnectionView*)[addToView viewWithTag:TAG_OF_NETWORKCONNECTIONVIEW];
    StoreNetworkConnectionView* connectionView = (StoreNetworkConnectionView*)sView;
    if ([connectionView isKindOfClass:[StoreNetworkConnectionView class]]) {
        [connectionView stop];
        [connectionView setLabelText:text];
    }
     */
}

+ (void)removeConnectionView:(UIView*)addToView;
{
    for (StoreNetworkConnectionView* connectionView in [addToView subviews])
    {
        if ([connectionView isKindOfClass:[StoreNetworkConnectionView class]])
        {
            [connectionView removeFromSuperview];
            break;
        }
    }

    /*StoreNetworkConnectionView* connectionView = (StoreNetworkConnectionView*)[addToView viewWithTag:TAG_OF_NETWORKCONNECTIONVIEW];
    if (connectionView != nil) {
        [connectionView removeFromSuperview];
    }*/

}
@end
