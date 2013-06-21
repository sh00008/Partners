//
//  FavorViewCell.h
//  Partners
//
//  Created by JiaLi on 13-6-1.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavorViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel* pkgTitle;
@property (nonatomic, retain) IBOutlet UIView* pkgCourseBGView;
@property (nonatomic, retain) IBOutlet UIButton* deletePkg;
@end
