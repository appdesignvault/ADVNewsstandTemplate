//
//  NewsstandDownloader.h
//  Baker
//
//  Created by Tope on 21/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>
#import "IssueInfo.h"
#import "Publisher.h"

@protocol NewsstandDownloaderDelegate;

@interface NewsstandDownloader : NSObject <NSURLConnectionDownloadDelegate>

-(id)initWithPublisher:(Publisher*)thePublisher;

-(void)handleNotification:(NSNotification*)notification;

-(void)fetchContent;

@property (nonatomic, assign) id<NewsstandDownloaderDelegate> delegate;

@property (nonatomic, strong) Publisher* publisher;

-(void)downloadIssueAtIndex:(NSInteger)index;

@end

@protocol NewsstandDownloaderDelegate <NSObject>

-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes;

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes;

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes;


- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL;

@end
