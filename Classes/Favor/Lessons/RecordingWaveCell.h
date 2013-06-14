//
//  RecordingWaveCell.h
//  Voice
//
//  Created by JiaLi on 11-8-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaveView.h"

@class RecordingWaveCell;
@protocol RecordingWaveCellDelegate <NSObject>

- (void)playing:(NSInteger)buttonTag withSentence:(id)sen withCell:(RecordingWaveCell*)cell;

@end

@interface RecordingWaveCell : UITableViewCell {
    UIButton* _playingButton;
    WaveView* _waveView;
    UIImageView* _icon;
    UILabel* _timelabel;
    id < RecordingWaveCellDelegate> delegate;
}
@property (nonatomic, retain) IBOutlet UIButton* playingButton;
@property (nonatomic, retain) IBOutlet UIButton* playingUpButton;
@property (nonatomic, retain) IBOutlet UIButton* playingDownButton;
@property (nonatomic, retain) IBOutlet WaveView* waveView;
@property (nonatomic, retain) IBOutlet UILabel* timelabel;
@property (nonatomic, assign) id < RecordingWaveCellDelegate> delegate;
@property (nonatomic, assign) id sentence;
- (IBAction)onPlaying:(id)sender;

@end
