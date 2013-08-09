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

- (void)start;
- (void)setShowText:(NSString*)t forBlue:(BOOL)isBlue;
@end
