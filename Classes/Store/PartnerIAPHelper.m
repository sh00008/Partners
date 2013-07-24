//
//  PartnerIAPHelper.m
//  Partners
//
//  Created by DingLi on 13-7-22.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "PartnerIAPHelper.h"

@implementation PartnerIAPHelper

+ (PartnerIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static PartnerIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObject:@"com.story.partners.unlockdefaultlibrary"];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
