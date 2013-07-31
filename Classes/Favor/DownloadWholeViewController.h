//
//  DownloadWholeViewController.h
//  Partners
//
//  Created by JiaLi on 13-7-26.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    POPVIEW_TYPE_NONE = 0,
    POPVIEW_TYPE_NOMAL = 1,
    POPVIEW_TYPE_BORROW = 2,
};
typedef NSInteger POPVIEW_TYPE;


@class DownloadWholeViewController;
@protocol MJSecondPopupDelegate<NSObject>
@optional
- (void)cancelButtonClicked:(DownloadWholeViewController*)secondDetailViewController;
- (void)doneButtonClicked:(DownloadWholeViewController*)secondDetailViewController;
- (void)dimissPopView:(DownloadWholeViewController*)secondDetailViewController;
@end

@interface DownloadWholeViewController : UIViewController
@property (assign, nonatomic) id <MJSecondPopupDelegate>delegate;

@property (nonatomic, retain) NSString* scenesName;
@property (nonatomic, retain) NSString* pkgName;
@property (nonatomic, retain) NSString* dataPath;
@property (nonatomic, retain) IBOutlet UIButton* buttonCancel;
@property (nonatomic, retain) IBOutlet UILabel* viewTitle;
@property (nonatomic, retain) IBOutlet UIButton* buttonDownload;
@property (nonatomic, retain) IBOutlet UIButton* buttonRenew;
@property (nonatomic, assign) POPVIEW_TYPE eViewType;

- (IBAction)cancel:(id)sender;
- (IBAction)downAll:(id)sender;
- (IBAction)renew:(id)sender;
- (void)startDownload;
@end
