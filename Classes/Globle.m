//
//  Globle.m
//  Partners
//
//  Created by JiaLi on 13-5-13.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "Globle.h"
#import "VoiceDef.h"

@implementation Globle
+ (CGSize)calcTextHeight:(NSString *)str withWidth:(CGFloat)width;
{
    
    CGSize textSize = {width, 20000.0};
    CGSize size     = [str sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_BUBBLE]
                      constrainedToSize:textSize];
    
    return size;
}

+ (CGSize)calcTextHeight:(NSString *)str withWidth:(CGFloat)width withFontSize:(CGFloat)fontSize;
{
    
    CGSize textSize = {width, 20000.0};
    CGSize size     = [str sizeWithFont:[UIFont systemFontOfSize:fontSize]
                      constrainedToSize:textSize];
    
    return size;
}

+ (void)addSkipBackupAttributeToFile:(NSString *)file {
    if (file == nil || [file length] == 0) {
        return;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.1")) {
        NSURL* URL = [NSURL fileURLWithPath:file];
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
          }
    } else {
        u_int8_t b = 1;
        NSURL *url = [[NSURL alloc] initFileURLWithPath:file];
        setxattr([[url path] fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
        [url release];
    }
}
+ (NSString*)getPkgPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    documentDirectory = [documentDirectory stringByAppendingFormat:@"/%@", STRING_VOICE_PKG_DIR];
    if (![fm fileExistsAtPath:documentDirectory isDirectory:nil]) {
        [fm createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        [Globle addSkipBackupAttributeToFile:documentDirectory];
    }
    return documentDirectory;
}

@end
