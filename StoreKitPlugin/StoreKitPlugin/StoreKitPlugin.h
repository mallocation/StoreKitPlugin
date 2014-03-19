//
//  StoreKitPlugin.h
//
//  Created by Curtis Johnson on 2/25/14.
//  Copyright (c) 2014 mallocation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
@interface StoreKitPlugin : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

+(StoreKitPlugin *)sharedInstance;

- (void)requestProducts;
- (void)buyProductWithIdentifier:(NSString *)identifier;
- (void)setCallbackObjectName:(NSString *)objectName;

@end
