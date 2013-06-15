//
//  RecordingWaveCell.m
//  Voice
//
//  Created by JiaLi on 11-8-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "RecordingWaveCell.h"


@implementation RecordingWaveCell
@synthesize playingButton = _recordingButton;
@synthesize waveView = _waveView;
@synthesize timelabel = _timelabel;
@synthesize delegate;
@synthesize sentence;
@synthesize playingUpButton, playingDownButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    self.sentence = nil;
    [self.playingButton release];
    [self.waveView release];
    [self.timelabel release];
    [super dealloc];
}

- (IBAction)onPlaying:(id)sender;
{
    UIButton* button = (UIButton*)sender;
    [delegate playing:button.tag withSentence:self.sentence withCell:self];
}

@end
