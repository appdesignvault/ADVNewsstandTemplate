//
//  ViewController.m
//  ADVNewsstandTemplate
//
//  Created by Tope on 07/03/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "IssuesGridViewController.h"
#import "IssueCell.h"
#import "BakerBook.h"
#import "BakerViewController.h"

@interface IssuesGridViewController ()

@end

@implementation IssuesGridViewController

- (void)viewDidLoad
{
    self.publisher = [[AppDelegate instance] publisher];
    
    UINib *cellNib = [UINib nibWithNibName:@"IssueCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"IssueCell"];
    
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    
    [self.collectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    NewsstandDownloader* downloader = [[AppDelegate instance] newsstandDownloader];
    [downloader setDelegate:self];
    
    [self loadIssues];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadIssues) name:@"com.emityme.appdesignmag.newsstand.returnFromBackground" object:nil];
    
    UIBarButtonItem* trashButton =[[UIBarButtonItem alloc] initWithTitle:@"Delete all downloads" style:UIBarButtonItemStyleBordered target:self action:@selector(trashContent)];
    [trashButton setStyle:UIBarButtonItemStyleBordered];
    
    [self.navigationItem setLeftBarButtonItem:trashButton];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = @"Issues";
    [label sizeToFit];
    
    self.navigationItem.titleView = label;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.publisher numberOfIssues];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    IssueCell *cell = (IssueCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"IssueCell"
                                                                     forIndexPath:indexPath];
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    
    NKIssue *nkIssue = [nkLib issueWithName:[self.publisher nameOfIssueAtIndex:indexPath.row]];
    [cell updateCellInformationWithStatus:nkIssue.status];
    
    NSString* title = [self.publisher titleOfIssueAtIndex:indexPath.row];
    [cell.issueTitleLabel setText:title];

    
    UIImage* coverImage = [self.publisher coverImageForIssueAtIndex:indexPath.row];
    if(coverImage)
    {
        [cell.coverImageView setImage:coverImage];
    }
    else {
        [cell.coverImageView setImage:nil];
        [self.publisher setCoverOfIssueAtIndex:indexPath.row completionBlock:^(UIImage *img) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                        
                [cell.coverImageView setImage:img];
            });
        }];
    }

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self showOrDownloadIssueAtIndex:indexPath.row];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(300, 471);
}


- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(50, 50, 50, 50);
}


-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    // get asset
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    
    int tileIndex = [[dnl.userInfo objectForKey:@"Index"] intValue];
    
    NSLog(@"Tile index %d",tileIndex);
    
    IssueCell* tile = (IssueCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:tileIndex inSection:0]];
    
    
    UIProgressView *progressView = tile.downloadProgress;
    [progressView setAlpha:1.0];
    progressView.progress=1.f*totalBytesWritten/expectedTotalBytes;
    
    [tile updateCellInformationWithStatus:NKIssueContentStatusDownloading];
}

-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    NSLog(@"Resume downloading %f",1.f*totalBytesWritten/expectedTotalBytes);
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    // copy file to destination URL
    
    NSLog(@"connection:(NSURLConnection *)connectionDidFinishDownloading");
    
    [self.collectionView reloadData];
}


-(void)loadIssues {
    
    self.collectionView.alpha = 0.0;
    
    //[self showRefreshButton:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publisherReady:) name:PublisherDidUpdateNotification object:self.publisher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publisherFailed:) name:PublisherFailedUpdateNotification object:self.publisher];
    [self.publisher getIssuesList];
}

-(void)publisherReady:(NSNotification *)not {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublisherDidUpdateNotification object:self.publisher];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublisherFailedUpdateNotification object:self.publisher];
    [self showIssues];
}

-(void)showIssues {
    //[self showRefreshButton:YES];
    self.collectionView.alpha = 1.0;
    [self.collectionView reloadData];
}

-(void)publisherFailed:(NSNotification *)not {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublisherDidUpdateNotification object:self.publisher];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublisherFailedUpdateNotification object:self.publisher];
    NSLog(@"%@",not);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Cannot get issues from publisher server."
                                                   delegate:nil
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    [alert show];
    //[self showRefreshButton:YES];
}


-(void)readIssue:(NKIssue *)nkIssue {
    
    [[NKLibrary sharedLibrary] setCurrentlyReadingIssue:nkIssue];
    
    NSString* issuePath = nkIssue.contentURL.path;
    BakerBook* book = [[BakerBook alloc] initWithBookPath:issuePath bundled:NO];
                       
    BakerViewController *bakerViewController = [[BakerViewController alloc] initWithBook:book];
    [self.navigationController pushViewController:bakerViewController animated:YES];

    /*RootViewController* readerController = [[RootViewController alloc] init];
    
    [[BakerAppDelegate instance].window setEventsDelegate:readerController];
    [[BakerAppDelegate instance].window setTarget:readerController.view];
    
    readerController.delegate = self;
    
    [readerController initBook:[[nkIssue contentURL] path] andName:[nkIssue name]];
    
    [self presentViewController:readerController animated:YES completion:nil];
    */
}

-(void)returnToIssueListInitiated
{
    //[[AppDelegate instance].window setEventsDelegate:nil];
    //[[AppDelegate instance].window setTarget:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showOrDownloadIssueAtIndex:(int)index{
    //StoreManager* storeManager = [AppDelegate instance].storeManager;
    
    //if([storeManager isSubscribed])
    if(YES)
    {
        NKLibrary *nkLib = [NKLibrary sharedLibrary];
        
        NKIssue *nkIssue = [nkLib issueWithName:[self.publisher nameOfIssueAtIndex:index]];
        
        if(nkIssue.status==NKIssueContentStatusAvailable) {
            
            //NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:nkIssue.name, @"IssueName", @"iPad", @"Device", nil];
            //[Flurry logEvent:@"IssueRead" withParameters:dictionary timed:YES];
            
            [self readIssue:nkIssue];
        } else if(nkIssue.status==NKIssueContentStatusNone) {
            
            //NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:nkIssue.name, @"IssueName", @"iPad", @"Device", nil];
            //[Flurry logEvent:@"IssueDownload" withParameters:dictionary timed:YES];
            [self downloadIssueAtIndex:index];
        }
    }
    else {
        
        [self showSubscriptionViewWithImageAtIndex:index];
    }
    
}


-(void)downloadIssueAtIndex:(NSInteger)index {
    
    NewsstandDownloader* downloader = [[AppDelegate instance] newsstandDownloader];
    
    [downloader downloadIssueAtIndex:index];
    
    IssueCell* tile = (IssueCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    [tile updateCellInformationWithStatus:NKIssueContentStatusDownloading];
}

-(void)showSubscriptionViewWithImageAtIndex:(int)index
{
/*    HoverViewController* subscribeController = [[HoverViewController alloc] initWithNibName:@"HoverViewController" bundle:nil];
    [subscribeController setLatestIssueImage:[publisher coverImageForIssueAtIndex:index]];
    [subscribeController setDelegate:self];
    [subscribeController setModalPresentationStyle:UIModalPresentationFormSheet];
    
    
    [self presentViewController:subscribeController animated:YES completion:nil];
 */
}

-(void)trashContent {
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NSLog(@"%@",nkLib.issues);
    [nkLib.issues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [nkLib removeIssue:(NKIssue *)obj];
    }];
    [self.publisher addIssuesInNewsstand];
    [self.collectionView reloadData];
}

@end
