//
//  DownloadWholeLessonViewController.h
//  Partners
//
//  Created by JiaLi on 13-7-26.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DownloadWholeLessonViewController;
@protocol MJSecondPopupDelegate<NSObject>
@optional
- (void)cancelButtonClicked:(DownloadWholeLessonViewController*)secondDetailViewController;
- (void)doneButtonClicked:(DownloadWholeLessonViewController*)secondDetailViewController;
@end
@interface DownloadWholeLessonViewController : UIViewController
@property (assign, nonatomic) id <MJSecondPopupDelegate>delegate;
@property (nonatomic, retain) NSString* scenesName;
@property (nonatomic, retain) NSString* pkgName;
@property (nonatomic, retain) NSString* dataPath;

- (IBAction)cancel:(id)sender;
- (IBAction)downAll:(id)sender;
- (void)startDownload;
@end
