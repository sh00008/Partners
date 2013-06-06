//
//  ListeningCell.h
//  Partners
//
//  Created by JiaLi on 13-6-6.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UITeacherIconView : UIView
@end

@interface ListeningCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UITeacherIconView* teatcherIconView;
@property (nonatomic, retain) IBOutlet UIImageView* teatcherImageView;
@property (nonatomic, retain) IBOutlet UILabel* sentenceSrc;
@property (nonatomic, retain) IBOutlet UILabel* sentenceTrans;

@end
