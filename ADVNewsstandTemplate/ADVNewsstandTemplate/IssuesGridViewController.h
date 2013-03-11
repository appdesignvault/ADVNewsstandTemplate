//
//  ViewController.h
//  ADVNewsstandTemplate
//
//  Created by Tope on 07/03/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface IssuesGridViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NewsstandDownloaderDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) Publisher* publisher;

@end

