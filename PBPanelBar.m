//
//  PBPanelBar.m
//  PlayBook
//
//  Created by 전명곤 on 11. 11. 7..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PBPanelBar.h"


@implementation PBPanelBar

@synthesize m_SecondBgImageView;
@synthesize m_BgColorControlBtn;
@synthesize m_FontSizeBtn;

@synthesize m_BottomBgImageView;


@synthesize m_SildeBgView;
@synthesize m_SildeBgImageView;

@synthesize m_PageLabel;
@synthesize m_PageSlide;
@synthesize m_MaxPageNumber;
@synthesize m_MinPageNumber;

@synthesize m_PageSlideBtn;
@synthesize m_BrightnessBtn;
@synthesize m_ScreenFixedBtn;

@synthesize m_BrightnessPopup;
@synthesize m_ZoomPopup;

@synthesize m_PageSlidePopup;
@synthesize m_FontSizePopup;
@synthesize m_BackgroundTonePopup;


- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) 
	{
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
/*
	if (m_SildeBgView != nil) {
		[m_SildeBgView release];
	}	
	if (m_SildeBgImageView != nil) {
		[m_SildeBgImageView release];
	}
	
	if (m_SecondBgImageView != nil) {
		[m_SecondBgImageView release];
	}
	
	[m_BottomBgImageView release];
	
	[m_PageLabel release];
	[m_PageSlide release];
	[m_MinPageNumber release];
	[m_MaxPageNumber release];
	
	[m_ScreenFixedBtn release];
	
	if (m_BgColorControlBtn != nil) {
		[m_BgColorControlBtn release];
	}	
	if (m_FontSizeBtn != nil) {
		[m_FontSizeBtn release];
	}
	if (m_PageSlideBtn != nil) {
		[m_PageSlideBtn release];
	}	
	if (m_BrightnessBtn != nil) {
		[m_BrightnessBtn release];
	}
	
	if (m_TableOfContentsViewBtn != nil) {
		[m_TableOfContentsViewBtn release];
	}
*/	
	[super dealloc];
}

- (void) close
{
	if (m_BrightnessPopup != nil)
	{
		[m_BrightnessPopup removeFromSuperview];
		[m_BrightnessPopup release];
	}
	
	if (m_ZoomPopup != nil)
	{
		[m_ZoomPopup removeFromSuperview];
		[m_ZoomPopup release];
	}
	
	if (m_BackgroundTonePopup != nil)
	{
		[m_BackgroundTonePopup removeFromSuperview];
		[m_BackgroundTonePopup release];
	}
	
	/*
	if (m_BgColorControlBtn != nil)
	{
		[m_BgColorControlBtn removeFromSuperview];
		[m_BgColorControlBtn release];
	}
	
	if (m_FontSizeBtn != nil)
	{
		[m_FontSizeBtn removeFromSuperview];
		[m_FontSizeBtn release];
	}
	
	if (m_SecondBgImageView != nil)
	{
		[m_SecondBgImageView removeFromSuperview];
		[m_SecondBgImageView release];
	}
	
	if (m_ScreenFixedBtn != nil)
	{
		[m_ScreenFixedBtn removeFromSuperview];
		[m_ScreenFixedBtn release];
	}
	
	if (m_BrightnessBtn != nil)
	{
		[m_BrightnessBtn removeFromSuperview];
		[m_BrightnessBtn release];
	}
	
	if (m_MaxPageNumber != nil)
	{
		[m_MaxPageNumber removeFromSuperview];
		[m_MaxPageNumber release];
	}
	
	if (m_MinPageNumber != nil)
	{
		[m_MinPageNumber removeFromSuperview];
		[m_MinPageNumber release];
	}
	
	if (m_PageSlide != nil)
	{
		[m_PageSlide removeFromSuperview];
		[m_PageSlide release];
	}
	
	if (m_BottomBgImageView != nil)
	{
		[m_BottomBgImageView removeFromSuperview];
		[m_BottomBgImageView release];
	}
*/
}


+ (id) createWithType:(NSInteger)type orientation:(UIDeviceOrientation)toInterfaceOrientation delegate:(id)delegate
{
	PBPanelBar *	panelBar = [[PBPanelBar alloc] initWithType:type orientation:toInterfaceOrientation delegate:delegate];
	if (panelBar == nil)
	{
		return nil;
	}
	
	if (type == PB_PANEL_BAR_TYPE_CARTOON)
	{
		if (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight)
		{
			[panelBar setFrame:CGRectMake(0, 320.0f, DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_WIDTH, 36.0f)];
		}
		else 
		{
//			[panelBar setFrame:CGRectMake(0, 460.0f, DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_WIDTH, DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_HEIGHT)];
			[panelBar setFrame:CGRectMake(0, 480.0f, DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_WIDTH, 45.0f)];
		}
	}
	else 
	{
		if (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight)
		{
			[panelBar setFrame:CGRectMake(0, 320.0f, DF_FORM_PANEL_BAR_EPUB_TYPE_HORZ_WIDTH, 36.0f * 2)];
		}
		else 
		{
//			[panelBar setFrame:CGRectMake(0, 460.0f, DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_WIDTH, DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_HEIGHT)];
			[panelBar setFrame:CGRectMake(0, 480.0f, DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_WIDTH, 45.0f * 2)];
		}
	}
	
	return panelBar;
}
 

- (id) initWithType:(NSInteger)type orientation:(UIDeviceOrientation)toInterfaceOrientation delegate:(id)delegate
{
	if ((self = [super init]) != nil)
	{
		m_bShow					= NO;
		m_Delegate				= delegate;
		m_Type					= type;
		m_Orientation			= toInterfaceOrientation;		
		m_bCheckBrightness		= NO;
		m_bCheckLock			= NO;
		m_BrightnessPopup		= nil;
		m_ZoomPopup				= nil;
		m_BackgroundTonePopup	= nil;
		m_Brightness			= 0.0f;
		m_ToneIndex				= BG_TONE_INDEX_WHITE;	
		m_ValidPage				= INT_MAX;
		
		if (type == PB_PANEL_BAR_TYPE_CARTOON)
		{
			if (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight)
			{
				// horizontal
				NSLog(@"horizontal = UIDeviceOrientationLandscapeLeft || UIDeviceOrientationLandscapeRight");
				
				// background image
				m_BottomBgImageView	= [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_cartoon_land.png")];
				[m_BottomBgImageView setFrame:CGRectMake(0, 0, DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_WIDTH, 36.0f)];
				[self addSubview:m_BottomBgImageView];
				
				m_PageLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 3.0f, 50.0f, 30.0f)];
				[m_PageLabel setBackgroundColor:[UIColor clearColor]];
				[m_PageLabel setTextColor:[UIColor whiteColor]];
				[m_PageLabel setFont:[m_PageLabel.font fontWithSize:12.0f]];
				[m_PageLabel setTextAlignment:UITextAlignmentLeft];		
				[m_PageLabel setText:@"페이지"];
				
				[self addSubview:m_PageLabel];

				
				// page slider
				m_PageSlide = [[UISlider alloc] initWithFrame:CGRectMake(8.0f + 50.0f, //DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_PAGE_SLIDER_SX, 
																		 6.0f,			//DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_PAGE_SLIDER_SY, 
																		 255.0f,		//DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_PAGE_SLIDER_WIDTH, 
																		 26.0f)];		//]DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_PAGE_SLIDER_HEIGHT)];
				[m_PageSlide addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
				m_PageSlide.backgroundColor = [UIColor clearColor];
				
				UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"vi_footer_config_line_comic_land_on.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
				UIImage *stetchRightTrack	= [[UIImage imageNamed:@"vi_footer_config_line_comic_land_off.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
				[m_PageSlide setThumbImage: [UIImage imageNamed:@"vi_footer_pointer.png"] forState:UIControlStateNormal];
				[m_PageSlide setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
				[m_PageSlide setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
				m_PageSlide.minimumValue = 1.0f;
				m_PageSlide.maximumValue = 100.0f;
				m_PageSlide.continuous = YES;
				[self addSubview:m_PageSlide];
				
				// min page number
				m_MinPageNumber = [[UILabel alloc] init];
				[m_MinPageNumber setFrame:CGRectMake(10.0f + 50.0f + 245.0f + 7.0f, //DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_MIN_PAGE_NUMBER_SX, 
													 3.0f,							//DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_MIN_PAGE_NUMBER_SY, 
													 30.0f,							//DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_MIN_PAGE_NUMBER_WIDTH, 
													 30.0f)];						//DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_MIN_PAGE_NUMBER_HEIGHT)];
				[m_MinPageNumber setBackgroundColor:[UIColor clearColor]];
				[m_MinPageNumber setTextColor:[UIColor redColor]];
				[m_MinPageNumber setFont:[m_MinPageNumber.font fontWithSize:13.0f]];
				[m_MinPageNumber setTextAlignment:UITextAlignmentRight];		
				[m_MinPageNumber setText:@"0"];
				[self addSubview:m_MinPageNumber];
				
				// max page number
				m_MaxPageNumber = [[UILabel alloc] init];
				[m_MaxPageNumber setFrame:CGRectMake(10.0f + 50.0f + 245.0f + 7.0f + 30.0f, //DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_MAX_PAGE_NUMBER_SX, 
													 3.0f,							//DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_MAX_PAGE_NUMBER_SY, 
													 30.0f,							//DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_MAX_PAGE_NUMBER_WIDTH, 
													 30.0f)];						//DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_MAX_PAGE_NUMBER_HEIGHT)];
				[m_MaxPageNumber setBackgroundColor:[UIColor clearColor]];
				[m_MaxPageNumber setTextColor:[UIColor whiteColor]];
				[m_MaxPageNumber setFont:[m_MaxPageNumber.font fontWithSize:13.0f]];
				[m_MaxPageNumber setTextAlignment:UITextAlignmentLeft];			
				[m_MaxPageNumber setText:[NSString stringWithFormat:@"/%d",0]];
				[self addSubview:m_MaxPageNumber];
				
				// screen fixed button
				m_ScreenFixedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				[m_ScreenFixedBtn setFrame:CGRectMake(480.f - 97.0f,	//DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_SCREEN_FIXED_SX, 
													  0.0f,				//DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_SCREEN_FIXED_SY, 
													  97.0f,			//DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_SCREEN_FIXED_WIDTH, 
													  36.0f)];			//DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_SCREEN_FIXED_HEIGHT)];
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_land_off.png") forState:UIControlStateNormal];  
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_land_on.png") forState:UIControlStateHighlighted];
				[m_ScreenFixedBtn addTarget:self action:@selector(clickScreenFixedBtn:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:m_ScreenFixedBtn];
			}
			else 
			{
				// background image
				m_BottomBgImageView	= [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_cartoon.png")];
				[m_BottomBgImageView setFrame:CGRectMake(0, 
														 0, 
														 DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_WIDTH, 
														 45.0f)];
				[self addSubview:m_BottomBgImageView];
				
				m_PageLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 8.0f, 50.0f, 30.0f)];
				[m_PageLabel setBackgroundColor:[UIColor clearColor]];
				[m_PageLabel setTextColor:[UIColor whiteColor]];
				[m_PageLabel setFont:[m_PageLabel.font fontWithSize:13.0f]];
				[m_PageLabel setTextAlignment:UITextAlignmentLeft];		
				[m_PageLabel setText:@"페이지"];				
				[self addSubview:m_PageLabel];

				
				// page slider
				m_PageSlide = [[UISlider alloc] initWithFrame:CGRectMake(8.0f + 50.0f, //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_PAGE_SLIDER_SX, 
																		 10.0f,			//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_PAGE_SLIDER_SY, 
																		 144.0f,		//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_PAGE_SLIDER_WIDTH, 
																		 26.0f)];		//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_PAGE_SLIDER_HEIGHT)];
				m_PageSlide.backgroundColor = [UIColor clearColor];
				
				UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"vi_footer_config_line_comic_on.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
				UIImage *stetchRightTrack	= [[UIImage imageNamed:@"vi_footer_config_line_comic_off.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
				
				[m_PageSlide setThumbImage: [UIImage imageNamed:@"vi_footer_pointer.png"] forState:UIControlStateNormal];
				[m_PageSlide setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
				[m_PageSlide setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
				m_PageSlide.minimumValue = 0.0f;
				m_PageSlide.maximumValue = 0.0f;
				m_PageSlide.continuous = YES;
				m_PageSlide.value = 0.0f;
				[m_PageSlide addTarget:self action:@selector(sliderActionTouchUp:) forControlEvents:UIControlEventTouchUpInside];
                [m_PageSlide addTarget:self action:@selector(sliderActionTouchUp:) forControlEvents:UIControlEventTouchUpOutside];	
				[m_PageSlide addTarget:self action:@selector(sliderActionValueChanged:) forControlEvents:UIControlEventValueChanged];
				[self addSubview:m_PageSlide];
				
				// min page number
				m_MinPageNumber = [[UILabel alloc] init];
				[m_MinPageNumber setFrame:CGRectMake(10.0f + 50.0f + 133.0f + 2.0f, //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MIN_PAGE_NUMBER_SX, 
													 8.0f,							//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MIN_PAGE_NUMBER_SY, 
													 30.0f,							//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MIN_PAGE_NUMBER_WIDTH, 
													 30.0f)];						//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MIN_PAGE_NUMBER_HEIGHT)];
				[m_MinPageNumber setBackgroundColor:[UIColor clearColor]];
				[m_MinPageNumber setTextColor:[UIColor redColor]];
				[m_MinPageNumber setFont:[m_MinPageNumber.font fontWithSize:13.0f]];
				[m_MinPageNumber setTextAlignment:UITextAlignmentRight];		
				[m_MinPageNumber setText:@"0"];
				[self addSubview:m_MinPageNumber];
				
				// max page number
				m_MaxPageNumber = [[UILabel alloc] init];
				[m_MaxPageNumber setFrame:CGRectMake(10.0f + 50.0f + 133.0f + 2.0f + 30.0f, //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MAX_PAGE_NUMBER_SX, 
													 8.0f,									 //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MAX_PAGE_NUMBER_SY, 
													 30.0f,									 //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MAX_PAGE_NUMBER_WIDTH, 
													 30.0f)];								//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MAX_PAGE_NUMBER_HEIGHT)];
				[m_MaxPageNumber setBackgroundColor:[UIColor clearColor]];
				[m_MaxPageNumber setTextColor:[UIColor whiteColor]];
				[m_MaxPageNumber setFont:[m_MaxPageNumber.font fontWithSize:13.0f]];
				[m_MaxPageNumber setTextAlignment:UITextAlignmentLeft];		
				[m_MaxPageNumber setText:[NSString stringWithFormat:@"/%d",0]];
				[self addSubview:m_MaxPageNumber];
		
				m_ScreenFixedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				[m_ScreenFixedBtn setFrame:CGRectMake(320.f - 62.0f, 
													  1.0f, 
													  62.0f, 
													  45.0f)];
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_off.png") forState:UIControlStateNormal];  
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_on.png") forState:UIControlStateHighlighted];
				[m_ScreenFixedBtn addTarget:self action:@selector(clickScreenFixedBtn:) forControlEvents:UIControlEventTouchUpInside];
				
				[self addSubview:m_ScreenFixedBtn];				
			}
		}
		else // epub
		{
			if (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight)
			{
				// horizontal
				
				// first bottom line				
				m_SildeBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 480.0f, 36.0f)];
				[m_SildeBgView setBackgroundColor:[UIColor clearColor]];
				[self addSubview:m_SildeBgView];
				
				m_SildeBgImageView = [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_novel2depth_land.png")];				 
				[m_SildeBgImageView setFrame:CGRectMake(0.0f, 0.0f, 480.0f, 36.0f)];
				[m_SildeBgView addSubview:m_SildeBgImageView];
				
				m_PageLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 3.0f, 50.0f, 30.0f)];
				[m_PageLabel setBackgroundColor:[UIColor clearColor]];
				[m_PageLabel setTextColor:[UIColor whiteColor]];
				[m_PageLabel setFont:[m_PageLabel.font fontWithSize:13.0f]];
				[m_PageLabel setTextAlignment:UITextAlignmentLeft];		
				[m_PageLabel setText:@"페이지"];		
				[m_SildeBgView addSubview:m_PageLabel];
				
				// page slider
				m_PageSlide = [[UISlider alloc] initWithFrame:CGRectMake(15.0f + 50.0f - 5.0f, 5.0f, 345.0f, 26.0f)];
				[m_PageSlide setBackgroundColor:[UIColor clearColor]];
				[m_PageSlide setThumbImage: [UIImage imageNamed:@"vi_footer_pointer.png"] forState:UIControlStateNormal];
				
				UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"vi_footer_config_line_on.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
				UIImage *stetchRightTrack	= [[UIImage imageNamed:@"vi_footer_config_line_off.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];				
				[m_PageSlide setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
				[m_PageSlide setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
				m_PageSlide.minimumValue = 0.0f;
				m_PageSlide.maximumValue = 0.0f;
				m_PageSlide.continuous = YES;
				m_PageSlide.value = 0.0f;
				
				[m_PageSlide addTarget:self action:@selector(sliderActionTouchUp:) forControlEvents:UIControlEventTouchUpInside];			
                [m_PageSlide addTarget:self action:@selector(sliderActionTouchUp:) forControlEvents:UIControlEventTouchUpOutside];	
				[m_PageSlide addTarget:self action:@selector(sliderActionValueChanged:) forControlEvents:UIControlEventValueChanged];			
				[m_SildeBgView addSubview:m_PageSlide];
				
				m_MinPageNumber = [[UILabel alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 330.0f, 3.0f, 40.0f, 30.0f)];
				[m_MinPageNumber setBackgroundColor:[UIColor clearColor]];
				[m_MinPageNumber setTextColor:[UIColor whiteColor]];
				[m_MinPageNumber setFont:[m_MinPageNumber.font fontWithSize:13.0f]];
				[m_MinPageNumber setTextAlignment:UITextAlignmentRight];		
				[m_MinPageNumber setText:@"0"];			
				[m_SildeBgView addSubview:m_MinPageNumber];
				
				
				m_MaxPageNumber = [[UILabel alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 330.0f + 40.0f, 3.0f, 40.0f, 30.0f)];
				[m_MaxPageNumber setBackgroundColor:[UIColor clearColor]];
				[m_MaxPageNumber setTextColor:[UIColor redColor]];
				[m_MaxPageNumber setFont:[m_MaxPageNumber.font fontWithSize:13.0f]];
				[m_MaxPageNumber setTextAlignment:UITextAlignmentLeft];		
				[m_MaxPageNumber setText:@"/0"];
				
				[m_SildeBgView addSubview:m_MaxPageNumber];
				
				// second bottom line
				m_BottomBgImageView	= [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_novel_land.png")];
				[m_BottomBgImageView setFrame:CGRectMake(0, //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_SX, 
														 0 + 36.0f, //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_SY, 
														 DF_FORM_PANEL_BAR_EPUB_TYPE_HORZ_FIRST_WIDTH, 
														 36.0f)]; //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_HEIGHT)];
				[self addSubview:m_BottomBgImageView];
				
				m_PageSlideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				[m_PageSlideBtn setFrame:CGRectMake(0.0f, 
													0.0f + 36.0f, 
													120.0f, 
													36.0f)];
				[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_off.png") forState:UIControlStateNormal];  
				[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_off.png") forState:UIControlStateHighlighted];
				[m_PageSlideBtn addTarget:self action:@selector(clickPageSlideBtn:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:m_PageSlideBtn];
				
				m_BgColorControlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				[m_BgColorControlBtn setFrame:CGRectMake(0.0f + 120.0f, 
														 0.0f + 36.0f, 
														 120.0f, 
														 36.0f)];
				[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_off.png") forState:UIControlStateNormal];  
				[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_off.png") forState:UIControlStateHighlighted];
				[m_BgColorControlBtn addTarget:self action:@selector(clickBgColorControlBtn:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:m_BgColorControlBtn];
				
				
				m_FontSizeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				[m_FontSizeBtn setFrame:CGRectMake(0.0f + (120.0f * 2), 
												   0.0f + 36.0f, 
												   120.0f, 
												   36.0f)];
				[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_off.png") forState:UIControlStateNormal];  
				[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_off.png") forState:UIControlStateHighlighted];
				[m_FontSizeBtn addTarget:self action:@selector(clickFontSizeBtn:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:m_FontSizeBtn];
				
				m_ScreenFixedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				[m_ScreenFixedBtn setFrame:CGRectMake(0.0f + (120.0f * 3), 
													  0.0f + 36.0f, 
													  120.0f, 
													  36.0f)];
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_off.png") forState:UIControlStateNormal];  
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_on.png") forState:UIControlStateHighlighted];  				
				[m_ScreenFixedBtn addTarget:self action:@selector(clickScreenFixedBtn:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:m_ScreenFixedBtn];
				
			}
			else 
			{
				// Vertical

				m_SildeBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 45.0f)];
				[m_SildeBgView setBackgroundColor:[UIColor clearColor]];
				[self addSubview:m_SildeBgView];
				
				m_SildeBgImageView = [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_novel2depth.png")];				 
				[m_SildeBgImageView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 45.0f)];
				[m_SildeBgView addSubview:m_SildeBgImageView];
								 
				// first bottom line
				
				m_PageLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 8.0f, 50.0f, 30.0f)];
				[m_PageLabel setBackgroundColor:[UIColor clearColor]];
				[m_PageLabel setTextColor:[UIColor whiteColor]];
				[m_PageLabel setFont:[m_PageLabel.font fontWithSize:13.0f]];
				[m_PageLabel setTextAlignment:UITextAlignmentLeft];		
				[m_PageLabel setText:@"페이지"];		
				[m_SildeBgView addSubview:m_PageLabel];

				// page slider
				m_PageSlide = [[UISlider alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 5.0f, 8.0f, 173.0f, 30.0f)];
				[m_PageSlide setBackgroundColor:[UIColor clearColor]];
				[m_PageSlide setThumbImage: [UIImage imageNamed:@"vi_footer_pointer.png"] forState:UIControlStateNormal];
				
				UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"vi_footer_config_line_on.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
				UIImage *stetchRightTrack	= [[UIImage imageNamed:@"vi_footer_config_line_off.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];				
				[m_PageSlide setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
				[m_PageSlide setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
				m_PageSlide.minimumValue = 0.0f;
				m_PageSlide.maximumValue = 0.0f;
				m_PageSlide.continuous = YES;
				m_PageSlide.value = 0.0f;
				
				[m_PageSlide addTarget:self action:@selector(sliderActionTouchUp:) forControlEvents:UIControlEventTouchUpInside];			
                [m_PageSlide addTarget:self action:@selector(sliderActionTouchUp:) forControlEvents:UIControlEventTouchUpOutside];	                
				[m_PageSlide addTarget:self action:@selector(sliderActionValueChanged:) forControlEvents:UIControlEventValueChanged];			
				[m_SildeBgView addSubview:m_PageSlide];
				
				m_MinPageNumber = [[UILabel alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 173.0f, 8.0f, 40.0f, 30.0f)];
				[m_MinPageNumber setBackgroundColor:[UIColor clearColor]];
				[m_MinPageNumber setTextColor:[UIColor whiteColor]];
				[m_MinPageNumber setFont:[m_MinPageNumber.font fontWithSize:13.0f]];
				[m_MinPageNumber setTextAlignment:UITextAlignmentRight];		
				[m_MinPageNumber setText:@"0"];			
				[m_SildeBgView addSubview:m_MinPageNumber];
				
				
				m_MaxPageNumber = [[UILabel alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 173.0f + 40.0f, 8.0f, 40.0f, 30.0f)];
				[m_MaxPageNumber setBackgroundColor:[UIColor clearColor]];
				[m_MaxPageNumber setTextColor:[UIColor redColor]];
				[m_MaxPageNumber setFont:[m_MaxPageNumber.font fontWithSize:13.0f]];
				[m_MaxPageNumber setTextAlignment:UITextAlignmentLeft];		
				[m_MaxPageNumber setText:@"/0"];
				
				[m_SildeBgView addSubview:m_MaxPageNumber];
				
				
				// second bottom line
				m_BottomBgImageView	= [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_novel.png")];
				[m_BottomBgImageView setFrame:CGRectMake(0, //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_SX, 
														 0 + 45.0f, //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_SY, 
														 DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_WIDTH, 
														 45.0f)]; //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_HEIGHT)];
				[self addSubview:m_BottomBgImageView];
				
				m_PageSlideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				[m_PageSlideBtn setFrame:CGRectMake(0.0f, 
													45.0f, 
													80.0f, 
													45.0f)];
				[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_off.png") forState:UIControlStateNormal];  
				[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_off.png") forState:UIControlStateHighlighted];
				[m_PageSlideBtn addTarget:self action:@selector(clickPageSlideBtn:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:m_PageSlideBtn];

				m_BgColorControlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				[m_BgColorControlBtn setFrame:CGRectMake(0.0f + 80.0f, 
													45.0f, 
													80.0f, 
													45.0f)];
				[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_off.png") forState:UIControlStateNormal];  
				[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_off.png") forState:UIControlStateHighlighted];
				[m_BgColorControlBtn addTarget:self action:@selector(clickBgColorControlBtn:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:m_BgColorControlBtn];
				
				
				m_FontSizeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				[m_FontSizeBtn setFrame:CGRectMake(0.0f + (80.0f * 2), 
													45.0f, 
													80.0f, 
													45.0f)];
				[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_off.png") forState:UIControlStateNormal];  
				[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_off.png") forState:UIControlStateHighlighted];
				[m_FontSizeBtn addTarget:self action:@selector(clickFontSizeBtn:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:m_FontSizeBtn];

				m_ScreenFixedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				[m_ScreenFixedBtn setFrame:CGRectMake(0.0f + (80.0f * 3), 
												   45.0f, 
												   80.0f, 
												   45.0f)];
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_off.png") forState:UIControlStateNormal];  
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_on.png") forState:UIControlStateHighlighted];  				
				[m_ScreenFixedBtn addTarget:self action:@selector(clickScreenFixedBtn:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:m_ScreenFixedBtn];
				
			}
		}
	}
	
	return self;
}

- (void) resize:(UIInterfaceOrientation)toInterfaceOrientation
{
	m_Orientation = toInterfaceOrientation;
	
	if (m_Type == PB_PANEL_BAR_TYPE_CARTOON)
	{
		if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
		{			
			
			NSLog(@"[UIInterfaceOrientationLandscapeLeft] m_bShow=[%@]", (m_bShow == YES) ? @"YES" : @"NO");
			
			if (m_bShow == YES)
			{
				[self setFrame:CGRectMake(0.0f, 
										  320.0f - 36.0f, 
										  DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_WIDTH, 
										  36.0f)];
			}
			else 
			{
				[self setFrame:CGRectMake(0.0f, 
										  320.0f, 
										  DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_WIDTH, 
										  36.0f)];
			}
		
			[m_PageLabel setFrame:CGRectMake(15.0f, 3.0f, 50.0f, 30.0f)];
			
			// background image
			[m_BottomBgImageView setImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_cartoon_land.png")];
			[m_BottomBgImageView setFrame:CGRectMake(0, 
													 0, 
													 DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_WIDTH, 
													 36.0f)];

			// page slider
			[m_PageSlide setFrame:CGRectMake(8.0f + 50.0f, //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_PAGE_SLIDER_SX, 
											 6.0f,			//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_PAGE_SLIDER_SY, 
											 255.0f,		//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_PAGE_SLIDER_WIDTH, 245
											 26.0f)];		//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_PAGE_SLIDER_HEIGHT)];
			UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"vi_footer_config_line_comic_land_on.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			UIImage *stetchRightTrack	= [[UIImage imageNamed:@"vi_footer_config_line_comic_land_off.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];

			[m_PageSlide setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
			[m_PageSlide setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
			
			// min page number
			[m_MinPageNumber setFrame:CGRectMake(10.0f + 50.0f + 245.0f + 7.0f, //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MIN_PAGE_NUMBER_SX, 
												 3.0f,							//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MIN_PAGE_NUMBER_SY, 
												 30.0f,							//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MIN_PAGE_NUMBER_WIDTH, 
												 30.0f)];						//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MIN_PAGE_NUMBER_HEIGHT)];
			// max page number
			[m_MaxPageNumber setFrame:CGRectMake(10.0f + 50.0f + 245.0f + 7.0f + 30.0f, //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MAX_PAGE_NUMBER_SX, 
												 3.0f,									 //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MAX_PAGE_NUMBER_SY, 
												 30.0f,									 //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MAX_PAGE_NUMBER_WIDTH, 
												 30.0f)];								//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MAX_PAGE_NUMBER_HEIGHT)];
			
			[m_ScreenFixedBtn setFrame:CGRectMake(480.f - 97.0f, 
												  0.0f, 
												  97.0f, 
												  36.0f)];			
			[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_land_off.png") forState:UIControlStateNormal];
			[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_land_on.png") forState:UIControlStateHighlighted];  
		}
		else 
		{
			NSLog(@"[UIInterfaceOrientationPortrait] m_bShow=[%@]", (m_bShow == YES) ? @"YES" : @"NO");
			
			if (m_bShow == YES)
			{
				[self setFrame:CGRectMake(0.0f, 
										  480.0f - 45.0f, 
										  DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_WIDTH, 
										  45.0f)];
			}
			else 
			{
				[self setFrame:CGRectMake(0.0f, 
										  480.0f, 
										  DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_WIDTH, 
										  45.0f)];
			}

			[m_PageLabel setFrame:CGRectMake(15.0f, 8.0f, 50.0f, 30.0f)];
			
			// background image
			[m_BottomBgImageView setImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_cartoon.png")];
			[m_BottomBgImageView setFrame:CGRectMake(0, 
													 0, 
													 DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_WIDTH, 
													 45.0f)];

			// page slider
			[m_PageSlide setFrame:CGRectMake(8.0f + 50.0f, //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_PAGE_SLIDER_SX, 
											 10.0f,			//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_PAGE_SLIDER_SY, 
											 144.0f,		//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_PAGE_SLIDER_WIDTH, 
											 26.0f)];		//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_PAGE_SLIDER_HEIGHT)];
			UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"vi_footer_config_line_comic_on.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			UIImage *stetchRightTrack	= [[UIImage imageNamed:@"vi_footer_config_line_comic_off.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			
			[m_PageSlide setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
			[m_PageSlide setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
			
			// min page number
			[m_MinPageNumber setFrame:CGRectMake(10.0f + 50.0f + 133.0f + 2.0f, //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MIN_PAGE_NUMBER_SX, 
												 8.0f,							//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MIN_PAGE_NUMBER_SY, 
												 30.0f,							//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MIN_PAGE_NUMBER_WIDTH, 
												 30.0f)];						//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MIN_PAGE_NUMBER_HEIGHT)];
			// max page number
			[m_MaxPageNumber setFrame:CGRectMake(10.0f + 50.0f + 133.0f + 2.0f + 30.0f, //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MAX_PAGE_NUMBER_SX, 
												 8.0f,									 //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MAX_PAGE_NUMBER_SY, 
												 30.0f,									 //DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MAX_PAGE_NUMBER_WIDTH, 
												 30.0f)];								//DF_FORM_PANEL_BAR_CARTOON_TYPE_VERT_MAX_PAGE_NUMBER_HEIGHT)];

			
			[m_ScreenFixedBtn setFrame:CGRectMake(320.0f - 62.0f, 
												  1.0f, 
												  62.0f, 
												  45.0f)];
			
			[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_off.png") forState:UIControlStateNormal];  
			[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_on.png") forState:UIControlStateHighlighted];			
		}
	}
	else // epub
	{
		if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
		{
			// Horizontal
			
			if (m_bShow == YES)
			{
				[self setFrame:CGRectMake(0.0f, 
										  320.0f - (36.0f * 2), 
										  DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_WIDTH, 
										  36.0f)];
			}
			else 
			{
				[self setFrame:CGRectMake(0.0f, 
										  320.0f, 
										  DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_WIDTH, 
										  36.0f * 2)];
			}
			
			// first bottom line
			[m_SildeBgView setFrame:CGRectMake(0.0f, 0.0f, 480.0f, 36.0f)];
			
			[m_SildeBgImageView setImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_novel2depth_land.png")];				 
			[m_SildeBgImageView setFrame:CGRectMake(0.0f, 0.0f, 480.0f, 36.0f)];

			[m_PageLabel setFrame:CGRectMake(15.0f, 3.0f, 50.0f, 30.0f)];
			
			// page slider
			[m_PageSlide setFrame:CGRectMake(15.0f + 50.0f - 5.0f, 5.0f, 345.0f, 26.0f)];
			
			UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"vi_footer_config_line_land_on.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			UIImage *stetchRightTrack	= [[UIImage imageNamed:@"vi_footer_config_line_land_off.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			[m_PageSlide setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
			[m_PageSlide setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
			
			[m_MinPageNumber setFrame:CGRectMake(15.0f + 50.0f + 330.0f, 3.0f, 40.0f, 30.0f)];
			[m_MaxPageNumber setFrame:CGRectMake(15.0f + 50.0f + 330.0f + 40.0f, 3.0f, 40.0f, 30.0f)];
			
			
			// second bottom bar
			[m_BottomBgImageView setFrame:CGRectMake(0, //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_SX, 
													 0 + 36.0f, //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_SY, 
													 DF_FORM_PANEL_BAR_CARTOON_TYPE_HORZ_WIDTH, 
													 36.0f)]; //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_HEIGHT)];
			[m_BottomBgImageView setImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_novel_land.png")];
			
			[m_PageSlideBtn setFrame:CGRectMake(0.0f, 
												0.0f + 36.0f, 
												120.0f, 
												36.0f)];
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_land_off.png") forState:UIControlStateNormal];  
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_land_on.png") forState:UIControlStateHighlighted];
			
			
			[m_BgColorControlBtn setFrame:CGRectMake(0.0f + 120.0f, 
													 0.0f + 36.0f, 
													 120.0f, 
													 36.0f)];
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_land_off.png") forState:UIControlStateNormal];  
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_land_on.png") forState:UIControlStateHighlighted];

			[m_FontSizeBtn setFrame:CGRectMake(0.0f + (120.0f * 2), 
											   0.0f + 36.0f, 
											   120.0f, 
											   36.0f)];
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_land_off.png") forState:UIControlStateNormal];  
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_land_on.png") forState:UIControlStateHighlighted];

			[m_ScreenFixedBtn setFrame:CGRectMake(0.0f + (120.0f * 3), 
												  0.0f + 36.0f, 
												  120.0f, 
												  36.0f)];			
			[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_land_off.png") forState:UIControlStateNormal];
			[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_land_on.png") forState:UIControlStateHighlighted];


		}
		else 
		{
			// Vertical
			
			if (m_bShow == YES)
			{
				[self setFrame:CGRectMake(0.0f, 
										  480.0f - (45.0f * 2), //460.0f - DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_HEIGHT, 
										  DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_WIDTH, 
										  45.0f * 2)]; //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_HEIGHT)];
			}
			else 
			{
				[self setFrame:CGRectMake(0.0f, 
										  480.0f, 
										  DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_WIDTH, 
										  45.0f * 2)]; //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_HEIGHT)];
			}

			// first bottom line
			[m_SildeBgView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 45.0f)];
			
			[m_SildeBgImageView setImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_novel2depth.png")];				 
			[m_SildeBgImageView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 45.0f)];

			[m_PageLabel setFrame:CGRectMake(15.0f, 8.0f, 50.0f, 30.0f)];
			
			// page slider
			[m_PageSlide setFrame:CGRectMake(15.0f + 50.0f + 5.0f, 8.0f, 173.0f, 30.0f)];

			UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"vi_footer_config_line_on.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			UIImage *stetchRightTrack	= [[UIImage imageNamed:@"vi_footer_config_line_off.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			[m_PageSlide setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
			[m_PageSlide setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
			
			[m_MinPageNumber setFrame:CGRectMake(15.0f + 50.0f + 173.0f, 8.0f, 40.0f, 30.0f)];
			[m_MaxPageNumber setFrame:CGRectMake(15.0f + 50.0f + 173.0f + 40.0f, 8.0f, 40.0f, 30.0f)];
			
			
			// second bottom bar	
			[m_BottomBgImageView setFrame:CGRectMake(0, //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_SX, 
													 0 + 45.0f, //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_SY, 
													 DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_WIDTH, 
													 45.0f)]; //DF_FORM_PANEL_BAR_EPUB_TYPE_VERT_FIRST_HEIGHT)];
			[m_BottomBgImageView setImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_novel.png")];
			
			[m_PageSlideBtn setFrame:CGRectMake(0.0f, 
												45.0f, 
												80.0f, 
												45.0f)];
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_off.png") forState:UIControlStateNormal];  
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_off.png") forState:UIControlStateHighlighted];


			[m_BgColorControlBtn setFrame:CGRectMake(0.0f + 80.0f, 
													 45.0f, 
													 80.0f, 
													 45.0f)];
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_off.png") forState:UIControlStateNormal];  
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_off.png") forState:UIControlStateHighlighted];
			
			[m_FontSizeBtn setFrame:CGRectMake(0.0f + (80.0f * 2), 
											   45.0f, 
											   80.0f, 
											   45.0f)];
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_off.png") forState:UIControlStateNormal];  
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_off.png") forState:UIControlStateHighlighted];
			
			[m_ScreenFixedBtn setFrame:CGRectMake(0.0f + (80.0f * 3), 
												  45.0f, 
												  80.0f, 
												  45.0f)];
			[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_off.png") forState:UIControlStateNormal];  
			[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_on.png") forState:UIControlStateHighlighted];
		}
	}
	
	if (m_BrightnessPopup != nil)
	{
		[m_BrightnessPopup resize:toInterfaceOrientation];
	}
	
	if (m_ZoomPopup != nil)
	{
		[m_ZoomPopup resize:toInterfaceOrientation];
	}
}

- (void) showBar:(BOOL)bShow
{
	if (m_bShow == bShow)
	{
		return;
	}
	
	TRACE(@"bShow = %d", bShow);
	
	m_bShow = bShow;
	
	if (bShow == YES)
	{
		[self _hideSubPopup:SUB_POPUP_NONE];
		
		CGRect rcBar = self.frame;
		
		[self setFrame:rcBar];

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        
		rcBar.origin.y -= rcBar.size.height;
        [self setFrame:rcBar]; 

        [UIView commitAnimations];				
	}
	else 
	{
		[UIView animateWithDuration:VIEW_ANI_DURATION
						 animations:^{
							 CGRect rcBar = self.frame;
							 
							 [self setFrame:rcBar];
							 
							 rcBar.origin.y += rcBar.size.height;
							 [self setFrame:rcBar]; 					 		
							 
							 UIView* subPopup = [self _getActiveSubPopup];
							 if (subPopup != nil) {
								 CGRect rect = subPopup.frame;
								 
								 rect.origin.y += rcBar.size.height;
								 [subPopup setFrame:rect];
							 }
						 }
						 completion:^(BOOL finished){
							 //do nothing
							 [self _hideSubPopup:SUB_POPUP_NONE];
						 }];
		
/*		
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        

		
		rcBar.origin.y += rcBar.size.height;
        [self setFrame:rcBar]; 

        [UIView commitAnimations];
*/ 
	}

}

- (BOOL) isShowBar
{
	return m_bShow;
}

- (void) setPageMax:(CGFloat)max
{
	if (m_Type == PB_PANEL_BAR_TYPE_CARTOON) {
		[m_PageSlide setMaximumValue:max];
		
		[m_MaxPageNumber setText:[NSString stringWithFormat:@"/%d", (NSInteger)max]];
	}
	else {
		[m_PageSlide setMaximumValue:max];

		[m_MaxPageNumber setText:[NSString stringWithFormat:@"/%d", (NSInteger)max]];
	}
}

- (void) setPageWithMin:(CGFloat)min max:(CGFloat)max
{
	if (m_Type == PB_PANEL_BAR_TYPE_CARTOON) {
		[m_PageSlide setMinimumValue:min];
		[m_PageSlide setMaximumValue:max];
		
		[m_MinPageNumber setText:[NSString stringWithFormat:@"%d", (NSInteger)min]];
		[m_MaxPageNumber setText:[NSString stringWithFormat:@"/%d", (NSInteger)max]];
	}
	else {
		[m_PageSlide setMinimumValue:min];
		[m_PageSlide setMaximumValue:max];
		
		[m_MinPageNumber setText:[NSString stringWithFormat:@"%d", (NSInteger)min]];
		[m_MaxPageNumber setText:[NSString stringWithFormat:@"/%d", (NSInteger)max]];
	}
}

- (void) setValidPage:(CGFloat)page
{
	m_ValidPage = page;
}

- (CGFloat) getCurrentPage
{
	return m_PageSlide.value;
}

- (CGFloat) setcurrentPage:(CGFloat)pageNumber
{
	NSLog(@"pageNumber=[%f]", pageNumber);
	
	CGFloat preValue = m_PageSlide.value;
	
	[m_PageSlide setValue:1.0f];
	[m_PageSlide setValue:pageNumber];
	[m_MinPageNumber setText:[NSString stringWithFormat:@"%d", (NSInteger)pageNumber]];
	
	return preValue;
/*	
	CGFloat preValue = m_PageSlide.value;
	
	[m_PageSlide setValue:1.0f];
	[m_PageSlide setValue:pageNumber];
	[m_MinPageNumber setText:[NSString stringWithFormat:@"%d", (NSInteger)pageNumber]];
	
	return preValue;
*/ 
}

- (void) setReloadPercent:(NSInteger)percent
{
	[m_MaxPageNumber setText:[NSString stringWithFormat:@"/%d%@", (NSInteger)percent, @"%"]];
}

- (void) setBrightness:(CGFloat)brightness
{
	m_Brightness = brightness;
	
	if (m_BrightnessPopup != nil)
	{
		[m_BrightnessPopup setBrightness:brightness];
	}
}

- (void) setBackgroundTone:(NSInteger)toneIndex
{
	if (m_ToneIndex == toneIndex)
	{
		return;
	}
	
	m_ToneIndex	= toneIndex;
	
	if (m_BackgroundTonePopup != nil)
	{
		[m_BackgroundTonePopup setToneIndex:m_ToneIndex];
	}
}

- (void) setFontScale:(CGFloat)fontScale {
	
	NSLog(@"fontScale=[%f]", fontScale);
	
	m_FontScale= fontScale;
}



- (UIView*) _getActiveSubPopup
{
	if (m_FontSizePopup != nil) { 
		return m_FontSizePopup; 
	}
	else if (m_BackgroundTonePopup != nil) { 
		return m_BackgroundTonePopup; 
	}	
	return nil;
}

- (void) _hideSubPopup:(NSInteger)notHidesubPopupIndex
{
	UIDeviceOrientation orientation	= m_Orientation;
	
	if (notHidesubPopupIndex == SUB_POPUP_PAGE_SLIDE || notHidesubPopupIndex == SUB_POPUP_NONE) {	
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_land_on.png") forState:UIControlStateNormal];  
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_land_on.png") forState:UIControlStateHighlighted];
		}
		else {
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_on.png") forState:UIControlStateNormal];  
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_on.png") forState:UIControlStateHighlighted];
		}
		[m_SildeBgView setHidden:NO];
	}
	else if(notHidesubPopupIndex != SUB_POPUP_PAGE_SLIDE) {
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_land_off.png") forState:UIControlStateNormal];  
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_land_off.png") forState:UIControlStateHighlighted];
		}
		else {
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_off.png") forState:UIControlStateNormal];  
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_off.png") forState:UIControlStateHighlighted];
		}
		[m_SildeBgView setHidden:YES];	
	}

	
/*		
	if (m_BrightnessPopup != nil && notHidesubPopupIndex != SUB_POPUP_BRIGHTNESS)
	{
		[m_BrightnessBtn setBackgroundImage:RESOURCE_IMAGE(@"brightness_change.png") forState:UIControlStateNormal];  
		[m_BrightnessBtn setBackgroundImage:RESOURCE_IMAGE(@"brightness_change.png") forState:UIControlStateHighlighted];
		
		[m_BrightnessPopup removeFromSuperview];
		[m_BrightnessPopup release];
		m_BrightnessPopup = nil;
	}	

	if (m_PageSlidePopup != nil && notHidesubPopupIndex != SUB_POPUP_PAGE_SLIDE) 
	{
		[m_PageSlidePopup removeFromSuperview];
		[m_PageSlidePopup release];
		m_PageSlidePopup = nil;		
		
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_land_off.png") forState:UIControlStateNormal];  
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_land_off.png") forState:UIControlStateHighlighted];
		}
		else {
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_off.png") forState:UIControlStateNormal];  
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_off.png") forState:UIControlStateHighlighted];
		}
	} 
*/	
	if (m_FontSizePopup != nil && notHidesubPopupIndex != SUB_POPUP_ZOOM)
	{
		[m_FontSizePopup removeFromSuperview];
		[m_FontSizePopup release];
		m_FontSizePopup = nil;
		
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_land_off.png") forState:UIControlStateNormal];  
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_land_off.png") forState:UIControlStateHighlighted];
		}
		else {
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_off.png") forState:UIControlStateNormal];  
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_off.png") forState:UIControlStateHighlighted];
		}
	}
	
	if (m_BackgroundTonePopup != nil && notHidesubPopupIndex != SUB_POPUP_BG_TONE)
	{
		[m_BackgroundTonePopup removeFromSuperview];
		[m_BackgroundTonePopup release];
		m_BackgroundTonePopup = nil;

		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {		
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_land_off.png") forState:UIControlStateNormal];  
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_land_off.png") forState:UIControlStateHighlighted];		
		}
		else {
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_off.png") forState:UIControlStateNormal];  
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_off.png") forState:UIControlStateHighlighted];					
		}
	}
}


#pragma mark -
#pragma mark UISlider action
- (void)sliderAction:(id)sender
{ 
	TRACE(@"slide value = %d", (NSInteger)m_PageSlide.value);
	
	[self _hideSubPopup:SUB_POPUP_NONE];

	[m_MinPageNumber setText:[NSString stringWithFormat:@"%d", (NSInteger)m_PageSlide.value]];
	
	
	[m_Delegate pbpChangePage:m_PageSlide.value];
}

- (void) pbbChangeBrightness:(CGFloat)brightness
{
	TRACE(@"brightness = %f", brightness);
	
	m_Brightness = brightness;
	[m_Delegate pbpChangeBrightness:brightness];
}

#pragma mark -
#pragma mark UIButton action

- (IBAction) clickPageSlideBtn:(id)sender
{
	TRACE(@"");
	
	[self _hideSubPopup:SUB_POPUP_PAGE_SLIDE];
/*	
	UIDeviceOrientation orientation	= m_Orientation; 
	
	if (m_PageSlidePopup == nil) {
		[self _hideSubPopup:SUB_POPUP_PAGE_SLIDE];
	
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_land_on.png") forState:UIControlStateNormal];  
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_ladn_on.png") forState:UIControlStateHighlighted];  
		}
		else {
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_on.png") forState:UIControlStateNormal];  
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_on.png") forState:UIControlStateHighlighted];  			
		}
		
		m_PageSlidePopup = [PageSlidePopup createWithDelegate:self orientation:orientation];
		[m_PageSlidePopup setPageWithMin:m_PageSlideMin max:m_PageSlideMax];
		[m_PageSlidePopup setCurrentPage:m_CurrentPage];
		
		[self.superview addSubview:m_PageSlidePopup];
	}
	else {
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_land_off.png") forState:UIControlStateNormal];  
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_land_off.png") forState:UIControlStateHighlighted];  			
		}
		else {
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_off.png") forState:UIControlStateNormal];  
			[m_PageSlideBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_page_off.png") forState:UIControlStateHighlighted];  
		}
		
		[m_PageSlidePopup removeFromSuperview];
		[m_PageSlidePopup release];
		m_PageSlidePopup = nil;		
	}
*/	
}
										  
- (IBAction) clickBrightnessBtn:(id)sender
{
	TRACE(@"");
			
	if (m_BrightnessPopup == nil)
	{
		[self _hideSubPopup:SUB_POPUP_BRIGHTNESS];

		[m_BrightnessBtn setBackgroundImage:RESOURCE_IMAGE(@"brightness_change_checked.png") forState:UIControlStateNormal];  
		[m_BrightnessBtn setBackgroundImage:RESOURCE_IMAGE(@"brightness_change_checked.png") forState:UIControlStateHighlighted];			
		
		m_BrightnessPopup = [PBBrightnessPopup createWithDelegate:self];
		[m_BrightnessPopup setBrightness:m_Brightness];
		
		[self.superview addSubview:m_BrightnessPopup];
	}
	else 
	{
		[m_BrightnessBtn setBackgroundImage:RESOURCE_IMAGE(@"brightness_change.png") forState:UIControlStateNormal];  
		[m_BrightnessBtn setBackgroundImage:RESOURCE_IMAGE(@"brightness_change.png") forState:UIControlStateHighlighted];

		[m_BrightnessPopup removeFromSuperview];
		[m_BrightnessPopup release];
		
		m_BrightnessPopup = nil;
	}
}

- (IBAction) clickScreenFixedBtn:(id)sender
{
	TRACE(@"");
	UIDeviceOrientation orientation	= m_Orientation;
	
	//[self _hideSubPopup:SUB_POPUP_NONE];

	if (m_bCheckLock == YES) {
		m_bCheckLock = NO;
		
		if (m_Type == PB_PANEL_BAR_TYPE_CARTOON) {			
			if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_land_off.png") forState:UIControlStateNormal];  
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_land_off.png") forState:UIControlStateHighlighted];
			}
			else {
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_off.png") forState:UIControlStateNormal];  
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_off.png") forState:UIControlStateHighlighted];				
			}
		}
		else {
			if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_land_off.png") forState:UIControlStateNormal];  
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_land_off.png") forState:UIControlStateHighlighted];			
			}
			else {
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_off.png") forState:UIControlStateNormal];  
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_off.png") forState:UIControlStateHighlighted];			
			}
		}
	}
	else {
		m_bCheckLock = YES;

		if (m_Type == PB_PANEL_BAR_TYPE_CARTOON) {			
			if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_land_on.png") forState:UIControlStateNormal];  
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_land_on.png") forState:UIControlStateHighlighted];
			}
			else {
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_on.png") forState:UIControlStateNormal];  
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_comic_rotate_on.png") forState:UIControlStateHighlighted];
			}
		}
		else {
			if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {			
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_land_on.png") forState:UIControlStateNormal];  
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_land_on.png") forState:UIControlStateHighlighted];
			}
			else {
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_on.png") forState:UIControlStateNormal];  
				[m_ScreenFixedBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_rotate_on.png") forState:UIControlStateHighlighted];
			}

		}

	}

	
	[m_Delegate pbpChangeScreenLock:sender lock:m_bCheckLock];
}

- (IBAction) clickTableOfContentsViewBtn:(id)sender
{
	TRACE(@"");
}

- (IBAction) clickBgColorControlBtn:(id)sender
{
	TRACE(@"");
	
	UIDeviceOrientation orientation	= m_Orientation;
		
	if (m_BackgroundTonePopup == nil)
	{
		[self _hideSubPopup:SUB_POPUP_BG_TONE];

		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_land_on.png") forState:UIControlStateNormal];  
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_land_on.png") forState:UIControlStateHighlighted];  
		}
		else {
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_on.png") forState:UIControlStateNormal];  
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_on.png") forState:UIControlStateHighlighted];  
		}
		
		m_BackgroundTonePopup = [BackgroundTonePopup createWithDelegate:self orientation:orientation toneIndex:m_ToneIndex];
		
		[self.superview addSubview:m_BackgroundTonePopup];
	}
	else 
	{
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_land_off.png") forState:UIControlStateNormal];  
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_land_off.png") forState:UIControlStateHighlighted];  			
		}
		else {
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_off.png") forState:UIControlStateNormal];  
			[m_BgColorControlBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_off.png") forState:UIControlStateHighlighted];  
		}
		
		[m_BackgroundTonePopup removeFromSuperview];
		[m_BackgroundTonePopup release];
		m_BackgroundTonePopup = nil;
	}

}

- (IBAction) clickFontSizeBtn:(id)sender
{
	TRACE(@"");
	
	UIDeviceOrientation orientation	= m_Orientation;
	
	if (m_FontSizePopup == nil) {
		[self _hideSubPopup:SUB_POPUP_ZOOM];
		
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_land_on.png") forState:UIControlStateNormal];  
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_land_on.png") forState:UIControlStateHighlighted];  
		}
		else {
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_on.png") forState:UIControlStateNormal];  
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_on.png") forState:UIControlStateHighlighted];  			
		}

		m_FontSizePopup = [FontSizePopup createWithDelegate:self orientation:orientation];
		[m_FontSizePopup setFontScale:m_FontScale];
		[self.superview addSubview:m_FontSizePopup];
	}
	else {
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_land_off.png") forState:UIControlStateNormal];  
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_land_off.png") forState:UIControlStateHighlighted];  
		}
		else {
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_off.png") forState:UIControlStateNormal];  
			[m_FontSizeBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_font_off.png") forState:UIControlStateHighlighted];  			
		}

		[m_FontSizePopup removeFromSuperview];
		[m_FontSizePopup release];
		m_FontSizePopup = nil;		
	}
	
}

#pragma mark -
#pragma mark PageSidePopupDelegate
- (void) pageSildeValueChanged:(CGFloat)changedValue
{
	[m_Delegate pbpChangePage:changedValue];
}

- (void)sliderActionTouchUp:(id)sender
{ 
	TRACE(@"slide value = %d", (NSInteger)m_PageSlide.value);
	
	[self setcurrentPage:(NSInteger)m_PageSlide.value];
	[m_Delegate pbpChangePage:[self getCurrentPage]];
}

- (void)sliderActionValueChanged:(id)sender
{ 
	TRACE(@"slide value = %d", (NSInteger)m_PageSlide.value);
	
	if (m_PageSlide.value > m_ValidPage){
		m_PageSlide.value = m_ValidPage;
	}
	
	[m_MinPageNumber setText:[NSString stringWithFormat:@"%d", (NSInteger)m_PageSlide.value]];
	[m_MaxPageNumber setText:[NSString stringWithFormat:@"/%d", (NSInteger)m_PageSlide.maximumValue]];
}

#pragma mark -
#pragma mark ZoomPopupDelegate
- (void) zoomIncrease
{
	if (m_Delegate != nil)
	{
		[m_Delegate pbpChangeFontSize:YES];
	}
}

- (void) zoomDecrease
{
	if (m_Delegate != nil)
	{
		[m_Delegate pbpChangeFontSize:NO];
	}
}

- (void) fontSizeSildeValueChanged:(CGFloat)changedValue
{
	if (m_FontScale == changedValue) { return; }
	m_FontScale = changedValue;
	
	if (m_Delegate != nil)
	{
		[m_Delegate pbpChangeFontScale:changedValue];
	}
}

#pragma mark -
#pragma mark BackgroundTonePopupDelegate
- (void) bgtSelectedTone:(NSInteger)toneIndex
{
	if (m_ToneIndex == toneIndex)
	{
		return;
	}
	
	m_ToneIndex = toneIndex;
	
	if (m_Delegate != nil)
	{
		[m_Delegate pbpSelectedToneIndex:m_ToneIndex];
	}
}

@end
