    //
//  PlayyBookWebView.m
//  PlayBook
//
//  Created by Daniel on 12. 5. 14..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayyBookWebView.h"
#import <QuartzCore/QuartzCore.h>
#import "URLParser.h"
#import "NSDataAdditions.h"
#include "CommonCrypto/CommonCryptor.h"
#import "UserProfile.h"


@implementation PlayyBookWebView

@synthesize m_Background;
@synthesize m_LabTitle;
@synthesize m_CloseButton;
@synthesize m_CloseArrow;
@synthesize m_WebView;

@synthesize m_TitleName;
@synthesize m_ReqURLString;

@synthesize m_Delegate;
@synthesize m_WebViewType;

+ (id) createWithTitle:(NSString*)titleName reqURL:(NSString*)reqUrlString
{
	PlayyBookWebView* viewController = [[PlayyBookWebView alloc] initWithNibName:@"PlayyBookWebView" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {	
		return nil;
	}
	[viewController setCloseButtonType:CloseButtonLeft];
	
	viewController.m_TitleName = titleName;
	viewController.m_ReqURLString = reqUrlString;
	viewController.m_WebViewType = WEBVIEW_TYPE_NORMAL;
	
	return viewController;
}

+ (id) createWithCloseButtonType:(CloseButtonType)type titleName:(NSString*)titleName reqURL:(NSString*)reqUrlString
{
	PlayyBookWebView* viewController = [[PlayyBookWebView alloc] initWithNibName:@"PlayyBookWebView" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {	
		return nil;
	}
	[viewController setCloseButtonType:type];
	
	viewController.m_TitleName = titleName;
	viewController.m_ReqURLString = reqUrlString;
	viewController.m_WebViewType = WEBVIEW_TYPE_NORMAL;
	
	return viewController;
}

+ (id) createRealnameOrAdult:(NSInteger) webviewType
{
	PlayyBookWebView* viewController = [[PlayyBookWebView alloc] initWithNibName:@"PlayyBookWebView" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {	
		return nil;
	}
	
	[viewController setCloseButtonType:CloseButtonRight];
	
	if (webviewType == WEBVIEW_TYPE_REALNAME)
	{
		viewController.m_TitleName = @"실명인증";
		//viewController.m_ReqURLString = @"http://211.45.130.95//api/realAdult.do?cmd=realnm";
		viewController.m_ReqURLString = @"http://api.book.playy.co.kr/api/userInfoCheck.do?type=realnm&result=0";
		viewController.m_WebViewType = WEBVIEW_TYPE_REALNAME;
	}
	else if (webviewType == WEBVIEW_TYPE_ADULT)
	{
		viewController.m_TitleName = @"성인인증";
		//viewController.m_ReqURLString = @"http://211.45.130.95/api/realAdult.do?cmd=adult";
        viewController.m_ReqURLString = @"http://api.book.playy.co.kr/api/realAdult.do?cmd=adult";
		viewController.m_WebViewType = WEBVIEW_TYPE_ADULT;
	}

	return viewController;
}

- (void)setDeleagte:(id)delegate
{
	m_Delegate = delegate;
}

- (void) setCloseButtonType:(BOOL)type 
{
	m_CloseButtonType = type;
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
 
	[m_LabTitle setText:m_TitleName];	
	
	if (m_CloseButtonType == CloseButtonLeft) {
		[m_CloseArrow setBackgroundImage:RESOURCE_IMAGE(@"view_top_btn_back_off.png") forState:UIControlStateNormal];
		[m_CloseArrow setBackgroundImage:RESOURCE_IMAGE(@"view_top_btn_back_on.png") forState:UIControlStateHighlighted];
		
		[m_CloseButton setHidden:YES];
	}
	else {
		[m_CloseButton setBackgroundImage:RESOURCE_IMAGE(@"view_top_btn_close_off.png") forState:UIControlStateNormal];
		[m_CloseButton setBackgroundImage:RESOURCE_IMAGE(@"view_top_btn_close_on.png") forState:UIControlStateHighlighted];
		
		[m_CloseArrow setHidden:YES];
	}
	m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:m_Background orientation:UIDeviceOrientationPortrait];

	m_bBottomUp = NO;
	
	NSRange range = [m_ReqURLString rangeOfString:@"help.paran.com"];
	if (range.location != NSNotFound){
		m_bBottomUp = YES;
	}

	NSMutableURLRequest* request;
	
	if (m_WebViewType == WEBVIEW_TYPE_REALNAME || m_WebViewType == WEBVIEW_TYPE_ADULT)
	{
		NSURL *url = [NSURL URLWithString:m_ReqURLString];
		NSString *body = [NSString stringWithFormat: @"mc=%@&cs=%@", [UserProfile getMC], [UserProfile getCS]];
		request = [[NSMutableURLRequest alloc]initWithURL: url];
		[request setHTTPMethod: @"POST"];
		[request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
		m_bBottomUp = YES;
	}
	else 
	{
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:m_ReqURLString]];
	}
	
	[m_WebView loadRequest:request];	
	
	CALayer * layer = [m_Background layer];
	UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:m_Background.bounds];
	[layer setMasksToBounds:NO];
	[layer setShadowColor:[[UIColor blackColor] CGColor]];
	[layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
	[layer setShadowOpacity:0.4f];
	[layer setShadowRadius:50.0f];
	[layer setShadowPath:shadowPath.CGPath];
	
	if (m_bBottomUp == YES){
		m_Background.frame = VIEW_RECT_BOTTOM;	
		
		[UIView animateWithDuration:VIEW_ANI_DURATION
						 animations:^{
							 m_Background.frame = CGRectMake(0, 20, 320, 460);
						 }
						 completion:^(BOOL finished){
							 //do nothing
						 }];
	}
	else {
		m_Background.frame = VIEW_RECT_RIGHT;	
		[UIView animateWithDuration:VIEW_ANI_DURATION
						 animations:^{
							 m_Background.frame = VIEW_RECT_NORMAL;
						 }
						 completion:^(BOOL finished){
							 //do nothing
						 }];
	}
	
	
	NSLog(@"viewDidLoad");
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[m_WebView release];
	
	[m_CloseButton release];
	[m_CloseArrow release];
	
	[m_Background release];	
	m_Delegate = nil;
	
    [super dealloc];
}


- (NSData *)AES128Decrypt:(NSData *)Data
{
    char key[17] = {0x34, 0xe3, 0x75, 0x63, 0xde, 0x70, 0x39, 0x19, 0x51, 0x4c, 0x07, 0x0d, 0xf4, 0x94, 0xcf, 0xe7, 0x00};
	char iv[17] = {0xa2, 0x30, 0x43, 0x8e, 0x29, 0xf1, 0x79, 0x58, 0x68, 0xe3, 0xeb, 0x46, 0x88, 0x58, 0xea, 0x70, 0x00};
	
    NSUInteger dataLength = [Data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
	
	const char *byte = [Data bytes];
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, 
                                          kCCAlgorithmAES128, 
										  0,
                                          //kCCOptionECBMode +kCCOptionPKCS7Padding,
                                          key, 
										  kCCKeySizeAES128, // oorspronkelijk 256
                                          iv /* initialization vector (optional) */,
                                          byte, 
										  dataLength, /* input */
                                          buffer, 
										  bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	NSLog(@"An error happened during load, [%@]", error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSLog(@"shouldStartLoadWithRequest");
	
	if (m_ActivityIndicator == nil) {
		m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:m_Background orientation:UIDeviceOrientationPortrait];
	}
	
	NSString *requestString = [[request URL] absoluteString];
	
	NSLog(@"requestString:%@", requestString);
	//playybookresult:realnm:10
	
	NSRange range = [requestString rangeOfString:@"playybookresult:realnm:"];
	if (range.location != NSNotFound)
	{
		NSString *strCode = [requestString substringFromIndex:range.location + range.length];
		if (strCode != nil){
			if ([strCode isEqualToString:@"00"] == YES){
				[UserProfile setRealnameCheck:YES];
				//실명인증 성공 성인인증 넘어가야함
				
				m_TitleName = @"성인인증";
				//m_ReqURLString = @"http://211.45.130.95/api/realAdult.do?cmd=adult";
                m_ReqURLString = @"http://api.book.playy.co.kr/api/realAdult.do?cmd=adult";
				m_WebViewType = WEBVIEW_TYPE_ADULT;
				
				NSMutableURLRequest* request;
				
				NSURL *url = [NSURL URLWithString:m_ReqURLString];
				NSString *body = [NSString stringWithFormat: @"mc=%@&cs=%@", [UserProfile getMC], [UserProfile getCS]];
				request = [[NSMutableURLRequest alloc]initWithURL: url];
				[request setHTTPMethod: @"POST"];
				[request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
				m_bBottomUp = YES;
			
				[m_WebView loadRequest:request];
			}
			else{
				
				[UserProfile setRealnameCheck:NO];
				//실명인증 실패
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"알림" 
																	message:@"실명인증 실패"
																   delegate:nil cancelButtonTitle:@"확인" 
														  otherButtonTitles:nil];
				[alertView show];
				[alertView release];
				
				[self clickBtnClose:self];
			}
		}
	}

	range = [requestString rangeOfString:@"playybookresult:adult:"];
	if (range.location != NSNotFound)
	{
		NSString *strCode = [requestString substringFromIndex:range.location + range.length];
		if (strCode != nil){
			if ([strCode isEqualToString:@"1"] == YES){				
				[UserProfile setAdultCheck:YES];
				//성인인증 성공
				/*
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"알림" 
																	message:@"성인인증 성공"
																   delegate:nil cancelButtonTitle:@"확인" 
														  otherButtonTitles:nil];
				[alertView show];
				[alertView release];
				*/
				[self clickBtnClose:self];				 
			}
			else{
				[UserProfile setAdultCheck:NO];				
				//성인인증 실패
				/*
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"알림" 
																	message:@"성인인증 실패"
																   delegate:nil cancelButtonTitle:@"확인" 
														  otherButtonTitles:nil];
				[alertView show];
				[alertView release];
				*/
				[self clickBtnClose:self];
			}	
		}
	}
		
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	NSLog(@"finished loading [%@]", [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"]);
	
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	BOOL bLoginSuccess = NO;
	NSString *currentURL = [webView.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSRange range = [currentURL rangeOfString:@"login/appOAuthResult.html"];	
	int length = range.length;
	
	if (length == 0){
		return;
	}
	
	URLParser *urlParser = [[URLParser alloc] initWithURLString:currentURL];
	if (urlParser != nil)
	{
		NSInteger rtCode = [[urlParser valueForVariable:@"rtcode"] intValue];
		
		if (rtCode == 0)
		{
			NSString *rtMsg = [urlParser valueForVariable:@"rtmsg"];
			
			if (rtMsg != nil)
			{			
				NSData *base64DecodedData = [NSData dataWithBase64EncodedString:rtMsg];
				
				NSData *aesDecodedData = [self AES128Decrypt:base64DecodedData];
				
				NSString* aStr = [[NSString alloc] initWithData:aesDecodedData encoding:NSUTF8StringEncoding];
				
				NSLog(@"string [%@]", aStr);
				//[atkey=88afbdb8eafda4ecbbf96870c6b376ca5b55618f&expiredt=202109101739586&userno=620019167379&iddomain=evanstrip@gmail.com&idtype=1&usernm=evanstrip%40&nickname=evanstrip%40&&oauth=201206041910132%16620019167379%16facebook.com%16playy%16100001398451904%16%16Hosung+Hwang%16evanstrip%40gmail.com%16%16%16AAAEXRNU6e7MBAFxU0231jj6KXiC85AtBDSzWUZA5ehnGvTRUaMW2O2OyYseLjeRVpZCoPwUpawflWlHo6NwCZA9aWbqnu92GGWh2PCtZAAZDZD%16%16201206041910132]
				
				NSString* urldecode = [aStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSLog(@"urldecode [%@]", urldecode);
				//atkey=88afbdb8eafda4ecbbf96870c6b376ca5b55618f&expiredt=202109101739586&userno=620019167379&iddomain=evanstrip@gmail.com&idtype=1&usernm=evanstrip@&nickname=evanstrip@&&oauth=201206041912472620019167379facebook.complayy100001398451904Hosung+Hwangevanstrip@gmail.comAAAEXRNU6e7MBAFxU0231jj6KXiC85AtBDSzWUZA5ehnGvTRUaMW2O2OyYseLjeRVpZCoPwUpawflWlHo6NwCZA9aWbqnu92GGWh2PCtZAAZDZD201206041912472
				
				[aStr release];
				
				if (urldecode != nil)
				{
					NSString *newString = [NSString stringWithFormat:@"hello?%@", urldecode];
					
					[urlParser release];
					urlParser = [[URLParser alloc] initWithURLString:newString];
					if (urlParser != nil && [urlParser getCount] > 0)
					{
						// successed login
						[UserProfile setAtKey:[urlParser valueForVariable:@"atkey"]];
						[UserProfile setExpiredt:[urlParser valueForVariable:@"expiredt"]];
						[UserProfile setUserId:[urlParser valueForVariable:@"iddomain"]];
						[UserProfile setIdDomain:[urlParser valueForVariable:@"iddomain"]];
						[UserProfile setIdType:[[urlParser valueForVariable:@"idtype"] integerValue]];
						[UserProfile setNickName:[urlParser valueForVariable:@"nickname"]];
						[UserProfile setUserName:[urlParser valueForVariable:@"usernm"]];
						[UserProfile setUserNo:[urlParser valueForVariable:@"userno"]];
						
						[UserProfile setLoginState:YES];
						bLoginSuccess = YES;
					}
					
					[UserProfile setRtCode:rtCode];
					[UserProfile setRtMsg:urldecode];
				}				
			}
		}
		
		[urlParser release];
	}
	
	if (bLoginSuccess == YES){
		if ([APPDELEGATE.m_Request requestCookieWithCt:@"json" AtKey:[UserProfile getAtKey] delegate:self] == NO)
		{
			if (m_ActivityIndicator != nil)
			{
				m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
			}
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
																message:@"로그인을 다시 시도하세요." 
															   delegate:nil cancelButtonTitle:@"확인" 
													  otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			
			if ([m_Delegate respondsToSelector:@selector(loginViewSuccessed)] == YES) {
				[m_Delegate loginViewFailed];
			}
		}
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	NSLog(@"loading started");
}


-(void) clickBtnClose:(id)sender
{
	[UIView animateWithDuration:VIEW_ANI_DURATION
					 animations:^{
						 if (m_bBottomUp){
							 self.view.frame = VIEW_RECT_BOTTOM;
						 }
						 else {
							 self.view.frame = VIEW_RECT_RIGHT;							 
						 }
					 }
					 completion:^(BOOL finished){
						 [self.view removeFromSuperview];	
						 [self release];
					 }];
}

#pragma mark -
#pragma mark PlayBookRequest Delegate
- (void) pbrDidReceiveResponse:(NSURLResponse *)response command:(NSInteger)command
{
	TRACE(@"");
	
}

- (void) pbrDidReceiveData:(NSData *)data response:(NSURLResponse *)response command:(NSInteger)command
{
	TRACE(@"");
}

- (void) pbrDidFailWithError:(NSError *)error command:(NSInteger)command
{
	TRACE(@"");
	
	if (m_ActivityIndicator != nil)
	{
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
														message:[error localizedDescription] 
													   delegate:nil cancelButtonTitle:@"확인" 
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	
	if ([m_Delegate respondsToSelector:@selector(loginViewSuccessed)] == YES) {
		[m_Delegate loginViewFailed];
	}
}

- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{
	NSDictionary *	dicInfo = (NSDictionary *)userInfo;
	
	TRACE(@"command = %d, dicInfo = %@", command, dicInfo);
	
	if (command == DF_URL_CMD_REQUEST_COOKIE)
	{
		if (m_ActivityIndicator != nil)
		{
			m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
		}
		
		NSInteger rtCode = [[dicInfo objectForKey:@"rtcode"] integerValue];
		
		if (rtCode == 0)
		{
			if ([APPDELEGATE.m_Request loginInfoWithUserId:[UserProfile getUserID] delegate:self] == NO)
			{
				if (m_ActivityIndicator != nil)
				{
					m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
				}
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
																	message:@"로그인을 다시 시도하세요." 
																   delegate:nil cancelButtonTitle:@"확인" 
														  otherButtonTitles:nil];
				[alertView show];
				[alertView release];
				
				if ([m_Delegate respondsToSelector:@selector(loginViewSuccessed)] == YES) {
					[m_Delegate loginViewFailed];
				}
			}
		}
		else 
		{
			// fail
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
																message:[dicInfo objectForKey:@"rtmsg"] 
															   delegate:nil cancelButtonTitle:@"확인" 
													  otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			
			if ([m_Delegate respondsToSelector:@selector(loginViewSuccessed)] == YES) {
				[m_Delegate loginViewFailed];
			}
		}
	}
	else if (command == DF_URL_CMD_LOGININFO)
	{
		if (m_ActivityIndicator != nil)
		{
			m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
		}
		
		NSDictionary *data = [dicInfo objectForKey:@"data"];
		
		NSString *rCode = [data objectForKey:@"result_code"];
		
		if ([rCode isEqualToString:@"0"] == YES)
		{
			if (m_ActivityIndicator != nil)
			{
				m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
			}
			
			NSString * realnmgb = [data objectForKey:@"realnmgb"];
			NSString * adult = [data objectForKey:@"adult"];	
			
			NSLog(@"realnmgb=[%@] adult=[%@]", realnmgb, adult);
			//- realnmgb : 실명확인 결과 ( 10 : 실명확인, 11 : 자료없음, 00 : 비실명) 
			//- adult : 성인확인 결과 (1 : 성인인증을 거친자, else : 성인페이지로 이동) 
			
			if (realnmgb != nil && adult != nil)
			{
				if ([realnmgb isEqualToString:@"10"] == YES){
					[UserProfile setRealnameCheck:YES];
				}
				else {
					[UserProfile setRealnameCheck:NO];				
				}
				/*
				if ([adult isEqualToString:@"1"] == YES){
					[UserProfile setAdultCheck:YES];
				}
				else {
					[UserProfile setAdultCheck:NO];				
				}
				 */
				[UserProfile setAdultCheck:NO];	
			}
			
			NSString *token = [UserProfile getDeviceToken];
			
			if (token != nil && [token length] > 1)
			{
				[APPDELEGATE.m_Request pushDeviceInfoWithUserNo:[UserProfile getUserNo] deviceToken:token screenType:@"03" delYN:@"N" delegate:self];
			}
			else {
				// success
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATACHANGED object:nil userInfo:nil];
				
				if ([m_Delegate respondsToSelector:@selector(loginViewSuccessed)] == YES) {
					[m_Delegate loginViewSuccessed];		
				}
				
				[self.view removeFromSuperview];	
				[self release];
			}
			
		}
		else 
		{
			// fail
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
																message:[data objectForKey:@"result_msg"] 
															   delegate:nil cancelButtonTitle:@"확인" 
													  otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			
			if ([m_Delegate respondsToSelector:@selector(loginViewSuccessed)] == YES){
				[m_Delegate loginViewFailed];
			}
		}
	}
	else if (command == DF_URL_CMD_PUSH_DEVICE_INFO)
	{
		// success
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATACHANGED object:nil userInfo:nil];
		
		if ([m_Delegate respondsToSelector:@selector(loginViewSuccessed)] == YES) {
			[m_Delegate loginViewSuccessed];		
		}
		
		
		[self.view removeFromSuperview];	
		[self release];	
	}
}



@end
