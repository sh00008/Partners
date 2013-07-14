//
//  BorrowInfo.h
//  Partners
//
//  Created by DingLi on 13-7-14.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BorrowInfo : NSObject
{
    NSString* version;
    NSDate* date;
    NSString* externData;
}

@property(nonatomic, retain)NSString* version;
@property(nonatomic, retain)NSDate* date;
@property(nonatomic, retain)NSString* externData;

- (NSString*) makeBorroinfoString;
- (NSData*) makeBorrowinfoData;

- (NSInteger) parseInfo:(NSString*)filedata;

@end
