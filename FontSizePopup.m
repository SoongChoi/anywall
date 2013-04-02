//
//  FontSizePopup.m
//  PlayBook
//
//  Created by Daniel on 12. 5. 19..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FontSizePopup.h"


@implementation FontSizePopup



@synthesize m_BgImageView;
@synthesize m_LabFontSize;

@synthesize m_SlideFontSize;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void) dealloc
{
	//[m_IncreaseBtn removeFromSuperview];
	//[m_IncreaseBtn release];
	
	//[m_DecreaseBtn removeFromSuperview];
	//[m_DecreaseBtn release];
	
	[m_LabFontSize release];
	[m_SlideFontSize release];
	
	[m_BgImageView removeFromSuperview];
	[m_BgImageView release];
	
    [super dealloc];
}

+ (id) createWithDelegate:(id)delegate orientation:(UIDeviceOrientation)orientation
{
	FontSizePopup* fontSizePopup = [[FontSizePopup alloc] initWithDelegate:delegate orientation:orientation];
	if (fontSizePopup == nil)
	{
		return nil;
	}
	
	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		[fontSizePopup setFrame:CGRectMake(0.0f, 320.0f - (36.0f * 2) , 480.0f, 36.0f)];
	}
	else 
	{
		[fontSizePopup setFrame:CGRectMake(0.0f, 480.0f - (45.0f * 2) , 320.0f, 45.0f)];
	}
	
	return fontSizePopup;
}


- (id) initWithDelegate:(id)delegate orientation:(UIDeviceOrientation)orientation
{
	
	if ((self = [super init]) != nil)
	{
		m_Delegate = delegate;
		
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
		{
			// background image
			m_BgImageView = [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_novel2depth_land.png")];
			//[m_BgImageView setFrame:CGRectMake(0.0f, 0.0f, DF_FORM_ZOOM_POPUP_VERT_WIDTH, DF_FORM_ZOOM_POPUP_VERT_HEIGHT)];
			[m_BgImageView setFrame:CGRectMake(0.0f, 0.0f, 480, 36.0f)];
			[self addSubview:m_BgImageView];			
			
			UILabel* labFontSize = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 3.0f, 60.0f, 30.0f)];
			[labFontSize setBackgroundColor:[UIColor clearColor]];
			[labFontSize setTextColor:[UIColor whiteColor]];
			[labFontSize setFont:[labFontSize.font fontWithSize:13.0f]];
			[labFontSize setTextAlignment:UITextAlignmentLeft];		
			[labFontSize setText:@"글자크기"];
			[self addSubview:labFontSize];
			[labFontSize release];
			
			
			UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"vi_footer_config_line_font_land_on.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			UIImage *stetchRightTrack	= [[UIImage imageNamed:@"vi_footer_config_line_font_land_off.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			
			// page slider
			m_SlideFontSize = [[UISlider alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 13.0f, 5.0f, 345.0f, 26.0f)];
			[m_SlideFontSize setBackgroundColor:[UIColor clearColor]];
			[m_SlideFontSize setThumbImage: [UIImage imageNamed:@"vi_footer_pointer.png"] forState:UIControlStateNormal];
			[m_SlideFontSize setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
			[m_SlideFontSize setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
			m_SlideFontSize.minimumValue = 0.3f;
			m_SlideFontSize.maximumValue = 3.0f;
			m_SlideFontSize.continuous = YES;
			m_SlideFontSize.value = 0.0f;
			
			[m_SlideFontSize addTarget:self action:@selector(sliderActionTouchUp:) forControlEvents:UIControlEventTouchUpInside];			
			[m_SlideFontSize addTarget:self action:@selector(sliderActionValueChanged:) forControlEvents:UIControlEventValueChanged];						
			[self addSubview:m_SlideFontSize];
			
			m_LabFontSize = [[UILabel alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 15.0f + 10.0f +345.0f, 3.0f, 60.0f, 30.0f)];
			[m_LabFontSize setBackgroundColor:[UIColor clearColor]];
			[m_LabFontSize setTextColor:[UIColor redColor]];
			[m_LabFontSize setFont:[m_LabFontSize.font fontWithSize:13.0f]];
			[m_LabFontSize setTextAlignment:UITextAlignmentLeft];		
			[m_LabFontSize setText:@"12pixel"];
			
			[self addSubview:m_LabFontSize];		}
		else 
		{
			// background image
			m_BgImageView = [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_novel2depth.png")];
			//[m_BgImageView setFrame:CGRectMake(0.0f, 0.0f, DF_FORM_ZOOM_POPUP_VERT_WIDTH, DF_FORM_ZOOM_POPUP_VERT_HEIGHT)];
			[m_BgImageView setFrame:CGRectMake(0.0f, 0.0f, 320, 45.0f)];
			[self addSubview:m_BgImageView];			
			
			UILabel* labFontSize = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 8.0f, 60.0f, 30.0f)];
			[labFontSize setBackgroundColor:[UIColor clearColor]];
			[labFontSize setTextColor:[UIColor whiteColor]];
			[labFontSize setFont:[labFontSize.font fontWithSize:13.0f]];
			[labFontSize setTextAlignment:UITextAlignmentLeft];		
			[labFontSize setText:@"글자크기"];
			[self addSubview:labFontSize];
			[labFontSize release];
			
			
			UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"vi_footer_config_line_font_on.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			UIImage *stetchRightTrack	= [[UIImage imageNamed:@"vi_footer_config_line_font_off.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			
			// page slider
			m_SlideFontSize = [[UISlider alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 13.0f, 8.0f, 173.0f, 30.0f)];
			[m_SlideFontSize setBackgroundColor:[UIColor clearColor]];
			[m_SlideFontSize setThumbImage: [UIImage imageNamed:@"vi_footer_pointer.png"] forState:UIControlStateNormal];
			[m_SlideFontSize setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
			[m_SlideFontSize setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
			m_SlideFontSize.minimumValue = 0.3f;
			m_SlideFontSize.maximumValue = 3.0f;
			m_SlideFontSize.continuous = YES;
			m_SlideFontSize.value = 0.0f;
			
			[m_SlideFontSize addTarget:self action:@selector(sliderActionTouchUp:) forControlEvents:UIControlEventTouchUpInside];			
			[m_SlideFontSize addTarget:self action:@selector(sliderActionValueChanged:) forControlEvents:UIControlEventValueChanged];						
			[self addSubview:m_SlideFontSize];
			
			m_LabFontSize = [[UILabel alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 15.0f + 10.0f + 173.0f, 8.0f, 60.0f, 30.0f)];
			[m_LabFontSize setBackgroundColor:[UIColor clearColor]];
			[m_LabFontSize setTextColor:[UIColor redColor]];
			[m_LabFontSize setFont:[m_LabFontSize.font fontWithSize:13.0f]];
			[m_LabFontSize setTextAlignment:UITextAlignmentLeft];		
			[m_LabFontSize setText:@"12pixel"];
			
			[self addSubview:m_LabFontSize];
			
		}
	}
	
	return self;
}

- (void) resize:(UIInterfaceOrientation)toInterfaceOrientation
{
}

- (void) setFontScale:(CGFloat)fontScale
{
	m_SlideFontSize.value = fontScale;	
	
	if (fontScale >= 0.3f && fontScale < 0.7f) {
		[m_LabFontSize setText:@"12pixel"];
	}
	else if (fontScale >= 0.7f && fontScale < 1.1f) {
		[m_LabFontSize setText:@"13pixel"];
	}
	else if (fontScale >= 1.1f && fontScale < 1.5f) {
		[m_LabFontSize setText:@"14pixel"];
	}
	else if (fontScale >= 1.5f && fontScale < 2.0f) {
		[m_LabFontSize setText:@"15pixel"];
	}
	else if (fontScale >= 2.0f && fontScale < 2.4f) {
		[m_LabFontSize setText:@"16pixel"];
	}
	else if (fontScale >= 2.4f && fontScale <= 3.0f) {
		[m_LabFontSize setText:@"17pixel"];
	}
}

#pragma mark -
#pragma mark UISlider action
- (void)sliderActionTouchUp:(id)sender
{ 
	TRACE(@"slide value = %f", m_SlideFontSize.value);
	
	[m_Delegate fontSizeSildeValueChanged:m_SlideFontSize.value];
}

- (void)sliderActionValueChanged:(id)sender
{ 
	TRACE(@"slide value = %f", m_SlideFontSize.value);
	
	CGFloat fontScale = m_SlideFontSize.value;
	
	if (fontScale >= 0.3f && fontScale < 0.7f) {
		[m_LabFontSize setText:@"12pixel"];
	}
	else if (fontScale >= 0.7f && fontScale < 1.1f) {
		[m_LabFontSize setText:@"13pixel"];
	}
	else if (fontScale >= 1.1f && fontScale < 1.5f) {
		[m_LabFontSize setText:@"14pixel"];
	}
	else if (fontScale >= 1.5f && fontScale < 2.0f) {
		[m_LabFontSize setText:@"15pixel"];
	}
	else if (fontScale >= 2.0f && fontScale < 2.4f) {
		[m_LabFontSize setText:@"16pixel"];
	}
	else if (fontScale >= 2.4f && fontScale <= 3.0f) {
		[m_LabFontSize setText:@"17pixel"];
	}
}

@end
