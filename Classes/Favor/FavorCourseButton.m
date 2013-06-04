//
//  FavorCourseButton.m
//  Partners
//
//  Created by JiaLi on 13-6-2.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "FavorCourseButton.h"

@implementation FavorCourseButton
@synthesize pkgPath;
@synthesize pkgTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setFont:[UIFont systemFontOfSize:12]];
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.tintColor = [UIColor whiteColor];
        [self setBackgroundColor:[UIColor colorWithRed:66.0/255.0 green:168.0/255.0 blue:250.0/255.0 alpha:1.0]];// forState:UIControlStateNormal];
   }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setCourseTitle:(NSString*)title;
{
    [self setTitle:title forState:UIControlStateNormal];
    //[bt setBackgroundColor:[UIColor redColor]];

}
@end
