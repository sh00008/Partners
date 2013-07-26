//
//  DownloadWholeViewController.h
//  Partners
//
//  Created by JiaLi on 13-7-26.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DownloadWholeViewController;
@protocol MJSecondPopupDelegate<NSObject>
@optional
- (void)cancelButtonClicked:(DownloadWholeViewController*)secondDetailViewController;
- (void)doneButtonClicked:(DownloadWholeViewController*)secondDetailViewController;
@end

@interface DownloadWholeViewController : UIViewController
@property (assign, nonatomic) id <MJSecondPopupDelegate>delegate;
@property (nonatomic, retain) NSString* scenesName;
@property (nonatomic, retain) NSString* pkgName;
@property (nonatomic, retain) NSString* dataPath;
@property (nonatomic, retain) IBOutlet UIButton* buttonCancel;
@property (nonatomic, retain) IBOutlet UIButton* buttonDownload;

- (IBAction)cancel:(id)sender;
- (IBAction)downAll:(id)sender;
- (void)startDownload;
@end
