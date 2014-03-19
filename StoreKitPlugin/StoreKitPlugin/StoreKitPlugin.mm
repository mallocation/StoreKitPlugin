//
//  StoreKitPlugin.m
//
//  Created by Curtis Johnson on 2/25/14.
//  Copyright (c) 2014 mallocation. All rights reserved.
//

#import "StoreKitPlugin.h"

extern void UnitySendMessage(const char* obj, const char* method, const char* msg);

@implementation StoreKitPlugin
{
    NSSet *_productIdentifiers;
    NSMutableSet *_purchasedProductIdentifiers;
    NSArray *_availableProducts;
    NSString *_callbackObjectName;
}

+(StoreKitPlugin *)sharedInstance {
    static StoreKitPlugin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSSet *identifiers = [NSSet setWithObjects: nil];
        
        sharedInstance = [[StoreKitPlugin alloc] initWithProductIdentifiers:identifiers];
    });
    return sharedInstance;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if (self = [super init]) {
        // store product identifiers
        _productIdentifiers = [NSSet setWithSet:productIdentifiers];
        
        _purchasedProductIdentifiers = [NSMutableSet set];
        
        for (NSString *productIdentifier in _productIdentifiers) {
            BOOL purchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (purchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }
            else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
        // let the payment queue know we are an observer.
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
    return self;
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    [_purchasedProductIdentifiers addObject:productIdentifier];
    
    UnitySendMessage([_callbackObjectName UTF8String],
                     "OnProvideContentForProductIdentifier",
                     [productIdentifier UTF8String]);
}


- (void)requestProducts {
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    request.delegate = self;
    
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Received list of products.");
    
    NSArray *products = response.products;
    
    for (SKProduct *product in products) {
        NSLog(@"Found Product: %@ %@ %0.2f",
              product.productIdentifier,
              product.localizedTitle,
              product.price.floatValue);
    }
    
    NSArray *oldValue = _availableProducts;
    _availableProducts = [products copy];
    [oldValue release];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to receive list of products: %@", [error localizedDescription]);
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)buyProductWithIdentifier:(NSString *)identifier {
   
    NSArray *filter = [_availableProducts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        SKProduct *product = (SKProduct *)evaluatedObject;
        return [product.productIdentifier isEqualToString:identifier];
    }]];
    
    if (filter.count == 0) {
        NSLog(@"Cannot find product with identifier: %@", identifier);
        return;
    }
    
    SKProduct *product = [filter objectAtIndex:0];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)setCallbackObjectName:(NSString *)objectName {
    _callbackObjectName = objectName;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        //
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                // complete the transaction
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                // failed transaction
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                // restore transaction
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

@end

// Helper method used to convert NSStrings into C-style strings.
NSString *SKPlugin_CreateNSString(const char* string) {
    if (string) {
        return [NSString stringWithUTF8String:string];
    } else {
        return [NSString stringWithUTF8String:""];
    }
}

extern "C" {
    
    void _RequestProducts()
    {
        [[StoreKitPlugin sharedInstance] requestProducts];
    }
    
    void _BuyProductWithIdentifier(const char *identifier)
    {
        [[StoreKitPlugin sharedInstance] buyProductWithIdentifier:SKPlugin_CreateNSString(identifier)];
    }    
    
    void _SetCallbackObjectName(const char *name)
    {
        [[StoreKitPlugin sharedInstance] setCallbackObjectName:SKPlugin_CreateNSString(name)];
    }
}

