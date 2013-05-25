//
//  PersonalViewController.h
//  Partners
//
//  Created by JiaLi on 13-5-13.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MGScrollView, MGBox;

@interface PersonalViewController : UIViewController
{
    
}

@property (nonatomic, retain) IBOutlet MGScrollView* scroller;

- (MGBox *)libAddBox;
- (BOOL)allLibsLoaded;
- (MGBox *)libBoxFor:(int)i;
- (CGSize)libBoxSize;
@end
