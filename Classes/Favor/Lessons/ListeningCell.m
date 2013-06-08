//
//  ListeningCell.m
//  Partners
//
//  Created by JiaLi on 13-6-6.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "ListeningCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Globle.h"

@implementation UITeacherIconView
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.layer.cornerRadius = 36;
    return self;
}

- (void) drawRect:(CGRect)rect
{
    self.layer.cornerRadius = 36;
    [super drawRect:rect];
}
@end

@implementation ListeningCell
@synthesize teatcherIconView, teatcherImageView;
@synthesize sentenceSrc;
@synthesize sentenceTrans;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutCell;
{
    self.teatcherIconView.layer.cornerRadius = 36;
    self.teatcherIconView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.teatcherIconView.layer.borderWidth = 1.0;
    self.sentenceSrc.numberOfLines = 0;
    self.sentenceSrc.lineBreakMode   = UILineBreakModeWordWrap;
    [self.sentenceSrc sizeToFit];
    self.sentenceTrans.numberOfLines = 0;
    self.sentenceTrans.lineBreakMode   = UILineBreakModeWordWrap;
    [self.sentenceTrans sizeToFit];

}
- (void)cleanUp;
{
    self.backgroundView = nil;
    while ([[self.contentView subviews] count] > 0) {
        UIView *sub = [[self.contentView subviews] objectAtIndex:0];
        if (sub != nil) {
            [sub removeFromSuperview];
        }
    }
 }


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMsgText:(NSString *)msgText withTrans:(NSString*)transText;
{
    self.sentenceSrc.text = msgText;
    self.sentenceTrans.text = transText;
}

- (void)dealloc
{
    [self.teatcherImageView release];
    [self.teatcherIconView release];
    [super dealloc];
}
@end
