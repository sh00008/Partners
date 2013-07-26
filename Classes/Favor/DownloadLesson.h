//
//  DownloadLesson.h
//  Partners
//
//  Created by JiaLi on 13-7-27.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CourseParser.h"
//delegate

@class DownloadLesson;
@protocol DownloadLessonDelegate<NSObject>
@optional
- (void)startDownloadingXinFile:(DownloadLesson*)download;
- (void)endDownloadingXinFile:(DownloadLesson*)download;
- (void)startDownloadingLesFile:(DownloadLesson*)download;
- (void)endDownloadingLesFile:(DownloadLesson*)download;
- (void)startDownloadingIsbFile:(DownloadLesson*)download;
- (void)endDownloadingIsbFile:(DownloadLesson*)download;
- (void)downloadSucceed:(DownloadLesson*)download;
- (void)downloadfailed:(DownloadLesson*)download;

@end

@interface DownloadLesson : NSObject
{
    BOOL     _bDownloadedXAT;
    BOOL     _bDownloadedISB;
    BOOL     _bDownloadedLES;
    
}
@property (nonatomic, assign) NSInteger nPositionInCourse;
@property (nonatomic, assign)id <DownloadLessonDelegate>delegate;
@property (nonatomic, retain) CourseParser* courseParser;

- (BOOL)checkIsNeedDownload;
- (BOOL)isDownloaed;
@end
