//
//  IssueCell.h
//  ADVNewsstandTemplate
//
//  Created by Tope on 07/03/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NewsstandKit/NewsstandKit.h>

@interface IssueCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIView* coverContainerView;

@property (nonatomic, weak) IBOutlet UIImageView* coverImageView;

@property (nonatomic, weak) IBOutlet UILabel* issueTitleLabel;

@property (nonatomic, weak) IBOutlet UILabel* actionLabel;

@property (nonatomic, weak) IBOutlet UIImageView* actionImageView;

@property (nonatomic, weak) IBOutlet UIProgressView* downloadProgress;

-(void)updateCellInformationWithStatus:(NKIssueContentStatus)status;

@end
