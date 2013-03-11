//
//  Publisher.h
//  Newsstand
//
//  Created by Carlo Vigiani on 18/Oct/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>

extern  NSString *PublisherDidUpdateNotification;
extern  NSString *PublisherFailedUpdateNotification;

@interface Publisher : NSObject {
    
}

@property (nonatomic,readonly,getter = isReady) BOOL ready;

@property (nonatomic, strong) NSArray *issues;

-(void)addIssuesInNewsstand;
-(void)getIssuesList;
-(void)getIssuesListSynchronous;
-(NSInteger)numberOfIssues;
-(NSString *)titleOfIssueAtIndex:(NSInteger)index;
-(NSString *)nameOfIssueAtIndex:(NSInteger)index;
-(void)setCoverOfIssueAtIndex:(NSInteger)index completionBlock:(void(^)(UIImage *img))block;
-(NSURL *)contentURLForIssueWithName:(NSString *)name;
-(NSString *)downloadPathForIssue:(NKIssue *)nkIssue;
-(UIImage *)coverImageForIssue:(NKIssue *)nkIssue;
-(UIImage *)coverImageForIssueAtIndex:(NSInteger)index;

-(NSString*)getBothLastComponentsFromPath:(NSString*)path;
@end
