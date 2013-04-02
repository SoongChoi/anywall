//
//  EpubViewController.m
//  PlayBook
//
//  Created by 전명곤 on 11. 12. 2..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EpubViewController.h"
#import "EpubViewForm.h"
#include "xsyncv20.h"
#import "UserProfile.h"
#import "PBDatabase.h"
#import "SettingPreference.h"
#import "MyBookGallaryViewController.h"

#define ACTIONSHEET_NONE						0
#define ACTIONSHEET_NETERROR					1
#define ACTIONSHEET_SHOWNEXTDOWNLOADCONTENT		2
#define ACTIONSHEET_NEXT_EXIST					3
#define ACTIONSHEET_LOGIN_REQUEST				4
#define ACTIONSHEET_SAMPLEPAGE_END				5
#define ACTIONSHEET_MOVE_REPLAY_PAGE			6
#define ACTIONSHEET_OPEN_REQUEST_BROWSER		7

#define degreesToRadian(x)  ( M_PI * (x) / 180.0)

@implementation EpubViewController

@synthesize m_ScreenGuid;
@synthesize	m_NavigationBar;
@synthesize m_PanelBar;
@synthesize m_ContentTitle;
@synthesize m_ReqDictionary;
@synthesize m_Request;
@synthesize m_tmpFileName;
@synthesize m_NextViewCaller;
@synthesize m_DRMRetryCount;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[self.view setFrame:CGRectMake(0.0f, 0.0f, DF_FORM_EPUB_VIEW_VERT_WIDTH, DF_FORM_EPUB_VIEW_VERT_HEIGHT)];
	
	m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:self.view textInd:@"로딩중..." orientation:UIDeviceOrientationPortrait];
	m_bScreenLock = NO;
	m_isClosed = NO;
	m_IsContentLoaded = NO;
	m_CurrentOrientation = UIDeviceOrientationPortrait;
	m_OrientationLock = UIDeviceOrientationPortrait;
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	m_isBrowserCalledStreaming = NO;
    if (m_Type == CARTOON_CONTENT_TYPE_STREAM)
    {
	    NSString* browser = getStringValue([m_ReqDictionary objectForKey:@"browser"]);
        NSString* curl = getStringValue([m_ReqDictionary objectForKey:@"curl"]);
        
        if (browser != nil && curl != nil){
            m_isBrowserCalledStreaming = YES;
        }
	}
    else
	{	
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
			BOOL bRet = [self setContentOfFile:m_tmpFileName];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
				m_Request = [[PlayBookRequest alloc] init];
				
				if (m_isClosed == YES) { return; }
				
				[m_NavigationBar showBar:NO];
				[m_PanelBar showBar:NO];

				if (bRet == YES) 
				{	
					EpubView* epubView = (EpubView *)self.view;
			
					NSArray *			arrNavPoints	= [epubView getNavPoints];
					NSMutableArray *	arrItems		= [[NSMutableArray alloc] initWithCapacity:0];
					//NSMutableArray *	arrItems		= [NSMutableArray arrayWithCapacity:0];
                    
					for (NavPoint *item in arrNavPoints)
					{
						[arrItems addObject:item.m_Text];
					}					
					[m_NavigationBar setContentsOfTable:arrItems];
					//[arrItems release];
					
					[m_NavigationBar resize:UIDeviceOrientationPortrait];
					[m_PanelBar resize:UIDeviceOrientationPortrait];

					if (m_MoveToReplayNo == NO) {												
						[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
						[epubView setEnableCtViewDelegate:YES];						
						
						if ([SettingPreference getShowScreenGuide:NO] == NO) {
							m_ScreenGuid =  [ScreenGuide createWithDelegate:self];
							[self.view addSubview:m_ScreenGuid];
						}
					}					
					else {
						[epubView setEnableCtViewDelegate:NO];												
					}										
					m_IsContentLoaded = YES;
					
					epubView.m_ImageView.image = nil;	
					[epubView resize:UIDeviceOrientationPortrait];
					
					// [ Goodscnt 얻어온다 ]	
					NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
					NSString* contentType  = getStringValue([m_ReqDictionary objectForKey:@"content_type"]);							
					[m_Request goodsCntWithMasterNo:masterNumber contentType:contentType platformType:@"01" delegate:self];
				} 
				else 
				{					
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
																		message:RESC_STRING_NOT_READ_CONTENT 
																	   delegate:nil cancelButtonTitle:@"확인" 
															  otherButtonTitles:nil];
					[alertView show];
					[alertView release];
					
					[self close];		
					[self.view removeFromSuperview];
					[self release];
				}
			});
		});
	}

	// navigation bar
	m_NavigationBar = [PBNavigationBar createWithType:PB_PANEL_BAR_TYPE_EPUB orientation:UIDeviceOrientationPortrait delegate:self];
    
    NSString *volume_number = getStringValue([m_ReqDictionary objectForKey:@"book_no"]);
    if (volume_number == nil){
        volume_number = getStringValue([m_ReqDictionary objectForKey:@"volume_number"]);
    }
    
	NSString *title = [NSString stringWithFormat:@"%@ %@권", m_ContentTitle, volume_number];
	[m_NavigationBar setTitle:title];
	[self.view addSubview:m_NavigationBar];
	
	// panel bar
	m_PanelBar = [PBPanelBar createWithType:PB_PANEL_BAR_TYPE_EPUB orientation:UIDeviceOrientationPortrait delegate:self];
	[m_PanelBar setPageWithMin:0.0f max:0.0f];
	[m_PanelBar setcurrentPage:0.0f];
	[self.view addSubview:m_PanelBar];
	
	EpubView * epubView = (EpubView *)self.view;
	[epubView setDelegate:self];

}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSLog(@"will Appear");
	
	UIDeviceOrientation orientation = UIDeviceOrientationPortrait;
	if (m_IsContentLoaded == YES) {
		orientation	= [[UIDevice currentDevice] orientation];
		
		[self orientationTransformBounds:orientation];
	}
    NSString *volume_number = getStringValue([m_ReqDictionary objectForKey:@"book_no"]);
    if (volume_number == nil){
        volume_number = getStringValue([m_ReqDictionary objectForKey:@"volume_number"]);
    }
    
	NSString *title = [NSString stringWithFormat:@"%@ %@권", m_ContentTitle, volume_number];
	[m_NavigationBar setTitle:title];
	
	[m_NavigationBar resize:orientation];
	[m_PanelBar resize:orientation];
	
	[m_NavigationBar showBar:YES];
	[m_PanelBar showBar:YES];

}

- (void) orientationTransformBounds:(UIDeviceOrientation) deviceOrientation
{
	CGRect mainBounds = [[ UIScreen mainScreen ] bounds ];	
	if (deviceOrientation == UIDeviceOrientationPortrait) {
		[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)deviceOrientation animated:NO];
		CGRect bounds = CGRectMake(mainBounds.origin.x, mainBounds.origin.y, mainBounds.size.width, mainBounds.size.height);
		
		self.view.transform = CGAffineTransformMakeRotation(0.0);
		[self.view setBounds:bounds];
	}
	else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
		[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)deviceOrientation animated:NO];
		CGRect bounds = CGRectMake(mainBounds.origin.x, mainBounds.origin.y, mainBounds.size.height, mainBounds.size.width);
		
		self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(90));		
		[self.view setBounds:bounds];
	}
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
		[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)deviceOrientation animated:NO];
		CGRect bounds = CGRectMake(mainBounds.origin.x, mainBounds.origin.y, mainBounds.size.height, mainBounds.size.width);
		
		self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(-90));
		[self.view setBounds:bounds];
		
	}
	else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
		[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)deviceOrientation animated:NO];
		CGRect bounds = CGRectMake(mainBounds.origin.x, mainBounds.origin.y, mainBounds.size.width, mainBounds.size.height);
		
		self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(180));
		[self.view setBounds:bounds];		
	}		
}


- (void) orientationChanged:(NSNotificationCenter*)notification 
{
	if (m_bScreenLock == YES) { 
		[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)m_OrientationLock animated:NO];
		return;	
	}
	
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;	

	if (deviceOrientation == UIDeviceOrientationPortrait || 
		deviceOrientation == UIDeviceOrientationPortraitUpsideDown ||
		deviceOrientation == UIDeviceOrientationLandscapeLeft ||
		deviceOrientation == UIDeviceOrientationLandscapeRight)
	{
		if (m_CurrentOrientation == deviceOrientation) { return; }
		m_CurrentOrientation = deviceOrientation;
		
		if ([m_NavigationBar isShowBar] == YES)
		{
			[m_NavigationBar showBar:NO];
			[m_PanelBar showBar:NO];
		}
		
		[m_NavigationBar resize:deviceOrientation];
		[m_PanelBar resize:deviceOrientation];
		[m_PanelBar setPageWithMin:0.0f max:0.0f];
		[m_PanelBar setcurrentPage:0.0f];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration: 0.3];
		
		[self orientationTransformBounds:deviceOrientation];
		
		EpubView * epubView = (EpubView *)self.view;
		
		epubView.m_ImageView.image = nil;	
		[epubView resize:deviceOrientation];
		
		if (m_ActivityIndicator == nil) {
			m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:self.view textInd:@"로딩중..." orientation:deviceOrientation];
		}		
		else {
			[m_ActivityIndicator resize:deviceOrientation];
		}
		
		[UIView commitAnimations];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view. e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	NSLog(@"EpubView dealloc");
	
	@try 
	{
		if (m_ActivityIndicator != nil) {
			m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
		}
		
		if (m_PanelBar != nil)
		{
			[m_PanelBar release];
		}
		
		if (m_NavigationBar != nil)
		{
			[m_NavigationBar release];
		}
		
		if (m_tmpFileName != nil){
			[m_tmpFileName release];
		}
		
		if (m_ReqDictionary != nil){
			[m_ReqDictionary release];
		}
		
		if (m_NextViewCaller != nil){
			[m_NextViewCaller release];
		}
		
		[super dealloc];
	}
	@catch (NSException * e) {
		NSLog(@"EPubViewController dealloc [%@]", e);
	}
	@finally {
		
	}	
}

- (void) close
{
	m_isClosed = YES;
	
	@try 
	{
		[self deleteTmpFile];

		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
		
		[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)UIDeviceOrientationPortrait animated:NO];
		
		
		EpubView * epubView = (EpubView *)self.view;
		
		[epubView stopReadEpub];
		[self.m_PanelBar _hideSubPopup:SUB_POPUP_NONE];
		
		
		if (m_PanelBar != nil)
		{
			[m_PanelBar close];
		}
		
		if (m_NavigationBar != nil)
		{
			[m_NavigationBar close];
		}
		
		[epubView closeEpubDoc];
	}
	@catch (NSException * e) {
		NSLog(@"EPubViewController dealloc [%@]", e);
	}
	@finally {
		
	}		
}


#ifdef __XSYNCV20_USED__

void ainitContentFile(NSString *fileName)
{
	NSString *psFilePath, *psDocDir;
	HANDLE		hContext = NULL;
	XDRM_RESULT	DRMResult;
	FILE*		pOutFile = NULL;
	char *pcPath = (char*)[fileName UTF8String];
	NSArray*	psaPaths ;
	
	int			nReadBytes;
	char		cBuffer[2048] = {'\0',};
	
	time_t		ttSetTime = 0;	
	
	HANDLE hXSync = [(PlayBookAppDelegate*)[[UIApplication sharedApplication] delegate] getDRMHandle];
	
	psaPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	psDocDir = [psaPaths objectAtIndex:0];
	psDocDir = [psDocDir stringByAppendingString:@"/"];
	pcPath = (char*)[[psDocDir stringByAppendingString:fileName] UTF8String];
	
	NSLog(@"pcPath=[%s], fileName=[%@]", pcPath, fileName);
	
	//	XSync 형식 파일을 오픈한다.
	//
	if (XDRM_SUCCESS != (DRMResult = XSYNC_Open(hXSync, pcPath, ttSetTime, &hContext)))
	{
		goto FUNCTION_ERROR;
	}
	
	//	원본 파일을 저장할 파일 포인터를 생성한다.
	//
	
	psDocDir = [psDocDir stringByAppendingString:fileName];
	psFilePath = [psDocDir stringByAppendingString:@".tmp"];
	pcPath = (char*)[psFilePath UTF8String];
	if (NULL == (pOutFile = fopen(pcPath, "wb")))
	{
		goto FUNCTION_ERROR;
	}
	
	while (0 < (nReadBytes = XSYNC_Read(hContext, cBuffer, sizeof(cBuffer))))
	{
		fwrite((unsigned char*)cBuffer, 1, nReadBytes, pOutFile);
	}
	
	
FUNCTION_ERROR:
	
	if (NULL != pOutFile)
	{
		fclose(pOutFile);
		pOutFile = NULL;
	}
	
	//	열려진 컨텍스트를 제거한다.
	//
	if (NULL != hContext)
	{
		XSYNC_Close(hContext);
		hContext = NULL;
	}
}

void areleaseContentFile(NSString *m_FileName)
{
	NSFileManager *	fm		= [NSFileManager defaultManager];
	NSString *		path	= m_FileName;
	
	[fm removeItemAtPath:path error:nil];
	
	[fm release];
}

#endif //__XSYNCV20_USED__

+ (id) createWithContentsStreaming:(NSDictionary*)dicStreaming
{
	
	EpubViewController *	epubViewController = (EpubViewController *)[[EpubViewController alloc] initWithNibName:@"EpubViewController" bundle:[NSBundle mainBundle]];
	if (epubViewController == nil)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
															message:RESC_STRING_NOT_CREATE_EPUB_VIEW 
														   delegate:nil cancelButtonTitle:@"확인" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return nil;
	}
	[epubViewController setContentType:CARTOON_CONTENT_TYPE_STREAM];
	epubViewController.m_ReqDictionary = dicStreaming;
    epubViewController.m_DRMRetryCount = 0;
	
	NSString* contentTitle = [dicStreaming objectForKey:@"content_title"];
	if (contentTitle != nil) {
		epubViewController.m_ContentTitle = contentTitle;
	}
	else {
		epubViewController.m_ContentTitle = [dicStreaming objectForKey:@"title"];
	}

	
	[epubViewController __requestContinueView];

	
	return epubViewController;
}

- (BOOL) __requestContinueView
{
	m_Request = [[PlayBookRequest alloc] init];
	
	return [m_Request continueViewWithMasterNo:getStringValue([m_ReqDictionary objectForKey:@"master_no"])
										userNo:[UserProfile getUserNo]
										fileNo:getStringValue([m_ReqDictionary objectForKey:@"file_no"])
									  delegate:self];
}

- (BOOL) initWithContentsFile:(NSString *)fileName
{
#ifdef __XSYNCV20_USED__		
	ainitContentFile(fileName); // XSync	
	fileName = [fileName stringByAppendingString:@".tmp"]; // XSync
	m_tmpFileName = fileName;
	
#endif //__XSYNCV20_USED__				
	
	if ([self setContentOfFile:fileName] == NO)
	{	
		return NO;
	}

/*	
	EpubView *	epubView = (EpubView *)self.view;
	[self setContentTitle:[epubView.m_EpubDoc getTitle]];
*/	
	//[epubViewController.m_NavigationBar setTitle:[epubView.m_EpubDoc getTitle]];
	
	return YES;
	
	
}

+ (id) createWithContentsOfFile:(NSString *)fileName title:(NSString *)title dicDownload:(NSDictionary*)dicDownload
{
	
#ifdef __XSYNCV20_USED__		
	ainitContentFile(fileName); // XSync	
	fileName = [fileName stringByAppendingString:@".tmp"]; // XSync
#endif //__XSYNCV20_USED__				
	
	if (fileName == nil)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
															message:RESC_STRING_ENTER_CONTENT_FILENAME 
														   delegate:nil cancelButtonTitle:@"확인" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
		return nil;
	}
	
	if ([fileName length] == 0)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
															message:RESC_STRING_ENTER_CONTENT_FILENAME 
														   delegate:nil cancelButtonTitle:@"확인" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
		return nil;
	}
	
	EpubViewController * epubViewController = (EpubViewController *)[[EpubViewController alloc] initWithNibName:@"EpubViewController" bundle:[NSBundle mainBundle]];
	if (epubViewController == nil)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
															message:RESC_STRING_NOT_CREATE_EPUB_VIEW 
														   delegate:nil cancelButtonTitle:@"확인" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return nil;
	}
	[epubViewController setContentType:CARTOON_CONTENT_TYPE_DOWNLOAD];
	
	epubViewController.m_NextViewCaller = [[NextViewCaller alloc]initWithContentType:CARTOON_CONTENT_TYPE_DOWNLOAD];
	epubViewController.m_tmpFileName = fileName;
	epubViewController.m_ReqDictionary = dicDownload;
	
	NSString* contentTitle = [dicDownload objectForKey:@"content_title"];
	if (contentTitle != nil) {
		epubViewController.m_ContentTitle = contentTitle;
	}
	else {
		epubViewController.m_ContentTitle = title;		
	}

	return epubViewController;
}

- (void) setContentType:(NSInteger)type
{
	m_Type = type;
}

- (BOOL) setContentOfFile:(NSString *)fileName
{
	EpubView *	epubView = (EpubView *)self.view;

	if (m_Type == CARTOON_CONTENT_TYPE_DOWNLOAD) { 
		NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
		NSString* fileNumber   = getStringValue([m_ReqDictionary objectForKey:@"file_no"]);		
		
		m_ReplayNo = [PBDatabase getBookReadPosition:masterNumber filaNumber:fileNumber];
		m_MoveToReplayNo = (m_ReplayNo > 1) ? YES : NO;
	}
	NSLog(@"m_ReplayNo=[%d]", m_ReplayNo);

	if ([epubView loadEpubWithContentsOfFile:fileName replayPage:m_ReplayNo] == NO)
	{
		return NO;
	}	

	return YES;
}

- (void) setContentTitle:(NSString *)title
{
	m_ContentTitle = title;
	
	NSString *tmpTitle = [NSString stringWithFormat:@"%@ %@권", m_ContentTitle, getStringValue([m_ReqDictionary objectForKey:@"book_no"])];
	[m_NavigationBar setTitle:tmpTitle];
}


- (NSInteger) getCurrentPageIndex
{
	EpubView *	epubView = (EpubView *)self.view;
	
	if (epubView.m_EpubDoc == nil)
	{
		return 0;
	}
	
	if ([epubView getPageCount] == 0)
	{
		return 0;
	}
	
	return [epubView getCurrentPageIndex];
}

- (BOOL) setCurrentPage:(NSInteger)pageIndex
{
	EpubView *	epubView = (EpubView *)self.view;
	
	return [epubView setCurrentPageWithIndex:pageIndex];
}

- (NSInteger) getCurrentParagraphIndex
{
	EpubView *	epubView = (EpubView *)self.view;
	
	if (epubView.m_EpubDoc == nil)
	{
		return 0;
	}
	
	if ([epubView getPageCount] == 0)
	{
		return 0;
	}
	
	return [epubView getCurrentParagraphIndex];
}

- (BOOL) setCurrentParagraph:(NSInteger)paragraphIndex
{
	EpubView *	epubView = (EpubView *)self.view;
	
	return [epubView setCurrentPageWithParagraphIndex:paragraphIndex];
}

- (NSUInteger) getCurrentElementIndex
{
	EpubView *epubView = (EpubView *)self.view;
	
	return [epubView getCurrentElementIndex];
}
- (NSInteger) setCurrentElementIndex:(NSUInteger)elementIndex
{
	EpubView *epubView = (EpubView *)self.view;
	
	return [epubView setCurrentPageWithElementIndex:elementIndex];
}

- (NSUInteger) getPageCount
{
	EpubView *epubView = (EpubView *)self.view;
	
	NSUInteger pageCount = [epubView getPageCount];
	
	return pageCount;
}

- (void) setDelegate:(id)delegate
{
	m_Delegate = delegate;
}

- (BOOL) isCompletedLoadCurrentPage
{
	EpubView *epubView = (EpubView *)self.view;
	
	return [epubView isCompletedLoadCurrentPage];
}

- (BOOL) isCompletedLoadPages
{
	EpubView *epubView = (EpubView *)self.view;
	
	return [epubView isCompletedLoadPages];
}

- (void) touchScreenGuid:(UIEvent*)event
{
	[SettingPreference setShowScreenGuide:NO bShow:YES];
	
	[m_ScreenGuid removeFromSuperview];
	[m_ScreenGuid release];
	m_ScreenGuid = nil;
}

#pragma mark -
#pragma mark EpubViewDelegate

- (UIDeviceOrientation) getCurrentOrientation
{
    return m_CurrentOrientation;
}

- (void) epubViewTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event position:(NSInteger)pos
{
	if ([m_NavigationBar isShowBar] == YES)
	{
		[m_NavigationBar showBar:NO];
		[m_PanelBar showBar:NO];
		
		return;
	}
	
	EpubView *epubView = (EpubView *)self.view;

	if (pos == 1)
	{
		if (epubView.m_EpubDoc == nil || [epubView.m_EpubDoc hasContent] == NO) {
			return;
		}
		// prev page
		[epubView prevPage];
		
	}
	else if (pos == 2)
	{
		BOOL bShowNavi = [m_NavigationBar isShowBar];
		
		if (bShowNavi == NO)
		{
			[m_PanelBar setcurrentPage:[epubView getCurrentPageIndex]];
		}
		
		[m_NavigationBar showBar:!bShowNavi];
		[m_PanelBar showBar:!bShowNavi];	
		
		[m_PanelBar setFontScale:[epubView.m_EpubDoc getFontScale]];
		[m_PanelBar setBrightness:[epubView getBrightness]];
	}
	else if (pos == 3)
	{
		if (epubView.m_EpubDoc == nil || [epubView.m_EpubDoc hasContent] == NO) {
			return;
		}
		
		if (m_SampleCount > 0)
		{
			if ([self getCurrentParagraphIndex] >= m_SampleCount){		
				UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@"" message:RESC_STRING_SAMPLE_LAST_PAGE delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				pAlertView.tag = ACTIONSHEET_SAMPLEPAGE_END;
				[pAlertView show];	
				[pAlertView release];
				return;
			}
		}

		//ios 5.01 patch
		if ([epubView getPageCount] > 1)
		{
			if ([epubView nextPage] == NO)
			{
				if (m_Type == CARTOON_CONTENT_TYPE_STREAM){
					[self RequestLastNextPage];
				}
				else {
					UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@"" message:RESC_STRING_COMPLETE_BOOK_MESSAGE delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
					[pAlertView show];	
					[pAlertView release];
				}
			}
		}
	}
}

- (void) epubViewIndicateReloadPage:(NSInteger)percent
{
	[m_PanelBar setReloadPercent:percent];
}

- (void) epubViewCompletedReplayPage:(NSUInteger)pageIndex
{
	NSLog(@"pageIndex=[%d]", pageIndex);
	
	if (m_MoveToReplayNo == YES) 
	{	
		EpubView *epubView = (EpubView *)self.view;
		
		[epubView setEnableCtViewDelegate:YES];
		NSInteger currentPage = [epubView setCurrentPageWithElementIndex:m_ReplayNo];
		NSLog(@"pageIndex=[%d]", currentPage);
		
		[m_PanelBar setPageWithMin:1.0f max:(CGFloat)[epubView getPageCount]];
		[m_PanelBar setcurrentPage:(CGFloat)currentPage];
		
		if (m_ActivityIndicator != nil) {
			m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
		}
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
		
		if ([SettingPreference getShowScreenGuide:NO] == NO) {
			m_ScreenGuid =  [ScreenGuide createWithDelegate:self];
			[self.view addSubview:m_ScreenGuid];
		}		
		m_MoveToReplayNo = NO;
	}
}

- (void) epubViewChangeCurrentPageWithIndex:(NSUInteger)pageIndex
{
	NSLog(@"pageIndex=[%d]", pageIndex);

	if (m_MoveToReplayNo == NO) 
	{
		if (m_ActivityIndicator != nil) {
			m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
		}
	
		EpubView *epubView = (EpubView *)self.view;
		[epubView updateView];
		
		[m_PanelBar setPageWithMin:1.0f max:(CGFloat)[epubView getPageCount]];
		[m_PanelBar setcurrentPage:(CGFloat)pageIndex];
	}
}

- (void) epubViewCompletedLoadDocWithCount:(NSUInteger)count
{
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	EpubView *epubView = (EpubView *)self.view;
	[epubView updateView];
	
	[m_PanelBar setPageWithMin:1.0f max:(CGFloat)count];
	[m_PanelBar setcurrentPage:(CGFloat)[epubView getCurrentPageIndex]];
}


- (void) RequestLastNextPage
{
	NSInteger nextCallerStatus = m_NextViewCaller.mCurrentStatus;
	
	switch (nextCallerStatus) {
		case CALLER_STATUS_NETERROR:
		{
			//[PBDatabase 
			
			NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
			NSInteger curVolume = [getStringValue([m_ReqDictionary objectForKey:@"book_no"]) intValue];
			NSString* curPlus1 = [NSString stringWithFormat:@"%d", curVolume + 1];
			
			NSDictionary *nextVolume = [PBDatabase getBookContentWithVolumeNumber:curPlus1 masterNumber:masterNumber];
			
			if (nextVolume != nil)//파일 있으면
			{
				UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@"" message:RESC_STRING_SHOW_NEXT_VOLUME_QUESTION delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
				pAlertView.tag = ACTIONSHEET_SHOWNEXTDOWNLOADCONTENT;
				[pAlertView show];	
				[pAlertView release];
			}
			else 
			{
				UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@"" message:RESC_STRING_FAIL_NOT_LOAD_NEXT_VOLUME delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				pAlertView.tag = ACTIONSHEET_NETERROR;
				[pAlertView show];	
				[pAlertView release];
			}
			break;
		}
			
		case CALLER_STATUS_GOOLVOLUMES:
		case CALLER_STATUS_CHECKPURCHASE:
			switch ([m_NextViewCaller getNextStatue]) 
			{
				case NEXT_STATUS_FINISH_SERIESE:
				{
					UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@"" message:RESC_STRING_COMPLETE_BOOK_MESSAGE delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
					pAlertView.tag = ACTIONSHEET_NETERROR;
					[pAlertView show];	
					[pAlertView release];
					break;
				}
					
				case NEXT_STATUS_NONE_NEXT_SERIESE:
				{
					UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@"" message:RESC_STRING_NOT_COMPLENTE_BOOK_MESSAGE delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
					pAlertView.tag = ACTIONSHEET_NETERROR;
					[pAlertView show];	
					[pAlertView release];				
					break;
				}
					
				case NEXT_STATUS_CLOSED_CONTENT:
					break;
					
				case NEXT_STATUS_NEXT_EXIST:
				{
					UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@"" message:RESC_STRING_SHOW_NEXT_VOLUME_QUESTION delegate:self cancelButtonTitle:@"확인" otherButtonTitles:@"취소", nil];
					pAlertView.tag = ACTIONSHEET_NEXT_EXIST;
					[pAlertView show];	
					[pAlertView release];
					break;
				}				
			}
			break;
			
		default:
			break;
	}
	
}

#pragma mark -
#pragma mark MessageBox Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag) 
	{
		case ACTIONSHEET_SHOWNEXTDOWNLOADCONTENT:
			if (buttonIndex == 0) {			// [확인]
				//다운로드된 다음권 연다.
			}
			else if (buttonIndex == 1) {	//취소
			}
			break;
			
		case ACTIONSHEET_NETERROR:
			if (buttonIndex == 0) {			// [확인]
				//do nothing
			}
			else if (buttonIndex == 1) {	//취소
			}
			break;
			
		case ACTIONSHEET_SAMPLEPAGE_END:
			if (buttonIndex == 0) {			// [확인]
				//do nothing
			}
			else if (buttonIndex == 1) {	//취소
			}
			break;
			
		case ACTIONSHEET_NEXT_EXIST:
			if (buttonIndex == 0) 
			{			// [확인]
				NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
				
				switch ([m_NextViewCaller getExcuteStatue:masterNumber])
				{
					case EXE_STATUS_REQUEST_LOGIN:
					{
						UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@"" message:RESC_STRING_REQUEST_LOGIN delegate:self cancelButtonTitle:@"확인" otherButtonTitles:@"취소", nil];
						pAlertView.tag = ACTIONSHEET_LOGIN_REQUEST;
						[pAlertView show];	
						[pAlertView release];
						break;
					}
					case EXE_STATUS_LOAD_DBCONTENT:
					{
						NSLog(@"[EXE_STATUS_LOAD_DBCONTENT]");
						
						//[m_NextViewCaller loadNextVolumes:getStringValue([m_ReqDictionary objectForKey:@"file_no"]) bookVolume:getStringValue([m_ReqDictionary objectForKey:@"book_no"])];
						
						NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
						NSInteger curVolume = [getStringValue([m_ReqDictionary objectForKey:@"book_no"]) intValue];
						NSString *curPlus1 = [NSString stringWithFormat:@"%d", (curVolume + 1)];
						
						NSDictionary *nextVolume = [PBDatabase getBookContentWithVolumeNumber:curPlus1 masterNumber:masterNumber];						
						if (nextVolume != nil)//DB에 다음 파일 있으면 
						{
							NSMutableDictionary *content = [nextVolume mutableCopy];
							NSString *strNextVolume = [NSString stringWithFormat:@"%d", curVolume + 1];
							[content setObject:strNextVolume forKey:@"book_no"];
							
							[self updateLocalFilePosition];
							
							NSString* filePathLocal = getStringValue([nextVolume objectForKey:@"file_path_local"]);
							
							EpubViewController* epubViewController = [EpubViewController createWithContentsOfFile:filePathLocal title:[nextVolume objectForKey:@"title"] dicDownload:content];
							if (epubViewController != nil)
							{
								[APPDELEGATE.m_Window addSubview:epubViewController.view];
							}
							
							[self close];		
							[self.view removeFromSuperview];
							[self release];
						}
						break;
					}
					case EXE_STATUS_CHECK_PURCHASE:
					{
						/**
						 * I'd Like To View Next Book Volume, But Next Book Volume Isn't Exist In Local... 
						 */
						//nextfilenumber
						if ([m_Request isDownloading] == NO){
							NSString* pageNumber =  [NSString stringWithFormat:@"%d|0|0", [self getCurrentParagraphIndex]];
							NSString* fileNumber   = getStringValue([m_ReqDictionary objectForKey:@"file_no"]);
							m_NextViewCaller.mCurrentStatus = CALLER_STATUS_CHECKPURCHASE;
							[m_Request continueViewInsWithMasterNo:masterNumber userNo:[UserProfile getUserNo] replayNo:pageNumber fileNo:fileNumber delegate:self];
						}
						break;
					}
				}
				
			}
			else if (buttonIndex == 1) {	//취소
				//[self close];		
				//[self.view removeFromSuperview];
				//[self release];
			}
			break;
			
		case ACTIONSHEET_LOGIN_REQUEST:
			//launch login UI
			if (buttonIndex == 0){
				[APPDELEGATE createLoginViewController];
			}
			break;
            
		case ACTIONSHEET_MOVE_REPLAY_PAGE:			
			if (buttonIndex == 0) {			// [확인]
			}
			else if (buttonIndex == 1) {	//취소				
				m_ReplayNo = 1;
				m_MoveToReplayNo = NO;
			}			
			[self __requestStreamingContent];
			break;
            
        case ACTIONSHEET_OPEN_REQUEST_BROWSER:
            if (buttonIndex == 1){
                NSString* browser = getStringValue([m_ReqDictionary objectForKey:@"browser"]);
                NSString* curl = getStringValue([m_ReqDictionary objectForKey:@"curl"]);
                NSURL *inputURL = [NSURL URLWithString:curl];
                
                if ([browser isEqualToString:@"chrome"] == YES){
                    //open curl in chrome
                    NSString *scheme = inputURL.scheme;
                    
                    // Replace the URL Scheme with the Chrome equivalent.
                    NSString *chromeScheme = nil;
                    if ([scheme isEqualToString:@"http"]) {
                        chromeScheme = @"googlechrome";
                    } else if ([scheme isEqualToString:@"https"]) {
                        chromeScheme = @"googlechromes";
                    }
                    
                    // Proceed only if a valid Google Chrome URI Scheme is available.
                    if (chromeScheme) {
                        NSString *absoluteString = [inputURL absoluteString];
                        NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
                        NSString *urlNoScheme =
                        [absoluteString substringFromIndex:rangeForScheme.location];
                        NSString *chromeURLString =
                        [chromeScheme stringByAppendingString:urlNoScheme];
                        NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
                        
                        // Open the URL with Chrome.
                        [[UIApplication sharedApplication] openURL:chromeURL];
                    }
                }
                else{
                    //open curl in safari
                    [[UIApplication sharedApplication] openURL:inputURL];
                }
			}
            
            //close anyway
            [self close];
            [self.view removeFromSuperview];
            [self release];
            
            break;

	}
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	NSLog(@"buttonIndex=[%d]", buttonIndex);
	switch (actionSheet.tag)
	{
		case ACTIONSHEET_SHOWNEXTDOWNLOADCONTENT:
			if (buttonIndex == 0) {			// [확인]
				//다운로드된 다음권 연다.
			}
			else if (buttonIndex == 1) {	//취소
			}
			break;
			
		case ACTIONSHEET_NETERROR:
			if (buttonIndex == 0) {			// [확인]
				//do nothing
			}
			else if (buttonIndex == 1) {	//취소
			}
			break;
			
		case ACTIONSHEET_SAMPLEPAGE_END:
			if (buttonIndex == 0) {			// [확인]
				//do nothing
			}
			else if (buttonIndex == 1) {	//취소
			}
			break;
			
		case ACTIONSHEET_NEXT_EXIST:
			if (buttonIndex == 0) 
			{			// [확인]
				NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
				
				switch ([m_NextViewCaller getExcuteStatue:masterNumber])
				{
					case EXE_STATUS_REQUEST_LOGIN:
					{
						UIActionSheet *menuPopup = [[UIActionSheet alloc] initWithTitle:@"로그인이 필요한 서비스 입니다." 
																			   delegate:self 
																	  cancelButtonTitle:@"취소" 
																 destructiveButtonTitle:nil 
																	  otherButtonTitles:@"확인", nil];
						menuPopup.actionSheetStyle = UIActionSheetStyleBlackOpaque;
						menuPopup.tag = ACTIONSHEET_LOGIN_REQUEST; 
						
						[menuPopup showInView:self.view];
						[menuPopup release];
						break;
					}
					case EXE_STATUS_LOAD_DBCONTENT:
					{
						NSLog(@"[EXE_STATUS_LOAD_DBCONTENT]");
						
						//[m_NextViewCaller loadNextVolumes:getStringValue([m_ReqDictionary objectForKey:@"file_no"]) bookVolume:getStringValue([m_ReqDictionary objectForKey:@"book_no"])];
						
						NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
						NSInteger curVolume = [getStringValue([m_ReqDictionary objectForKey:@"book_no"]) intValue];
						NSString *curPlus1 = [NSString stringWithFormat:@"%d", (curVolume + 1)];
						
						NSDictionary *nextVolume = [PBDatabase getBookContentWithVolumeNumber:curPlus1 masterNumber:masterNumber];						
						if (nextVolume != nil)//DB에 다음 파일 있으면 
						{
							NSMutableDictionary *content = [nextVolume mutableCopy];
							NSString *strNextVolume = [NSString stringWithFormat:@"%d", curVolume + 1];
							[content setObject:strNextVolume forKey:@"book_no"];
							
							[self updateLocalFilePosition];
							
							NSString* filePathLocal = getStringValue([nextVolume objectForKey:@"file_path_local"]);
							
							EpubViewController* epubViewController = [EpubViewController createWithContentsOfFile:filePathLocal title:[nextVolume objectForKey:@"title"] dicDownload:content];
							if (epubViewController != nil)
							{
								[APPDELEGATE.m_Window addSubview:epubViewController.view];
							}
							
							[self close];		
							[self.view removeFromSuperview];
							[self release];
						}
						break;
					}
					case EXE_STATUS_CHECK_PURCHASE:
					{
						/**
						 * I'd Like To View Next Book Volume, But Next Book Volume Isn't Exist In Local... 
						 */
						//nextfilenumber
						if ([m_Request isDownloading] == NO)
						{
							[m_Request checkBuyWithDomain:BI_PURCHASE_DOMAIN userNo:[UserProfile getUserNo] fileNo:[m_NextViewCaller getNextVolumeFileNumber] delegate:self];						
							
						}
						break;
					}
				}
				
			}
			else if (buttonIndex == 1) {	//취소
				[self close];		
				[self.view removeFromSuperview];
				[self release];
			}
			break;
			
		case ACTIONSHEET_LOGIN_REQUEST:
			//launch login UI
			if (buttonIndex == 0){
				[APPDELEGATE createLoginViewController];
			}
			break;			
	}
}

- (void) updateLocalFilePosition
{
	NSUInteger  currentElementIndex = [self getCurrentElementIndex];
	
	if (currentElementIndex >= 0) {		
		NSLog(@"currentPageIndex=[%d], currentElementIndex=[%d]", [self getCurrentPageIndex], currentElementIndex);
		
		NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
		NSString* fileNumber   = getStringValue([m_ReqDictionary objectForKey:@"file_no"]);		
		[PBDatabase updateBookContentWithReadState:masterNumber fileNumber:fileNumber readState:0 readPosition:currentElementIndex];				
	}				
}	

#pragma mark -
#pragma mark PBNavigationBarDelegate
- (void) pbnClickRightButton:(id)sender
{
	if (m_ActivityIndicator == nil) {
		UIDeviceOrientation orientation = (m_bScreenLock == YES) ? m_OrientationLock : m_CurrentOrientation;
		m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:self.view textInd:@"종료중..." orientation:orientation];
	}
	else {
		[m_ActivityIndicator setTextInd:@"종료중..."];
	}
	
	[m_Delegate evcCloseEpubView];
	
	if (m_Type == CARTOON_CONTENT_TYPE_DOWNLOAD) 
	{
		[self updateLocalFilePosition];	
		
		[self close];		
		[self.view removeFromSuperview];
		[self release];
	}
	else {
        if ([m_Request isDownloading] == YES) {
			
            if ([m_Request getCommand] == DF_URL_CMD_CONTINUE_VIEW_INS)
            {
                [m_Request cancelConnection];
                
                //alert browser
                if (m_isBrowserCalledStreaming){
                    UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@""message:RESC_STRING_OPEN_REQUEST_BROWSER delegate:self cancelButtonTitle:@"취소"otherButtonTitles:@"확인", nil];
                    pAlertView.tag = ACTIONSHEET_OPEN_REQUEST_BROWSER;
                    [pAlertView show];
                    [pAlertView release];
                }
                else{
                    [self close];
                    [self.view removeFromSuperview];
                    [self release];
                }
                
                return;
            }
		}
        
		if ([m_Request isDownloading] == YES) {
			[m_Request cancelConnection];
		}
		
		NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
		NSString* fileNumber   = getStringValue([m_ReqDictionary objectForKey:@"file_no"]);		
		NSString* userNumber   = [UserProfile getUserNo];
		//NSString* pageNumber =  [NSString stringWithFormat:@"%d|0|0", [self getCurrentParagraphIndex]];
		NSString* pageNumber =  [NSString stringWithFormat:@"%d", [self getCurrentElementIndex]];
		
		[m_Request continueViewInsWithMasterNo:masterNumber userNo:userNumber replayNo:pageNumber fileNo:fileNumber];
	}
}

#pragma mark -
#pragma mark PBPanelBarDelegate
- (void) pbpChangePage:(CGFloat)pageNumber
{
	EpubView *epubView = (EpubView *)self.view;
	
	if (epubView.m_EpubDoc == nil || [epubView.m_EpubDoc hasContent] == NO) {
		return;
	}
	
	[epubView setCurrentPageWithIndex:(NSInteger)pageNumber];
}

- (void) pbpChangeBrightness:(CGFloat)brightness
{
	EpubView *epubView = (EpubView *)self.view;
	
	[epubView setBrightnessWithValue:brightness];
}

- (void) pbpChangeScreenLock:(id)sender lock:(BOOL)bLock
{
	m_CurrentOrientation = [[UIDevice currentDevice] orientation]; 
	m_OrientationLock = m_CurrentOrientation;
	
	m_bScreenLock = bLock;	
}

- (void) pbpSelectedTocPage:(NSUInteger)pageNumber
{
	if ([m_NavigationBar isShowBar] == YES)	
	{
		[m_NavigationBar showBar:NO];
		[m_PanelBar showBar:NO];
	}
	
	EpubView *epubView = (EpubView *)self.view;
	
	NSArray * arrItems = [epubView getNavPoints];
	NavPoint * element = [arrItems objectAtIndex:pageNumber];
	
	if (element.m_ElementIndex == -1) { return; }
	
	NSLog(@"pageNumber=[%d] elementIndex=[%d]", pageNumber, element.m_ElementIndex);

	[epubView setCurrentPageWithElementIndex:element.m_ElementIndex];	
	[epubView updateView];
}

- (void) pbpSelectedToneIndex:(NSInteger)toneIndex
{
	NSLog(@"Background Tone Index = %d", toneIndex);
	
	EpubView *epubView = (EpubView *)self.view;
	
	if (epubView.m_EpubDoc == nil || [epubView.m_EpubDoc hasContent] == NO) {
		return;
	}
	
	[epubView setBackgroundToneWithIndex:toneIndex];
	[epubView updateView];
}

- (void) pbpChangeFontSize:(BOOL)increase
{
	EpubView *epubView = (EpubView *)self.view;
	
	if (epubView.m_EpubDoc == nil || [epubView.m_EpubDoc hasContent] == NO) {
		return;
	}
	
	if (increase == YES)
	{
		[epubView increaseFontScale];
	}
	else 
	{
		[epubView decreaseFontScale];
	}
}

- (void) pbpChangeFontScale:(CGFloat)fontScale
{
	EpubView *epubView = (EpubView *)self.view;
	
	if (epubView.m_EpubDoc == nil || [epubView.m_EpubDoc hasContent] == NO) {
		return;
	}	
	[epubView setFontScale:fontScale];
	
	epubView.m_ImageView.image = nil;	
	[epubView resize:m_CurrentOrientation];
	
	[m_PanelBar setPageWithMin:0.0f max:0.0f];
	[m_PanelBar setcurrentPage:0.0f];
}

#pragma mark -
#pragma mark PlayBookRequestDelegate
- (void) pbrDidReceiveResponse:(NSURLResponse *)response command:(NSInteger)command
{
	if (command == DF_URL_CMD_CONTENT_DOWNLOAD)
	{
		TRACE(@"expectedContentLength = %d", [response expectedContentLength]);
		
		//NSMutableDictionary *item = [m_Queue objectAtIndex:0];
		
		//[item setObject:[NSNumber numberWithInteger:[response expectedContentLength]] forKey:@"total_size"];
	}
}

//여기서 디코딩해서 setData, appendWithData
- (void) pbrDidReceiveData:(NSData *)data response:(NSURLResponse *)response command:(NSInteger)command
{
	if (command == DF_URL_CMD_CONTENT_DOWNLOAD)
	{
		TRACE(@"command = DF_URL_CMD_CONTENT_DOWNLOAD : length = %d", [data length]);
	}
}

- (void) pbrDidFailWithError:(NSError *)error command:(NSInteger)command
{
	// 에러 처리
	NSLog(@"[command = %d] : %@", [error description]);
	
	if (command == DF_URL_CMD_CONTENT_DOWNLOAD)
	{
		[self close];		
		[self.view removeFromSuperview];
		[self release];
	}
	else if (command == DF_URL_CMD_CHECK_BUY)
	{
		m_NextViewCaller.mCurrentStatus = CALLER_STATUS_NETERROR;
	}
	else if (command == DF_URL_CMD_GOODS_CNT)
	{
		m_NextViewCaller.mCurrentStatus = CALLER_STATUS_NETERROR;
	}
	else if (command == DF_URL_CMD_CONTINUE_VIEW_INS)
	{
		//alert browser
        if (m_isBrowserCalledStreaming){
            UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@""message:RESC_STRING_OPEN_REQUEST_BROWSER delegate:self cancelButtonTitle:@"취소"otherButtonTitles:@"확인", nil];
            pAlertView.tag = ACTIONSHEET_OPEN_REQUEST_BROWSER;
            [pAlertView show];
            [pAlertView release];
        }
        else{
            [self close];
            [self.view removeFromSuperview];
            [self release];
        }
	}
}

- (void) deleteTmpFile
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *	filePath	 = [JMDevKit appDocumentFilePath:@"stream.epub"];
	[fileManager removeItemAtPath:filePath error:NULL];
	
	filePath = [JMDevKit appDocumentFilePath:@"stream.epub.tmp"];
	[fileManager removeItemAtPath:filePath error:NULL];
	
	filePath = [JMDevKit appDocumentFilePath:@"temp"];
	[fileManager removeItemAtPath:filePath error:NULL];
	
	if (m_tmpFileName != nil && [m_tmpFileName length] > 0){
		[fileManager removeItemAtPath:[JMDevKit appDocumentFilePath:m_tmpFileName] error:NULL];
	}
	
	[fileManager release];
}

//userinfo가 NSMutableData *		m_ReceiveData
- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{	
	BOOL retValue = NO;
	
	NSString *	filePath	 = [JMDevKit appDocumentFilePath:@"stream.epub"];
	
	if (command == DF_URL_CMD_CONTENT_DOWNLOAD)
	{
		[self deleteTmpFile];

		NSData *				data	= (NSData *)userInfo;
		
		TRACE(@"DF_URL_CMD_CONTENT_DOWNLOAD : length = %d", [data length]);
		const unsigned char* bytes	= [data bytes];
		const unsigned char* retPtrrn	= (const unsigned char *)strstr((const char *)bytes, "\r\n");
		
        char* retPtr	= (char *)strstr((const char *)bytes, "<RESULT>0</RESULT>");
        if (retPtr == 0)
        {
            NSLog(@"DRM result : FAILED");
            
            if (m_DRMRetryCount < 4){
                m_DRMRetryCount++;
                [m_Request cancelConnection];
                [self __requestStreamingContent];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
                                                                    message:RESC_STRING_NETWORK_FAIL 
                                                                   delegate:nil cancelButtonTitle:@"확인" 
                                                          otherButtonTitles:nil];
                [alertView show];
                [alertView release];
            }
        }
        else if (retPtrrn != NULL)
		{
			NSInteger	pos			= (NSInteger)(retPtrrn - bytes);
			
			NSRange		range		= NSMakeRange(0, pos);
			NSData*		fileData	= [data subdataWithRange:range];
			NSString*	retString	= [[NSString alloc] initWithBytes:[fileData bytes] length:pos encoding:NSUTF8StringEncoding];
			APDocument* xmlDoc		= [APDocument documentWithXMLString:retString];
			APElement*	rootElement	= [xmlDoc rootElement];
			NSString*	value		= [rootElement value];
			
			if ([value integerValue] == 0)
			{
				// binary data
				range	 = NSMakeRange((pos + 2), ([data length] - pos - 2));
				fileData = [data subdataWithRange:range];
				
				[fileData writeToFile:filePath atomically:YES];
				
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{					
					BOOL bRet = [self initWithContentsFile:@"stream.epub"];
					
					dispatch_async(dispatch_get_main_queue(), ^{

						if (m_isClosed == YES) { return; }
						
						[m_NavigationBar showBar:NO];
						[m_PanelBar showBar:NO];
						
						if (bRet == YES) 
						{	
							
							[self.view setFrame:CGRectMake(0.0f, 0.0f, DF_FORM_EPUB_VIEW_VERT_WIDTH, DF_FORM_EPUB_VIEW_VERT_HEIGHT)];
							
							EpubView* epubView = (EpubView *)self.view;
							
							NSArray *			arrNavPoints	= [epubView getNavPoints];
							NSMutableArray *	arrItems		= [[NSMutableArray alloc] initWithCapacity:0];
							//NSMutableArray *	arrItems		= [NSMutableArray arrayWithCapacity:0];
                            
							for (NavPoint *item in arrNavPoints)
							{
								[arrItems addObject:item.m_Text];
							}					
							[m_NavigationBar setContentsOfTable:arrItems];
                            //[arrItems release];
							
							[m_NavigationBar resize:UIDeviceOrientationPortrait];
							[m_PanelBar resize:UIDeviceOrientationPortrait];
		
							if (m_MoveToReplayNo == NO) {
								[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];							
								[epubView setEnableCtViewDelegate:YES];						
								
								if ([SettingPreference getShowScreenGuide:NO] == NO) {
									m_ScreenGuid =  [ScreenGuide createWithDelegate:self];
									[self.view addSubview:m_ScreenGuid];
								}
							}					
							else {
								[epubView setEnableCtViewDelegate:NO];												
							}														
							m_IsContentLoaded = YES;
							
							epubView.m_ImageView.image = nil;	
							[epubView resize:UIDeviceOrientationPortrait];

							NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
							NSString* contentType    = getStringValue([m_ReqDictionary objectForKey:@"content_type"]);
							
							[m_Request goodsCntWithMasterNo:masterNumber contentType:contentType platformType:@"01" delegate:self];
							
						} 
						else 
						{
							UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
																				message:RESC_STRING_NOT_READ_CONTENT 
																			   delegate:nil cancelButtonTitle:@"확인" 
																	  otherButtonTitles:nil];
							[alertView show];
							[alertView release];
							
						}
					});
				});
								
				retValue = YES;
			}
		}
	}
	else if (command == DF_URL_CMD_CHECK_BUY)
	{
		m_NextViewCaller.mCurrentStatus = CALLER_STATUS_CHECKPURCHASE;
		
		NSDictionary *dicInfo = (NSDictionary *) userInfo;
		NSInteger rtCode = [[dicInfo objectForKey:@"result_code"] intValue];	
		if(rtCode == 0) 
		{
			NSDictionary* dicData   = [dicInfo objectForKey:@"data"];
			NSDictionary* dicResult = [dicData objectForKey:@"result"];
			
			BOOL bExbuy_yn = [[dicResult objectForKey:@"exbuy_yn"] isEqualToString:@"Y"];
			NSInteger exbuy_type = [[dicResult objectForKey:@"exbuy_type"] intValue];
			
			//exbuy_yn Y이고 0(마스터유저), 1(스트리밍무료), 3(맛보기상품)인 경우 보인다.
			if (bExbuy_yn && ((exbuy_type == 0) || (exbuy_type == 1) || (exbuy_type == 3) || (exbuy_type == 100)))
			{			
				NSArray *playyArray = [dicInfo objectForKey:@"playy_info"];
				for (NSDictionary *playyDictionary in playyArray)
				{
					NSArray *fileinfoArray = [playyDictionary objectForKey:@"file_info"];					
					for (NSDictionary *fileDictionary in fileinfoArray)
					{					
						NSString* contentType    = [dicInfo objectForKey:@"content_type"];
						NSString* preDRM		 = [dicInfo objectForKey:@"pre_drm"];
						NSString* filePath       = [fileDictionary valueForKey:@"file_path"];
						NSString* bookNumber	 = getStringValue([fileDictionary valueForKey:@"book_no"]);
						NSString* masterNumber	 = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
						NSString* fileNo		 = getStringValue([fileDictionary valueForKey:@"file_no"]);
						
						NSMutableDictionary* content = [m_ReqDictionary mutableCopy];
						
						NSLog(@"createWithContentDownload %@", content);
						[content setObject:m_ContentTitle forKey:@"title"]; 
						[content setObject:contentType forKey:@"content_type"];
						[content setObject:preDRM forKey:@"pre_drm"];
						[content setObject:filePath forKey:@"file_path_remote"];
						[content setObject:masterNumber forKey:@"master_no"];
						[content setObject:bookNumber forKey:@"book_no"];
						[content setObject:fileNo forKey:@"file_no"];
						[content setObject:bookNumber forKey:@"volume_number"];
						
						
						if (m_Type == CARTOON_CONTENT_TYPE_DOWNLOAD)
						{
							NSString* drmType = [dicResult objectForKey:@"drm_type"];
							NSString* expireDate = @"00000000";
							NSString* counter = @"0";
							
							if ([BI_DRM_TYPE_UNLIMITE isEqualToString:drmType] == YES) {
								counter = @"-1";
							}
							else if ([BI_DRM_TYPE_PERIOD isEqualToString:drmType] == YES) {
								NSString* drmValue = [dicResult objectForKey:@"drm_value"];
								NSArray* expireString = [drmValue componentsSeparatedByString:@"-"];
								
								if ([expireString count] == 2) {
									NSString* dateString = [expireString objectAtIndex:0];
									NSString* period = [expireString objectAtIndex:1];
									NSString* startString = [dateString substringWithRange:NSMakeRange(0, 8)];
									
									NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
									[dateFormatter setDateFormat:@"yyyyMMdd"];
									
									NSDate* startDate = [dateFormatter dateFromString:startString];	
									NSDate* endDate = [startDate dateByAddingTimeInterval:((60*60*24) * [period integerValue])]; 
									
									expireDate = [dateFormatter stringFromDate:endDate];
									[dateFormatter release];
									
									NSLog(@"dateString=[%@], expireString=[%@]", drmValue, expireDate);
								}
							}
							else {
								counter = getStringValue([dicResult objectForKey:@"drm_value"]);
							}
							
							//NSLog(@"createWithContentDownload %@", content);
							
							
							NSDictionary *currentVolume = [PBDatabase getBookContent:masterNumber fileNumber:getStringValue([m_ReqDictionary objectForKey:@"file_no"])];
							if (currentVolume != nil)
							{
								[content setObject:[currentVolume objectForKey:@"main_group"] forKey:@"main_group"];
								[content setObject:[currentVolume objectForKey:@"sub_group"] forKey:@"sub_group"];
								[content setObject:[currentVolume objectForKey:@"title"] forKey:@"content_title"];
								[content setObject:[currentVolume objectForKey:@"writer"] forKey:@"writer"];
								//[content setObject:[currentVolume objectForKey:@"file_path"] forKey:@"file_path"];
								
								
								NSData* imageData = [currentVolume objectForKey:@"title_image"];								
								[content setObject:imageData forKey:@"title_image"];
							}
							
							[content setObject:drmType forKey:@"drm_type"];
							[content setObject:expireDate forKey:@"expiredt"];	
							[content setObject:counter forKey:@"counter"];
							NSLog(@"createWithContentDownload %@", content);
							
							MyBookGallaryViewController* gallaryViewController = [MyBookGallaryViewController createWithContentDownload:content];
							if (gallaryViewController != nil) {		
								[APPDELEGATE.m_MyBookMainViewController.view addSubview:gallaryViewController.view];		
							}
							
							[self pbnClickRightButton:nil];
							
							return;
						}
						else if (m_Type == CARTOON_CONTENT_TYPE_STREAM)
						{	
							//NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
							//NSString* fileNumber   = getStringValue([m_ReqDictionary objectForKey:@"file_no"]);		
							//NSString* userNumber   = [UserProfile getUserNo];
							//NSString* pageNumber =  [NSString stringWithFormat:@"%d", [self getCurrentPage]];
							
							//[self pbnClickRightButton:nil];
							
							//[m_Request continueViewInsWithMasterNo:masterNumber userNo:userNumber replayNo:pageNumber fileNo:fileNumber delegate:self];

							EpubViewController* epubViewController = [EpubViewController createWithContentsStreaming:content];
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_READCHANGED object:nil userInfo:content];
                            
							if (epubViewController != nil) {
								[APPDELEGATE.m_Window addSubview:epubViewController.view];
							}
							
							[self close];
							[self.view removeFromSuperview];
							[self release];
							
						}
					}
				}
			}
			else 
			{
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"안내" 
																	message:RESC_STRING_NO_AUTHORITY 
																   delegate:nil cancelButtonTitle:@"확인" 
														  otherButtonTitles:nil];
				[alertView show];
				[alertView release];
				
				[self close];		
				[self.view removeFromSuperview];
				[self release];
			}
		}
		else
		{
			//Show Error Message
		}
	}
	else if (command == DF_URL_CMD_CONTINUE_VIEW)
	{
		m_ReplayNo = 0;
		
		NSDictionary *dicInfo = (NSDictionary *) userInfo;
		
		NSDictionary *data = [dicInfo objectForKey:@"data"];
		
		NSInteger rCode = [[data objectForKey:@"result_code"] intValue];
		
		if (rCode == 0){
			NSDictionary *result = [data objectForKey:@"result"];			
			NSString *strReplayNo = [result objectForKey:@"replay_no"];
			if (strReplayNo != nil)
			{
				NSString *tmpString;
				NSScanner *scanner = [NSScanner scannerWithString:strReplayNo];
				if ([scanner scanUpToString:@"|" intoString:&tmpString]){
					m_ReplayNo = [tmpString intValue];					
				}
			}
			NSLog(@"replay_no : %@", [result objectForKey:@"replay_no"]);
			
			m_SampleCount = [[m_ReqDictionary objectForKey:@"sample_count"] intValue];
			if (m_SampleCount > 0)
			{
				m_ReplayNo = 1;
			}
			m_MoveToReplayNo = (m_ReplayNo > 1) ? YES : NO;
			
			if (m_MoveToReplayNo == YES) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" 
																	message:RESC_STRING_SHOW_LAST_PAGE_QUESTION 
																   delegate:self 
														  cancelButtonTitle:@"예" 
														  otherButtonTitles:@"아니오",nil];		
				
				alertView.tag = ACTIONSHEET_MOVE_REPLAY_PAGE;
				
				[alertView show];
				[alertView release];
			}						
			else {
				[self __requestStreamingContent];
			}

		}
	}
	else if (command == DF_URL_CMD_CONTINUE_VIEW_INS)
	{
		if (CALLER_STATUS_CHECKPURCHASE == m_NextViewCaller.mCurrentStatus)
		{
			[m_Request checkBuyWithDomain:BI_PURCHASE_DOMAIN userNo:[UserProfile getUserNo] fileNo:[m_NextViewCaller getNextVolumeFileNumber] delegate:self];						
		}
		else 
		{
			//중간종료
			if (m_ActivityIndicator != nil) {
				m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
			}
			
			if (m_isBrowserCalledStreaming){
                UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@""message:RESC_STRING_OPEN_REQUEST_BROWSER delegate:self cancelButtonTitle:@"취소"otherButtonTitles:@"확인", nil];
                pAlertView.tag = ACTIONSHEET_OPEN_REQUEST_BROWSER;
                [pAlertView show];
                [pAlertView release];
            }
            else{
                [self close];
                [self.view removeFromSuperview];
                [self release];
            }
		}
	}
	else if (command == DF_URL_CMD_GOODS_CNT)
	{
		NSLog(@"DF_URL_CMD_GOODS_CNT");
		NSString* fileNumber   = getStringValue([m_ReqDictionary objectForKey:@"file_no"]);		
		NSString* volumeNumber   = getStringValue([m_ReqDictionary objectForKey:@"book_no"]);		
		
		NSDictionary *dicInfo = (NSDictionary *) userInfo;
		[m_NextViewCaller setGoodsVolumes:dicInfo];
		[m_NextViewCaller setNextVolumes:(NSDictionary *)dicInfo fileNumber:fileNumber bookVolume:volumeNumber];
		m_NextViewCaller.mCurrentStatus = CALLER_STATUS_GOOLVOLUMES;
		
		//download, streaming		
	}
}


- (void) __requestStreamingContent
{	
	m_NextViewCaller = [[NextViewCaller alloc]initWithContentType:CARTOON_CONTENT_TYPE_STREAM];
	
	NSString* userId     = [UserProfile getUserID];
	NSString* userNo     = [UserProfile getUserNo];
	NSString* deviceKey  = [SettingPreference getDeviceKey];
	NSString* fileNumber = getStringValue([m_ReqDictionary objectForKey:@"file_no"]);
	NSString* fileType   = getStringValue([m_ReqDictionary objectForKey:@"pre_drm"]);
	
	[m_Request downloadContentsWithContentId:fileNumber
									  userID:userId 
								  userNumber:userNo 
									filePath:[m_ReqDictionary objectForKey:@"file_path_remote"]
									fileType:fileType
								   deviceKey:deviceKey 
								 contentType:[m_ReqDictionary objectForKey:@"content_type"]
									delegate:self];	
}

@end
