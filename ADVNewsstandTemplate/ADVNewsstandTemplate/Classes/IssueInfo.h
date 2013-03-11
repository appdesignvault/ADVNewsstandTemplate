//
//  MagIssue.h
//  Baker
//
//  Created by Tope on 19/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>

@interface IssueInfo : NSObject

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSDate* publicationDate;

@property (nonatomic, strong) NSString* url;

@property (nonatomic, strong) NKIssue* issue;
@end
