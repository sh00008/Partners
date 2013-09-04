//
//  IAPHelper.h
//  Partners
//
//  Created by DingLi on 13-7-22.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductFailedTransactionNotification;
UIKIT_EXTERN NSString *const IAPHelperProductDoneTransactionNotification;
UIKIT_EXTERN NSString *const IAPHelperProductRequestFailedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

@property (nonatomic, retain) NSSet * _productIdentifiers;
@property (nonatomic, retain) NSMutableSet * _purchasedProductIdentifiers;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (BOOL)isExistenceNetwork;

- (void)restoreCompletedTransactions;

- (void)dealloc;
@end
