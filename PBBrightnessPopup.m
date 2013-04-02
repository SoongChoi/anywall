//
//  PBBrightnessPopup.m
//  PlayBook
//
//  Created by 전명곤 on 11. 11. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PBBrightnessPopup.h"


@implementation PBBrightnessPopup

@synthesize m_BgImageView;
@synthesize m_BrightnessSlider;


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
	[m_BrightnessSlider release];
	[m_BgImageView release];
	
    [super dealloc];
}

+ (id) createWithDelegate:(id)delegate
{
	PBBrightnessPopup *	brightnessPopup = [[PBBrightnessPopup alloc] initWithDelegate:delegate];
	if (brightnessPopup == nil)
	{
		return nil;
	}
	
	UIDeviceOrientation orientation	= [[UIDevice currentDevice] orientation];

	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		[brightnessPopup setFrame:CGRectMake(DF_FORM_BNP_HORZ_SX, DF_FORM_BNP_HORZ_SY, DF_FORM_BNP_HORZ_WIDTH, DF_FORM_BNP_HORZ_HEIGHT)];
	}
	else 
	{
		[brightnessPopup setFrame:CGRectMake(DF_FORM_BNP_VERT_SX, DF_FORM_BNP_VERT_SY, DF_FORM_BNP_VERT_WIDTH, DF_FORM_BNP_VERT_HEIGHT)];
	}
	
	return brightnessPopup;
}

- (id) initWithDelegate:(id)delegate
{
	if ((self = [super init]) != nil)
	{
		m_Delegate = delegate;
		
		UIDeviceOrientation orientation	= [[UIDevice currentDevice] orientation];
		
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
		{
			// background image
			m_BgImageView	= [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"popup_brightness_background.png")];
			[m_BgImageView setFrame:CGRectMake(0, 0, DF_FORM_BNP_HORZ_WIDTH, DF_FORM_BNP_HORZ_HEIGHT)];
			[self addSubview:m_BgImageView];
			
			// slider
			m_BrightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(DF_FORM_BNP_HORZ_SLIDER_SX, 
																	 DF_FORM_BNP_HORZ_SLIDER_SY, 
																	 DF_FORM_BNP_HORZ_SLIDER_WIDTH, 
																	 DF_FORM_BNP_HORZ_SLIDER_HEIGHT)];
			[m_BrightnessSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
			m_BrightnessSlider.backgroundColor = [UIColor clearColor];
			
			UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"orangeslide.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
			UIImage *stetchRightTrack	= [[UIImage imageNamed:@"yellowslide.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
			[m_BrightnessSlider setThumbImage: [UIImage imageNamed:@"slider_ball.png"] forState:UIControlStateNormal];
			[m_BrightnessSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
			[m_BrightnessSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
			m_BrightnessSlider.minimumValue = -0.5f;
			m_BrightnessSlider.maximumValue = 0.5f;
			m_BrightnessSlider.continuous = YES;
			[self addSubview:m_BrightnessSlider];
		}
		else 
		{
			// background image
			m_BgImageView	= [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"popup_brightness_background.png")];
			[m_BgImageView setFrame:CGRectMake(0, 0, DF_FORM_BNP_VERT_WIDTH, DF_FORM_BNP_VERT_HEIGHT)];
			[self addSubview:m_BgImageView];
			
			// slider
			m_BrightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(DF_FORM_BNP_VERT_SLIDER_SX, 
																			DF_FORM_BNP_VERT_SLIDER_SY, 
																			DF_FORM_BNP_VERT_SLIDER_WIDTH, 
																			DF_FORM_BNP_VERT_SLIDER_HEIGHT)];
			[m_BrightnessSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
			m_BrightnessSlider.backgroundColor = [UIColor clearColor];
			
			UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"orangeslide.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
			UIImage *stetchRightTrack	= [[UIImage imageNamed:@"yellowslide.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
			[m_BrightnessSlider setThumbImage: [UIImage imageNamed:@"slider_ball.png"] forState:UIControlStateNormal];
			[m_BrightnessSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
			[m_BrightnessSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
			m_BrightnessSlider.minimumValue = -0.5f;
			m_BrightnessSlider.maximumValue = 0.5f;
			m_BrightnessSlider.continuous = YES;
			[self addSubview:m_BrightnessSlider];
		}
		
		m_BrightnessSlider.value = 0.0f;
		
		CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 0.5);
		m_BrightnessSlider.transform = trans;

	}
	
	return self;
}

- (void) resize:(UIInterfaceOrientation)toInterfaceOrientation
{
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		[self setFrame:CGRectMake(DF_FORM_BNP_HORZ_SX, DF_FORM_BNP_HORZ_SY, DF_FORM_BNP_HORZ_WIDTH, DF_FORM_BNP_HORZ_HEIGHT)];
	}
	else 
	{
		[self setFrame:CGRectMake(DF_FORM_BNP_VERT_SX, DF_FORM_BNP_VERT_SY, DF_FORM_BNP_VERT_WIDTH, DF_FORM_BNP_VERT_HEIGHT)];
	}
}

- (CGFloat) getBrightness
{
	return (m_BrightnessSlider.value * -1.0f);
}

- (CGFloat) setBrightness:(CGFloat)brightness
{
	CGFloat	preValue = (m_BrightnessSlider.value * -1.0f);
	
	[m_BrightnessSlider setValue:(brightness * -1.0f)];
	
	return preValue;
}

#pragma mark -
#pragma mark UISlider action
- (void)sliderAction:(id)sender
{ 
	CGFloat brightness = m_BrightnessSlider.value * -1.0f;
	
	TRACE(@"brightness value = %f", brightness);
	
	[m_Delegate pbbChangeBrightness:brightness];
}

@end
