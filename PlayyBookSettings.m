    //
//  PlayyBookSettings.m
//  PlayBook
//
//  Created by Daniel on 12. 5. 9..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "PlayyBookSettings.h"
#import "PlayyBookVersion.h"
#import "UserProfile.h"
#import "SettingPreference.h"

#define _SCROLL_VIEW_HEIGHT					417.0f
#define _SCROLL_CONTENT_HEIGHT_OFF			417.0f
#define _SCROLL_CONTENT_HEIGHT_ON			450.0f

@implementation PlayyBookSettings

@synthesize m_ScrollView;

@synthesize m_CloseButton;
@synthesize m_LoginButton;

@synthesize m_NowVersion;

@synthesize m_use3G;
@synthesize m_use3GPopup;

@synthesize m_LoginViewController;


+ (id) createSettings
{
	PlayyBookSettings* viewController = [[PlayyBookSettings alloc] initWithNibName:@"PlayyBookSettings" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {	
		return nil;
	}
	
	return viewController;
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

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNotification:) name:NOTIFY_DATACHANGED object:nil];

	[m_CloseButton setImage:RESOURCE_IMAGE(@"view_top_btn_back_off.png") forState:UIControlStateNormal];
	[m_CloseButton setImage:RESOURCE_IMAGE(@"view_top_btn_back_on.png") forState:UIControlStateHighlighted];
	
	
	[m_ScrollView setFrame:CGRectMake(0.0f, 43.0f, 320.0f, _SCROLL_VIEW_HEIGHT)];

	if ([UserProfile getLoginState] == YES) {
		[m_LoginButton setTitle:[UserProfile getUserID] forState:UIControlStateNormal];
		[m_ScrollView setContentSize:CGSizeMake(320, _SCROLL_CONTENT_HEIGHT_ON)];
	}
	else {
		[m_LoginButton setTitle:@"로그인" forState:UIControlStateNormal];
		[m_ScrollView setContentSize:CGSizeMake(320, _SCROLL_CONTENT_HEIGHT_ON)];
	}
	
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];
	//[m_LayoutSettings setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];	
	
	[m_NowVersion setText:[[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"]];
	
	self.view.frame = VIEW_RECT_RIGHT;
	
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
	
	m_use3G.on = [SettingPreference getUse3G];
	m_use3GPopup.on = [SettingPreference getUse3GPopup];
    m_use3GPopup.enabled = [SettingPreference getUse3G];
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
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
	
	[m_ScrollView release];
	
	[m_CloseButton release];
	[m_LoginButton release];
	
	[m_use3G release];
	[m_use3GPopup release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark Login Button Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	NSLog(@"buttonIndex=[%d]", buttonIndex);
	
	
	if (buttonIndex == 0) {		 
		[APPDELEGATE.m_Request logoutWithDelegate:self];

		[m_LoginButton setTitle:@"로그인" forState:UIControlStateNormal];
		[UserProfile setLoginState:NO];	
		[UserProfile setAdultCheck:NO];
		[UserProfile setRealnameCheck:NO];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DATACHANGED object:nil userInfo:nil];
	}	
}

-(void) clickBtnLogin:(id)sender
{
	if ([UserProfile getLoginState] == YES) { 
		UIActionSheet *menuPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"로그아웃", nil];
		menuPopup.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		
		[menuPopup showInView:self.view];
		[menuPopup release];
	}
	else {
		[self createLoginViewController];
	}
}

-(void) clickBtnClose:(id)sender
{
	[UIView animateWithDuration:VIEW_ANI_DURATION
					 animations:^{
						 self.view.frame = VIEW_RECT_RIGHT;
					 }
					 completion:^(BOOL finished){
						 [self.view removeFromSuperview];	
						 [self release];
					 }];	
}


- (void) createLoginViewController
{
	if ((m_LoginViewController = (LoginViewController *)[LoginViewController createWithDelegate:self]) != nil) {
		[APPDELEGATE.m_Window addSubview:m_LoginViewController.view];
	}
}

-(void) clickBtnVersioin:(id)sender
{
	NSString* newVersionNumber = APPDELEGATE.m_NewVersionNumber;
	NSLog(@"newVersionNumbe=[%@]", newVersionNumber);
	
	PlayyBookVersion* viewController = [PlayyBookVersion createWithNewVersion:newVersionNumber];
	if (viewController != nil) {
		[self.view addSubview:viewController.view];
	}
}


-(IBAction)switcherChanged:(id)sender
{
	UISwitch *Sender = (UISwitch *)sender;
	if (Sender == nil)
		return;
	
	switch (Sender.tag)
	{
		case 1: //3g use
			//Sender.on 
		{
			if (m_use3G.on == NO)
			{
				m_use3GPopup.on = NO;
				m_use3GPopup.enabled = NO;
			}
			else 
			{
				m_use3GPopup.enabled = YES;
			}
			
            [SettingPreference setUse3GPopup:m_use3GPopup.on];
			[SettingPreference setUse3G:m_use3G.on];
		}
			break;
			
		case 2: //3g popup
			[SettingPreference setUse3GPopup:m_use3GPopup.on];
			break;
	}
}

#pragma mark -
#pragma mark LoginChanged Notification 
- (void)onReceiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:NOTIFY_DATACHANGED] == YES) {
        NSLog (@"Notification NOTIFY_LOGINCHANGED");
		
		if ([UserProfile getLoginState] == YES) {
			
			[m_LoginButton setTitle:[UserProfile getUserID] forState:UIControlStateNormal];		
		}	
	}
}


#pragma mark -
#pragma mark LoginViewDelegate
- (void) loginViewSuccessed
{
	[m_LoginViewController.view removeFromSuperview];
	[m_LoginViewController release];
	m_LoginViewController = nil;

	[APPDELEGATE.m_Window addSubview:APPDELEGATE.m_SwitchViewController.view];		
}

- (void) loginViewFailed
{

}

- (void) loginViewCanceled
{
	[m_LoginViewController.view removeFromSuperview];
	[m_LoginViewController release];
	m_LoginViewController = nil;
	
	[APPDELEGATE.m_Window addSubview:APPDELEGATE.m_SwitchViewController.view];
}

#pragma mark -
#pragma mark PlayBookRequest Delegate
- (void) pbrDidReceiveResponse:(NSURLResponse *)response command:(NSInteger)command
{
	
}

- (void) pbrDidReceiveData:(NSData *)data response:(NSURLResponse *)response command:(NSInteger)command
{
}

- (void) pbrDidFailWithError:(NSError *)error command:(NSInteger)command
{
	NSLog(@"%@", error);
}

- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{
	if (command == DF_URL_CMD_LOGOUT) {
	}
}

#pragma mark -
#pragma mark ScrollView scrollDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{	
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

@end
