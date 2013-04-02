//
//  PBNavigationBar.m
//  MoimDoma
//
//  Created by 전명곤 on 11. 11. 7..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PBNavigationBar.h"

@implementation PBNavigationBar

@synthesize m_BgImageView;
@synthesize m_TableContentButton;
@synthesize m_TitleText;
@synthesize m_RightButton;

@synthesize m_TableOfContentsPopup;



+ (id) createWithType:(NSInteger)type orientation:(UIDeviceOrientation)toInterfaceOrientation delegate:(id)delegate
{
	PBNavigationBar *	pbNaviBar = [[PBNavigationBar alloc] initWithType:type orientation:toInterfaceOrientation delegate:delegate];
	if (pbNaviBar == nil)
	{
		return nil;
	}
	
	if (type == PB_PANEL_BAR_TYPE_CARTOON) {
		if (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight)
		{
			[pbNaviBar setFrame:CGRectMake(0, -DF_FORM_PB_NAVI_BAR_HORZ_HEIGHT, DF_FORM_PB_NAVI_BAR_HORZ_WIDTH, 31.0f)];
		}
		else 
		{
			[pbNaviBar setFrame:CGRectMake(0, -DF_FORM_PB_NAVI_BAR_VERT_HEIGHT, DF_FORM_PB_NAVI_BAR_VERT_WIDTH, 45.0f)];
		}
	}
	else {
		if (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight)
		{
			[pbNaviBar setFrame:CGRectMake(0, -DF_FORM_PB_NAVI_BAR_HORZ_HEIGHT, DF_FORM_PB_NAVI_BAR_HORZ_WIDTH, 31.0f)];
		}
		else 
		{
			[pbNaviBar setFrame:CGRectMake(0, -DF_FORM_PB_NAVI_BAR_VERT_HEIGHT, DF_FORM_PB_NAVI_BAR_VERT_WIDTH, 45.0f)];
		}
	}

	return pbNaviBar;
}


- (id) initWithType:(NSInteger)type orientation:(UIDeviceOrientation)toInterfaceOrientation delegate:(id)delegate
{
	if ((self = [super init]) != nil)
	{
		//self.multipleTouchEnabled	= NO;
		//self.exclusiveTouch			= YES;
		
		m_Orientation = toInterfaceOrientation;
		m_Type		  = type;
		m_bShow		  = NO;
		m_Delegate    = delegate;
		
		if (type == PB_PANEL_BAR_TYPE_CARTOON) {
			if (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight)
			{
				// horizontal
				m_BgImageView	= [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_top_bg_bar_land.png")];
				[m_BgImageView setFrame:CGRectMake(0, 0, DF_FORM_PB_NAVI_BAR_HORZ_WIDTH, 31.0f)];
				[self addSubview:m_BgImageView];
				
				m_TitleText		= [[UILabel alloc] init];
				[m_TitleText setFrame:CGRectMake(15.0f,				//DF_FORM_PB_NAVI_BAR_HORZ_TITLE_SX, 
												 0.0f,				//DF_FORM_PB_NAVI_BAR_HORZ_TITLE_SY, 
												 DF_FORM_PB_NAVI_BAR_HORZ_TITLE_WIDTH, 
												 31.0f)];			//DF_FORM_PB_NAVI_BAR_HORZ_TITLE_HEIGHT)];
				[m_TitleText setBackgroundColor:[UIColor clearColor]];
				[m_TitleText setTextColor:[UIColor whiteColor]];
				m_TitleText.font = [m_TitleText.font fontWithSize:14.0f];
				[self addSubview:m_TitleText];
				
				m_RightButton	= [UIButton buttonWithType:UIButtonTypeCustom];
				//[m_RightButton setAlpha:1.0f];
				[m_RightButton setFrame:CGRectMake(480.0f - 45.0f,	//DF_FORM_PB_NAVI_BAR_HORZ_RIGHT_BTN_SX, 
												   0.0f,			//DF_FORM_PB_NAVI_BAR_HORZ_RIGHT_BTN_SY, 
												   35.0f,			//DF_FORM_PB_NAVI_BAR_HORZ_RIGHT_BTN_WIDTH, 
												   31.0f)];			//DF_FORM_PB_NAVI_BAR_HORZ_RIGHT_BTN_HEIGHT)];
				[m_RightButton setImage:RESOURCE_IMAGE(@"vi_top_btn_close_off.png") forState:UIControlStateNormal];  
				[m_RightButton setImage:RESOURCE_IMAGE(@"vi_top_btn_close_on.png") forState:UIControlStateHighlighted];
				[m_RightButton setContentEdgeInsets:UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f)];			
				[m_RightButton addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:m_RightButton];
			}
			else 
			{
				// verttical
				m_BgImageView	= [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_top_bg_bar.png")];
				[m_BgImageView setFrame:CGRectMake(0, 0, DF_FORM_PB_NAVI_BAR_VERT_WIDTH, 45.0f)];
				[self addSubview:m_BgImageView];
				
				m_TitleText		= [[UILabel alloc] init];
				[m_TitleText setFrame:CGRectMake(15.0f, 
												 DF_FORM_PB_NAVI_BAR_VERT_TITLE_SY, 
												 DF_FORM_PB_NAVI_BAR_VERT_TITLE_WIDTH, 
												 35.0f)]; //DF_FORM_PB_NAVI_BAR_VERT_TITLE_HEIGHT)];
				
				[m_TitleText setBackgroundColor:[UIColor clearColor]];
				[m_TitleText setTextColor:[UIColor whiteColor]];
				m_TitleText.font = [m_TitleText.font fontWithSize:16.0f];
				[self addSubview:m_TitleText];
				
				m_RightButton	= [UIButton buttonWithType:UIButtonTypeCustom];
				//[m_RightButton setAlpha:1.0f];
				[m_RightButton setFrame:CGRectMake(320.0f - 55.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_SX, 
												   0.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_SY, 
												   55.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_WIDTH, 
												   45.0f)];	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_HEIGHT)];
				[m_RightButton setImage:RESOURCE_IMAGE(@"vi_top_btn_close_off.png") forState:UIControlStateNormal];  
				[m_RightButton setImage:RESOURCE_IMAGE(@"vi_top_btn_close_on.png") forState:UIControlStateHighlighted];
				[m_RightButton setContentEdgeInsets:UIEdgeInsetsMake(7.0f, 10.0f, 7.0f, 10.0f)];
				[m_RightButton addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:m_RightButton];
			}
		}
		else {
			// Epub
			
			if (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight)
			{
				// horizontal
				m_BgImageView	= [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_top_bg_bar_land.png")];
				[m_BgImageView setFrame:CGRectMake(0, 0, DF_FORM_PB_NAVI_BAR_HORZ_WIDTH, 31.0f)];
				[self addSubview:m_BgImageView];
				
				m_TableContentButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[m_TableContentButton setFrame:CGRectMake(10.0f, 0.0f, 48.0f, 31.0f)];
				[m_TableContentButton setImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_list_off.png") forState:UIControlStateNormal];
				[m_TableContentButton setImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_list_on.png") forState:UIControlStateHighlighted];
				[m_TableContentButton setContentEdgeInsets:UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 15.0f)];
 				[m_TableContentButton addTarget:self action:@selector(clickContentTableButton:) forControlEvents:UIControlEventTouchUpInside];				 
				[self addSubview:m_TableContentButton];			
				
				m_TitleText		= [[UILabel alloc] init];
				[m_TitleText setFrame:CGRectMake(10.0f + 48.0f,		//DF_FORM_PB_NAVI_BAR_HORZ_TITLE_SX, 
												 0.0f,				//DF_FORM_PB_NAVI_BAR_HORZ_TITLE_SY, 
												 365.0f,			//DF_FORM_PB_NAVI_BAR_HORZ_TITLE_WIDTH, 
												 31.0f)];			//DF_FORM_PB_NAVI_BAR_HORZ_TITLE_HEIGHT)];
				[m_TitleText setBackgroundColor:[UIColor clearColor]];
				[m_TitleText setTextColor:[UIColor whiteColor]];
				[m_TitleText setTextAlignment:UITextAlignmentCenter];				
				m_TitleText.font = [m_TitleText.font fontWithSize:14.0f];
				[self addSubview:m_TitleText];
				
				m_RightButton	= [UIButton buttonWithType:UIButtonTypeCustom];
				//[m_RightButton setAlpha:1.0f];
				[m_RightButton setFrame:CGRectMake(480.0f - 45.0f,	//DF_FORM_PB_NAVI_BAR_HORZ_RIGHT_BTN_SX, 
												   0.0f,			//DF_FORM_PB_NAVI_BAR_HORZ_RIGHT_BTN_SY, 
												   35.0f,			//DF_FORM_PB_NAVI_BAR_HORZ_RIGHT_BTN_WIDTH, 
												   31.0f)];			//DF_FORM_PB_NAVI_BAR_HORZ_RIGHT_BTN_HEIGHT)];
				[m_RightButton setImage:RESOURCE_IMAGE(@"vi_top_btn_close_off.png") forState:UIControlStateNormal];  
				[m_RightButton setImage:RESOURCE_IMAGE(@"vi_top_btn_close_on.png") forState:UIControlStateHighlighted];
				[m_RightButton setContentEdgeInsets:UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f)];			
				[m_RightButton addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:m_RightButton];
			}
			else 
			{
				// verttical
				m_BgImageView	= [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_top_bg_bar.png")];
				[m_BgImageView setFrame:CGRectMake(0, 0, DF_FORM_PB_NAVI_BAR_VERT_WIDTH, 45.0f)];
				[self addSubview:m_BgImageView];
				
				m_TableContentButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[m_TableContentButton setFrame:CGRectMake(10.0f, 0.0f, 48.0f, 45.0f)];
				[m_TableContentButton setImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_list_off.png") forState:UIControlStateNormal];
				[m_TableContentButton setImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_list_on.png") forState:UIControlStateHighlighted];
				[m_TableContentButton setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 13.0f)];  
 				[m_TableContentButton addTarget:self action:@selector(clickContentTableButton:) forControlEvents:UIControlEventTouchUpInside];				 
				[self addSubview:m_TableContentButton];				 
				 
				m_TitleText	= [[UILabel alloc] init];
				[m_TitleText setFrame:CGRectMake(10.0f + 48.0f,
												 DF_FORM_PB_NAVI_BAR_VERT_TITLE_SY, 
												 205.0f, 
												 35.0f)]; //DF_FORM_PB_NAVI_BAR_VERT_TITLE_HEIGHT)];
				
				[m_TitleText setBackgroundColor:[UIColor clearColor]];
				[m_TitleText setTextColor:[UIColor whiteColor]];
				[m_TitleText setTextAlignment:UITextAlignmentCenter];		
				m_TitleText.font = [m_TitleText.font fontWithSize:16.0f];
				[self addSubview:m_TitleText];
				
				m_RightButton	= [UIButton buttonWithType:UIButtonTypeCustom];
				//[m_RightButton setAlpha:1.0f];
				[m_RightButton setFrame:CGRectMake(320.0f - 55.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_SX, 
												   0.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_SY, 
												   55.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_WIDTH, 
												   45.0f)];	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_HEIGHT)];
				[m_RightButton setImage:RESOURCE_IMAGE(@"vi_top_btn_close_off.png") forState:UIControlStateNormal];  
				[m_RightButton setImage:RESOURCE_IMAGE(@"vi_top_btn_close_on.png") forState:UIControlStateHighlighted];
				[m_RightButton setContentEdgeInsets:UIEdgeInsetsMake(7.0f, 10.0f, 7.0f, 10.0f)];
				[m_RightButton addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:m_RightButton];
			}
		}
	}
	
	return self;
}


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc 
{
    [super dealloc];
}

- (void) close
{
	UIApplication* application = [UIApplication sharedApplication];
	if ([application isStatusBarHidden] == YES) { 
		[application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	}
	
	if (m_TableOfContentsPopup != nil)
	{
		[m_TableOfContentsPopup.view removeFromSuperview];
		[m_TableOfContentsPopup release];
	}
	
	if (m_TableContentButton != nil) {
		[m_TableContentButton removeFromSuperview];
//		[m_TableContentButton release];
	}

	if (m_RightButton != nil)
	{
		[m_RightButton removeFromSuperview];
//		[m_RightButton release];
	}
	
	if (m_TitleText != nil)
	{
		[m_TitleText removeFromSuperview];
		[m_TitleText release];
	}
	
	if (m_BgImageView != nil)
	{
		[m_BgImageView removeFromSuperview];
		[m_BgImageView release];
	}
}


- (void) setTitle:(NSString *)titleText
{
	[m_TitleText setText:titleText];
}

- (void) resize:(UIInterfaceOrientation)toInterfaceOrientation
{
	m_Orientation = toInterfaceOrientation;
	
	if (m_Type == PB_PANEL_BAR_TYPE_CARTOON) {
		if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
		{
			// horizontal
			[self setFrame:CGRectMake(0, -DF_FORM_PB_NAVI_BAR_HORZ_HEIGHT, DF_FORM_PB_NAVI_BAR_HORZ_WIDTH, 31.0f)];

			[m_BgImageView setImage:RESOURCE_IMAGE(@"vi_top_bg_bar_land.png")];		
			[m_BgImageView setFrame:CGRectMake(0, 0, DF_FORM_PB_NAVI_BAR_HORZ_WIDTH, 31.0f)];
			
			[m_TitleText setFrame:CGRectMake(15.0f, 
											 0, 
											 DF_FORM_PB_NAVI_BAR_HORZ_TITLE_WIDTH, 
											 31.0f)]; //DF_FORM_PB_NAVI_BAR_VERT_TITLE_HEIGHT)];
			
			[m_RightButton setFrame:CGRectMake(480.0f - 45.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_SX, 
											   0.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_SY, 
											   35.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_WIDTH, 
											   31.0f)];	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_HEIGHT)];
			[m_RightButton setContentEdgeInsets:UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f)];
			 
		}
		else 
		{
			// verttical
			[self setFrame:CGRectMake(0, -DF_FORM_PB_NAVI_BAR_VERT_HEIGHT, DF_FORM_PB_NAVI_BAR_VERT_WIDTH, 45.0f)];

			[m_BgImageView setImage:RESOURCE_IMAGE(@"vi_top_bg_bar.png")];
			[m_BgImageView setFrame:CGRectMake(0, 0, DF_FORM_PB_NAVI_BAR_VERT_WIDTH, 45.0f)];

			[m_TitleText setFrame:CGRectMake(15.0f, 
											 DF_FORM_PB_NAVI_BAR_VERT_TITLE_SY, 
											 DF_FORM_PB_NAVI_BAR_VERT_TITLE_WIDTH, 
											 35.0f)]; //DF_FORM_PB_NAVI_BAR_VERT_TITLE_HEIGHT)];
			
			[m_RightButton setFrame:CGRectMake(320.0f - 55.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_SX, 
											   0.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_SY, 
											   55.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_WIDTH, 
											   45.0f)];	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_HEIGHT)];
			[m_RightButton setContentEdgeInsets:UIEdgeInsetsMake(7.0f, 10.0f, 7.0f, 10.0f)];
			
		}
	}
	else {
		//Epub
		
		if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
		{
			// horizontal
			[self setFrame:CGRectMake(0, -DF_FORM_PB_NAVI_BAR_HORZ_HEIGHT, DF_FORM_PB_NAVI_BAR_HORZ_WIDTH, 31.0f)];
			
			[m_BgImageView setImage:RESOURCE_IMAGE(@"vi_top_bg_bar_land.png")];		
			[m_BgImageView setFrame:CGRectMake(0, 0, DF_FORM_PB_NAVI_BAR_HORZ_WIDTH, 31.0f)];
			
			
			[m_TableContentButton setFrame:CGRectMake(10.0f, 0.0f, 48.0f, 31.0f)];
			[m_TableContentButton setContentEdgeInsets:UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 15.0f)];  
			
			[m_TitleText setFrame:CGRectMake(10.0f + 48.0f, 
											 0, 
											 365.0f, 
											 31.0f)]; //DF_FORM_PB_NAVI_BAR_VERT_TITLE_HEIGHT)];
			
			[m_RightButton setFrame:CGRectMake(480.0f - 45.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_SX, 
											   0.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_SY, 
											   35.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_WIDTH, 
											   31.0f)];	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_HEIGHT)];
			[m_RightButton setContentEdgeInsets:UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f)];
			
		}
		else 
		{
			// verttical
			[self setFrame:CGRectMake(0, -DF_FORM_PB_NAVI_BAR_VERT_HEIGHT, DF_FORM_PB_NAVI_BAR_VERT_WIDTH, 45.0f)];
			
			[m_BgImageView setImage:RESOURCE_IMAGE(@"vi_top_bg_bar.png")];
			[m_BgImageView setFrame:CGRectMake(0, 0, DF_FORM_PB_NAVI_BAR_VERT_WIDTH, 45.0f)];

			[m_TableContentButton setFrame:CGRectMake(10.0f, 0.0f, 48.0f, 45.0f)];
			[m_TableContentButton setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 13.0f)];  
			
			[m_TitleText setFrame:CGRectMake(10.0f + 48.0f, 
											 DF_FORM_PB_NAVI_BAR_VERT_TITLE_SY, 
											 205.0f, 
											 35.0f)]; //DF_FORM_PB_NAVI_BAR_VERT_TITLE_HEIGHT)];
			
			[m_RightButton setFrame:CGRectMake(320.0f - 55.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_SX, 
											   0.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_SY, 
											   55.0f,	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_WIDTH, 
											   45.0f)];	//DF_FORM_PB_NAVI_BAR_VERT_RIGHT_BTN_HEIGHT)];
			[m_RightButton setContentEdgeInsets:UIEdgeInsetsMake(7.0f, 10.0f, 7.0f, 10.0f)];
			
		}		
	}
}

- (void) showBar:(BOOL)bShow
{

	if (m_bShow == bShow)
	{
		return;
	}

	m_bShow = bShow;
	
	[self _hideSubPopup:SUB_POPUP_NONE];
	
	CGRect rcBar = self.frame;
	
	if (bShow == YES)
	{
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		
		rcBar.origin.y = -rcBar.size.height;
		
		[self setFrame:rcBar];
		
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        
		rcBar.origin.y = 20.0f;
        [self setFrame:rcBar]; 
		
        [UIView commitAnimations];
	}
	else 
	{
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
		
		rcBar.origin.y = 0;
		[self setFrame:rcBar];
		
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        
		rcBar.origin.y = -rcBar.size.height;
        [self setFrame:rcBar]; 
		
        [UIView commitAnimations];
	}
}

- (BOOL) isShowBar
{
	return m_bShow;
}

- (void) _hideSubPopup:(NSInteger)notHidesubPopupIndex
{
	if (m_TableOfContentsPopup != nil && notHidesubPopupIndex != SUB_POPUP_CONTENTS)
	{
		[m_TableOfContentsPopup setDelegate:nil];
		[m_TableOfContentsPopup.view removeFromSuperview];
		[m_TableOfContentsPopup release];
		m_TableOfContentsPopup = nil;
		
		[m_TableContentButton setImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_list_off.png") forState:UIControlStateNormal];
	}
}

- (void) setContentsOfTable:(NSArray *)items
{
	m_ContentsOfTable = items;
}


#pragma mark -
#pragma mark PopupMenuController
- (void) pmSelectedMenuItem:(NSInteger)index
{

	if (m_TableOfContentsPopup != nil)
	{
		[m_TableOfContentsPopup setDelegate:nil];
		[m_TableOfContentsPopup.view removeFromSuperview];
		[m_TableOfContentsPopup release];		
		m_TableOfContentsPopup = nil;
		
		[m_TableContentButton setImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_list_off.png") forState:UIControlStateNormal];
	}

	[m_Delegate pbpSelectedTocPage:index];
}
				 
- (IBAction) clickContentTableButton:(id)sender 
{	
	if (m_TableOfContentsPopup == nil)
	{
		[self _hideSubPopup:SUB_POPUP_CONTENTS];
		
		[m_TableContentButton setImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_list_open.png") forState:UIControlStateNormal];
		
		UIDeviceOrientation orientation	= m_Orientation;
		
		m_TableOfContentsPopup = [PopupMenuController createWithOrientation:orientation];
		[m_TableOfContentsPopup setDelegate:self];
		[m_TableOfContentsPopup addItems:m_ContentsOfTable];
		
		[self.superview addSubview:m_TableOfContentsPopup.view];
	}
	else 
	{
		[m_TableContentButton setImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_list_off.png") forState:UIControlStateNormal];
		
		[m_TableOfContentsPopup setDelegate:nil];
		[m_TableOfContentsPopup.view removeFromSuperview];
		[m_TableOfContentsPopup release];
		m_TableOfContentsPopup = nil;
	}
}
				 
- (IBAction) clickRightButton:(id)sender
{
	[m_Delegate pbnClickRightButton:sender];
}


@end
