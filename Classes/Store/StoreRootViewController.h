//
//  StoreRootViewController.h
//  Sanger
//
//  Created by JiaLi on 12-9-19.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoicePkgInfoObject.h"

@protocol StoreRootViewControllerDelegate <NSObject>

- (void)pushViewController:(UIViewController*)detail;
- (void)backToShelf:(DownloadDataPkgInfo*)info;
@end
 
@interface StoreRootViewController : UITableViewController
@property (nonatomic, retain, readwrite) NSMutableArray* pkgArray;
@property (nonatomic, assign, readwrite) id<StoreRootViewControllerDelegate> delegate;
@end
