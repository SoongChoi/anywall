//
//  BackgroundTonePopup.m
//  PlayBook
//
//  Created by 전명곤 on 11. 12. 4..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BackgroundTonePopup.h"


@implementation BackgroundTonePopup

@synthesize m_BgImageView;
@synthesize m_DarkBtn;
@synthesize m_PaperBtn;
@synthesize m_GrayBtn;
@synthesize m_WhiteBtn;


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
	[m_BgImageView removeFromSuperview];
	[m_BgImageView release];
	
    [super dealloc];
}

+ (id) createWithDelegate:(id)delegate orientation:(UIDeviceOrientation)orientation toneIndex:(NSInteger)toneIndex
{
	BackgroundTonePopup *	bgTonePopup = [[BackgroundTonePopup alloc] initWithDelegate:delegate orientation:orientation toneIndex:toneIndex];
	if (bgTonePopup == nil)
	{
		return nil;
	}
	
	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		[bgTonePopup setFrame:CGRectMake(0.0f, 320.0f - (36.0f * 2), 480.0f, 36.0f)];
	}
	else 
	{
		//[bgTonePopup setFrame:CGRectMake(DF_FORM_TONE_POPUP_VERT_SX, DF_FORM_TONE_POPUP_VERT_SY, DF_FORM_TONE_POPUP_VERT_WIDTH, DF_FORM_TONE_POPUP_VERT_HEIGHT)];
		[bgTonePopup setFrame:CGRectMake(0.0f, 480.0f - (45.0f * 2), 320.0f, 45.0f)];
	}

	return bgTonePopup;
}

- (id) initWithDelegate:(id)delegate orientation:(UIDeviceOrientation)orientation toneIndex:(NSInteger)toneIndex
{
	if ((self = [super init]) != nil)
	{
		m_Orientation = orientation;
		m_Delegate	  = delegate;
		m_ToneIndex	  = toneIndex;
		
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
		{
			// background image
			m_BgImageView = [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_novel2depth_land.png")];
			[m_BgImageView setFrame:CGRectMake(0.0f, 
											   0.0f, 
											   480.0f, //DF_FORM_TONE_POPUP_VERT_WIDTH, 
											   36.0f)];//DF_FORM_TONE_POPUP_VERT_HEIGHT)];
			[self addSubview:m_BgImageView];
			
			// dark
			m_DarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[m_DarkBtn setFrame:CGRectMake(14.0f,	//DF_FORM_TONE_POPUP_VERT_DARK_SX, 
										   5.0f,	//DF_FORM_TONE_POPUP_VERT_DARK_SY, 
										   92.0f,	//DF_FORM_TONE_POPUP_VERT_DARK_WIDTH, 
										   25.0f)]; //DF_FORM_TONE_POPUP_VERT_DARK_HEIGHT)];
			if (m_ToneIndex == BG_TONE_INDEX_DARK)
			{
				[m_DarkBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_d_land_on.png") forState:UIControlStateNormal];
			}
			else
			{
				[m_DarkBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_d_land_off.png") forState:UIControlStateNormal];
			}
			[m_DarkBtn addTarget:self action:@selector(clickDarkBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:m_DarkBtn];
			
			// paper
			m_PaperBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[m_PaperBtn setFrame:CGRectMake((14.0f + 93.0f) + 28.0f,		//DF_FORM_TONE_POPUP_VERT_PAPER_SX, 
											5.0f,		//DF_FORM_TONE_POPUP_VERT_PAPER_SY, 
											92.0f,		//DF_FORM_TONE_POPUP_VERT_PAPER_WIDTH, 
											25.0f)];	//DF_FORM_TONE_POPUP_VERT_PAPER_HEIGHT)];
			if (m_ToneIndex == BG_TONE_INDEX_PAPER)
			{
				[m_PaperBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_p_land_on.png") forState:UIControlStateNormal];
			}
			else 
			{
				[m_PaperBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_p_land_off.png") forState:UIControlStateNormal];
			}
			[m_PaperBtn addTarget:self action:@selector(clickPaperBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:m_PaperBtn];
			
			// gray
			m_GrayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[m_GrayBtn setFrame:CGRectMake(14.0f + (92.0f * 2) + 28.0f + 28.0f, //DF_FORM_TONE_POPUP_VERT_GRAY_SX, 
										   5.0f, //DF_FORM_TONE_POPUP_VERT_GRAY_SY, 
										   92.0f, //DF_FORM_TONE_POPUP_VERT_GRAY_WIDTH, 
										   25.0f)]; //DF_FORM_TONE_POPUP_VERT_GRAY_HEIGHT)];
			if (m_ToneIndex == BG_TONE_INDEX_GRAY)
			{
				[m_GrayBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_g_land_on.png") forState:UIControlStateNormal];
			}
			else 
			{
				[m_GrayBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_g_land_off.png") forState:UIControlStateNormal];
			}
			[m_GrayBtn addTarget:self action:@selector(clickGrayBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:m_GrayBtn];
			
			// white
			m_WhiteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[m_WhiteBtn setFrame:CGRectMake(480.0f - (92.0f + 14.0f), //DF_FORM_TONE_POPUP_VERT_WHITE_SX, 
											5.0f,		//DF_FORM_TONE_POPUP_VERT_WHITE_SY, 
											92.0f,   //DF_FORM_TONE_POPUP_VERT_WHITE_WIDTH, 
											25.0f)]; //DF_FORM_TONE_POPUP_VERT_WHITE_HEIGHT)];
			if (m_ToneIndex == BG_TONE_INDEX_WHITE)
			{
				[m_WhiteBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_w_land_on.png") forState:UIControlStateNormal];
			}
			else 
			{
				[m_WhiteBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_w_land_off.png") forState:UIControlStateNormal];
			}
			[m_WhiteBtn addTarget:self action:@selector(clickWhiteBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:m_WhiteBtn];
			
		}
		else 
		{
			// background image
			m_BgImageView = [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_novel2depth.png")];
			[m_BgImageView setFrame:CGRectMake(0.0f, 
											   0.0f, 
											   320.0f, //DF_FORM_TONE_POPUP_VERT_WIDTH, 
											   45.0f)];//DF_FORM_TONE_POPUP_VERT_HEIGHT)];
			[self addSubview:m_BgImageView];
			
			// dark
			m_DarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[m_DarkBtn setFrame:CGRectMake(14.0f,	//DF_FORM_TONE_POPUP_VERT_DARK_SX, 
										   8.0f,	//DF_FORM_TONE_POPUP_VERT_DARK_SY, 
										   62.0f,	//DF_FORM_TONE_POPUP_VERT_DARK_WIDTH, 
										   31.0f)]; //DF_FORM_TONE_POPUP_VERT_DARK_HEIGHT)];
			if (m_ToneIndex == BG_TONE_INDEX_DARK)
			{
				[m_DarkBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_d_on.png") forState:UIControlStateNormal];
			}
			else
			{
				[m_DarkBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_d_off.png") forState:UIControlStateNormal];
			}
			[m_DarkBtn addTarget:self action:@selector(clickDarkBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:m_DarkBtn];
			
			// paper
			m_PaperBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[m_PaperBtn setFrame:CGRectMake((14.0f + 62.0f) + 14.0f,		//DF_FORM_TONE_POPUP_VERT_PAPER_SX, 
											8.0f,		//DF_FORM_TONE_POPUP_VERT_PAPER_SY, 
											62.0f,		//DF_FORM_TONE_POPUP_VERT_PAPER_WIDTH, 
											31.0f)];	//DF_FORM_TONE_POPUP_VERT_PAPER_HEIGHT)];
			if (m_ToneIndex == BG_TONE_INDEX_PAPER)
			{
				[m_PaperBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_p_on.png") forState:UIControlStateNormal];
			}
			else 
			{
				[m_PaperBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_p_off.png") forState:UIControlStateNormal];
			}
			[m_PaperBtn addTarget:self action:@selector(clickPaperBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:m_PaperBtn];
			
			// gray
			m_GrayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[m_GrayBtn setFrame:CGRectMake(14.0f + (62.0f * 2) + 14.0f + 14.0f, //DF_FORM_TONE_POPUP_VERT_GRAY_SX, 
										   8.0f, //DF_FORM_TONE_POPUP_VERT_GRAY_SY, 
										   62.0f, //DF_FORM_TONE_POPUP_VERT_GRAY_WIDTH, 
										   31.0f)]; //DF_FORM_TONE_POPUP_VERT_GRAY_HEIGHT)];
			if (m_ToneIndex == BG_TONE_INDEX_GRAY)
			{
				[m_GrayBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_g_on.png") forState:UIControlStateNormal];
			}
			else 
			{
				[m_GrayBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_g_off.png") forState:UIControlStateNormal];
			}
			[m_GrayBtn addTarget:self action:@selector(clickGrayBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:m_GrayBtn];
			
			// white
			m_WhiteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[m_WhiteBtn setFrame:CGRectMake(14.0f + (62.0f * 3) + 14.0f + 14.0f + 14.0f, //DF_FORM_TONE_POPUP_VERT_WHITE_SX, 
											8.0f,		//DF_FORM_TONE_POPUP_VERT_WHITE_SY, 
											62.0f,   //DF_FORM_TONE_POPUP_VERT_WHITE_WIDTH, 
											31.0f)]; //DF_FORM_TONE_POPUP_VERT_WHITE_HEIGHT)];
			if (m_ToneIndex == BG_TONE_INDEX_WHITE)
			{
				[m_WhiteBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_w_on.png") forState:UIControlStateNormal];
			}
			else 
			{
				[m_WhiteBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_w_off.png") forState:UIControlStateNormal];
			}
			[m_WhiteBtn addTarget:self action:@selector(clickWhiteBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:m_WhiteBtn];
			
		}

	}
	
	return self;
}

- (void) resize:(UIInterfaceOrientation)toInterfaceOrientation
{
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		[self setFrame:CGRectMake(DF_FORM_ZOOM_POPUP_HORZ_SX, DF_FORM_ZOOM_POPUP_HORZ_SY, DF_FORM_ZOOM_POPUP_HORZ_WIDTH, DF_FORM_ZOOM_POPUP_HORZ_HEIGHT)];
	}
	else 
	{
		[self setFrame:CGRectMake(DF_FORM_ZOOM_POPUP_VERT_SX, DF_FORM_ZOOM_POPUP_VERT_SY, DF_FORM_ZOOM_POPUP_VERT_WIDTH, DF_FORM_ZOOM_POPUP_VERT_HEIGHT)];
	}
}

- (NSInteger) getToneIndex
{
	return m_ToneIndex;
}

- (BOOL) setToneIndex:(NSInteger)toneIndex
{
	if (m_ToneIndex == toneIndex)
	{
		return NO;
	}
	
	if (m_Orientation == UIDeviceOrientationLandscapeLeft || m_Orientation == UIDeviceOrientationLandscapeRight) {	
		switch (m_ToneIndex)
		{
			case BG_TONE_INDEX_DARK:
				[m_DarkBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_d_land_off.png") forState:UIControlStateNormal];
				break;
			case BG_TONE_INDEX_PAPER:
				[m_PaperBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_p_land_off.png") forState:UIControlStateNormal];
				break;
			case BG_TONE_INDEX_GRAY:
				[m_GrayBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_g_land_off.png") forState:UIControlStateNormal];
				break;
			case BG_TONE_INDEX_WHITE:
				[m_WhiteBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_w_land_off.png") forState:UIControlStateNormal];
				break;
		}
	}
	else {
		switch (m_ToneIndex)
		{
			case BG_TONE_INDEX_DARK:
				[m_DarkBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_d_off.png") forState:UIControlStateNormal];
				break;
			case BG_TONE_INDEX_PAPER:
				[m_PaperBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_p_off.png") forState:UIControlStateNormal];
				break;
			case BG_TONE_INDEX_GRAY:
				[m_GrayBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_g_off.png") forState:UIControlStateNormal];
				break;
			case BG_TONE_INDEX_WHITE:
				[m_WhiteBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_w_off.png") forState:UIControlStateNormal];
				break;
		}
	}
	m_ToneIndex = toneIndex;
	
	if (m_Orientation == UIDeviceOrientationLandscapeLeft || m_Orientation == UIDeviceOrientationLandscapeRight) {	
		switch (m_ToneIndex)
		{
			case BG_TONE_INDEX_DARK:
				[m_DarkBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_d_land_on.png") forState:UIControlStateNormal];
				break;
			case BG_TONE_INDEX_PAPER:
				[m_PaperBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_p_land_on.png") forState:UIControlStateNormal];
				break;
			case BG_TONE_INDEX_GRAY:
				[m_GrayBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_g_land_on.png") forState:UIControlStateNormal];
				break;
			case BG_TONE_INDEX_WHITE:
				[m_WhiteBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_w_land_on.png") forState:UIControlStateNormal];
				break;
		}
	}
	else {
		switch (m_ToneIndex)
		{
			case BG_TONE_INDEX_DARK:
				[m_DarkBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_d_on.png") forState:UIControlStateNormal];
				break;
			case BG_TONE_INDEX_PAPER:
				[m_PaperBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_p_on.png") forState:UIControlStateNormal];
				break;
			case BG_TONE_INDEX_GRAY:
				[m_GrayBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_g_on.png") forState:UIControlStateNormal];
				break;
			case BG_TONE_INDEX_WHITE:
				[m_WhiteBtn setBackgroundImage:RESOURCE_IMAGE(@"vi_footer_btn_novel_back_w_on.png") forState:UIControlStateNormal];
				break;
		}		
	}
		
	return YES;
}

- (IBAction) clickDarkBtn:(id)sender
{
	if ([self setToneIndex:BG_TONE_INDEX_DARK] == YES)
	{
		TRACE(@"Tone Index = %d", m_ToneIndex);
		
		[m_Delegate bgtSelectedTone:m_ToneIndex];
	}
}

- (IBAction) clickPaperBtn:(id)sender
{
	if ([self setToneIndex:BG_TONE_INDEX_PAPER] == YES)
	{
		TRACE(@"Tone Index = %d", m_ToneIndex);

		[m_Delegate bgtSelectedTone:m_ToneIndex];
	}
}

- (IBAction) clickGrayBtn:(id)sender
{
	if ([self setToneIndex:BG_TONE_INDEX_GRAY] == YES)
	{
		TRACE(@"Tone Index = %d", m_ToneIndex);

		[m_Delegate bgtSelectedTone:m_ToneIndex];
	}
}

- (IBAction) clickWhiteBtn:(id)sender
{
	if ([self setToneIndex:BG_TONE_INDEX_WHITE] == YES)
	{
		TRACE(@"Tone Index = %d", m_ToneIndex);

		[m_Delegate bgtSelectedTone:m_ToneIndex];
	}
}

@end
