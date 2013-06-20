//
//  CollapseClickCell.m
//  CollapseClick
//
//  Created by Ben Gordon on 2/28/13.
//  Copyright (c) 2013 Ben Gordon. All rights reserved.
//

#import "CollapseClickCell.h"

@implementation CollapseClickCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (CollapseClickCell *)newCollapseClickCellWithHeader:(UIView*)headerView index:(int)index content:(UIView *)content;
{
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"CollapseClickCell" owner:nil options:nil];
    CGRect rcHeader = headerView.frame;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    headerView.frame = CGRectMake(rcHeader.origin.x, rcHeader.origin.y, width, rcHeader.size.height);
    CollapseClickCell *cell = [[CollapseClickCell alloc] initWithFrame:CGRectMake(0, 0, rcHeader.size.width, rcHeader.size.height + content.frame.size.height)];
    cell = [views objectAtIndex:0];
    cell.frame = CGRectMake(0, 0, width , rcHeader.size.height + content.frame.size.height );
    // Initialization Here
    [cell.TitleView addSubview:headerView];
    [cell bringSubviewToFront:headerView];
    headerView.tag = 101;
    cell.TitleView.frame = headerView.frame;
    cell.index = index;
    cell.TitleButton.tag = index;
    cell.TitleButton.frame = headerView.frame;
     cell.ContentView.frame = CGRectMake(cell.ContentView.frame.origin.x, cell.TitleView.frame.origin.y + cell.TitleView.frame.size.height, width, content.frame.size.height);
    content.tag = 102;
    NSArray* waveViews = content.subviews;
    if (waveViews != nil) {
        for (NSInteger i = 0; i < waveViews.count; i ++) {
            UIView* sub = [waveViews objectAtIndex:i];
            sub.frame = CGRectMake(sub.frame.origin.x, sub.frame.origin.y, width, sub.frame.size.height);
        }
    }
    [cell.ContentView addSubview:content];
    [cell bringSubviewToFront:cell.TitleButton];
   
    if (index % 2 == 0) {
        cell.backgroundColor = [UIColor lightGrayColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
     return cell;

}

+ (CollapseClickCell *)newCollapseClickCellWithTitle:(NSString *)title index:(int)index content:(UIView *)content {
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"CollapseClickCell" owner:nil options:nil];
    CollapseClickCell *cell = [[CollapseClickCell alloc] initWithFrame:CGRectMake(0, 0, 320, kCCHeaderHeight)];
    cell = [views objectAtIndex:0];
    
    // Initialization Here
    cell.TitleLabel.text = title;
    cell.index = index;
    cell.TitleButton.tag = index;
    cell.ContentView.frame = CGRectMake(cell.ContentView.frame.origin.x, cell.ContentView.frame.origin.y, cell.ContentView.frame.size.width, content.frame.size.height);
    [cell.ContentView addSubview:content];
    
    return cell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
