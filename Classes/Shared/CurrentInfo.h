//
//  CurrentInfo.h
//  Partners
//
//  Created by JiaLi on 13-7-5.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoicePkgInfoObject.h"
@class DownloadLicense;

@protocol DownloadLicenseDelegate <NSObject>
- (void)didDownload:(NSError*)error withDownloadLicense:(DownloadLicense*)download;
@end

@interface DownloadLicense : NSObject
@property (nonatomic, assign) NSInteger libID;
@property (nonatomic, assign) id<DownloadLicenseDelegate>delegate;
- (void)checkLisence:(NSString*)url;
@end

@interface CurrentInfo : NSObject
@property (nonatomic, retain) NSString* currentPkgDataPath;
@property (nonatomic, retain) NSString* currentPkgDataTitle;
@property (nonatomic, assign) NSInteger currentLibID;

+ (CurrentInfo*)sharedCurrentInfo;
@end
