//
//  StoreCourceTableViewCell.h
//  Sanger
//
//  Created by JiaLi on 12-9-25.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoicePkgInfoObject.h"

@interface StoreCourceTableViewCellBackground : UIView

@property (nonatomic, assign) BOOL bDark;
@property (nonatomic, assign) BOOL bSeperator;
@end

@interface StoreCourceTableViewCell : UITableViewCell
{
    DownloadDataPkgCourseInfo* _course;
}

@property (nonatomic, retain) IBOutlet UILabel* courseIndexLabel;
@property (nonatomic, retain) IBOutlet UILabel* courseNameLabel;


- (void)setCourseData:(DownloadDataPkgCourseInfo*)course withURL:(NSString*)parentURL;

@end
