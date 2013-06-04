//
//  FavorCourseButton.h
//  Partners
//
//  Created by JiaLi on 13-6-2.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavorCourseButton : UIButton

@property(nonatomic, retain)NSString* pkgPath;
@property(nonatomic, retain)NSString* pkgTitle;
- (void)setCourseTitle:(NSString*)title;
@end
