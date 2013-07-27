//
//  PersonalMainViewController.h
//  Partners
//
//  Created by JiaLi on 13-6-24.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalMainViewController : UITableViewController
{
    NSMutableArray* _dataArray;
    BOOL _edit;
    
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
    BOOL _isCloseAddLibView;
}

@property (nonatomic, retain) NSArray *_products;

- (void)loadLibaryInfo;
- (void)reloadInfo;

@end
