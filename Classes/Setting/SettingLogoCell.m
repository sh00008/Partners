//
//  SettingLogoCell.m
//  Partners
//
//  Created by JiaLi on 13-8-7.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "SettingLogoCell.h"

@implementation SettingLogoCell
@synthesize logoImageView, versionLabel, version;
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
