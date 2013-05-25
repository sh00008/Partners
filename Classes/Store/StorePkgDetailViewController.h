//
//  StorePkgDetailViewController.h
//  Sanger
//
//  Created by JiaLi on 12-9-20.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoicePkgInfoObject.h"
@protocol StorePkgDetailViewControllerDelegate <NSObject>

- (void)doDownload:(DownloadDataPkgInfo*)info;
- (void)startLearning:(DownloadDataPkgInfo*)info;
@end

@interface StorePkgDetailViewController : UITableViewController

@property (nonatomic, retain, readwrite) DownloadDataPkgInfo* info;
@property (nonatomic, assign) id<StorePkgDetailViewControllerDelegate>delegate;

+ (CGSize)calcTextHeight:(NSString *)str withWidth:(CGFloat)width withFontSize:(CGFloat)fontSize;

- (IBAction)doDownload:(id)sender;
@end
