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

#define STRING_DB_TABLENAME_VOICE_PKG                   @"VoicePkgInfo"
#define STRING_DB_TABLENAME_VOICE_COURSES               @"VoicePkgCoursesInfo"
#define STRING_DB_VOICE_ID                              @"ID"
#define STRING_DB_VOICE_TITLE                           @"Title"
#define STRING_DB_VOICE_PATH                            @"Path"
#define STRING_DB_VOICE_COURSE_FILE                     @"File"
#define STRING_DB_VOICE_COVER                           @"Cover"
#define STRING_DB_VOICE_URL                             @"URL"
#define STRING_DB_VOICE_CREATEDATE                      @"CreateDate"
#define STRING_DB_VOICE_IS_LISTENED                     @"IsListened"
#define STRING_DB_VOICE_LISENCE                         @"Lisence"
#define STRING_DB_VOICE_LISENCE_LEN                     @"LisenceLength"
#define STRING_DB_TABLENAME_PKG_DOWNLOADINFO            @"VoicePkgDownloadInfo"

#define STRING_DB_TABLENAME_LIB_INFO                    @"LibaryInfo"
#define STRING_DB_TABLENAME_LIB_LISENCE_INFO            @"LibaryLisenceInfo"
#define STRING_DB_LIBARY_ID                             @"LibaryID"

#define STRING_DB_TABLENAME_DOWNLOAD_INFO               @"PKGDownloadInfo"
#define STRING_DB_VOICE_PROCESS                         @"DownloadProcess"
#define STRING_DB_VOICE_DOWNLOAD_FLAG                   @"DownloadFlag"


#define STRING_DB_TABLENAME_RECORDING_HISTORY           @"RecordingHistoryInfo"
#define STRING_DB_VOICE_COURSEID                        @"CourseID"
#define STRING_DB_VOICE_SCORE                           @"Score"

@interface Database : NSObject {
 	Database* _database;
    NSLock *databaseLock; //mutex used to create our Critical Section
}

+ (Database*)sharedDatabase;
- (BOOL)createTable;
- (BOOL)createVoicePkgInfoTable;
- (BOOL)createVoicePkgcCourseTable;
- (BOOL)createLibInfoTable;
- (BOOL)createLibLisenceTable;
- (BOOL)createDownloadPkgTable;
- (BOOL)createRecordingHistoryTable;

- (BOOL)isExistsTable:(NSString*)tableName;
- (BOOL)insertVoicePkgInfo:(DownloadDataPkgInfo*)info;
- (BOOL)insertVoiceCourseInfo:(DownloadDataPkgInfo*)info;;

- (BOOL)insertLibaryInfo:(LibaryInfo*)info;
- (BOOL)updateLibaryInfo:(LibaryInfo*)info;
- (BOOL)insertLibaryLisenceInfo:(LibaryInfo *)info;
- (BOOL)updateLibaryLisenceInfo:(LibaryInfo *)info;
- (LibaryInfo*)getLibaryInfoByID:(NSInteger)libID;
- (LibaryInfo*)getLibaryInfoByURL:(NSString*)url;
- (void)getLisenceInfo:(LibaryInfo*)info;
- (BOOL)deleteLibaryInfo:(NSInteger)libID;
- (BOOL)deleteLibaryLisenceInfo:(NSInteger)libID;
- (BOOL)deleteLibaryData:(NSInteger)libID;

- (BOOL)isPkgDownloaded:(NSString*)title withPath:(NSString*)path;
- (BOOL)insertDownloadedInfo:(NSString*)title withPath:(NSString*)path;
- (BOOL)deleteDownloadedInfo:(NSString*)path;
- (BOOL)updateDownloadedInfo:(NSString*)title withPath:(NSString*)path;
- (BOOL)isExistDownloadedInfo:(NSString*)title withPath:(NSString*)path;

- (NSInteger)getVoicePkgInfoID:(NSString*)title withPath:(NSString*)path;
// return VoiceDataPkgObject object
- (NSMutableArray*)loadVoicePkgInfo;
- (NSMutableArray*)loadLibaryInfo;
- (VoiceDataPkgObjectFullInfo*)loadVoicePkgInfo:(DownloadDataPkgInfo*)downloadinfo;
- (VoiceDataPkgObjectFullInfo*)loadVoicePkgInfoByTitle:(NSString*)title withLibID:(NSInteger)libID;
- (VoiceDataPkgObjectFullInfo*)loadVoicePkgInfoByPath:(NSString*)path;
- (DownloadDataPkgCourseInfo*)loadPkgCourseInfoByTitle:(NSString*)title withPKGID:(NSInteger)pkgID;
- (NSInteger)getCourseInfoIDByTitle:(NSString*)title withPKGID:(NSInteger)pkgID;

- (NSMutableArray*)getCourseTitleByID:(NSInteger)nID;
- (BOOL)deleteVoicePkgInfoByTitle:(NSString*)title withLibID:(NSInteger)libID;
- (BOOL)deleteCourseInfoByTitle:(NSString*)title withPath:(NSString*)path;
- (NSString*)getAbsolutelyPath:(NSString*)path;
- (NSInteger)getlastRecordID:(NSString*)tableName;
- (BOOL)setPkgListend:(NSString*)title withLibID:(NSInteger)libID;
- (BOOL)setPkgListendwithPath:(NSString*)path;
- (BOOL)getPkgIsListened:(NSString*)title withLibID:(NSInteger)libID;

- (BOOL)addRecordingInfo:(NSString*)fromWaveFilePath withScore:(NSInteger)score;
- (NSMutableArray*)loadRecordingInfo:(NSString*)fromWaveFilePath;
- (BOOL)clearAllRecordingInfo:(NSString*)fromWaveFilePath;
- (NSMutableArray*)loadRecordingInfoByPath:(NSString*)path;
@end
