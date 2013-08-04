//
//  RecordingScoreViewController.h
//  Partners
//
//  Created by JiaLi on 13-8-5.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordingScoreViewController : UIViewController

@property(nonatomic, retain) IBOutlet UITableView* scoreTable;
@property(nonatomic, retain) IBOutlet UINavigationBar* naviBar;
@property(nonatomic, retain) NSString* waveFile;
- (IBAction)clearRecordingScore:(id)sender;
@end
