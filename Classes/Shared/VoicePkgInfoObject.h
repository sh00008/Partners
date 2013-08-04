//
//  VoiceDataPkgObject.h
//  Sanger
//
//  Created by JiaLi on 12-10-11.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface DownloadServerInfo :NSObject

@property (nonatomic, retain, readwrite) NSMutableArray* serverList;
+ (DownloadServerInfo*)sharedDownloadServerInfo;

@end;

@interface DownloadDataPkgCourseInfo : NSObject
@property (nonatomic, retain, readwrite) NSString* title;
@property (nonatomic, retain, readwrite) NSString* path;
@property (nonatomic, retain, readwrite) NSString* file;
@property (nonatomic, retain, readwrite) NSString* cover;
@property (nonatomic, retain, readwrite) NSString* url;
@property (nonatomic, retain, readwrite) NSString* receivedXMLPath;
@end

@interface DownloadDataPkgInfo :NSObject
@property (nonatomic, assign, readwrite) NSInteger libID;
@property (nonatomic, retain, readwrite) NSString* title;
@property (nonatomic, assign, readwrite) NSInteger count;
@property (nonatomic, retain, readwrite) NSString* coverURL;
@property (nonatomic, retain, readwrite) NSString* url;
@property (nonatomic, retain, readwrite) NSString* intro;
@property (nonatomic, retain, readwrite) NSMutableArray* dataPkgCourseInfoArray;
@property (nonatomic, retain, readwrite) NSString* receivedCoverImagePath;
@end


@interface VoiceDataPkgObject : NSObject
@property (nonatomic, retain) NSString* dataPath;
@property (nonatomic, retain) NSString* dataTitle;
@property (nonatomic, retain) NSString* dataCover;
@property (nonatomic, retain, readwrite) NSMutableArray* dataPkgCourseTitleArray;

@end

@interface VoiceDataPkgObjectFullInfo : VoiceDataPkgObject
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* createTime;

@end

@interface LibaryInfo : NSObject
@property (nonatomic, assign, readwrite) NSInteger libID;
@property (nonatomic, retain, readwrite) NSString* title;
@property (nonatomic, retain, readwrite) NSString* path;
@property (nonatomic, retain, readwrite) NSString* file;
@property (nonatomic, retain, readwrite) NSString* cover;
@property (nonatomic, retain, readwrite) NSString* url;
@property (nonatomic, retain, readwrite) NSString* lisence;
@property (nonatomic, retain) NSString* createTime;
@property (nonatomic) long lisenceLen;
@end

@interface RecordingInfo : NSObject
@property (nonatomic, readwrite) NSInteger score;
@property (nonatomic, retain, readwrite) NSString* date;
@end
