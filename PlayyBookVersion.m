    //
//  PlayyBookVersion.m
//  PlayBook
//
//  Created by Daniel on 12. 5. 27..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/CALayer.h>
#import "PlayyBookVersion.h"


@implementation PlayyBookVersion

@synthesize m_NowVersion;
@synthesize m_NewVersion;

@synthesize m_UpdateButton;	

@synthesize m_NowVersionNumber;
@synthesize m_NewVersionNumber;




+ (id)createWithNewVersion:(NSString*)newVersion
{
	PlayyBookVersion* viewController = [[PlayyBookVersion alloc] initWithNibName:@"PlayyBookVersion" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {	
		return nil;
	}
	viewController.m_NewVersionNumber = newVersion;
	
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

- (void)viewDidLoad {
    [super viewDidLoad];	
	
	m_NowVersionNumber = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];

	[m_NowVersion setText:m_NowVersionNumber];
	[m_NewVersion setText:m_NewVersionNumber];
	
	[m_UpdateButton setImage:RESOURCE_IMAGE(@"con_btn_update_off.png") forState:UIControlStateNormal];
	[m_UpdateButton setImage:RESOURCE_IMAGE(@"con_btn_update_on.png") forState:UIControlStateHighlighted];
	
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];
	
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
	[m_NowVersion release];
	[m_NewVersion release];
	
	[m_UpdateButton release];	
	
    [super dealloc];
}

- (void) clickCloseButton:(id)sender 
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

- (void) clickUpateButton:(id)sender
{
	NSLog(@"");
	if ([m_NowVersionNumber isEqualToString:m_NewVersionNumber] == NO) {
		NSLog(@"NO");
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_LINK_URL]];
	}
	else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"안내" 
															message:@"최신 버전입니다." 
														   delegate:nil cancelButtonTitle:@"확인" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];						
	}
}


@end
