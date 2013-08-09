//
//  BuyButton.h
//  Partners
//
//  Created by JiaLi on 13-8-9.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuyButton : UIButton {
    UIActivityIndicatorView* _indicatior;
}
@property(nonatomic, assign) BOOL isLoading;

- (void)start;
- (void)showText:(NSString*)t forBlue:(BOOL)isBlue;
@end
