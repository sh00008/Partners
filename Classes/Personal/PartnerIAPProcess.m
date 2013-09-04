//
//  PartnerIAPProcess.m
//  Partners
//
//  Created by JiaLi on 13-9-4.
//  Copyright (c) 2013年 JiaLi. All rights reserved.
//

#import "PartnerIAPProcess.h"
#import "PartnerIAPHelper.h"
static PartnerIAPProcess* _iap;

@implementation PartnerIAPProcess
@synthesize status;

+ (PartnerIAPProcess*)sharedInstance
{
	if (_iap == nil) {
		_iap = [[PartnerIAPProcess alloc] init];
	}
	return _iap;
}

- (id)init {
    self = [super init];
    self.status = IAP_STATUS_NONE;
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(provideContentForProductIdentifier:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productFailed:) name:IAPHelperProductFailedTransactionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeTransaction:) name:IAPHelperProductDoneTransactionNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFailed:) name:IAPHelperProductRequestFailedNotification object:nil];
    return self;
}

- (void)start {
    if (![self hasNetwork]) {
        self.status = IAP_STATUS_NETWORK_FAILED;
    } else {
        [self requestIAP];
    }
}

// action
- (void)doCheckNetwork {
    [self status];
}

- (void)doBuyProduct {
    self.status = IAP_STATUS_BUYING_PRODUCT;
    SKProduct * product = (SKProduct *)_products[0];
    [[PartnerIAPHelper sharedInstance] buyProduct:product];
}

- (void)doRestore {
    [[PartnerIAPHelper sharedInstance] restoreCompletedTransactions];   
}

- (void)checkProductBuy:(NSString*)productIdentifier {
    if ([[PartnerIAPHelper sharedInstance] productPurchased:productIdentifier]) {
        self.status = IAP_STATUS_ALREADY_BUYED;
    } else {
        self.status = IAP_STATUS_READY_TO_BUY;
    } 
}

- (NSString*)getPriceString
{
    if ([_products count] < 1) {
        return nil;
    }
    SKProduct * product = (SKProduct *)_products[0];
    [_priceFormatter setLocale:product.priceLocale];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString* price = [_priceFormatter stringFromNumber:product.price];
    return price;
}

- (BOOL)hasNetwork {
    BOOL hasNetWork = [[PartnerIAPHelper sharedInstance] isExistenceNetwork];
    return hasNetWork;
}

- (void)requestIAP {
    self.status = IAP_STATUS_REQUESTING_IAP;
    [[PartnerIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            if ([products count] > 0) {
                _products = products;
                [_products retain];
                SKProduct * product = (SKProduct *)_products[0];
                if ([[PartnerIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
                    self.status = IAP_STATUS_ALREADY_BUYED;                   
                } else {
                    self.status = IAP_STATUS_READY_TO_BUY;
                }
            } else {
                self.status = IAP_STATUS_NO_PRODUCT;
            }
        } else {
            self.status = IAP_STATUS_REQUEST_IAP_FAILED;
        }
    }];
}

- (void)provideContentForProductIdentifier:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
           // [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            
            *stop = YES;
        }
    }];
    
}

- (void)productFailed:(NSNotification *)notification {
    self.status = IAP_STATUS_BUYED_FAILED;
}

- (void)completeTransaction:(NSNotification *)notification {
    SKPaymentTransaction* transaction = notification.object;// (SKPaymentTransaction *)transaction
    if (transaction == nil) {
        return;
    }
    [self checkProductBuy:transaction.payment.productIdentifier];
}

- (void)requestFailed:(NSNotification *)notification {
    self.status = IAP_STATUS_REQUEST_IAP_FAILED;
}

- (void)setStatus:(IAP_STATUS)s
{
    status = s;
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_IAPSTATUS_CHANGED object: [NSNumber numberWithInt:s]];
}


@end
