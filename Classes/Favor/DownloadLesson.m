//
//  DownloadLesson.m
//  Partners
//
//  Created by JiaLi on 13-7-27.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//
#define STRING_KEY_LESSONFILE @"lessonFile"
#define STRING_KEY_DATAPATH @"dataPath"
#define STRING_KEY_COURSETITLE @"title"
#define STRING_KEY_LESSONPATH @"lessonPath"
#define STRING_KEY_TRYSERVERLIST @"tryServerListIndex"
#define STRING_KEY_FILETYPE @"fileType"
#define STRING_KEY_FILETYPE_XIN @"xin"
#define STRING_KEY_FILETYPE_ISB @"isb"
#define STRING_KEY_FILETYPE_LES @"les"

#import "DownloadLesson.h"
#import "Database.h"
#import "CurrentInfo.h"
#import "VoicePkgInfoObject.h"
#import "Course.h"
#import "Lesson.h"
#import "GTMHTTPFetcher.h"

@implementation DownloadLesson
@synthesize nPositionInCourse, courseParser;
@synthesize delegate;

-(BOOL)checkIsNeedDownload
{
    _bDownloadedXAT = NO;
    _bDownloadedISB = NO;
    _bDownloadedLES = NO;

    Database* db = [Database sharedDatabase];
    
    CurrentInfo* lib = [CurrentInfo sharedCurrentInfo];
    VoiceDataPkgObjectFullInfo* info = [db loadVoicePkgInfoByPath:lib.currentPkgDataPath];
    if (info == nil) {
        return NO;
    }
    [self downloadXINByURL:info.url withTryIndex:-1];
    [self downloadISBByURL:info.url withTryIndex:-1];
    [self downloadLESByURL:info.url withTryIndex:-1];
    if (!_bDownloadedISB || !_bDownloadedXAT) {
        return YES;
    }
    return NO;
}

- (void)downloadXINByURL:(NSString*)url withTryIndex:(NSInteger)tryIndex
{
    Lesson* lesson = (Lesson*)[self.courseParser.course.lessons objectAtIndex:self.nPositionInCourse];
    Database* db = [Database sharedDatabase];
    CurrentInfo* lib = [CurrentInfo sharedCurrentInfo];
    VoiceDataPkgObjectFullInfo* info = [db loadVoicePkgInfoByPath:lib.currentPkgDataPath];
    if (info == nil) {
        return;
    }
    
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    [dic setObject:lesson.file forKey:STRING_KEY_LESSONFILE];
    [dic setObject:info.dataPath forKey:STRING_KEY_DATAPATH];
    [dic setObject:lib.currentPkgDataTitle forKey:STRING_KEY_COURSETITLE];
    [dic setObject:lesson.path forKey:STRING_KEY_LESSONPATH];
    [dic setObject:[NSNumber numberWithInteger:tryIndex] forKey:STRING_KEY_TRYSERVERLIST];
     NSString* dataFile = [lesson.file substringToIndex:[lesson.file length] - 4];
    {
        NSString* xatFile = [dataFile stringByAppendingPathExtension:STRING_KEY_FILETYPE_XIN];
        NSString* xatURLpath = [NSString stringWithFormat:@"%@/%@/%@", url, lesson.path, xatFile];
        
        NSString* xatDatafile = [NSString stringWithFormat:@"%@/%@/%@/%@",info.dataPath, lib.currentPkgDataTitle, lesson.path, xatFile];
        NSLog(@"xatURLPath:  %@", xatURLpath);
        NSLog(@"xatDataPath:  %@", xatDatafile);
        
        if (![fileManager fileExistsAtPath:xatDatafile]) {
            NSURL* url = [NSURL URLWithString:xatURLpath];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setValue:STRING_KEY_FILETYPE_XIN forHTTPHeaderField:@"User-Agent"];
            NSMutableDictionary* userDic = [[[NSMutableDictionary alloc] initWithDictionary:dic] autorelease];
            [userDic setObject:STRING_KEY_FILETYPE_XIN forKey:STRING_KEY_FILETYPE];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
            fetcher.delegate =self;
            fetcher.userData = userDic;
            [fetcher beginFetchWithDelegate:self
                          didFinishSelector:@selector(fetcher:finishedWithData:error:)];
            
            _bDownloadedXAT = NO;
        } else {
            _bDownloadedXAT = YES;
        }
    }
    
}

- (BOOL)isDownloaed {
    return (_bDownloadedXAT && _bDownloadedISB);
}

- (void)downloadISBByURL:(NSString *)url withTryIndex:(NSInteger)tryIndex
{
    Lesson* lesson = (Lesson*)[self.courseParser.course.lessons objectAtIndex:self.nPositionInCourse];
    Database* db = [Database sharedDatabase];
    
    CurrentInfo* lib = [CurrentInfo sharedCurrentInfo];
    VoiceDataPkgObjectFullInfo* info = [db loadVoicePkgInfoByPath:lib.currentPkgDataPath];
    if (info == nil) {
        return;
    }
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    [dic setObject:lesson.file forKey:STRING_KEY_LESSONFILE];
    [dic setObject:info.dataPath forKey:STRING_KEY_DATAPATH];
    [dic setObject:lib.currentPkgDataTitle forKey:STRING_KEY_COURSETITLE];
    [dic setObject:lesson.path forKey:STRING_KEY_LESSONPATH];
    [dic setObject:[NSNumber numberWithInteger:tryIndex] forKey:STRING_KEY_TRYSERVERLIST];
    NSLog(@"try list isb %d", tryIndex);
    
    NSString* dataFile = [lesson.file substringToIndex:[lesson.file length] - 4];
    NSString* isbFile = [dataFile stringByAppendingPathExtension:STRING_KEY_FILETYPE_ISB];
    NSString* isbpath = [NSString stringWithFormat:@"%@/%@/%@", url, lesson.path, isbFile];
    NSString* isbDatafile = [NSString stringWithFormat:@"%@/%@/%@/%@",info.dataPath, lib.currentPkgDataTitle, lesson.path, isbFile];
    NSLog(@"isbPath:  %@", isbpath);
    NSLog(@"isbDataPath:  %@", isbDatafile);
    if (![fileManager fileExistsAtPath:isbDatafile]) {
        NSURL* url = [NSURL URLWithString:isbpath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:STRING_KEY_FILETYPE_ISB forHTTPHeaderField:@"User-Agent"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        fetcher.delegate =self;
        NSMutableDictionary* userDic = [[[NSMutableDictionary alloc] initWithDictionary:dic] autorelease];
        [userDic setObject:STRING_KEY_FILETYPE_ISB forKey:STRING_KEY_FILETYPE];
        fetcher.userData = userDic;
        [fetcher beginFetchWithDelegate:self
                      didFinishSelector:@selector(fetcher:finishedWithData:error:)];
        _bDownloadedISB = NO;
        
    } else {
        _bDownloadedISB = YES;
    }
}

- (void)downloadLESByURL:(NSString *)url withTryIndex:(NSInteger)tryIndex;
{
    Lesson* lesson = (Lesson*)[self.courseParser.course.lessons objectAtIndex:self.nPositionInCourse];
    Database* db = [Database sharedDatabase];
    
    CurrentInfo* lib = [CurrentInfo sharedCurrentInfo];
    VoiceDataPkgObjectFullInfo* info = [db loadVoicePkgInfoByPath:lib.currentPkgDataPath];
    if (info == nil) {
        return;
    }
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    [dic setObject:lesson.file forKey:STRING_KEY_LESSONFILE];
    [dic setObject:info.dataPath forKey:STRING_KEY_DATAPATH];
    [dic setObject:lib.currentPkgDataTitle forKey:STRING_KEY_COURSETITLE];
    [dic setObject:lesson.path forKey:STRING_KEY_LESSONPATH];
    [dic setObject:[NSNumber numberWithInteger:tryIndex] forKey:STRING_KEY_TRYSERVERLIST];
    NSLog(@"try list isb %d", tryIndex);
    
    NSString* dataFile = [lesson.file substringToIndex:[lesson.file length] - 4];
    NSString* isbFile = [dataFile stringByAppendingPathExtension:STRING_KEY_FILETYPE_LES];
    NSString* isbpath = [NSString stringWithFormat:@"%@/%@/%@", url, lesson.path, isbFile];
    NSString* isbDatafile = [NSString stringWithFormat:@"%@/%@/%@/%@",info.dataPath, lib.currentPkgDataTitle, lesson.path, isbFile];
    NSLog(@"isbPath:  %@", isbpath);
    NSLog(@"isbDataPath:  %@", isbDatafile);
    if (![fileManager fileExistsAtPath:isbDatafile]) {
        NSURL* url = [NSURL URLWithString:isbpath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:STRING_KEY_FILETYPE_LES forHTTPHeaderField:@"User-Agent"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        NSMutableDictionary* userDic = [[[NSMutableDictionary alloc] initWithDictionary:dic] autorelease];
        [userDic setObject:STRING_KEY_FILETYPE_LES forKey:STRING_KEY_FILETYPE];
        fetcher.userData = userDic;
        fetcher.delegate =self;
        [fetcher beginFetchWithDelegate:self
                      didFinishSelector:@selector(fetcher:finishedWithData:error:)];
        _bDownloadedLES = NO;
        
    } else {
        _bDownloadedLES = YES;
    }
}

- (void)fetcher:(GTMHTTPFetcher*)fecther finishedWithData:(NSData*)data error:(id)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (error != nil) {
        // try serverlist url
        DownloadServerInfo* info = [DownloadServerInfo sharedDownloadServerInfo];
        if (info != nil) {
            NSMutableArray* serverlist = info.serverList;
            NSMutableDictionary* dic = fecther.userData;
            if (dic != nil) {
                NSNumber* indexNumber = [dic objectForKey:STRING_KEY_TRYSERVERLIST];
                if (indexNumber == nil) {
                     if ([self.delegate respondsToSelector:@selector(downloadfailed:)]) {
                        [self.delegate downloadfailed:self];
                    }
                    //[self removeDownloadingView];
                    //[self addDownloadingFailedView];
                } else {
                    NSInteger index = [indexNumber integerValue];
                    index++;
                    if (index < [serverlist count]) {
                        NSString* url = [serverlist objectAtIndex:index];
                        NSString* fileType = [dic objectForKey:STRING_KEY_FILETYPE];
                        if ([fileType isEqualToString:STRING_KEY_FILETYPE_XIN]) {
                            [self downloadXINByURL:url withTryIndex:index];
                        } else if ([fileType isEqualToString:STRING_KEY_FILETYPE_ISB]) {
                            [self downloadISBByURL:url withTryIndex:index];
                        }
                    } else {
                        if ([self.delegate respondsToSelector:@selector(downloadfailed:)]) {
                            [self.delegate downloadfailed:self];
                        }
                       // [self removeDownloadingView];
                        //[self addDownloadingFailedView];
                    }
                }
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(downloadfailed:)]) {
                [self.delegate downloadfailed:self];
            }
            //[self removeDownloadingView];
            //[self addDownloadingFailedView];
        }
    } else {
        NSMutableDictionary* dic = fecther.userData;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSString* lessonPath = [dic objectForKey:STRING_KEY_LESSONPATH];
        NSString* dataPath = [dic objectForKey:STRING_KEY_DATAPATH];
        NSString* courseTitle = [dic objectForKey:STRING_KEY_COURSETITLE];
        NSString* lessonFile = [dic objectForKey:STRING_KEY_LESSONFILE];
        NSString* xatFile = [lessonFile substringToIndex:[lessonFile length] - 4];
        //NSNumber* indexNumber = [dic objectForKey:STRING_KEY_TRYSERVERLIST];
        //V_NSLog(@"try list %d", [indexNumber integerValue]);
        
        NSString* fileType = [dic objectForKey:STRING_KEY_FILETYPE];
        if ([fileType isEqualToString:STRING_KEY_FILETYPE_XIN]) {
            xatFile = [xatFile stringByAppendingPathExtension:STRING_KEY_FILETYPE_XIN];
            _bDownloadedXAT = YES;
        } else if ([fileType isEqualToString:STRING_KEY_FILETYPE_ISB]) {
            xatFile = [xatFile stringByAppendingPathExtension:STRING_KEY_FILETYPE_ISB];
            _bDownloadedISB = YES;
        } else if ([fileType isEqualToString:STRING_KEY_FILETYPE_LES]) {
            xatFile = [xatFile stringByAppendingPathExtension:STRING_KEY_FILETYPE_LES];
            _bDownloadedLES = YES;
        }
        NSString* path = [NSString stringWithFormat:@"%@/%@/%@",dataPath, courseTitle, lessonPath];
        
        if (![fileManager fileExistsAtPath:path]) {
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString* filePath = [NSString stringWithFormat:@"%@/%@", path, xatFile];
        NSLog(@"write path: %@", filePath);
        [data writeToFile:filePath atomically:YES];
        
        if (_bDownloadedISB && _bDownloadedXAT) {
            if ([self.delegate respondsToSelector:@selector(downloadSucceed:)]) {
                [self.delegate downloadSucceed:self];
            }
          //  [self removeDownloadingView];
          //  [self displayLesson];
        }
    }
    
}

@end
