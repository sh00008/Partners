//
//  Database.h
//  Voice
//
//  Created by JiaLi on 11-8-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoicePkgInfoObject.h"

#define HISTORY_TABLE_NAME @"History"
#define HISTORY_ID         @"ID"

#define STRING_DB_TABLENAME_VOICE_PKG @"VoicePkgInfo"
#define STRING_DB_TABLENAME_VOICE_COURSES @"VoicePkgCoursesInfo"
#define STRING_DB_VOICE_PKG_ID         @"ID"
#define STRING_DB_VOICE_PKG_TITLE      @"Title"
#define STRING_DB_VOICE_PKG_PATH       @"Path"
#define STRING_DB_VOICE_PKG_COVER      @"Cover"
#define STRING_DB_VOICE_PKG_URL        @"URL"
#define STRING_DB_VOICE_PKG_CREATEDATE @"CreateDate"
#define STRING_DB_VOICE_IS_LISTENED    @"IsListened"

#define STRING_DB_TABLENAME_PKG_DOWNLOADINFO @"VoicePkgDownloadInfo"
#define STRING_DB_VOICE_PKG_DOWNLOAD_FLAG    @"Flag"

#define STRING_DB_TABLENAME_LIB_INFO  @"LibaryInfo"
#define STRING_DB_LIBARY_ID         @"LibaryID"
@interface CurrentLibrary: NSObject {
    
}
+ (CurrentLibrary*)sharedCurrentLibrary;

@property (nonatomic, assign) NSInteger libID;
@property (nonatomic, retain) NSString* dataPath;
@property (nonatomic, retain) NSString*  dataTitle;
@end

@interface Database : NSObject {
 	Database* _database;
    NSLock *databaseLock; //mutex used to create our Critical Section
}

+ (Database*)sharedDatabase;
- (BOOL)createTable;
- (BOOL)createVoicePkgInfoTable;
- (BOOL)createVoicePkgcCourseTable;
- (BOOL)createLibInfoTable;
- (BOOL)isExistsTable:(NSString*)tableName;
- (BOOL)insertVoicePkgInfo:(DownloadDataPkgInfo*)info;
- (BOOL)insertVoiceCourseInfo:(DownloadDataPkgInfo*)info;;
- (BOOL)insertLibaryInfo:(LibaryInfo*)info;

- (NSInteger)getVoicePkgInfoID:(NSString*)title withPath:(NSString*)path;
// return VoiceDataPkgObject object
- (NSMutableArray*)loadVoicePkgInfo;
- (NSMutableArray*)loadLibaryInfo;
- (VoiceDataPkgObjectFullInfo*)loadVoicePkgInfo:(DownloadDataPkgInfo*)downloadinfo;
- (VoiceDataPkgObjectFullInfo*)loadVoicePkgInfoByTitle:(NSString*)title withLibID:(NSInteger)libID;
- (VoiceDataPkgObjectFullInfo*)loadVoicePkgInfoByPath:(NSString*)path;
- (NSMutableArray*)getCourseTitleByID:(NSInteger)nID;
- (BOOL)deleteVoicePkgInfoByTitle:(NSString*)title withLibID:(NSInteger)libID;
- (BOOL)deleteCourseInfoByTitle:(NSString*)title withPath:(NSString*)path;
- (NSString*)getAbsolutelyPath:(NSString*)path;
- (NSInteger)getlastRecordID:(NSString*)tableName;
- (BOOL)setPkgListend:(NSString*)title withLibID:(NSInteger)libID;
- (BOOL)setPkgListendwithPath:(NSString*)path;
- (BOOL)getPkgIsListened:(NSString*)title withLibID:(NSInteger)libID;
@end
