//
//  CartoonViewController.m
//  PlayBook
//
//  Created by 전명곤 on 11. 11. 16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CartoonViewController.h"
#import "CartoonViewForm.h"
#import "UIImage+Brightness.h"
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
#define ACTIONSHEET_REPLAYNOUSE					6
#define ACTIONSHEET_OPEN_REQUEST_BROWSER		7

#define degreesToRadian(x)  ( M_PI * (x) / 180.0)



@implementation CartoonViewController

@synthesize m_ScrollView;
@synthesize m_ImageView;
@synthesize m_ScreenGuid;
@synthesize m_NavigationBar;
@synthesize m_PanelBar;
@synthesize m_CartoonContent;
@synthesize m_ContentTitle;
@synthesize m_FileName;
@synthesize m_ReqDictionary;
@synthesize m_Request;
@synthesize m_NextViewCaller;
@synthesize m_DRMRetryCount;
@synthesize m_GoodsCntRetryCount;

- (CGRect) __calcImage:(UIImage *)image
{
	CGRect				rcImage;
	
	UIDeviceOrientation orientation	= m_OrientationLock;
	if (m_IsContentLoaded == YES && m_bScreenLock == NO) {
		orientation = m_CurrentOrientation;
	}

	if (image == nil)
	{
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
		{
			rcImage = CGRectMake(0.0f, 0.0f, DF_FORM_CTV_HORZ_WIDTH, DF_FORM_CTV_HORZ_HEIGHT);
		}
		else 
		{
			rcImage = CGRectMake(0.0f, 0.0f, DF_FORM_CTV_VERT_WIDTH, DF_FORM_CTV_VERT_HEIGHT);
		}

		return rcImage;
	}
	
	CGFloat	ratio	= 0.0f;
	CGFloat	height	= 0.0f;
	
	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		ratio	= DF_FORM_CTV_HORZ_WIDTH / image.size.width;
		height	= DF_FORM_CTV_HORZ_HEIGHT;
	}
	else 
	{
		ratio	= DF_FORM_CTV_VERT_WIDTH / image.size.width;
		height	= DF_FORM_CTV_VERT_HEIGHT;
	}
	
	rcImage.size.width	= image.size.width * ratio;
	rcImage.size.height	= image.size.height * ratio;
	
	rcImage.origin.x	= 0.0f;
	
	if (rcImage.size.height < height)
	{
		rcImage.origin.y = (height - rcImage.size.height) / 2.0f;
	}
	else 
	{
		rcImage.origin.y = 0.0f;
	}
	
	return rcImage;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

+ (id) createWithContentsStreaming:(NSDictionary*)dicStreaming
{	
	CartoonViewController *	cartoonViewController = (CartoonViewController *)[[CartoonViewController alloc] initWithNibName:@"CartoonViewController" bundle:[NSBundle mainBundle]];
	if (cartoonViewController == nil)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
															message:RESC_STRING_NOT_CREATE_CARTOON_VIEW 
														   delegate:nil cancelButtonTitle:@"확인" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return nil;
	}
	[cartoonViewController setContentType:CARTOON_CONTENT_TYPE_STREAM];		
	cartoonViewController.m_ReqDictionary = dicStreaming;
	cartoonViewController.m_DRMRetryCount = 0;
    
	NSString* contentTitle = [dicStreaming objectForKey:@"content_title"];
	if (contentTitle != nil) {
		cartoonViewController.m_ContentTitle = contentTitle;
	}
	else {
		cartoonViewController.m_ContentTitle = [dicStreaming objectForKey:@"title"];
	}
	
	CGRect rcFrame = cartoonViewController.view.frame;
	rcFrame.origin.y = 20.0f;
	[cartoonViewController.view setFrame:rcFrame];

//	NSLog(@"dicStreaming=[%@]", dicStreaming);

	[cartoonViewController __requestContinueView];
	
	return cartoonViewController;
}

- (BOOL) __requestContinueView
{
	m_HeaderInit = NO;
	m_ShowImage = NO;
	m_Request = [[PlayBookRequest alloc] init];
	
	return [m_Request continueViewWithMasterNo:getStringValue([m_ReqDictionary objectForKey:@"master_no"])
										userNo:[UserProfile getUserNo]
										fileNo:getStringValue([m_ReqDictionary objectForKey:@"file_no"])
									  delegate:self];
}

+ (id) createWithContentsOfFile:(NSString *)fileName title:(NSString *)title dicDownload:(NSMutableDictionary*)dicDownload
{
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
	
	CartoonViewController *	cartoonViewController = (CartoonViewController *)[[CartoonViewController alloc] initWithNibName:@"CartoonViewController" bundle:[NSBundle mainBundle]];
	if (cartoonViewController == nil)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
															message:RESC_STRING_NOT_CREATE_CARTOON_VIEW 
														   delegate:nil cancelButtonTitle:@"확인" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return nil;
	}
	
	[cartoonViewController setContentType:CARTOON_CONTENT_TYPE_DOWNLOAD];
	
	cartoonViewController.m_NextViewCaller = [[NextViewCaller alloc]initWithContentType:CARTOON_CONTENT_TYPE_DOWNLOAD];
	cartoonViewController.m_FileName = fileName;
	cartoonViewController.m_ReqDictionary = dicDownload;

	NSString* contentTitle = [dicDownload objectForKey:@"content_title"];
	if (contentTitle != nil) {
		cartoonViewController.m_ContentTitle = contentTitle;
	}
	else {
		cartoonViewController.m_ContentTitle = title;		
	}
	
	
	return cartoonViewController;
}

+ (id) createWithData:(NSData *)data title:(NSString *)title type:(NSInteger)type
{
	if (data == nil)
	{
		return nil;
	}
	
	if ([data length] == 0)
	{
		return nil;
	}
	
	CartoonViewController *	cartoonViewController = (CartoonViewController *)[[CartoonViewController alloc] initWithNibName:@"CartoonViewController" bundle:[NSBundle mainBundle]];
	if (cartoonViewController == nil)
	{
		return nil;
	}
	
	BOOL bRet = [cartoonViewController setData:data title:title type:type];
	if (bRet == NO)
	{
		[cartoonViewController release];
		return nil;
	}
	
	CGRect rcFrame = cartoonViewController.view.frame;
	rcFrame.origin.y = 20.0f;
	[cartoonViewController.view setFrame:rcFrame];

	return cartoonViewController;
}

- (void) setContentType:(NSInteger)type
{
	m_Type = type;
}

- (BOOL) setContentOfFile:(NSString *)fileName title:(NSString *)title type:(NSInteger)type
{
	if (m_CartoonContent != nil)
	{
		[m_CartoonContent release];
		m_CartoonContent = nil;
	}
	
	m_bScreenLock	= NO;
	m_ContentTitle	= @"";
	m_Brightness	= 0.0f;

	m_ContentTitle = title;
	
	NSString *		path = [JMDevKit appDocumentFilePath:fileName];
	NSFileManager *	fm	 = [NSFileManager defaultManager];
	
	if ([fm fileExistsAtPath:path] == NO)
	{
		[fm release];
		
		return NO;
	}
	[fm release];
	
	NSData *	data = [NSData dataWithContentsOfFile:path];
	if (data == nil)
	{
		return NO;
	}
	
	[self initializeDRMWithData:data];
	[data release];
	
	if (m_CartoonContent == nil)
	{
		return NO;
	}
	
	return YES;
}

- (BOOL) setData:(NSData *)data title:(NSString *)title type:(NSInteger)type
{
	if (m_CartoonContent != nil)
	{
		[m_CartoonContent release];
		m_CartoonContent = nil;
	}
	
	m_bScreenLock	= NO;
	m_ContentTitle	= @"";
	m_Brightness	= 0.0f;
	
	m_ContentTitle = title;

	m_CartoonContent = [[CartoonContent alloc] initWithData:data contentType:type];
	if (m_CartoonContent == nil)
	{
		return NO;
	}
	
	[m_CartoonContent appendWithData:nil header:0 length:m_DecodeOffset];
	
	return YES;
}


- (NSString*)getValidTitle:(NSString*)inTitle bookNo:(NSString*)book_no
{
	NSString *title = nil;
	
	NSRange range = [inTitle rangeOfString:@"권"];
	if (range.location != NSNotFound)
	{
		if (range.location == [inTitle length] - 1)
		{
			NSString *num = [inTitle substringWithRange:NSMakeRange(range.location - 1, 1)];
			
			if (num != nil){
				range = [@"0123456789" rangeOfString:num];
				
				if (range.location != NSNotFound){
					title = inTitle;
				}
			}
		}
	}
	
	if (title == nil){
		title = [NSString stringWithFormat:@"%@ %@권", inTitle, book_no];
	}
	
	return title;
}


- (void)showImage
{
	UIImage *	image	= [m_CartoonContent nextPage];
	m_rcImage = [self __calcImage:image];
	
	[m_ScrollView setZoomScale:1.0f];
	[m_ScrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
	[m_ScrollView setContentSize:CGSizeMake(m_rcImage.size.width, m_rcImage.size.height)];
	[m_ImageView setFrame:CGRectMake(m_rcImage.origin.x, m_rcImage.origin.y, m_rcImage.size.width, m_rcImage.size.height)];
	
	if(image != nil)
	{
		[m_ImageView setImage:image];
	}
	
	if (m_PanelBar != nil)
	{
		[m_NavigationBar showBar:NO];
		[m_PanelBar showBar:NO];

		NSString *volume_number = getStringValue([m_ReqDictionary objectForKey:@"book_no"]);
        if (volume_number == nil){
            volume_number = getStringValue([m_ReqDictionary objectForKey:@"volume_number"]);
        }
        
        NSString *title = [NSString stringWithFormat:@"%@ %@권", m_ContentTitle, volume_number];
		[m_NavigationBar setTitle:title];
		[m_PanelBar setPageWithMin:1.0f max:(CGFloat)[m_CartoonContent getFullPageCount]];
		[m_PanelBar setcurrentPage:(CGFloat)m_ReplayNo];
		[m_PanelBar setBrightness:0.0f];
	}
	
	[self setCurrentPage:(CGFloat)m_ReplayNo];
	
	m_ShowImage = YES;
}


- (NSInteger) getCurrentPage
{
	if (m_CartoonContent == nil)
	{
		return 0;
	}
	
	NSInteger pageNumber = [m_CartoonContent getCurrentPageNumber];
	
	return pageNumber;
}

- (BOOL) setCurrentPage:(CGFloat)currentPage
{
	if (m_SampleCount > 0 && currentPage > m_SampleCount)
	{
		currentPage = m_SampleCount;		
	}
	
	if (m_CartoonContent == nil)
	{
		return NO;
	}
	
	if ([m_CartoonContent getCurrentPageNumber] == currentPage)
	{
		return NO;
	}
	
	if (currentPage <= 0.0f)
	{
		return NO;
	}
	
	if ([m_CartoonContent getPageCount] < currentPage)
	{
		return NO;
	}
	
	//m_Brightness = 0.0f;
	//[m_PanelBar setBrightness:0.0f];
	
	[m_CartoonContent setCurrentPageNumber:currentPage];
	[m_PanelBar setcurrentPage:currentPage];
	
	UIImage *	image = [m_CartoonContent currentPage];

	m_rcImage	= [self __calcImage:image];
	
	image = [image imageWithBrightness:m_Brightness];
	
	[m_ScrollView setZoomScale:1.0f];
	[m_ScrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
	[m_ScrollView setContentSize:CGSizeMake(m_rcImage.size.width, m_rcImage.size.height)];
	[m_ImageView setFrame:CGRectMake(m_rcImage.origin.x, m_rcImage.origin.y, m_rcImage.size.width, m_rcImage.size.height)];
	
	if (image != nil)
	{
		[m_ImageView setImage:image];
	}
	
	return YES;
}

- (NSUInteger) getPageCount
{
	if (m_CartoonContent == nil)
	{
		return 0;
	}
	
	NSUInteger pageCount = [m_CartoonContent getPageCount];
	
	return pageCount;
}

- (void) setDelegate:(id)delegate
{
	m_Delegate = delegate;
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

	APPDELEGATE.m_CartoonViewController = self;
	
	[self.view setFrame:CGRectMake(0, 0, DF_FORM_CTV_VERT_WIDTH, DF_FORM_CTV_VERT_HEIGHT)];
	
	m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:self.view 
																	  textInd:@"로딩중..."
																  orientation:UIDeviceOrientationPortrait];
	m_IsContentLoaded = NO;
	m_isClosed = NO;
	m_bScreenLock = NO;	
	m_OrientationLock = UIDeviceOrientationPortrait;
	m_CurrentOrientation = UIDeviceOrientationPortrait;
	
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
			BOOL bRet = [self setContentOfFile:m_FileName title:m_ContentTitle type:m_Type];
			
			dispatch_async(dispatch_get_main_queue(), ^{

				m_Request = [[PlayBookRequest alloc] init];
				
				if (m_ActivityIndicator != nil) {
					m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
				}
				if (m_isClosed == YES) { return; }
/*				
				[m_NavigationBar showBar:NO];
				[m_PanelBar showBar:NO];
*/				
				if (bRet == YES) 
				{
					NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
					NSString* fileNumber   = getStringValue([m_ReqDictionary objectForKey:@"file_no"]);		
					
					m_ReplayNo = [PBDatabase getBookReadPosition:masterNumber filaNumber:fileNumber];					
					[m_CartoonContent setCurrentPageNumber:(m_ReplayNo == 0 ? 1 : m_ReplayNo)];
					
					
					UIImage* image	= [m_CartoonContent currentPage];					
					m_rcImage = [self __calcImage:image];
					
					[m_ScrollView setZoomScale:1.0f];
					[m_ScrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
					[m_ScrollView setContentSize:CGSizeMake(m_rcImage.size.width, m_rcImage.size.height)];
					[m_ImageView setFrame:CGRectMake(m_rcImage.origin.x, m_rcImage.origin.y, m_rcImage.size.width, m_rcImage.size.height)];
					
					if (image != nil) {
						[m_ImageView setImage:image];	
					}

					NSString *volume_number = getStringValue([m_ReqDictionary objectForKey:@"book_no"]);
                    if (volume_number == nil){
                        volume_number = getStringValue([m_ReqDictionary objectForKey:@"volume_number"]);
                    }
                    
                    NSString *title = [NSString stringWithFormat:@"%@ %@권", m_ContentTitle, volume_number];
					[m_NavigationBar setTitle:title];
					[m_PanelBar setPageWithMin:1.0f max:(CGFloat)[m_CartoonContent getPageCount]];
					[m_PanelBar setcurrentPage:1.0f];
					[m_PanelBar setBrightness:0.0f];
					
					[self showImage];

					m_IsContentLoaded = YES;					
					[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];					
					
					if ([SettingPreference getShowScreenGuide:YES] == NO) {
						m_ScreenGuid = [ScreenGuide createWithDelegate:self];
						[self.view addSubview:m_ScreenGuid];
					}
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
	
	// navigation
	m_NavigationBar = [PBNavigationBar createWithType:PB_PANEL_BAR_TYPE_CARTOON orientation:UIDeviceOrientationPortrait delegate:self];

	NSString *volume_number = getStringValue([m_ReqDictionary objectForKey:@"book_no"]);
    if (volume_number == nil){
        volume_number = getStringValue([m_ReqDictionary objectForKey:@"volume_number"]);
    }
    
	NSString *title = [NSString stringWithFormat:@"%@ %@권", m_ContentTitle, volume_number];
	[m_NavigationBar setTitle:title];
	[self.view addSubview:m_NavigationBar];
	
	// panel bar
	m_PanelBar = [PBPanelBar createWithType:PB_PANEL_BAR_TYPE_CARTOON orientation:UIDeviceOrientationPortrait delegate:self];
	[m_PanelBar setPageWithMin:0.0f max:0.0f];
	[m_PanelBar setcurrentPage:0.0f];
	[self.view addSubview:m_PanelBar];
	
	[m_ScrollView setTouchDelegate:self];

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
	else {
		[self.view setFrame:CGRectMake(0, 0, DF_FORM_CTV_VERT_WIDTH, DF_FORM_CTV_VERT_HEIGHT)];
	}

/*	
	if (m_CartoonContent != nil)
	{
		UIImage * image = [m_CartoonContent currentPage];
		if (image != nil) {		
			m_rcImage	= [self __calcImage:image];
			[m_ImageView setImage:image];
		}
		
		[m_ImageView setFrame:CGRectMake(m_rcImage.origin.x, m_rcImage.origin.y, m_rcImage.size.width, m_rcImage.size.height)];
		[m_ScrollView setContentSize:CGSizeMake(m_rcImage.size.width, m_rcImage.size.height)];
	}
	else 
 */
	{
	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
		[m_ImageView setFrame:CGRectMake(0, 0, 480, 320)];
		[m_ScrollView setContentSize:CGSizeMake(480, 320)];
	}
	else {			
		[m_ImageView setFrame:CGRectMake(0, 0, 320, 480)];
		[m_ScrollView setContentSize:CGSizeMake(320, 480)];
	}
	}
	
	[m_NavigationBar showBar:YES];
	[m_PanelBar showBar:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
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
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration: 0.3];

		[self orientationTransformBounds:deviceOrientation];

		[m_ScrollView setZoomScale:1.0f];
		[m_ScrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
		
		m_rcImage = [self __calcImage:m_ImageView.image];

		if (deviceOrientation == UIDeviceOrientationLandscapeLeft || deviceOrientation == UIDeviceOrientationLandscapeRight) {
			[m_ScrollView setFrame:CGRectMake(0, 0, DF_FORM_CTV_HORZ_WIDTH, DF_FORM_CTV_HORZ_HEIGHT)];
		}
		else {
			[m_ScrollView setFrame:CGRectMake(0, 0, DF_FORM_CTV_VERT_WIDTH, DF_FORM_CTV_VERT_HEIGHT)];
		}
			
		[m_ImageView setFrame:CGRectMake(m_rcImage.origin.x, m_rcImage.origin.y, m_rcImage.size.width, m_rcImage.size.height)];			
		[m_ScrollView setContentSize:CGSizeMake(m_rcImage.size.width, m_rcImage.size.height)];
		
		[m_NavigationBar resize:deviceOrientation];
		[m_PanelBar resize:deviceOrientation];
		
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
	NSLog(@"Cartoon Viewer Dealloc");
	
	@try {		
		[m_NextViewCaller release];
		
		if (m_ReqDictionary != nil) {
			[m_ReqDictionary release];
		}
		[m_ContentTitle release];
		[m_FileName release];
		[m_ScrollView release];
		[m_ImageView release];
		
		m_Delegate = nil;
	}
	@catch (NSException * e) {
		NSLog(@"dealloc exception %@", e);
	}
	@finally {
		
	}
	
    [super dealloc];
}

- (void) close
{	
	m_isClosed = YES;
	
	APPDELEGATE.m_CartoonViewController = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)UIDeviceOrientationPortrait animated:NO];
	
	[self.m_PanelBar _hideSubPopup:SUB_POPUP_NONE];

	@try {
		if (m_Request != nil){
			if ([m_Request isDownloading] == YES){
				[m_Request cancelConnection];				
			}	
			[m_Request release];
		}
		
		if (m_NavigationBar != nil)
		{
			[m_NavigationBar close];
		}	
		
		if (m_PanelBar != nil)
		{
			[m_PanelBar close];
		}
		
		if (self.m_CartoonContent != nil)
		{
			[self.m_CartoonContent release];
		}
	}
	@catch (NSException * e) {
		NSLog(@"close exception %@", e);
	}
	@finally {
		
	}
}

- (void) touchScreenGuid:(UIEvent*)event
{
	[SettingPreference setShowScreenGuide:YES bShow:YES];
	
	[m_ScreenGuid removeFromSuperview];
	[m_ScreenGuid release];
	m_ScreenGuid = nil;
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
	return m_ImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	if (scrollView.zoomScale >= 1.0f &&scrollView.frame.size.height > m_rcImage.size.height)
	{
		CGFloat newHeight = m_rcImage.size.height * scrollView.zoomScale;
		
		if (newHeight < scrollView.frame.size.height)
		{
			CGRect rcImageView = m_ImageView.frame;
			rcImageView.origin.y = (scrollView.frame.size.height - newHeight) / 2.0f;
			[m_ImageView setFrame:rcImageView];
		}
		else 
		{
			CGRect rcImageView = m_ImageView.frame;
			rcImageView.origin.y = 0.0f;
			[m_ImageView setFrame:rcImageView];
		}
	}
}

- (UIDeviceOrientation) getCurrentOrientation
{
    return m_CurrentOrientation;
}

- (void) touchScrollViewWithPos:(NSInteger)pos
{
	if ([m_NavigationBar isShowBar] == YES)
	{
		[m_NavigationBar showBar:NO];
		[m_PanelBar showBar:NO];
		
		return;
	}
	
	NSLog(@"pos=[%d]", pos);
	
	
	if (pos == 1)
	{
		if (m_ShowImage != YES){
			return;
		}
		
		if (m_CartoonContent == nil) {
			return;
		}
		
		//m_Brightness = 0.0f;
		//[m_PanelBar setBrightness:0.0f];
		
		UIImage *	image = [m_CartoonContent previousPage]; 

		if (image != nil)
		{
			m_rcImage	= [self __calcImage:image];
			image = [image imageWithBrightness:m_Brightness];
		
			[m_ScrollView setZoomScale:1.0f];
			[m_ScrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
			[m_ScrollView setContentSize:CGSizeMake(m_rcImage.size.width, m_rcImage.size.height)];
			[m_ImageView setFrame:CGRectMake(m_rcImage.origin.x, m_rcImage.origin.y, m_rcImage.size.width, m_rcImage.size.height)];
			[m_ImageView setImage:image];
			
			[m_PanelBar setcurrentPage:(CGFloat)[m_CartoonContent getCurrentPageNumber]];
		}
	}
	else if (pos == 2)
	{
		BOOL bShowNavi = [m_NavigationBar isShowBar];
		[m_NavigationBar showBar:!bShowNavi];
		[m_PanelBar showBar:!bShowNavi];	
		
		[m_PanelBar setBrightness:m_Brightness];
	}
	else if (pos == 3)
	{
		if (m_ShowImage != YES){
			return;
		}
		
		if (m_SampleCount > 0)
		{
			if ([self getCurrentPage] >= m_SampleCount){		
				UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@"" message:RESC_STRING_SAMPLE_LAST_PAGE delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				pAlertView.tag = ACTIONSHEET_SAMPLEPAGE_END;
				[pAlertView show];	
				[pAlertView release];
				
				return;
			}
		}
		
		if (m_CartoonContent == nil) {
			return;
		}

		//When downloading 
		if ([m_CartoonContent getCurrentPageNumber] < [m_CartoonContent getFullPageCount])
		{
			if ([m_CartoonContent getCurrentPageNumber] + 1 > [m_CartoonContent getPageCount])
				return;
		}
		
		//m_Brightness = 0.0f;
		//[m_PanelBar setBrightness:0.0f];

		UIImage *	image = [m_CartoonContent nextPage];
		
		if (image != nil)
		{
			m_rcImage	= [self __calcImage:image];
			image = [image imageWithBrightness:m_Brightness];

			[m_ScrollView setZoomScale:1.0f];
			[m_ScrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
			[m_ScrollView setContentSize:CGSizeMake(m_rcImage.size.width, m_rcImage.size.height)];
			[m_ImageView setFrame:CGRectMake(m_rcImage.origin.x, m_rcImage.origin.y, m_rcImage.size.width, m_rcImage.size.height)];
			[m_ImageView setImage:image];
			
			[m_PanelBar setcurrentPage:(CGFloat)[m_CartoonContent getCurrentPageNumber]];
			[self setCurrentPage:(CGFloat)[m_CartoonContent getCurrentPageNumber]];
		}
		else 
		{
			if ([m_CartoonContent getCurrentPageNumber] == [m_CartoonContent getFullPageCount])
			{
				if (CARTOON_CONTENT_TYPE_DOWNLOAD == m_Type)
				{
					UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@"" message:RESC_STRING_COMPLETE_BOOK_MESSAGE delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
					[pAlertView show];	
					[pAlertView release];
				}
				else {
					[self RequestLastNextPage];
				}
			}
		}
	}
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
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	NSLog(@"buttonIndex=[%d]", buttonIndex);
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
							
							CartoonViewController* cartoonViewController = [CartoonViewController createWithContentsOfFile:filePathLocal title:[nextVolume objectForKey:@"title"] dicDownload:content];
							if (cartoonViewController != nil)
							{
								[APPDELEGATE.m_Window addSubview:cartoonViewController.view];
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
							NSString* pageNumber =  [NSString stringWithFormat:@"%d", [self getCurrentPage]];
							NSString* fileNumber   = getStringValue([m_ReqDictionary objectForKey:@"file_no"]);
							m_NextViewCaller.mCurrentStatus = CALLER_STATUS_CHECKPURCHASE;
							[m_Request continueViewInsWithMasterNo:masterNumber userNo:[UserProfile getUserNo] replayNo:pageNumber fileNo:fileNumber delegate:self];
						}
						
						//							[m_Request checkBuyWithDomain:BI_PURCHASE_DOMAIN userNo:[UserProfile getUserNo] fileNo:[m_NextViewCaller getNextVolumeFileNumber] delegate:self];						
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
			
		case ACTIONSHEET_REPLAYNOUSE:
			
			if (buttonIndex == 1){
				m_ReplayNo = 1;
			}
			
			[self __requestStreaming];
			
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

/*
- (void) setContentTitle:(NSString *)contentTitle
{
	m_ContentTitle = contentTitle;
	[m_NavigationBar setTitle:m_ContentTitle];
}
*/

- (void) updateLocalFilePosition
{
	NSUInteger	currentPageIndex	= (NSUInteger)[self getCurrentPage];
	if (currentPageIndex > 0) {
		NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
		NSString* fileNumber   = getStringValue([m_ReqDictionary objectForKey:@"file_no"]);		
		
		[PBDatabase updateBookContentWithReadState:masterNumber fileNumber:fileNumber readState:0 readPosition:currentPageIndex];
	}
}	

#pragma mark -
#pragma mark PBNavigationBarDelegate
- (void) pbnClickRightButton:(id)sender
{
	if (m_ShowImage == NO){
        if ([m_Request isDownloading] == YES) {
            [m_Request cancelConnection];
        }
		
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
    
	if (m_ActivityIndicator == nil) {
		UIDeviceOrientation orientation = (m_bScreenLock == YES) ? m_OrientationLock : m_CurrentOrientation;
		m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:self.view textInd:@"종료중..." orientation:orientation];
	}
	else {
		[m_ActivityIndicator setTextInd:@"종료중..."];
	}

	if (![m_Delegate isKindOfClass:[NSNull class]])	{
		[m_Delegate cvcCloseCartoonView];
	}
	
	if (m_Type == CARTOON_CONTENT_TYPE_DOWNLOAD) 
	{
		if (m_IsContentLoaded == NO) { return; }
		
		[self updateLocalFilePosition];
	
		[self close];		
		[self.view removeFromSuperview];
		[self release];		
	}
	else 
	{
		if ([m_Request isDownloading] == YES) {
			
            if ([m_Request getCommand] == DF_URL_CMD_CONTINUE_VIEW_INS)
            {
                [m_Request cancelConnection];
                
                [self close];		
                [self.view removeFromSuperview];
                [self release];
                return;
            }
		}
		
        [m_Request cancelConnection];
		
		NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
		NSString* fileNumber   = getStringValue([m_ReqDictionary objectForKey:@"file_no"]);		
		NSString* userNumber   = [UserProfile getUserNo];
		NSString* pageNumber =  [NSString stringWithFormat:@"%d", [self getCurrentPage]];

		[m_Request continueViewInsWithMasterNo:masterNumber userNo:userNumber replayNo:pageNumber fileNo:fileNumber];
	}
}

#pragma mark -
#pragma mark PBPanelBarDelegate
- (void) pbpChangePage:(CGFloat)pageNumber
{
	if (m_ShowImage != YES){
		return;
	}
	
	if ([m_CartoonContent getCurrentPageNumber] == pageNumber)
	{
		return;
	}
	
	if (m_SampleCount > 0)
	{
		if (pageNumber > m_SampleCount)
		{
			pageNumber = [m_CartoonContent getCurrentPageNumber];
			[m_PanelBar setcurrentPage:pageNumber];
		}
	}
	
	if ([m_CartoonContent getPageCount] < pageNumber)
    {
        [m_PanelBar setcurrentPage:[m_CartoonContent getCurrentPageNumber]];
        return;
    }
	
	[m_CartoonContent setCurrentPageNumber:pageNumber];
	
	UIImage *	image = [m_CartoonContent currentPage];
	
	m_rcImage	= [self __calcImage:image];
	image = [image imageWithBrightness:m_Brightness];
		
	[m_ScrollView setZoomScale:1.0f];
	[m_ScrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
	[m_ScrollView setContentSize:CGSizeMake(m_rcImage.size.width, m_rcImage.size.height)];
	[m_ImageView setFrame:CGRectMake(m_rcImage.origin.x, m_rcImage.origin.y, m_rcImage.size.width, m_rcImage.size.height)];
	[m_ImageView setImage:image];
}

- (void) pbpChangeBrightness:(CGFloat)brightness
{
	m_Brightness = brightness;
	
	UIImage *	image = [m_CartoonContent currentPage]; 
	UIImage *processImage = [image imageWithBrightness:brightness];
	
	[m_ImageView setImage:processImage];
}

- (void) pbpChangeScreenLock:(id)sender lock:(BOOL)bLock
{
	m_CurrentOrientation = [[UIDevice currentDevice] orientation]; 
	m_OrientationLock = m_CurrentOrientation;
	
	m_bScreenLock = bLock;
}

- (BOOL) initializeDRMWithData:(NSData *)data
{
	XDRM_RESULT	DRMResult;
	HANDLE		hContext = NULL;	
	int dueToRead = 0;
	
	time_t		ttSetTime = 0;	
	/*
	 struct		tm	tmSetTime = {0};
	 tmSetTime.tm_year = 112;	//	년도(1900-)
	 tmSetTime.tm_mon = 5;		//	월(0-11)
	 tmSetTime.tm_mday = 2;		//	일(1-31)
	 tmSetTime.tm_hour = 12;		//	시(0-23)
	 tmSetTime.tm_min = 0;		//	분(0-59)
	 tmSetTime.tm_sec = 1;		//	초(0-59)
	 ttSetTime = mktime(&tmSetTime);
	 */
	
	
	HANDLE hXSync = [(PlayBookAppDelegate*)[[UIApplication sharedApplication] delegate] getDRMHandle];
	
	if (XDRM_SUCCESS != (DRMResult = XSYNC_Open_BufferedMode(hXSync, ttSetTime, &hContext, &dueToRead)))
	{		
		NSLog(@"XSYNC_Open_BufferedMode result : %08x", DRMResult);
		goto Error_Handler;
	}
	
    XDRM_RESULT Result;
	PXDRM_CTRL_CONTEXT pContext = hContext;
	//char* bytes	= (char *)[data bytes];
	//char*bytes = calloc(sizeof(char), [data length]);
	//memcpy(bytes, [data bytes], [data length]);
	m_DRMContext = (id)pContext;
	
	NSData*		fileData;
	NSRange		range;
	NSInteger	pos;
	
	char* bytes	= (char *)[data bytes];
	char* retPtr	= (char *)strstr((const char *)bytes, "\r\n");
	if (retPtr != NULL)
	{
		//		NSLog(@"DRM Result invalid");
		//		goto Error_Handler;		
		
		pos			= (NSInteger)(retPtr - bytes);
		
		range		= NSMakeRange(0, pos);
		fileData	= [data subdataWithRange:range];
		NSString*	retString	= [[NSString alloc] initWithBytes:[fileData bytes] length:pos encoding:NSUTF8StringEncoding];
		APDocument* xmlDoc		= [APDocument documentWithXMLString:retString];
		APElement*	rootElement	= [xmlDoc rootElement];
		NSString*	value		= [rootElement value];
		
		if ([value integerValue] != 0)
		{
			NSLog(@"DRM result : %08x", [value integerValue]);
			goto Error_Handler;
		}
		
		// binary data
		range	 = NSMakeRange((pos + 2), ([data length] - pos - 2));
		fileData = [data subdataWithRange:range];
	}
	else 
	{
		pos = -2;
		fileData = data;		
	}
	
	
	
	bytes = (char *)[fileData bytes];
	
	int readLen = dueToRead;
	int offset = 0;
	
	//
	//	DRM Header( meta & License)를 검사한다.
	//
	// 넘겨받은 헤더 사인을 검사하고, 메타 데이터 영역의 길이(dueToRead)를 리턴한다
	if (XDRM_SUCCESS == (Result = XDRM_HDR_Verify_BufferedMode(pContext, bytes, readLen, &dueToRead))) 
	{	
		offset = readLen;
		readLen = dueToRead;
		//리턴받은  메타 데이터 영역의 크기를 스트림에서 읽는다
		// 넘겨받은 메타 데이터를 복호화하여 컨텍스트(핸들)에 설정하고, 라이선스 영역의 길이를 리턴한다.
		if(XDRM_SUCCESS == (Result = XDRM_META_Verify_BufferedMode(pContext, bytes + offset, readLen, &dueToRead)))
		{
			offset += readLen;
			readLen = dueToRead;
			//스트림에서 라이선스를 읽어 온다.
			// 읽어온 라이선스 처리(검증)
			if(XDRM_SUCCESS == (Result = XDRM_LIC_Verify_BufferedMode(pContext, bytes + offset, readLen, ttSetTime)))
			{
				offset += readLen;
				
				if(XDRM_SUCCESS != (Result = XDRM_CNT_DecryptInit(pContext)))
				{
					NSLog(@"XDRM_CNT_DecryptInit : %08x", Result);
					goto Error_Handler;
				}
			}
		}
	}
	
	
	m_DecodeOffset = pos + 2 + offset;
	m_HeaderOffset = m_DecodeOffset;
	char *pBuffer = (char *)[data bytes];	
	pBuffer += m_DecodeOffset;	
	int nReadBytes = [data length] - m_DecodeOffset;
	
	if (m_Type == CARTOON_CONTENT_TYPE_STREAM){
		nReadBytes = nReadBytes - (nReadBytes % 2048);
	}
	
	nReadBytes = XSYNC_Read(hContext, pBuffer, nReadBytes);
	
	range		= NSMakeRange(m_DecodeOffset, nReadBytes);
	NSData *decodeData = [data subdataWithRange:range];
	
	m_DecodeOffset += nReadBytes;
	
	[self setData:decodeData title:m_ContentTitle type:CARTOON_CONTENT_TYPE_STREAM];
	
	m_HeaderInit = YES;
	
	[APPDELEGATE.m_Window addSubview:self.view];
	
	return YES;
	
Error_Handler:
	return NO;
}


//m_readBytes
//m_DecodeOffset - decode한 버퍼 오프셋
- (BOOL) appendDRMData:(NSData *)data length:(NSInteger)length  isLast:(BOOL)isLast
{
	if (m_DRMContext == nil)
		return NO;
	
	PXDRM_CTRL_CONTEXT pContext = (PXDRM_CTRL_CONTEXT)m_DRMContext;
	NSInteger nReadBytes = length - m_DecodeOffset;	
	char *pBuffer = (char *)[data bytes];
	pBuffer += m_DecodeOffset;
	
	if (isLast == NO) {
		nReadBytes = nReadBytes - (nReadBytes % 2048);
	}	
	
	nReadBytes = XSYNC_Read(pContext, pBuffer, nReadBytes);
	m_DecodeOffset += nReadBytes;
	
	[m_CartoonContent appendWithData:m_Request.m_ReceiveData header:m_HeaderOffset length:m_DecodeOffset];
	
	return YES;
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
		if (m_isClosed == YES) { 
			NSLog(@"m_IsClosed Is YES !!!");
			return; 
		}

#ifdef DEBUG_PROTO_LOG	
		NSLog(@"HeaderInit : %d", m_HeaderInit);
#endif	
		int length = [data length];
		
		if (m_HeaderInit == NO)
		{
			if (length > 2048 * 100)
			{
				NSLog(@"Stream Buffer Start %d", length);
				[self initializeDRMWithData:m_Request.m_ReceiveData];
				m_readBytes = length;
				
				[self.view setFrame:CGRectMake(0, 0, DF_FORM_CTV_VERT_WIDTH, DF_FORM_CTV_VERT_HEIGHT)];

				[m_PanelBar setPageWithMin:1.0f max:(CGFloat)[m_CartoonContent getFullPageCount]];				
				[m_PanelBar setcurrentPage:1.0f];
				[m_PanelBar setBrightness:0.0f];

				if (m_ActivityIndicator != nil) {
					m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
				}
				m_IsContentLoaded = YES;
				
				if ([m_CartoonContent getPageCount] > m_ReplayNo){
					[self showImage];
					[m_PanelBar setValidPage:[m_CartoonContent getPageCount]];
					
					[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
					
					if ([SettingPreference getShowScreenGuide:YES] == NO) {
						m_ScreenGuid = [ScreenGuide createWithDelegate:self];
						[self.view addSubview:m_ScreenGuid];
					}
                }
				else {
					m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:self.view 
																					  textInd:@"로딩중..."
																				  orientation:UIDeviceOrientationPortrait];
				}
			}
		}
		else {
			if ((length - m_readBytes) > 2048 * 100) {				
				[self appendDRMData:m_Request.m_ReceiveData length:length isLast:NO];
				m_readBytes += (length - m_readBytes);
				
				NSInteger count = [m_CartoonContent getPageCount];
				
				if (m_ShowImage == NO)
				{	
					if (count >= m_ReplayNo)
					{
						[self showImage];
						[m_PanelBar setValidPage:[m_CartoonContent getPageCount]];						
						
						//[m_PanelBar setPageWithMin:1.0f max:(CGFloat)count];
						//[m_PanelBar setcurrentPage:(CGFloat)[m_CartoonContent getCurrentPageNumber]];
						if (m_ActivityIndicator != nil) {
							m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
						}
						
						[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
						
						if ([SettingPreference getShowScreenGuide:YES] == NO) {
							m_ScreenGuid = [ScreenGuide createWithDelegate:self];
							[self.view addSubview:m_ScreenGuid];
						}
					}
				}
				else 
				{	
					if (m_isClosed == YES) { return; }					
					[m_PanelBar setValidPage:[m_CartoonContent getPageCount]];
					
					if (m_SampleCount > 0 && count > m_SampleCount)
						[m_Request cancelConnection];
				}
			}
		}
		
		//NSLog(@"command = DF_URL_CMD_CONTENT_DOWNLOAD : length = %d", [data length]);
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
        if (m_GoodsCntRetryCount == 0){
            NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
            NSString* contentType    = getStringValue([m_ReqDictionary objectForKey:@"content_type"]);
            
            m_GoodsCntRetryCount++;
            [m_Request goodsCntWithMasterNo:masterNumber contentType:contentType platformType:@"01" delegate:self];
        }
        else{
            m_NextViewCaller.mCurrentStatus = CALLER_STATUS_NETERROR;
        }
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

- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{

	if (command == DF_URL_CMD_CONTENT_DOWNLOAD)
	{	
		NSData *				data	= (NSData *)userInfo;
		
		TRACE(@"DF_URL_CMD_CONTENT_DOWNLOAD : length = %d", [data length]);
		
		if (m_HeaderInit == YES)
		{
			int length = [data length];
			
			if ((length - m_readBytes) > 0)
			{
				NSLog(@"Stream Buffer Ended %d", length - m_readBytes);
				
				[self appendDRMData:m_Request.m_ReceiveData length:length isLast:YES];
				m_readBytes += (length - m_readBytes);
			}
			
			if (m_ShowImage == NO)
			{	
				[self showImage];						
				
				if (m_ActivityIndicator != nil) {
					m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
				}					
			}
		}
		else {
			
            //NSString* aStr = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
            
            //NSLog(@"DF_URL_CMD_CONTENT_DOWNLOAD [%@]", aStr);
            char* bytes	= (char *)[data bytes];
            char* retPtr	= (char *)strstr((const char *)bytes, "<RESULT>0</RESULT>");
            if (retPtr == 0)
            {
                NSLog(@"DRM result : FAILED");
                
                if (m_DRMRetryCount < 4){
                    m_DRMRetryCount++;
                    [m_Request cancelConnection];
                    [self __requestStreaming];
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
            
        }
		
		if (m_ShowImage == YES){
            [m_PanelBar setValidPage:[m_CartoonContent getPageCount]];
            
            m_GoodsCntRetryCount = 0;
            NSString* masterNumber = getStringValue([m_ReqDictionary objectForKey:@"master_no"]);
            NSString* contentType    = getStringValue([m_ReqDictionary objectForKey:@"content_type"]);
            
            [m_Request goodsCntWithMasterNo:masterNumber contentType:contentType platformType:@"01" delegate:self];
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
							CartoonViewController* cartoonViewController = [CartoonViewController createWithContentsStreaming:content];
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_READCHANGED object:nil userInfo:content];
                            
							if (cartoonViewController != nil) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_READCHANGED object:nil userInfo:content];
								[APPDELEGATE.m_Window addSubview:cartoonViewController.view];
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
		m_NextViewCaller = [[NextViewCaller alloc]initWithContentType:CARTOON_CONTENT_TYPE_STREAM];
		
		NSDictionary *dicInfo = (NSDictionary *) userInfo;
		
		NSDictionary *data = [dicInfo objectForKey:@"data"];
		
		NSInteger rCode = [[data objectForKey:@"result_code"] intValue];
		
		if (rCode == 0){
			NSDictionary *result = [data objectForKey:@"result"];
			m_ReplayNo = [[result objectForKey:@"replay_no"] intValue];
			NSLog(@"replay_no : %@", [result objectForKey:@"replay_no"]);
		}
		
		if (m_ReplayNo == 0){
            m_ReplayNo = 1;
        }
		
		m_SampleCount = [[m_ReqDictionary objectForKey:@"sample_count"] intValue];
		if (m_SampleCount > 0)
		{
			m_ReplayNo = 1;
		}
		
		if (m_ReplayNo > 1)
		{
			UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@"" message:RESC_STRING_SHOW_LAST_PAGE_QUESTION delegate:self cancelButtonTitle:@"확인" otherButtonTitles:@"취소", nil];
			pAlertView.tag = ACTIONSHEET_REPLAYNOUSE;
			[pAlertView show];	
			[pAlertView release];
		}
		else {
			[self __requestStreaming];
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
		NSLog(@"getGoodVolumes.onHttpSendSuccess");
		NSString* fileNumber   = getStringValue([m_ReqDictionary objectForKey:@"file_no"]);		
		NSString* volumeNumber   = getStringValue([m_ReqDictionary objectForKey:@"book_no"]);		
		
		NSDictionary *dicInfo = (NSDictionary *) userInfo;
		[m_NextViewCaller setGoodsVolumes:dicInfo];
		[m_NextViewCaller setNextVolumes:(NSDictionary *)dicInfo fileNumber:fileNumber bookVolume:volumeNumber];
		m_NextViewCaller.mCurrentStatus = CALLER_STATUS_GOOLVOLUMES;
		
		//download, streaming		
	}

}


- (void) __requestStreaming
{
	m_readBytes = 0;
	
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
