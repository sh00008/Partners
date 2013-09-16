//
//  CurrentLibInfo.m
//  Partners
//
//  Created by JiaLi on 13-7-5.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "CurrentInfo.h"
#import "VoiceDef.h"
#import "ISaybEncrypt2.h"
#import "Database.h"
#import "GTMHTTPFetcher.h"
#import "Globle.h"
@implementation DownloadLicense
@synthesize libID, delegate;
- (void)getDeviceID
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documentDirectory = [Globle getPkgPath];
    documentDirectory = [documentDirectory stringByAppendingFormat:@"/%d", self.libID];
    documentDirectory = [documentDirectory stringByAppendingFormat:@"/%@", @"ServerRequest.dat"];
    if ([fm fileExistsAtPath:documentDirectory]) {
        // parse
        const char* licenseFile = [documentDirectory cStringUsingEncoding:NSUTF8StringEncoding];
        FILE* file = fopen(licenseFile, "rb");
        fseek(file, 0, SEEK_END);
        int length = ftell(file);
        fseek(file, 0, SEEK_SET);
        unsigned char* fileData = new unsigned char[length];
        fread(fileData, 1, length, file);
        char userName[256] = { '\0' };
        unsigned char* deviceID = nil;
        int lenDevceID = 0;
        ParseServerUserLicense(fileData, length, userName, &deviceID, lenDevceID);
        NSString* libUserName = [[NSString alloc] initWithCString:userName encoding:-2147482062];
        NSString* libLisence = [[NSString alloc] initWithBytes:deviceID length:lenDevceID encoding:NSUTF8StringEncoding];
        NSInteger deviceIDLen = lenDevceID;
        Database* db = [Database sharedDatabase];
        LibaryInfo* info = [db getLibaryInfoByID:self.libID];
        info.title = libUserName;
        info.lisence = libLisence;
        info.lisenceLen = deviceIDLen;
        [db updateLibaryInfo:info];
        fclose(file);
        delete[] fileData;
        delete[] deviceID;
        [libUserName release];
        [libLisence release];
    }
}

- (void)checkLisence:(NSString*)fromUrl;
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documentDirectory = [Globle getPkgPath];
    
    documentDirectory = [documentDirectory stringByAppendingFormat:@"/%d", self.libID];
    if (![fm fileExistsAtPath:documentDirectory isDirectory:nil])
        [fm createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString* devicePath = [documentDirectory stringByAppendingFormat:@"%@", @"ServerRequest.dat"];
    if (![fm fileExistsAtPath:devicePath isDirectory:nil]) {
        if (fromUrl != nil) {
            NSString* urlstr = [NSString stringWithFormat:@"%@ServerRequest.dat", fromUrl];
            NSURL* url = [NSURL URLWithString:urlstr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setValue:@"device" forHTTPHeaderField:@"User-Agent"];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
            fetcher.userData = @"device";
            [fetcher beginFetchWithDelegate:self
                          didFinishSelector:@selector(fetcher:finishedWithData:error:)];
        }
    } else {
        [self getDeviceID];
        [self.delegate didDownload:nil withDownloadLicense:self];
    }
    
}

- (void)fetcher:(GTMHTTPFetcher*)fecther finishedWithData:(NSData*)data error:(id)error
{
 	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    V_NSLog(@"fecther : %@", [fecther description]);
    V_NSLog(@"error : %@", [error description]);
    if (error != nil) {
    } else {
        [self finishDeviceData:data];
    }
    if (self.delegate != nil) {
        [self.delegate didDownload:error withDownloadLicense:self];
    }
}

- (void)finishDeviceData:(NSData*)data
{
    NSString *documentDirectory = [Globle getPkgPath];
    documentDirectory = [documentDirectory stringByAppendingFormat:@"/%d", self.libID];
    documentDirectory = [documentDirectory stringByAppendingFormat:@"%@", @"ServerRequest.dat"];
    [data writeToFile:documentDirectory atomically:YES];
    [self getDeviceID];
}

- (void)dealloc
{
    self.delegate = nil;
    [super dealloc];
}
@end


@implementation CurrentInfo
@synthesize currentPkgDataPath, currentPkgDataTitle, currentLibID;
static CurrentInfo* _currentInfo;

+ (CurrentInfo*)sharedCurrentInfo;
{
	if (_currentInfo == nil) {
		_currentInfo = [[CurrentInfo alloc] init];
        _currentInfo.currentLibID = -1;
	}
	
	return _currentInfo;
}

+ (void)releaseCurrentInfo
{
    if (_currentInfo != nil) {
        [_currentInfo release];
        _currentInfo = nil;
    }
}

- (void)dealloc
{
    [self.currentPkgDataPath release];
    [self.currentPkgDataTitle release];
    [super dealloc];
}

@end
