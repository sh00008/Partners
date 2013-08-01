//
//  ListeningCell.h
//  Partners
//
//  Created by JiaLi on 13-6-6.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributedLabel.h"
@interface UITeacherIconView : UIView
@end

@interface ListeningCell : UIView
{
    NSString* _srcMsg;
 }
@property (nonatomic, retain) IBOutlet UITeacherIconView* teatcherIconView;
@property (nonatomic, retain) IBOutlet UIImageView* teatcherImageView;
@property (nonatomic, retain) IBOutlet AttributedLabel* sentenceSrc;
@property (nonatomic, retain) IBOutlet UILabel* sentenceTrans;
@property (nonatomic, retain) IBOutlet UILabel* scroeLabel;
@property (nonatomic, retain) IBOutlet UIImageView* scoreImageView;

- (void)layoutCell;
- (void)setMsgText:(NSString *)msgText withTrans:(NSString*)transText;
- (void)changeTextColor:(NSMutableArray*)willCompareString;
- (void)resetCellState;
- (void)showScore:(NSInteger)score;
@end
