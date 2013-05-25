//
//  PersonalLibary.h
//  Partners
//
//  Created by JiaLi on 13-5-25.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGBox.h"
@interface PersonalLibary : MGBox

+ (PersonalLibary *)libAddBoxWithSize:(CGSize)size;
+ (PersonalLibary *)libBoxFor:(int)i size:(CGSize)size;

- (void)loadLib;

@end
