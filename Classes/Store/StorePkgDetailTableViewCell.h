//
//  StorePkgDetailTableViewCell.h
//  Sanger
//
//  Created by JiaLi on 12-9-20.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoicePkgInfoObject.h"

typedef enum {
	STORE_DOWNLOADING_STATUS_None           = 0,
	STORE_DOWNLOADING_STATUS_DOWNLOADING    = 1,
	STORE_DOWNLOADING_STATUS_CONTINUE_DOWNLOADING  = 2,
	STORE_DOWNLOADING_STATUS_DOWNLOADED         = 3,
} STORE_DOWNLOADING_STATUS;

@interface DetailCustomBackgroundView : UIView {
    
}
@property (nonatomic, assign) BOOL bUpToDown;

@end

@protocol StorePkgDetailTableViewCellDelegate <NSObject>

- (void)doDownload:(DownloadDataPkgInfo*)info;
- (void)startLearning:(DownloadDataPkgInfo*)info;
- (void)updateButtonStatus;

@end
@interface StorePkgDetailTableViewCell : UITableViewCell
{
    DownloadDataPkgInfo* _info;

}

@property (nonatomic, retain) IBOutlet UIImageView* coverImageView;
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UIButton* downloadButton;
@property (nonatomic, retain) IBOutlet UIButton* backToShelfButton;
@property (nonatomic, assign) id<StorePkgDetailTableViewCellDelegate> delegate;

- (void)setVoiceData:(DownloadDataPkgInfo*)info;
- (void)setButtomImage;
- (IBAction)clickButton:(id)sender;
- (IBAction)clickStartLearn:(id)sender;
- (void)delayShowBackToShelfButton;

@end
