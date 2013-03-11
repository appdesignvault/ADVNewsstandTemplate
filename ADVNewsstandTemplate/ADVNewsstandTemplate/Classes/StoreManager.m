//
//  StoreManager.m
//  Baker
//
//  Created by Tope on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, \
NSUserDomainMask, YES) objectAtIndex:0]

#define kFreeSubscription @"appville.subscription.free"

#define kFreeSubscriptionReceiptId @"appville.subscription.free.receipt"

#import "StoreManager.h"

@implementation StoreManager

@synthesize purchasing, delegate;

-(BOOL)isSubscribed
{
    id receipt = [[NSUserDefaults standardUserDefaults] objectForKey:kFreeSubscriptionReceiptId];
    
    return (receipt != nil);
     
}

-(void)subscribeToMagazine
{
    if(purchasing == YES) {
        return;
    }
    purchasing=YES;
    
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kFreeSubscription]];
    
    productsRequest.delegate=self;
    [productsRequest start];
}

-(void)requestDidFinish:(SKRequest *)request {
    purchasing = NO;
    NSLog(@"Request: %@",request);
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    purchasing = NO;
    NSLog(@"Request %@ failed with error %@",request,error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    for(SKProduct *product in response.products) {
        
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for(SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
                [self errorWithTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                [self finishedTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"Restored all completed transactions");
}

-(void)finishedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Finished transaction");
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    // save receipt
    [[NSUserDefaults standardUserDefaults] setObject:transaction.transactionIdentifier forKey:kFreeSubscriptionReceiptId];
    // check receipt
    [self checkReceipt:transaction.transactionReceipt];
    
    [delegate subscriptionCompletedWith:YES];
}

-(void)errorWithTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Subscription failure"
                                                    message:[transaction.error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    [alert show];
    
    [delegate subscriptionCompletedWith:NO];
}

-(void)checkReceipt:(NSData *)receipt {
    // save receipt
    NSString *receiptStorageFile = [DocumentsDirectory stringByAppendingPathComponent:@"receipts.plist"];
    NSMutableArray *receiptStorage = [[NSMutableArray alloc] initWithContentsOfFile:receiptStorageFile];
    if(!receiptStorage) {
        receiptStorage = [[NSMutableArray alloc] init];
    }
    [receiptStorage addObject:receipt];
    [receiptStorage writeToFile:receiptStorageFile atomically:YES];
    
    /*
     https://github.com/viggiosoft/NewsstandTutorial
     http://www.viggiosoft.com/blog/blog/2011/10/17/ios-newsstand-tutorial/
     [ReceiptCheck validateReceiptWithData:receipt completionHandler:^(BOOL success,NSString *answer){
     if(success==YES) {
     NSLog(@"Receipt has been validated: %@",answer);
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase OK" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
     [alert show];
     [alert release];
     } else {
     NSLog(@"Receipt not validated! Error: %@",answer);
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Error" message:@"Cannot validate receipt" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
     [alert show];
     [alert release];
     };
     }];*/
    
}



@end
