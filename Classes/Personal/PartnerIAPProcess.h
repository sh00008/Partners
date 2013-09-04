//
//  PartnerIAPProcess.h
//  Partners
//
//  Created by JiaLi on 13-9-4.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTIFICATION_IAPSTATUS_CHANGED @"IAPStatusChangedNofication"
enum {
    IAP_STATUS_NONE = 0,
    IAP_STATUS_CHECKING_NETWORK = 1,
    IAP_STATUS_NETWORK_FAILED,
    IAP_STATUS_REQUESTING_IAP,
    IAP_STATUS_REQUEST_IAP_FAILED,
    IAP_STATUS_NO_PRODUCT,
    IAP_STATUS_READY_TO_BUY,
    IAP_STATUS_BUYING_PRODUCT,
    IAP_STATUS_ALREADY_BUYED,
    IAP_STATUS_BUYED_FAILED
};
typedef NSInteger IAP_STATUS;


@interface PartnerIAPProcess : NSObject {
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
}

@property (nonatomic) IAP_STATUS status;
+ (PartnerIAPProcess *)sharedInstance;

- (void)start;


// action
- (void)doCheckNetwork;
- (void)doBuyProduct;
- (void)doRestore;
- (NSString*)getPriceString;


@end
