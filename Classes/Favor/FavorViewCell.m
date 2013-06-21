//
//  FavorViewCell.m
//  Partners
//
//  Created by JiaLi on 13-6-1.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "FavorViewCell.h"

@implementation FavorViewCell
@synthesize pkgTitle;
@synthesize pkgCourseBGView;
@synthesize deletePkg;

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
    [self.pkgTitle release];
    [self.pkgCourseBGView release];
    [super dealloc];
}

@end
