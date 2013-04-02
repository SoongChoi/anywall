//
//  IconImageDownloader.m
//  PlayBook
//
//  Created by Daniel on 12. 5. 2..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "IconImageDownloader.h"


@implementation IconImageDownloader


@synthesize m_IndexPath;
@synthesize m_ImageUrl;

@synthesize m_DownloadData;
@synthesize m_Connection;

@synthesize m_Delegate;

#pragma mark

+ (id)createWithIndexPath:(NSIndexPath*)indexPath imageUrl:(NSURL*)imageUrl delegate:(id)delegate 
{
	IconImageDownloader* downloader = [[IconImageDownloader alloc] init];
	if (downloader == nil) {
		return nil;
	}	
	downloader.m_IndexPath = indexPath;
	downloader.m_ImageUrl = imageUrl;
	downloader.m_Delegate = delegate;
	
	[downloader setIsDownloading:NO];
	
	return downloader;
}

- (void)dealloc
{
    [m_DownloadData release];
    
    [m_Connection cancel];
    [m_Connection release];
    
    [super dealloc];
}

- (BOOL)isDownloading
{
	return m_isDownloading;
}

- (void)setIsDownloading:(BOOL)isDownloading
{
	m_isDownloading = isDownloading;
}

- (void)startDownload
{	
	m_isDownloading = YES;
	
	m_DownloadData = [[NSMutableData alloc] initWithCapacity:0];
	
	// alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:m_ImageUrl] delegate:self];
    m_Connection = conn;
    [conn release];
}

- (void)cancelDownload
{
    [m_Connection cancel];
    m_Connection = nil;
    m_DownloadData = nil;
	m_isDownloading = NO;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [m_DownloadData appendData:data];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    m_DownloadData = nil;
    m_Connection = nil;
	m_isDownloading = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{	
	if (m_DownloadData != nil) {
		[m_Delegate iconImageDidLoad:m_IndexPath iconImage:m_DownloadData];
	}

	m_DownloadData = nil;
	m_Connection = nil;
	m_isDownloading = NO;
}


@end
