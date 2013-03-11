//
//  AppDelegate.h
//  ADVNewsstandTemplate
//
//  Created by Tope on 07/03/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsstandDownloader.h"
#import "StoreManager.h"
#import "InterceptorWindow.h"
#import "Publisher.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) InterceptorWindow *window;

@property (nonatomic, strong) NewsstandDownloader * newsstandDownloader;

@property (nonatomic, strong) StoreManager *storeManager;

@property (nonatomic, strong) Publisher *publisher;

+(AppDelegate*)instance;

@end
