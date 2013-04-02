//
//  LoginViewController.m
//  PlayBook
//
//  Created by 전명곤 on 11. 12. 19..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/CALayer.h>
#import "LoginViewController.h"
#import "UserProfile.h"
#import "PlayyBookWebView.h"

@implementation LoginViewController

@synthesize m_UserId;
@synthesize m_Password;
@synthesize m_SaveUserId;
@synthesize m_AutoLogin;

@synthesize m_CancelButton;

@synthesize m_Delegate;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	TRACE(@"");
	
	[m_CancelButton setImage:RESOURCE_IMAGE(@"view_top_btn_close_off.png") forState:UIControlStateNormal];
	[m_CancelButton setImage:RESOURCE_IMAGE(@"view_top_btn_close_on.png") forState:UIControlStateHighlighted];
	
	m_bShowKeyboard			= NO;
	m_ActivityIndicator		= nil;
	
	m_bCheckedSaveUserId	= [UserProfile getSavedUserId];
	m_bCheckedAutoLogin		= [UserProfile getAutoLogin];
	
	[(UITouchView *)self.view setDelegate:self];
	
	self.view.frame = VIEW_RECT_BOTTOM;	
	CALayer * layer = [self.view layer];
	UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
	[layer setMasksToBounds:NO];
	[layer setShadowColor:[[UIColor blackColor] CGColor]];
	[layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
	[layer setShadowOpacity:0.4f];
	[layer setShadowRadius:50.0f];
	[layer setShadowPath:shadowPath.CGPath];
	
	[UIView animateWithDuration:VIEW_ANI_DURATION
					 animations:^{
						 self.view.frame = VIEW_RECT_NORMAL;
					 }
					 completion:^(BOOL finished){
						 //do nothing
					 }];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	TRACE(@"");
	
	if (m_bCheckedSaveUserId == YES)
	{
		[m_SaveUserId setImage:RESOURCE_IMAGE(@"checkbox_login_checked.png") forState:UIControlStateNormal];
		[m_UserId setText:[UserProfile getUserID]];
	}
	else 
	{
		[m_SaveUserId setImage:RESOURCE_IMAGE(@"checkbox_login.png") forState:UIControlStateNormal];
	}
	
	if (m_bCheckedAutoLogin == YES)
	{
		[m_AutoLogin setImage:RESOURCE_IMAGE(@"checkbox_login_checked.png") forState:UIControlStateNormal];
	}
	else 
	{
		[m_AutoLogin setImage:RESOURCE_IMAGE(@"checkbox_login.png") forState:UIControlStateNormal];
	}
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


- (void)dealloc 
{
	TRACE(@"");
	
	m_Delegate = nil;
	
	[m_CancelButton release];
	
	[m_UserId release];
	[m_Password release];
	[m_SaveUserId release];
	[m_AutoLogin release];
	
    [super dealloc];
}

+ (id) createWithDelegate:(id)delegate
{
	TRACE(@"");
	
	LoginViewController *	viewController = (LoginViewController *)[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
	if (viewController == nil)
	{
		TRACE(@"viewController = nil");
		
		return nil;
	}
	
	CGRect rcFrame		= viewController.view.frame;
	rcFrame.origin.y	= 20.0f;
	[viewController.view setFrame:rcFrame];
	
	viewController.m_Delegate = delegate;
	
	return viewController;
}

- (IBAction) clickLogin:(id)sender
{
	TRACE(@"");
	
	if (m_ActivityIndicator != nil) { return; }
	
	if ([m_UserId.text length] == 0)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
															message:@"당신의 아이디를 입력하세요." 
														   delegate:nil cancelButtonTitle:@"확인" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
		return;
	}
	
	if ([m_Password.text length] == 0)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
															message:@"비밀번호를 입력하세요." 
														   delegate:nil cancelButtonTitle:@"확인" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
		return;
	}
	
	[UserProfile setSavedUserId:m_bCheckedSaveUserId];
	[UserProfile setAutoLogin:m_bCheckedAutoLogin];
	[UserProfile setUserId:m_UserId.text];
	
	NSString *strUserID;
	NSString *strUserDomain;
	
	NSString *strID = m_UserId.text;
	NSRange range = [strID rangeOfString:@"@"];
	if (range.location != NSNotFound){		
		strUserID = [strID substringToIndex:range.location];
		strUserDomain = [strID substringFromIndex:range.location + 1];		
	}
	else {
		strUserID = strID;
		strUserDomain = @"paran.com";
	}
	
	if ([APPDELEGATE.m_Request loginRestWithUserId:strUserID domain:strUserDomain passwd:m_Password.text env:@"1404" svc:@"1103" delegate:self] == NO)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
															message:@"로그인 시도가 실패했습니다." 
														   delegate:nil cancelButtonTitle:@"확인" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
	
	m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:self.view];
}
/*
- (IBAction) clickSimpleRegister:(id)sender
{
	if (m_ActivityIndicator != nil) { return; }
	
	PlayyBookWebView* asCenterViewController = [PlayyBookWebView createWithTitle:@"간편가입" reqURL:@"https://user.paran.com/paran/register.do?env=app&cskey=api.playy.paran.com&rturl=http://m.book.playy.co.kr/home.do&device="];
	if (asCenterViewController != nil) {
		[self.view addSubview:asCenterViewController.view];		
	}
	TRACE(@"");
}
*/
- (IBAction) clickCheckSaveUserId:(id)sender
{
	if (m_ActivityIndicator != nil) { return; }
	
	if (m_bCheckedSaveUserId == YES)
	{
		m_bCheckedSaveUserId = NO;
		[m_SaveUserId setImage:RESOURCE_IMAGE(@"checkbox_login.png") forState:UIControlStateNormal];
	}
	else 
	{
		m_bCheckedSaveUserId = YES;
		[m_SaveUserId setImage:RESOURCE_IMAGE(@"checkbox_login_checked.png") forState:UIControlStateNormal];
	}
	
	TRACE(@"m_bCheckedSaveUserId = %d", m_bCheckedSaveUserId);
}

- (IBAction) clickCheckAutoLogin:(id)sender
{
	if (m_ActivityIndicator != nil) { return; }
	
	if (m_bCheckedAutoLogin == YES)
	{
		m_bCheckedAutoLogin = NO;
		[m_AutoLogin setImage:RESOURCE_IMAGE(@"checkbox_login.png") forState:UIControlStateNormal];
	}
	else 
	{
		m_bCheckedAutoLogin = YES;
		[m_AutoLogin setImage:RESOURCE_IMAGE(@"checkbox_login_checked.png") forState:UIControlStateNormal];
	}
	
	TRACE(@"m_bCheckedAutoLogin = %d", m_bCheckedAutoLogin);
}


- (IBAction) clickFindParanId:(id)sender
{
	if (m_ActivityIndicator != nil) { return; }
	
	PlayyBookWebView* asCenterViewController = [PlayyBookWebView createWithTitle:@"아이디 찾기" reqURL:@"https://user.paran.com/paran/findid.do?env=app&cskey=api.playy.paran.com"];
	if (asCenterViewController != nil) {
		[self.view addSubview:asCenterViewController.view];		
	}
	TRACE(@"");
}

- (IBAction) clickFindPassword:(id)sender
{
	if (m_ActivityIndicator != nil) { return; }
	
	PlayyBookWebView* asCenterViewController = [PlayyBookWebView createWithTitle:@"비밀번호 찾기" reqURL:@"https://user.paran.com/paran/findpw.do?env=app&cskey=api.playy.paran.com"];
	if (asCenterViewController != nil) {
		[self.view addSubview:asCenterViewController.view];		
	}
	TRACE(@"");
}


- (IBAction) clickLoginTwitter:(id)sender
{
	PlayyBookWebView* asCenterViewController = [PlayyBookWebView createWithTitle:@"twitter 로그인" reqURL:@"http://main.playy.co.kr/login/appOAuthLogin.html?sitename=twitter.com&env=1404&svc=1103&device="];
	if (asCenterViewController != nil) {
		[self.view addSubview:asCenterViewController.view];		
		
		[asCenterViewController setDeleagte:m_Delegate];
	}
	TRACE(@"");
}

- (IBAction) clickLoginFacebook:(id)sender
{
	if (m_ActivityIndicator != nil) { return; }
	
	PlayyBookWebView* asCenterViewController = [PlayyBookWebView createWithTitle:@"facebook 로그인" reqURL:@"http://main.playy.co.kr/login/appOAuthLogin.html?sitename=facebook.com&env=1404&svc=1103&device="];
	if (asCenterViewController != nil) {
		[self.view addSubview:asCenterViewController.view];
		
		[asCenterViewController setDeleagte:m_Delegate];
	}
	TRACE(@"");
}

- (IBAction) clickCancel:(id)sender
{
	TRACE(@"");
	
	if ([APPDELEGATE.m_Request isDownloading] == YES) {
		[APPDELEGATE.m_Request cancelConnection];
	}
	
	if (m_ActivityIndicator != nil)
	{
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	[UIView animateWithDuration:VIEW_ANI_DURATION
					 animations:^{
						 self.view.frame = VIEW_RECT_BOTTOM;
					 }
					 completion:^(BOOL finished){
						 [m_Delegate loginViewCanceled];
					 }];
}

#pragma mark -
#pragma mark UITouchViewDelegate
- (void) UITouchViewtouchesEnded
{
	TRACE(@"");
	
	if (m_bShowKeyboard == YES)
	{
		m_bShowKeyboard = NO;
		[m_UserId resignFirstResponder];
		[m_Password resignFirstResponder];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	TRACE(@"");
	
    // the user pressed the "Done" button, so dismiss the keyboard
	m_bShowKeyboard = NO;
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	TRACE(@"");
	
	m_bShowKeyboard = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	TRACE(@"");
	
	m_bShowKeyboard = NO;
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
	
	[m_Delegate loginViewFailed];
}

- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{
	NSDictionary *	dicInfo = (NSDictionary *)userInfo;
	
	TRACE(@"command = %d, dicInfo = %@", command, dicInfo);
	
	if (command == DF_URL_CMD_LOGIN_REST)
	{
		NSInteger	rtCode = [[dicInfo objectForKey:@"rtcode"] integerValue];
		
		if (rtCode == 0)
		{
			// successed
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
				
				[m_Delegate loginViewFailed];
			}
		}
		else 
		{
			// failed
			if (m_ActivityIndicator != nil)
			{
				m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
			}
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"경고" 
																message:[dicInfo objectForKey:@"rtmsg"] 
															   delegate:nil cancelButtonTitle:@"확인" 
													  otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			
			[m_Delegate loginViewFailed];
		}
	}
	else if (command == DF_URL_CMD_REQUEST_COOKIE)
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
				
				[m_Delegate loginViewFailed];
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
			
			[m_Delegate loginViewFailed];
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
				[UIView animateWithDuration:VIEW_ANI_DURATION
								 animations:^{
									 self.view.frame = VIEW_RECT_BOTTOM;
								 }
								 completion:^(BOOL finished){
									 [m_Delegate loginViewSuccessed];
								 }];
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
			
			[UIView animateWithDuration:VIEW_ANI_DURATION
							 animations:^{
								 self.view.frame = VIEW_RECT_BOTTOM;
							 }
							 completion:^(BOOL finished){
								 [m_Delegate loginViewFailed];
							 }];
		}
	}
	else if (command == DF_URL_CMD_PUSH_DEVICE_INFO)
	{
		// success
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATACHANGED object:nil userInfo:nil];
		[UIView animateWithDuration:VIEW_ANI_DURATION
						 animations:^{
							 self.view.frame = VIEW_RECT_BOTTOM;
						 }
						 completion:^(BOOL finished){
							 [m_Delegate loginViewSuccessed];
						 }];
	}
}

@end
