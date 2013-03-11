//
//  NewsstandDownloader.m
//  Baker
//
//  Created by Tope on 21/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsstandDownloader.h"
#import "SSZipArchive.h"
#import "Publisher.h"

@implementation NewsstandDownloader

@synthesize delegate, publisher;

-(id)initWithPublisher:(Publisher*)thePublisher
{
    self = [super init];
    
    if(self)
    {
        self.publisher = thePublisher;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"com.emityme.appdesignmag.newsstand.notificationReceived" object:nil];
    }
    
    return self;
}

-(void)handleNotification:(NSNotification*)notification
{
    NSLog(@"handleNotification: %@", notification);
    
    [self fetchContent];
}

-(void)fetchContent
{
    [publisher getIssuesListSynchronous];
    
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    
    int numberOfIssues = [publisher numberOfIssues];
    
    
    
    //download latest issue
    NKIssue *nkIssue = [nkLib issueWithName:[publisher nameOfIssueAtIndex:numberOfIssues - 1]]; 
    
    if([nkIssue status] == NKIssueContentStatusNone)
    {
        [self downloadIssueAtIndex:numberOfIssues - 1];
    }
}

-(void)downloadIssueAtIndex:(NSInteger)index {
    
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NSString* issueName = [publisher nameOfIssueAtIndex:index];
    NKIssue *nkIssue = [nkLib issueWithName:issueName];
    
    NSURL *downloadURL = [publisher contentURLForIssueWithName:nkIssue.name];
    
    if(!downloadURL) return;
    
    NSURLRequest *req = [NSURLRequest requestWithURL:downloadURL];
    NKAssetDownload *assetDownload = [nkIssue addAssetWithRequest:req];
    [assetDownload downloadWithDelegate:self];
    [assetDownload setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:index],@"Index",
                                nil]];
}



-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
 
    [delegate updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}


- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
    NSLog(@"connection:(NSURLConnection *)connection didWriteData"); 
    
    [delegate connection:connection didWriteData:bytesWritten totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
    NSLog(@"connection:(NSURLConnection *)connectionDidResumeDownloading");
    
   [delegate connectionDidResumeDownloading:connection totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];

}


- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL
{
    NSLog(@"connection:(NSURLConnection *)connectionDidFinishDownloading");
    NSLog(@"connection:(NSURLConnection *)connectionDidFinishDownloading");
    NKAssetDownload *asset = [connection newsstandAssetDownload];
    NSURL* fileURL = [[asset issue] contentURL];
    
    [SSZipArchive unzipFileAtPath:[destinationURL path] toDestination:[fileURL path]];
    
    // update the Newsstand icon
    UIImage *img = [publisher coverImageForIssue:[asset issue]];
    if(img) {
        [[UIApplication sharedApplication] setNewsstandIconImage:img]; 
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    }

    [delegate connectionDidFinishDownloading:connection destinationURL:destinationURL];
    
}




@end
