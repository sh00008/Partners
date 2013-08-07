//
//  SettingData.h
//  Voice
//
//  Created by JiaLi on 11-8-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KSettingVersion      @"Version"
#define kSettingTimeInterval @"TimeInterval"
#define kSettingReadingCount @"ReadingCount"
#define kSettingReadingMode @"ReadingMode"
#define kSettingisShowTranslation @"ShowTextType"
#define kSettingLoopReading @"LoopReading"
#define kSettingShowDay @"showDaySentence"
#define kSettingVersion @"lastAppVersion"
#define kSettingShowDate @"showDayDatae"

typedef enum {
	SHOW_TEXT_TYPE_SRC = 0,
	SHOW_TEXT_TYPE_SRCANDTRANS,
	SHOW_TEXT_TYPE_NONE
} SHOW_TEXT_TYPE;

typedef enum {
	READING_MODE_WHOLE_TEXT = 0,
	READING_MODE_SENTENCE,
} READING_MODE;


@interface SettingData : NSObject {
    CGFloat dTimeInterval;
    NSInteger nReadingCount;
    READING_MODE eReadingMode;
    SHOW_TEXT_TYPE eShowTextType;
    BOOL bLoop;
    BOOL bShowDay;
}

@property (nonatomic, assign) CGFloat dTimeInterval;
@property (nonatomic, assign) NSInteger nReadingCount;
@property (nonatomic, assign) READING_MODE eReadingMode;
@property (nonatomic, assign) SHOW_TEXT_TYPE eShowTextType;
@property (nonatomic, assign) BOOL bLoop;
@property (nonatomic, assign) BOOL bShowDay;
@property (nonatomic, assign) CGFloat version;
@property (nonatomic, assign) BOOL isNeedCopyFreeSrc;

- (void)initSettingData;
- (void)loadSettingData;
- (void)saveSettingData;

@end
