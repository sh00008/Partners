//
//  BorrowInfo.m
//  Partners
//
//  Created by DingLi on 13-7-14.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "BorrowInfo.h"

@implementation BorrowInfo

@synthesize version, date, externData;

- (id)init
{
    version = @"1.0";
    externData = @"test";
    return [super init];
}

- (NSString *)stringFromDate:(NSDate *)inDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息 +0000。
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *destDateString = [dateFormatter stringFromDate:inDate];
    [dateFormatter release];
    return destDateString;
    
}

- (NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    [dateFormatter release];
    return destDate;
}

#define InfoSeparator @"~"
- (NSString*) makeBorroinfoString
{
    NSMutableString* str = [[NSMutableString alloc]init];
    date = [NSDate date];
    [str appendString:version];
    [str appendString:InfoSeparator];
    [str appendString:[self stringFromDate:date]];
    [str appendString:InfoSeparator];
    [str appendString:externData];
    return str;
}

- (NSData*) makeBorrowinfoData
{
    NSString* str = [self makeBorroinfoString];
    NSData* dateData = [str dataUsingEncoding: NSASCIIStringEncoding];
    [str release];
    return  dateData;
}

- (NSInteger) parseInfo:(NSString*)filedata
{
    // version
    if ([filedata length] == 0) {
        return 0;
    }
    NSRange versionRange = [filedata rangeOfString:InfoSeparator];
    if (versionRange.location == NSNotFound) {
        return 0;
    }
    version = [filedata substringToIndex:versionRange.location];

    // date
    NSRange dateRange = [filedata rangeOfString:InfoSeparator
                                       options:NSCaseInsensitiveSearch
                                         range:NSMakeRange(versionRange.location+1, [filedata length] - (versionRange.location + versionRange.length))];
    if (dateRange.location == NSNotFound) {
        return 0;
    }
    NSString* dateString = [filedata substringWithRange:NSMakeRange(versionRange.location + versionRange.length, dateRange.location - versionRange.location - 1)];
    date = [self dateFromString:dateString];
    
    // extern data
    NSString* strFind = @"<?xml";
    NSRange edataRange = [filedata rangeOfString:strFind
                                        options:NSCaseInsensitiveSearch
                                          range:NSMakeRange(dateRange.location+1, [filedata length] -(dateRange.location + dateRange.length))];
    if (edataRange.location == NSNotFound) {
        return 0;
    }
    externData = [filedata substringWithRange:NSMakeRange(dateRange.location + dateRange.length, edataRange.location - dateRange.location - 1)];
    return edataRange.location;
}

- (void)dealloc
{
    [super dealloc];
}

@end
