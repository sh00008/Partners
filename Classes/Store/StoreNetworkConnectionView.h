//
//  StoreNetworkConnectionView.h
//  Sanger
//
//  Created by JiaLi on 12-9-20.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TAG_OF_NETWORKCONNECTIONVIEW 100234

@interface StoreNetworkConnectionView : UIView
{
    UIActivityIndicatorView* _indicatorView;
    UILabel* _textLabel;
}

- (void)start;
- (void)stop;
- (void)setLabelText:(NSString*)text;

+ (void)startAnimation:(UIView*)addToView;
+ (void)stopAnimation:(NSString*)text withSuperView:(UIView*)addToView;
+ (void)removeConnectionView:(UIView*)addToView;

@end
