//
//  StoreManager.h
//  Baker
//
//  Created by Tope on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol StoreManagerDelegate;

@interface StoreManager : NSObject <SKPaymentTransactionObserver, SKRequestDelegate, SKProductsRequestDelegate>

@property (nonatomic, assign) BOOL purchasing;

-(void)subscribeToMagazine;

-(BOOL)isSubscribed;

@property (nonatomic, assign) id<StoreManagerDelegate> delegate;

@end


@protocol StoreManagerDelegate <NSObject>

-(void)subscriptionCompletedWith:(BOOL)success;

@end