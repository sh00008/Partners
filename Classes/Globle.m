//
//  Globle.m
//  Partners
//
//  Created by JiaLi on 13-5-13.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "Globle.h"
#import "VoiceDef.h"

@implementation Globle
+ (CGSize)calcTextHeight:(NSString *)str withWidth:(CGFloat)width;
{
    
    CGSize textSize = {width, 20000.0};
    CGSize size     = [str sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_BUBBLE]
                      constrainedToSize:textSize];
    
    return size;
}

+ (CGSize)calcTextHeight:(NSString *)str withWidth:(CGFloat)width withFontSize:(CGFloat)fontSize;
{
    
    CGSize textSize = {width, 20000.0};
    CGSize size     = [str sizeWithFont:[UIFont systemFontOfSize:fontSize]
                      constrainedToSize:textSize];
    
    return size;
}


@end
