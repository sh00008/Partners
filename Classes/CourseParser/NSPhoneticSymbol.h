//
//  NSPhoneticSymbol.h
//  Voice
//
//  Created by li ding on 12-5-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordPhonetic : NSObject
{
    NSString* word;
    NSString* phonetic;
}

@property(nonatomic, retain) NSString* word;
@property(nonatomic, retain) NSString* phonetic;

@end

@interface NSPhoneticSymbol : NSObject
{
    NSDictionary* psDict;
}

- (NSString*) getPhoneticSymbol:(NSString*)str;

@end
