//
//  ListeningCell.m
//  Partners
//
//  Created by JiaLi on 13-6-6.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "ListeningCell.h"
#import <QuartzCore/QuartzCore.h>

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
