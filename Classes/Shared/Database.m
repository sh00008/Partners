//
//  Database.m
//  Voice
//
//  Created by JiaLi on 11-8-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "Database.h"
#import <sqlite3.h>
#import "VoiceDef.h"

@implementation Database

static Database* _database;

+ (Database*)sharedDatabase
{
	if (_database == nil) {
		_database = [[Database alloc] init];
	}
	
	return _database;
}

- (id)init
{
	if ((self = [super init])) {
        NSError *error = nil;
        NSFileManager * fileMgr = [NSFileManager defaultManager];
		NSArray* libary =  NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
		NSString *libaryDir =  [libary objectAtIndex:0];
		
        NSString* userdata = PATH_USERDATA;
		NSString *sqlitePath = [libaryDir stringByAppendingString:userdata];
        if (![fileMgr fileExistsAtPath:sqlitePath isDirectory:nil])  
            [fileMgr createDirectoryAtPath:sqlitePath withIntermediateDirectories:YES attributes:nil error:nil];	

        NSString* dirdatabase = DIR_DATABASE;
		sqlitePath = [sqlitePath stringByAppendingPathComponent:dirdatabase];
        if (![fileMgr fileExistsAtPath:sqlitePath isDirectory:nil])  
            [fileMgr createDirectoryAtPath:sqlitePath withIntermediateDirectories:YES attributes:nil error:nil];	

        NSString* databaseName = DATABASE_NAME;
		sqlitePath = [sqlitePath stringByAppendingPathComponent:databaseName];
        if (![fileMgr fileExistsAtPath:sqlitePath isDirectory:nil]) {
            NSString *homePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/%@", dirdatabase];
            
            NSString *copyFromDatabasePath = [homePath stringByAppendingPathComponent:databaseName];
            [fileMgr copyItemAtPath:copyFromDatabasePath toPath:sqlitePath error:&error];
         } else {
           
        }
        int openResult = sqlite3_open([sqlitePath UTF8String], (sqlite3 **)(&_database));
		if (openResult == SQLITE_OK) {
            V_NSLog(@"%@", @"sqlite3_open ok");
 		} else {
            V_NSLog(@"%@", @"sqlite3_open failed");
           
        }
		databaseLock = [[NSLock alloc] init];
        [self createVoicePkgInfoTable];
        [self createVoicePkgcCourseTable];
        [self createLibInfoTable];
	}
	return self;
}

- (BOOL)createVoicePkgInfoTable;
{
    NSString* tableName = STRING_DB_TABLENAME_VOICE_PKG;
    if ([self isExistsTable:tableName]) {
        return NO;
	}
	
	[databaseLock lock];
	sqlite3_stmt *statement;
	BOOL bSuccess = NO;
	NSMutableString  *sql =[[NSMutableString alloc] initWithFormat:@"Create TABLE MAIN.[%@]", tableName];
	[sql appendString:@"("];
	[sql appendFormat:@"[%@] integer PRIMARY KEY UNIQUE NOT NULL",STRING_DB_VOICE_PKG_ID];
	[sql appendFormat:@",[%@] integer",STRING_DB_LIBARY_ID];
	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_TITLE];
	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_PATH];
 	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_COVER];
	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_URL];
 	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_CREATEDATE];
 	[sql appendFormat:@",[%@] integer",STRING_DB_VOICE_IS_LISTENED];
	[sql appendString:@");"];
	
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
	if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
	} else {
		
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
	return bSuccess;
}

- (BOOL)createVoicePkgcCourseTable;
{
    NSString* tableName = STRING_DB_TABLENAME_VOICE_COURSES;
    if ([self isExistsTable:tableName]) {
        return NO;
	}
	
	[databaseLock lock];
	sqlite3_stmt *statement;
	BOOL bSuccess = NO;
	NSMutableString  *sql =[[NSMutableString alloc] initWithFormat:@"Create TABLE MAIN.[%@]", tableName];
	[sql appendString:@"("];
	[sql appendFormat:@"[%@] integer",STRING_DB_VOICE_PKG_ID];
	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_TITLE];
	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_PATH];
 	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_COVER];
	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_URL];
 	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_CREATEDATE];
	[sql appendString:@");"];
	
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
	if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
	} else {
		
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];

	return bSuccess;
}

- (BOOL)createLibInfoTable;
{
    NSString* tableName = STRING_DB_TABLENAME_LIB_INFO;
    if ([self isExistsTable:tableName]) {
        return NO;
	}
	
	[databaseLock lock];
	sqlite3_stmt *statement;
	BOOL bSuccess = NO;
	NSMutableString  *sql =[[NSMutableString alloc] initWithFormat:@"Create TABLE MAIN.[%@]", tableName];
	[sql appendString:@"("];
	[sql appendFormat:@"[%@] integer PRIMARY KEY UNIQUE NOT NULL",STRING_DB_LIBARY_ID];
	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_TITLE];
	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_PATH];
 	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_COVER];
	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_URL];
	//[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_LISENCE];
  	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_PKG_CREATEDATE];
	[sql appendString:@");"];
	
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
	if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
	} else {
		
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];

    [self createLibLisenceTable];
   LibaryInfo* info = [[LibaryInfo alloc] init];
    info.url = STRING_STORE_URL_ADDRESS;
    [self insertLibaryInfo:info];
    
     [info release];

    return bSuccess;
}

- (BOOL)createLibLisenceTable;
{
    NSString* tableName = STRING_DB_TABLENAME_LIB_LISENCE_INFO  ;
    if ([self isExistsTable:tableName]) {
        return NO;
	}
	
	[databaseLock lock];
	sqlite3_stmt *statement;
	BOOL bSuccess = NO;
	NSMutableString  *sql =[[NSMutableString alloc] initWithFormat:@"Create TABLE MAIN.[%@]", tableName];
	[sql appendString:@"("];
	[sql appendFormat:@"[%@] integer PRIMARY KEY UNIQUE NOT NULL",STRING_DB_LIBARY_ID];
	[sql appendFormat:@",[%@] varchar",STRING_DB_VOICE_LISENCE];
	[sql appendFormat:@",[%@] integer",STRING_DB_VOICE_LISENCE_LEN];
	[sql appendString:@");"];
	
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
	if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
	} else {
		
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
    return bSuccess;
}

- (BOOL)createTable;
{
    return YES;
    /*NSString* history = HISTORY_TABLE_NAME;
    if ([self isExistsTable:history]) {
        return NO;
	}
	
	[databaseLock lock];
	sqlite3_stmt *statement;
	BOOL bSuccess = NO;
	NSMutableString  *sql =[[NSMutableString alloc] initWithFormat:@"Create TABLE MAIN.[%@]", history];
	[sql appendString:@"("];
	[sql appendFormat:@"[%@] integer PRIMARY KEY UNIQUE NOT NULL",LIB_LINE_FILEID];
	[sql appendFormat:@",[%@] varchar",LIB_LINE_ORG_NAME];
	[sql appendFormat:@",[%@] varchar",LIB_LINE_USER_NAME];
	[sql appendString:@");"];	
	
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
	if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
	} else {
		
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
	return bSuccess;*/	

}

- (BOOL)isExistsTable:(NSString*)tableName;
{
	BOOL bExist = NO;
	[databaseLock lock];
	sqlite3_stmt *statement;
    NSMutableString  *sql =[[NSMutableString alloc] initWithFormat:@"select name from sqlite_master WHERE type = %@ AND name = '%@'", @"\"table\"", tableName];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			bExist = YES;
		}
    } else {
		
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
	return bExist;
}

- (BOOL)insertVoicePkgInfo:(DownloadDataPkgInfo*)info;
{
 	/*int fileID = [self getFileIDbyPath:book.path];
	if (fileID != -1)
		return NO;
    */
	// insert a new record
	[databaseLock lock];
	sqlite3_stmt *statement;

    NSString* sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@,%@,%@) VALUES(?,?,?,?,?,?,?,?)", STRING_DB_TABLENAME_VOICE_PKG, STRING_DB_VOICE_PKG_ID, STRING_DB_LIBARY_ID, STRING_DB_VOICE_PKG_TITLE, STRING_DB_VOICE_PKG_PATH, STRING_DB_VOICE_PKG_COVER, STRING_DB_VOICE_PKG_URL, STRING_DB_VOICE_PKG_CREATEDATE, STRING_DB_VOICE_IS_LISTENED];
	//NSString  *sql = @"INSERT INTO FileInfo (FileID, FilePath, FileFormat, GroupID, OrderInGroup, FileSourceID, DateAdded, Title, Author, Publisher, PublishDate ,TotalPageCount, FileSize, CoverPath, IDentifier) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
	if (success == SQLITE_OK) {
		//sqlite3_bind_text(statement, 1, [channel.userID UTF8String], -1, SQLITE_TRANSIENT);
		NSInteger i = 2;
        
        sqlite3_bind_int(statement, i, info.libID);
        i++;
        
        // title
		sqlite3_bind_text(statement, i, [info.title UTF8String], -1, SQLITE_TRANSIENT);
		i++;
        
        // path
        NSString* path = [NSString stringWithFormat:@"%d/%@", info.libID, info.title ] ;
		sqlite3_bind_text(statement, i, [path UTF8String], -1, SQLITE_TRANSIENT);
		i++;
        

        // cover
        sqlite3_bind_text(statement, i, [@"" UTF8String], -1, SQLITE_TRANSIENT);
		i++;
        
        // url
        sqlite3_bind_text(statement, i, [info.url UTF8String], -1, SQLITE_TRANSIENT);
		i++;
      
        // createTime
        NSDate* d = [NSDate date];
        sqlite3_bind_text(statement, i, [[d description] UTF8String], -1, SQLITE_TRANSIENT);
		i++;
        
        sqlite3_bind_int(statement, i, 0);
        i++;
        success = sqlite3_step(statement);
		sqlite3_finalize(statement);
		[databaseLock unlock];
		if (success == SQLITE_ERROR) {
			V_NSLog(@"Error: failed to %@", @"insertVoicePkgInfo");
			return NO;
		}
	} else {
		[databaseLock unlock];
		V_NSLog(@"Error: failed to %@", @"insertVoicePkgInfo");
		return NO;
	}
    
    [self insertVoiceCourseInfo:info];
    return YES;
}

- (BOOL)insertVoiceCourseInfo:(DownloadDataPkgInfo*)info;
{
    NSInteger nID = [self getVoicePkgInfoID:info.title withPath:[NSString stringWithFormat:@"%d/%@", info.libID, info.title]];
    if (nID == -1) {
        return NO;
    }
    [databaseLock lock];
    
    for (NSInteger i = 0; i < [info.dataPkgCourseInfoArray count]; i++) {
        DownloadDataPkgCourseInfo* course = [info.dataPkgCourseInfoArray objectAtIndex:i];
        sqlite3_stmt *statement;
        NSString* sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@) VALUES(?,?,?,?,?,?)", STRING_DB_TABLENAME_VOICE_COURSES, STRING_DB_VOICE_PKG_ID, STRING_DB_VOICE_PKG_TITLE, STRING_DB_VOICE_PKG_PATH, STRING_DB_VOICE_PKG_COVER, STRING_DB_VOICE_PKG_URL, STRING_DB_VOICE_PKG_CREATEDATE];
        //NSString  *sql = @"INSERT INTO FileInfo (FileID, FilePath, FileFormat, GroupID, OrderInGroup, FileSourceID, DateAdded, Title, Author, Publisher, PublishDate ,TotalPageCount, FileSize, CoverPath, IDentifier) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
        if (success == SQLITE_OK) {
            NSInteger i = 1;
            // id
            sqlite3_bind_int(statement, i, nID);

            i++;
            // title
            sqlite3_bind_text(statement, i, [course.title UTF8String], -1, SQLITE_TRANSIENT);
            i++;
            
            // path
            sqlite3_bind_text(statement, i, [course.title UTF8String], -1, SQLITE_TRANSIENT);
            i++;
            
            
            // cover
            sqlite3_bind_text(statement, i, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            i++;
            
            // url
            sqlite3_bind_text(statement, i, [course.url UTF8String], -1, SQLITE_TRANSIENT);
            i++;
            
            // createTime
            NSDate* d = [NSDate date];
            sqlite3_bind_text(statement, i, [[d description] UTF8String], -1, SQLITE_TRANSIENT);
            i++;
            
            success = sqlite3_step(statement);
            sqlite3_finalize(statement);
            if (success == SQLITE_ERROR) {
                V_NSLog(@"Error: failed to %@", @"insertVoicePkgInfo");
            }
        } else {
             V_NSLog(@"Error: failed to %@", @"insertVoicePkgInfo");
        }

    }
    [databaseLock unlock];
   
    return YES;
}

- (BOOL)insertLibaryInfo:(LibaryInfo*)info;
{
    [databaseLock lock];
	sqlite3_stmt *statement;
    
    NSString* sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@) VALUES(?,?,?,?,?,?)", STRING_DB_TABLENAME_LIB_INFO, STRING_DB_LIBARY_ID,STRING_DB_VOICE_PKG_TITLE, STRING_DB_VOICE_PKG_PATH, STRING_DB_VOICE_PKG_COVER, STRING_DB_VOICE_PKG_URL, STRING_DB_VOICE_PKG_CREATEDATE];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
	if (success == SQLITE_OK) {
		//sqlite3_bind_text(statement, 1, [channel.userID UTF8String], -1, SQLITE_TRANSIENT);
		NSInteger i = 2;
        
        // title
		sqlite3_bind_text(statement, i, [info.title UTF8String], -1, SQLITE_TRANSIENT);
		i++;
        
        // path
		sqlite3_bind_text(statement, i, [info.title UTF8String], -1, SQLITE_TRANSIENT);
		i++;
        
        
        // cover
        sqlite3_bind_text(statement, i, [@"" UTF8String], -1, SQLITE_TRANSIENT);
		i++;
        
        // url
        sqlite3_bind_text(statement, i, [info.url UTF8String], -1, SQLITE_TRANSIENT);
		i++;
        
        // createTime
        NSDate* d = [NSDate date];
        sqlite3_bind_text(statement, i, [[d description] UTF8String], -1, SQLITE_TRANSIENT);
		i++;
        
        success = sqlite3_step(statement);
		sqlite3_finalize(statement);
		[databaseLock unlock];
		if (success == SQLITE_ERROR) {
			V_NSLog(@"Error: failed to %@", @"insertVoicePkgInfo");
			return NO;
		}
	} else {
		[databaseLock unlock];
		V_NSLog(@"Error: failed to %@", @"insertVoicePkgInfo");
		return NO;
	}
    
    info.libID = [self getlastRecordID:STRING_DB_TABLENAME_LIB_INFO];
    [self insertLibaryLisenceInfo:info];
    return YES;
}

- (BOOL)updateLibaryInfo:(LibaryInfo*)info;
{
    BOOL bResult = YES;
	[databaseLock lock];
	sqlite3_stmt *statement;
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = '%@',%@ = '%@',%@ = '%@' ,%@ = '%@'  WHERE %@ = %d",STRING_DB_TABLENAME_LIB_INFO,  STRING_DB_VOICE_PKG_TITLE, info.title, STRING_DB_VOICE_PKG_PATH, info.path,STRING_DB_VOICE_PKG_COVER, info.cover, STRING_DB_VOICE_PKG_URL, info.url,  STRING_DB_LIBARY_ID, info.libID];
    int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
		sqlite3_finalize(statement);
		[databaseLock unlock];
		if (success == SQLITE_ERROR) {
			bResult = NO;
		}
    } else {
		[databaseLock unlock];
		bResult = NO;
    }
	[sql release];
    [self updateLibaryLisenceInfo:info];
	return bResult;

}

- (BOOL)insertLibaryLisenceInfo:(LibaryInfo *)info
{
    [databaseLock lock];
	sqlite3_stmt *statement;
    
    NSString* sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@) VALUES(?,?,?)", STRING_DB_TABLENAME_LIB_LISENCE_INFO, STRING_DB_LIBARY_ID,STRING_DB_VOICE_LISENCE, STRING_DB_VOICE_LISENCE_LEN];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
	if (success == SQLITE_OK) {
		//sqlite3_bind_text(statement, 1, [channel.userID UTF8String], -1, SQLITE_TRANSIENT);
		NSInteger i = 1;
        sqlite3_bind_int(statement, i, info.libID);
        
		sqlite3_bind_text(statement, i, [info.lisence UTF8String], -1, SQLITE_TRANSIENT);
		i++;
        

		sqlite3_bind_int(statement, i, info.lisenceLen);
		i++;
        
        success = sqlite3_step(statement);
		sqlite3_finalize(statement);
		[databaseLock unlock];
		if (success == SQLITE_ERROR) {
			V_NSLog(@"Error: failed to %@", @"insertVoicePkgInfo");
			return NO;
		}
	} else {
		[databaseLock unlock];
		V_NSLog(@"Error: failed to %@", @"insertVoicePkgInfo");
		return NO;
	}
    return YES;

}
- (BOOL)updateLibaryLisenceInfo:(LibaryInfo *)info
{
    BOOL bResult = YES;
	[databaseLock lock];
	sqlite3_stmt *statement;
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = '%@',%@ = %ld  WHERE %@ = %d",STRING_DB_TABLENAME_LIB_LISENCE_INFO,  STRING_DB_VOICE_LISENCE, info.lisence, STRING_DB_VOICE_LISENCE_LEN, info.lisenceLen,  STRING_DB_LIBARY_ID, info.libID];
    int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
		sqlite3_finalize(statement);
		[databaseLock unlock];
		if (success == SQLITE_ERROR) {
			bResult = NO;
		}
    } else {
		[databaseLock unlock];
		bResult = NO;
    }
	[sql release];
	return bResult;

}


- (LibaryInfo*)getLibaryInfoByID:(NSInteger)libID;
{
     [databaseLock lock];
	LibaryInfo* info = nil;
	sqlite3_stmt *statement;
    NSString  *sql =[[NSString alloc] initWithFormat:@"SELECT %@, %@, %@, %@, %@  FROM %@ WHERE %@ = %d",  STRING_DB_VOICE_PKG_TITLE, STRING_DB_VOICE_PKG_PATH, STRING_DB_VOICE_PKG_COVER, STRING_DB_VOICE_PKG_URL, STRING_DB_VOICE_PKG_CREATEDATE, STRING_DB_TABLENAME_LIB_INFO, STRING_DB_LIBARY_ID, libID];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    NSString* path = nil;
    if (success == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            info = [[LibaryInfo alloc] init];
            char *titleChars = (char *) sqlite3_column_text(statement, 0);
            char *pathChars = (char *) sqlite3_column_text(statement, 1);
            //char *coverChars = (char *) sqlite3_column_text(statement, 2);
            // coverChars;
            char *urlChars = (char *) sqlite3_column_text(statement, 3);
            char *timeChars = (char *) sqlite3_column_text(statement, 4);
            //char *coverChars = (char *) sqlite3_column_text(statement, 2);
            if (pathChars != nil) {
                path = [NSString stringWithUTF8String:pathChars];
                info.path = [NSString stringWithFormat:@"%@", [self getAbsolutelyPath:path]];
                info.cover = [NSString stringWithFormat:@"%@/cover", [self getAbsolutelyPath:path]] ;
            }
            if (titleChars != nil) {
                NSString *title = [NSString stringWithUTF8String:titleChars];
                info.title = [NSString stringWithFormat:@"%@",title];
            }
            if (urlChars != nil) {
                NSString *title = [NSString stringWithUTF8String:urlChars];
                info.url = [NSString stringWithFormat:@"%@",title];
            }
            if (timeChars != nil) {
                NSString *title = [NSString stringWithUTF8String:timeChars];
                info.createTime = [NSString stringWithFormat:@"%@",title];
            }
            break;
 			
		}
    } else {
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
    info.libID = libID;
    [self getLisenceInfo:info];
	return [info autorelease];
}

- (void)getLisenceInfo:(LibaryInfo*)info;
{
    [databaseLock lock];
	sqlite3_stmt *statement;
    NSString  *sql =[[NSString alloc] initWithFormat:@"SELECT %@, %@ FROM %@ WHERE %@ = %d",  STRING_DB_VOICE_LISENCE, STRING_DB_VOICE_LISENCE_LEN, STRING_DB_TABLENAME_LIB_LISENCE_INFO, STRING_DB_LIBARY_ID, info.libID];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            char *lisenceChars = (char *) sqlite3_column_text(statement, 0);
            long length = sqlite3_column_int64(statement, 1);
            if (lisenceChars != nil) {
                NSString *title = [NSString stringWithUTF8String:lisenceChars];
                info.lisence  = [NSString stringWithFormat:@"%@",title];
            }
            info.lisenceLen = length;
            break;
 			
		}
    } else {
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
}

- (BOOL)deleteLibaryInfo:(NSInteger)libID {
    BOOL bOK = YES;
	[databaseLock lock];
	sqlite3_stmt *statement;
    NSString  *sql =[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE  %@ = %d", STRING_DB_TABLENAME_LIB_INFO,STRING_DB_LIBARY_ID, libID];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
		if (success == SQLITE_ERROR) {
			bOK = NO;
		}
    } else {
		bOK = NO;
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
    [self deleteLibaryLisenceInfo:libID];
	return bOK;
}

- (BOOL)deleteLibaryLisenceInfo:(NSInteger)libID {
    BOOL bOK = YES;
	[databaseLock lock];
	sqlite3_stmt *statement;
    NSString  *sql =[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE  %@ = %d", STRING_DB_TABLENAME_LIB_LISENCE_INFO,STRING_DB_LIBARY_ID, libID];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
		if (success == SQLITE_ERROR) {
			bOK = NO;
		}
    } else {
		bOK = NO;
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
	return bOK;

}

- (NSMutableArray*)loadVoicePkgInfo;
{
   	[databaseLock lock];
	NSMutableArray * arrResult = [[NSMutableArray alloc] init];
	sqlite3_stmt *statement;
    NSMutableString  *sql =[[NSMutableString alloc] initWithFormat:@"SELECT %@, %@ FROM %@",STRING_DB_VOICE_PKG_PATH, STRING_DB_VOICE_PKG_TITLE, STRING_DB_TABLENAME_VOICE_PKG];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            VoiceDataPkgObject* pkgObject = [[VoiceDataPkgObject alloc] init];
            char *pathChars = (char *) sqlite3_column_text(statement, 0);
            char *titleChars = (char *) sqlite3_column_text(statement, 1);
            //char *coverChars = (char *) sqlite3_column_text(statement, 2);
            NSString* path = nil;
            if (pathChars != nil) {
                path = [NSString stringWithUTF8String:pathChars];
                pkgObject.dataPath = [NSString stringWithFormat:@"%@", [self getAbsolutelyPath:path]];
                pkgObject.dataCover = [NSString stringWithFormat:@"%@/cover", [self getAbsolutelyPath:path]] ;
            }
            if (titleChars != nil) {
                NSString *title = [NSString stringWithUTF8String:titleChars];
                pkgObject.dataTitle = [NSString stringWithFormat:@"%@",title];
                NSInteger nID = [self getVoicePkgInfoID:title withPath:path];
                if (nID != -1) {
                    NSMutableArray* courseTitleArray = [self getCourseTitleByID:nID];
                    if ([courseTitleArray count] > 0) {
                        pkgObject.dataPkgCourseTitleArray = courseTitleArray ;
                    }
                }
                
            }
            [arrResult addObject:pkgObject];
 			
		}
    } else {
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
 	return arrResult;
}

- (NSMutableArray*)loadLibaryInfo;
{
    [databaseLock lock];
	NSMutableArray * arrResult = [[NSMutableArray alloc] init];
	sqlite3_stmt *statement;
    NSMutableString  *sql =[[NSMutableString alloc] initWithFormat:@"SELECT %@, %@, %@, %@, %@ FROM %@",STRING_DB_LIBARY_ID,  STRING_DB_VOICE_PKG_TITLE,STRING_DB_VOICE_PKG_PATH,STRING_DB_VOICE_PKG_URL, STRING_DB_VOICE_PKG_CREATEDATE, STRING_DB_TABLENAME_LIB_INFO];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            LibaryInfo* object = [[LibaryInfo alloc] init];
            NSInteger index = 0;
            int libID = sqlite3_column_int(statement, index);
            index++;
            char *titleChars = (char *) sqlite3_column_text(statement, index);
            index++;
            char *pathChars = (char *) sqlite3_column_text(statement, index);
            index++;
            //char *coverChars = (char *) sqlite3_column_text(statement, 2);
            // coverChars;
            char *urlChars = (char *) sqlite3_column_text(statement, index);
            index++;
            //char *lisenceChars = (char *) sqlite3_column_text(statement, index);
            //index++;
            char *timeChars = (char *) sqlite3_column_text(statement, index);
            index++;
            //char *coverChars = (char *) sqlite3_column_text(statement, 2);
            if (pathChars != nil) {
                NSString *path = [NSString stringWithUTF8String:pathChars];
                object.path = [NSString stringWithFormat:@"%@", [self getAbsolutelyPath:path]];
                object.cover = [NSString stringWithFormat:@"%@/cover", [self getAbsolutelyPath:path]] ;
            }
            if (titleChars != nil) {
                NSString *title = [NSString stringWithUTF8String:titleChars];
                object.title = [NSString stringWithFormat:@"%@",title];
            }
            if (urlChars != nil) {
                NSString *title = [NSString stringWithUTF8String:urlChars];
                object.url = [NSString stringWithFormat:@"%@",title];
            }
            /*if (lisenceChars != nil) {
                NSString *title = [NSString stringWithUTF8String:lisenceChars];
                object.lisence = [NSString stringWithFormat:@"%@",title];
            }*/
            if (timeChars != nil) {
                NSString *title = [NSString stringWithUTF8String:timeChars];
                object.createTime = [NSString stringWithFormat:@"%@",title];
            }
            object.libID = libID;
            [arrResult addObject:object];
            [object release];
		}
    } else {
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
 	return arrResult;
}
- (NSInteger)getVoicePkgInfoID:(NSString*)title withPath:(NSString*)path;
{
	//[databaseLock lock];
	int uniqueId = -1;
	sqlite3_stmt *statement;
    NSString  *sql =[[NSString alloc] initWithFormat:@"SELECT %@ FROM %@ WHERE %@ = '%@' AND %@ = '%@'", STRING_DB_VOICE_PKG_ID, STRING_DB_TABLENAME_VOICE_PKG, STRING_DB_VOICE_PKG_TITLE, title, STRING_DB_VOICE_PKG_PATH, path];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			uniqueId = sqlite3_column_int(statement, 0);
		}
    } else {
		uniqueId = -1;
	}
	sqlite3_finalize(statement);
	[sql release];
	//[databaseLock unlock];
	return uniqueId;
}

- (VoiceDataPkgObjectFullInfo*)loadVoicePkgInfo:(DownloadDataPkgInfo*)downloadinfo;
{
    NSString* title = downloadinfo.title;
    
    [databaseLock lock];
	VoiceDataPkgObjectFullInfo* info = nil;
	sqlite3_stmt *statement;
    NSString  *sql =[[NSString alloc] initWithFormat:@"SELECT %@, %@, %@, %@, %@  FROM %@ WHERE %@ = '%@' AND %@ = %d",  STRING_DB_VOICE_PKG_TITLE, STRING_DB_VOICE_PKG_PATH, STRING_DB_VOICE_PKG_COVER, STRING_DB_VOICE_PKG_URL, STRING_DB_VOICE_PKG_CREATEDATE, STRING_DB_TABLENAME_VOICE_PKG, STRING_DB_VOICE_PKG_TITLE, title, STRING_DB_LIBARY_ID, downloadinfo.libID];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    NSString* path = nil;
    if (success == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            info = [[VoiceDataPkgObjectFullInfo alloc] init];
            char *titleChars = (char *) sqlite3_column_text(statement, 0);
            char *pathChars = (char *) sqlite3_column_text(statement, 1);
            //char *coverChars = (char *) sqlite3_column_text(statement, 2);
            // coverChars;
            char *urlChars = (char *) sqlite3_column_text(statement, 3);
            char *timeChars = (char *) sqlite3_column_text(statement, 4);
            //char *coverChars = (char *) sqlite3_column_text(statement, 2);
            if (pathChars != nil) {
                path = [NSString stringWithUTF8String:pathChars];
                info.dataPath = [NSString stringWithFormat:@"%@", [self getAbsolutelyPath:path]];
                info.dataCover = [NSString stringWithFormat:@"%@/cover", [self getAbsolutelyPath:path]] ;
            }
            if (titleChars != nil) {
                NSString *title = [NSString stringWithUTF8String:titleChars];
                info.dataTitle = [NSString stringWithFormat:@"%@",title];
            }
            if (urlChars != nil) {
                NSString *title = [NSString stringWithUTF8String:urlChars];
                info.url = [NSString stringWithFormat:@"%@",title];
            }
            if (timeChars != nil) {
                NSString *title = [NSString stringWithUTF8String:timeChars];
                info.createTime = [NSString stringWithFormat:@"%@",title];
            }
            break;
 			
		}
    } else {
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
    NSInteger nID = [self getVoicePkgInfoID:title withPath:path];
    if (nID != -1) {
        NSMutableArray* courseTitleArray = [self getCourseTitleByID:nID];
        if ([courseTitleArray count] > 0) {
            info.dataPkgCourseTitleArray = courseTitleArray ;
        }
    }
	return [info autorelease];
    
}

- (VoiceDataPkgObjectFullInfo*)loadVoicePkgInfoByTitle:(NSString*)title withLibID:(NSInteger)libID;
{
    [databaseLock lock];
	VoiceDataPkgObjectFullInfo* info = nil;
	sqlite3_stmt *statement;
    NSString  *sql =[[NSString alloc] initWithFormat:@"SELECT %@, %@, %@, %@, %@  FROM %@ WHERE %@ = '%@'",  STRING_DB_VOICE_PKG_TITLE, STRING_DB_VOICE_PKG_PATH, STRING_DB_VOICE_PKG_COVER, STRING_DB_VOICE_PKG_URL, STRING_DB_VOICE_PKG_CREATEDATE, STRING_DB_TABLENAME_VOICE_PKG, STRING_DB_VOICE_PKG_TITLE, title];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    NSString* path = nil;
    if (success == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            info = [[VoiceDataPkgObjectFullInfo alloc] init];
            char *titleChars = (char *) sqlite3_column_text(statement, 0);
            char *pathChars = (char *) sqlite3_column_text(statement, 1);
            //char *coverChars = (char *) sqlite3_column_text(statement, 2);
           // coverChars;
            char *urlChars = (char *) sqlite3_column_text(statement, 3);
            char *timeChars = (char *) sqlite3_column_text(statement, 4);
             //char *coverChars = (char *) sqlite3_column_text(statement, 2);
            if (pathChars != nil) {
                path = [NSString stringWithUTF8String:pathChars];
                if (![path isEqualToString:[NSString stringWithFormat:@"%d/%@", libID, title]]) {
                    continue;
                }
                info.dataPath = [NSString stringWithFormat:@"%@", [self getAbsolutelyPath:path]];
                info.dataCover = [NSString stringWithFormat:@"%@/cover", [self getAbsolutelyPath:path]] ;
            }
            if (titleChars != nil) {
                NSString *title = [NSString stringWithUTF8String:titleChars];
                info.dataTitle = [NSString stringWithFormat:@"%@",title];
            }
            if (urlChars != nil) {
                NSString *title = [NSString stringWithUTF8String:urlChars];
                info.url = [NSString stringWithFormat:@"%@",title];
            }
            if (timeChars != nil) {
                NSString *title = [NSString stringWithUTF8String:timeChars];
                info.createTime = [NSString stringWithFormat:@"%@",title];
            }
            break;
 			
		}
    } else {
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
    NSInteger nID = [self getVoicePkgInfoID:title withPath:path];
    if (nID != -1) {
        NSMutableArray* courseTitleArray = [self getCourseTitleByID:nID];
        if ([courseTitleArray count] > 0) {
            info.dataPkgCourseTitleArray = courseTitleArray ;
        }
    }
	return [info autorelease];

}

- (VoiceDataPkgObjectFullInfo*)loadVoicePkgInfoByPath:(NSString*)path;
{
    [databaseLock lock];
	VoiceDataPkgObjectFullInfo* info = nil;
	sqlite3_stmt *statement;
    NSString  *sql =[[NSString alloc] initWithFormat:@"SELECT %@, %@, %@, %@, %@  FROM %@ WHERE %@ = '%@'",  STRING_DB_VOICE_PKG_TITLE , STRING_DB_VOICE_PKG_PATH, STRING_DB_VOICE_PKG_COVER, STRING_DB_VOICE_PKG_URL, STRING_DB_VOICE_PKG_CREATEDATE, STRING_DB_TABLENAME_VOICE_PKG, STRING_DB_VOICE_PKG_PATH, path];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    NSString* title = nil;
    if (success == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            info = [[VoiceDataPkgObjectFullInfo alloc] init];
            char *titleChars = (char *) sqlite3_column_text(statement, 0);
            char *pathChars = (char *) sqlite3_column_text(statement, 1);
            //char *coverChars = (char *) sqlite3_column_text(statement, 2);
            // coverChars;
            char *urlChars = (char *) sqlite3_column_text(statement, 3);
            char *timeChars = (char *) sqlite3_column_text(statement, 4);
            //char *coverChars = (char *) sqlite3_column_text(statement, 2);
            if (pathChars != nil) {
                NSString *path = [NSString stringWithUTF8String:pathChars];
                info.dataPath = [NSString stringWithFormat:@"%@", [self getAbsolutelyPath:path]];
                info.dataCover = [NSString stringWithFormat:@"%@/cover", [self getAbsolutelyPath:path]] ;
            }
            if (titleChars != nil) {
                NSString *title = [NSString stringWithUTF8String:titleChars];
                info.dataTitle = [NSString stringWithFormat:@"%@",title];
            }
            if (urlChars != nil) {
                NSString *title = [NSString stringWithUTF8String:urlChars];
                info.url = [NSString stringWithFormat:@"%@",title];
            }
            if (timeChars != nil) {
                title = [NSString stringWithUTF8String:timeChars];
                info.createTime = [NSString stringWithFormat:@"%@",title];
            }
            break;
 			
		}
    } else {
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
    NSInteger nID = [self getVoicePkgInfoID:title withPath:path];
    if (nID != -1) {
        NSMutableArray* courseTitleArray = [self getCourseTitleByID:nID];
        if ([courseTitleArray count] > 0) {
            info.dataPkgCourseTitleArray = courseTitleArray ;
        }
    }
	return [info autorelease];
}
- (NSMutableArray*)getCourseTitleByID:(NSInteger)nID;
{
   // [databaseLock lock];
    NSMutableArray* courseTitleArray = [[ NSMutableArray alloc] init];
	sqlite3_stmt *statement;
    NSString  *sql =[[NSString alloc] initWithFormat:@"SELECT %@ FROM %@ WHERE %@ = %d",  STRING_DB_VOICE_PKG_TITLE, STRING_DB_TABLENAME_VOICE_COURSES, STRING_DB_VOICE_PKG_ID, nID];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            char *titleChars = (char *) sqlite3_column_text(statement, 0);
             if (titleChars != nil) {
                NSString *title = [NSString stringWithUTF8String:titleChars];
                [courseTitleArray addObject:[NSString stringWithFormat:@"%@",title]];
            }
		}
    } else {
	}
	sqlite3_finalize(statement);
	[sql release];
	//[databaseLock unlock];
	return [courseTitleArray autorelease];
}

- (BOOL)deleteVoicePkgInfoByTitle:(NSString*)title withLibID:(NSInteger)libID;
{
    [self deleteCourseInfoByTitle:title withPath:[NSString stringWithFormat:@"%d/%@",libID, title ]];
    BOOL bOK = YES;
	[databaseLock lock];
	sqlite3_stmt *statement;
    NSString  *sql =[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND  %@ = %d", STRING_DB_TABLENAME_VOICE_PKG, STRING_DB_VOICE_PKG_TITLE, title,STRING_DB_LIBARY_ID, libID];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
		if (success == SQLITE_ERROR) {
			bOK = NO;
		}
    } else {
		bOK = NO;
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
	return bOK;

}

- (BOOL)deleteCourseInfoByTitle:(NSString*)title withPath:(NSString *)path
{
    NSInteger nID = [self getVoicePkgInfoID:title withPath:path];
    if (nID == -1) {
        return NO;
    }
    
    BOOL bOK = YES;
	[databaseLock lock];
	sqlite3_stmt *statement;
    NSString  *sql =[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@ = %d", STRING_DB_TABLENAME_VOICE_COURSES, STRING_DB_VOICE_PKG_ID, nID];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
		if (success == SQLITE_ERROR) {
			bOK = NO;
		}
    } else {
		bOK = NO;
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
	return bOK;
}

- (NSString*)getPathRelative:(NSString*)path;
{
	if (path == nil) {
		return nil;
	}
    
	NSString *filePath = [NSString stringWithString:path];
	NSRange rangeDocument = [filePath rangeOfString:SUB_DIR_DOCUMENT options:NSBackwardsSearch];
	if (rangeDocument.location != NSNotFound){
		NSInteger nSubFromIndex = rangeDocument.location + rangeDocument.length;
		if (nSubFromIndex < filePath.length) {
			filePath = [filePath substringFromIndex:nSubFromIndex];
		}
        
        return filePath;
	}
    
	rangeDocument = [filePath rangeOfString:SUB_DIR_CACHE options:NSBackwardsSearch];
	if (rangeDocument.location != NSNotFound){
		NSInteger nSubFromIndex = rangeDocument.location + rangeDocument.length;
		if (nSubFromIndex < filePath.length) {
			filePath = [filePath substringFromIndex:nSubFromIndex];
		}
	}
    
	return filePath;
}

- (NSString*)getAbsolutelyPath:(NSString*)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    documentDirectory = [documentDirectory stringByAppendingFormat:@"/%@", STRING_VOICE_PKG_DIR];
    
     
    documentDirectory = [documentDirectory stringByAppendingFormat:@"/%@", path];
    
    NSString* absolutePath = [NSString stringWithFormat:@"%@", documentDirectory];
    return absolutePath;
}

- (NSInteger)getlastRecordID:(NSString*)tableName {
	BOOL bResult = YES;
	NSInteger nID = -1;
	[databaseLock lock];
	sqlite3_stmt *statement;
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT last_insert_rowid() FROM %@ ",tableName ];
    int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
		nID =  sqlite3_column_int(statement, 0);
		sqlite3_finalize(statement);
		[databaseLock unlock];
		if (success == SQLITE_ERROR) {
			bResult = NO;
			nID = -1;
		}
    } else {
		[databaseLock unlock];
		bResult = NO;
		nID = -1;
	}
	[sql release];
	return nID;
}

- (BOOL)setPkgListend:(NSString*)title withLibID:(NSInteger)libID;
{
	BOOL bResult = YES;
	[databaseLock lock];
	sqlite3_stmt *statement;
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = %d WHERE %@ = '%@' AND  %@ = %d",STRING_DB_TABLENAME_VOICE_PKG,  STRING_DB_VOICE_IS_LISTENED, 1,  STRING_DB_VOICE_PKG_TITLE, title, STRING_DB_LIBARY_ID, libID];
    int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
		sqlite3_finalize(statement);
		[databaseLock unlock];
		if (success == SQLITE_ERROR) {
			bResult = NO;
		}
    } else {
		[databaseLock unlock];
		bResult = NO;
    }
	[sql release];
	return bResult;
}

- (BOOL)setPkgListendwithPath:(NSString*)path;
{
	BOOL bResult = YES;
	[databaseLock lock];
	sqlite3_stmt *statement;
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = %d WHERE %@ = '%@'",STRING_DB_TABLENAME_VOICE_PKG,  STRING_DB_VOICE_IS_LISTENED, 1,  STRING_DB_VOICE_PKG_PATH, path];
    int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    if (success == SQLITE_OK) {
		success = sqlite3_step(statement);
		sqlite3_finalize(statement);
		[databaseLock unlock];
		if (success == SQLITE_ERROR) {
			bResult = NO;
		}
    } else {
		[databaseLock unlock];
		bResult = NO;
    }
	[sql release];
	return bResult;
}

- (BOOL)getPkgIsListened:(NSString*)title withLibID:(NSInteger)libID;
{
    [databaseLock lock];
	sqlite3_stmt *statement;
    NSString  *sql =[[NSString alloc] initWithFormat:@"SELECT %@ FROM %@ WHERE %@ = '%@' AND %@ = %d",  STRING_DB_VOICE_IS_LISTENED,STRING_DB_TABLENAME_VOICE_PKG, STRING_DB_VOICE_PKG_TITLE, title, STRING_DB_LIBARY_ID, libID];
	int success = sqlite3_prepare_v2((sqlite3 *)_database, [sql UTF8String], -1, &statement, NULL);
    NSInteger bListened = 0;
    if (success == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            bListened = sqlite3_column_int(statement, 0);
             break;
 			
		}
    } else {
	}
	sqlite3_finalize(statement);
	[sql release];
	[databaseLock unlock];
    return bListened;
}
@end
