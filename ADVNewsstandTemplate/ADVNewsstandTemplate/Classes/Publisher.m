//
//  Publisher.m
//  Newsstand
//
//  Created by Carlo Vigiani on 18/Oct/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#define CacheDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#import "Publisher.h"
#import "Reachability.h"
#import <NewsstandKit/NewsstandKit.h>

NSString *PublisherDidUpdateNotification = @"PublisherDidUpdate";
NSString *PublisherFailedUpdateNotification = @"PublisherFailedUpdate";

NSString *PublisherIssuesLocation = @"http://www.appdesignvault.com/appville/issues-type.plist";
NSString *PublisherIssuesLocationiPhone = @"http://www.appdesignvault.com/appville/issues-type.plist";

@interface Publisher ()


@end


@implementation Publisher 

@synthesize ready;

-(id)init {
    
    self = [super init];
    if(self) {
        ready = NO;
        self.issues = nil;
        
        NSLog(@"There IS internet connection");
        
        NSString *issuesCachePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Issues Cached"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:issuesCachePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:issuesCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    
    }
    
    return self;
}

-(NSString*)getIssuesLocation{
    
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? PublisherIssuesLocation : PublisherIssuesLocationiPhone;
}

-(void)getIssuesList {
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        
        NSString* cachedIssuesName = [CacheDirectory stringByAppendingPathComponent:@"cachedIssues.plist"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:cachedIssuesName]) {
            
            self.issues = [NSArray arrayWithContentsOfFile:cachedIssuesName];
            ready = YES;
            [self addIssuesInNewsstand];
            NSLog(@"%@",self.issues);
            [[NSNotificationCenter defaultCenter] postNotificationName:PublisherDidUpdateNotification object:self];
        
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:PublisherFailedUpdateNotification object:self];
        }
        
    } else {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                      NSArray *tmpIssues = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:[self getIssuesLocation]]];
                       
                       if(!tmpIssues) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [[NSNotificationCenter defaultCenter] postNotificationName:PublisherFailedUpdateNotification object:self];
                           });
                          
                       } else {
                           
                           NSString* cachedIssuesName = [CacheDirectory stringByAppendingPathComponent:@"cachedIssues.plist"];
                           
                           [tmpIssues writeToFile:cachedIssuesName atomically:YES];
                           
                           self.issues = [[NSArray alloc] initWithArray:tmpIssues];
                           ready = YES;
                           [self addIssuesInNewsstand];
                           NSLog(@"%@",self.issues);
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [[NSNotificationCenter defaultCenter] postNotificationName:PublisherDidUpdateNotification object:self];
                           });
                       }
                   });
    }
}

-(void)getIssuesListSynchronous {

    NSArray *tmpIssues = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:[self getIssuesLocation]]];
   if(!tmpIssues) {
      
   } else {
       
       self.issues = [[NSArray alloc] initWithArray:tmpIssues];
       ready = YES;
       [self addIssuesInNewsstand];
       NSLog(@"%@",self.issues);
     
   }
}

-(void)addIssuesInNewsstand {
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    [self.issues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *name = [(NSDictionary *)obj objectForKey:@"Name"];
        NKIssue *nkIssue = [nkLib issueWithName:name];
        if(!nkIssue) {
            nkIssue = [nkLib addIssueWithName:name date:[(NSDictionary *)obj objectForKey:@"Date"]];
        }
        
        NSLog(@"Issue: %@",nkIssue);
    }];
}

-(NSInteger)numberOfIssues {
    if([self isReady] && self.issues) {
        return [self.issues count];
    } else {
        return 0;
    }
}

-(NSDictionary *)issueAtIndex:(NSInteger)index {
    return [self.issues objectAtIndex:index];
}

-(NSString *)titleOfIssueAtIndex:(NSInteger)index {
    return [[self issueAtIndex:index] objectForKey:@"Title"];
}

-(NSString *)nameOfIssueAtIndex:(NSInteger)index {
   return [[self issueAtIndex:index] objectForKey:@"Name"];    
}

-(void)setCoverOfIssueAtIndex:(NSInteger)index  completionBlock:(void(^)(UIImage *img))block {
    NSURL *coverURL = [NSURL URLWithString:[[self issueAtIndex:index] objectForKey:@"Cover"]];
    
    NSString *coverFileName = [self getBothLastComponentsFromPath:[coverURL path]];
      
    NSString *coverFilePath = [CacheDirectory stringByAppendingPathComponent:coverFileName];
    UIImage *image = [UIImage imageWithContentsOfFile:coverFilePath];
    if(image) {
        block(image);
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                       ^{
                           NSData *imageData = [NSData dataWithContentsOfURL:coverURL];
                           UIImage *image = [UIImage imageWithData:imageData];
                           if(image) {
                               [imageData writeToFile:coverFilePath atomically:YES];
                               block(image);
                           }
                       });
    }
}

-(UIImage *)coverImageForIssueAtIndex:(NSInteger)index{
    
    NSDictionary* issueInfo = [self.issues objectAtIndex:index];
    NSString *coverPath = [issueInfo objectForKey:@"Cover"];
    NSString *coverName = [self getBothLastComponentsFromPath:coverPath];
    NSString *coverFilePath = [CacheDirectory stringByAppendingPathComponent:coverName];
    UIImage *image = [UIImage imageWithContentsOfFile:coverFilePath];
    return image;
}

-(UIImage *)coverImageForIssue:(NKIssue *)nkIssue {
    NSString *name = nkIssue.name;
    for(NSDictionary *issueInfo in self.issues) {
        if([name isEqualToString:[issueInfo objectForKey:@"Name"]]) {
            NSString *coverPath = [issueInfo objectForKey:@"Cover"];
            NSString *coverName = [self getBothLastComponentsFromPath:coverPath];
            NSString *coverFilePath = [CacheDirectory stringByAppendingPathComponent:coverName];
            UIImage *image = [UIImage imageWithContentsOfFile:coverFilePath];
            return image;
        }
    }
    return nil;
}

-(NSString*)getBothLastComponentsFromPath:(NSString*)path
{
    NSString *filePath = [path lastPathComponent];
    NSArray* components = [path pathComponents];
    if([components count] > 1)
    {
        int count = [components count];
        filePath = [NSString stringWithFormat:@"%@%@", [components objectAtIndex:count - 2], [components objectAtIndex:count - 1]];
    }

    return filePath;
}

-(NSURL *)contentURLForIssueWithName:(NSString *)name {
    __block NSURL *contentURL=nil;
    [self.issues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *aName = [(NSDictionary *)obj objectForKey:@"Name"];
        if([aName isEqualToString:name]) {
            contentURL = [NSURL URLWithString:[(NSDictionary *)obj objectForKey:@"Content"]];
            *stop=YES;
        }
    }];
    NSLog(@"Content URL for issue with name %@ is %@",name,contentURL);
    return contentURL;
}

-(NSString *)downloadPathForIssue:(NKIssue *)nkIssue {
    return [[nkIssue.contentURL path] stringByAppendingPathComponent:@"magazine.pdf"];
}

@end
