//
//  IssueCell.m
//  ADVNewsstandTemplate
//
//  Created by Tope on 07/03/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "IssueCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation IssueCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{
    
    self.coverContainerView.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor;
    self.coverContainerView.layer.borderWidth = 3.0;
    
    //blue
    //UIColor* color = [UIColor colorWithRed:18.0/255 green:132.0/255 blue:195.0/255 alpha:1.0];
    
    //red
    //UIColor* color = [UIColor colorWithRed:212.0/255 green:58.0/255 blue:39.0/255 alpha:1.0];
    
    //orange
    UIColor* color = [UIColor colorWithRed:215.0/255 green:102.0/255 blue:0.0 alpha:1.0]; 
    
    [self.downloadProgress setProgressTintColor:color];
    [self.issueTitleLabel setTextColor:color];
    
    [self.downloadProgress setAlpha:0.0];
}

-(void)updateCellInformationWithStatus:(NKIssueContentStatus)status
{
    if(status==NKIssueContentStatusAvailable) {
        
        [self.actionLabel setText:@"READ"];
        [self.actionLabel setAlpha:1.0];
        [self.actionImageView setAlpha:1.0];
        
        [self.downloadProgress setAlpha:0.0];
        
    } else {
        
        if(status==NKIssueContentStatusDownloading) {
            [self.downloadProgress setAlpha:1.0];
            [self.actionLabel setAlpha:0.0];
            [self.actionImageView setAlpha:0.0];
            
        } else {
            [self.downloadProgress setProgress:0.0];
            [self.downloadProgress setAlpha:0.0];
            
            [self.actionLabel setText:@"DOWNLOAD"];
            [self.actionLabel setAlpha:1.0];
            [self.actionImageView setAlpha:1.0];
        }
        
    }
}


@end
