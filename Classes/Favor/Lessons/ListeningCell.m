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
    self.layer.cornerRadius = 28;
    return self;
}

- (void) drawRect:(CGRect)rect
{
    self.layer.cornerRadius = 28;
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
    //self.teatcherIconView.layer.cornerRadius = 28;
    self.teatcherIconView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.teatcherIconView.layer.borderWidth = 1.0;
    self.sentenceSrc.numberOfLines = 0;
    self.sentenceSrc.lineBreakMode   = UILineBreakModeWordWrap;
    self.sentenceTrans.numberOfLines = 0;
    self.sentenceTrans.lineBreakMode   = UILineBreakModeWordWrap;
}

- (void)cleanUp;
{
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
    CGSize szSrc = [Globle calcTextHeight:msgText withWidth:self.sentenceSrc.frame.size.width withFontSize:22];
    
    CGSize szTrans = [Globle calcTextHeight:transText withWidth:self.sentenceTrans.frame.size.width withFontSize:14];
    [self.sentenceSrc sizeToFit];
    
    [self.sentenceTrans sizeToFit];
    self.sentenceTrans.frame = CGRectMake(self.sentenceSrc.frame.origin.x, self.sentenceSrc.frame.origin.y, self.sentenceSrc.frame.size.width, szSrc.height);
    self.sentenceTrans.frame = CGRectMake(self.sentenceTrans.frame.origin.x, self.sentenceSrc.frame.origin.y + self.sentenceSrc.frame.size.height + 10, self.sentenceTrans.frame.size.width, szTrans.height);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.sentenceTrans.frame.origin.y + self.sentenceTrans.frame.size.height + 20);
}

- (void)dealloc
{
    [self.teatcherImageView release];
    [self.teatcherIconView release];
    [super dealloc];
}
@end
