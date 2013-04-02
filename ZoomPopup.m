//
//  ZoomPopup.m
//  PlayBook
//
//  Created by 전명곤 on 11. 12. 3..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ZoomPopup.h"


@implementation ZoomPopup

@synthesize m_BgImageView;
@synthesize m_IncreaseBtn;
@synthesize m_DecreaseBtn;


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

- (void) dealloc
{
	//[m_IncreaseBtn removeFromSuperview];
	//[m_IncreaseBtn release];
	
	//[m_DecreaseBtn removeFromSuperview];
	//[m_DecreaseBtn release];
	
	[m_BgImageView removeFromSuperview];
	[m_BgImageView release];
	
    [super dealloc];
}

+ (id) createWithDelegate:(id)delegate
{
	ZoomPopup *		zoomPopup = [[ZoomPopup alloc] initWithDelegate:delegate];
	if (zoomPopup == nil)
	{
		return nil;
	}
	
	UIDeviceOrientation orientation	= [[UIDevice currentDevice] orientation];
	
	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		[zoomPopup setFrame:CGRectMake(DF_FORM_ZOOM_POPUP_HORZ_SX, DF_FORM_ZOOM_POPUP_HORZ_SY, DF_FORM_ZOOM_POPUP_HORZ_WIDTH, DF_FORM_ZOOM_POPUP_HORZ_HEIGHT)];
	}
	else 
	{
		//[zoomPopup setFrame:CGRectMake(DF_FORM_ZOOM_POPUP_VERT_SX, DF_FORM_ZOOM_POPUP_VERT_SY, DF_FORM_ZOOM_POPUP_VERT_WIDTH, DF_FORM_ZOOM_POPUP_VERT_HEIGHT)];
		[zoomPopup setFrame:CGRectMake(0.0f, 400.0f, 320.0f, 67.0f)];
	}

	return zoomPopup;
}

- (id) initWithDelegate:(id)delegate
{
	if ((self = [super init]) != nil)
	{
		m_Delegate	= delegate;
		
		UIDeviceOrientation orientation	= [[UIDevice currentDevice] orientation];
		
		if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
		{
			// background image
			m_BgImageView = [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"popup_zoom_backgournd.png")];
			[m_BgImageView setFrame:CGRectMake(0.0f, 0.0f, DF_FORM_ZOOM_POPUP_HORZ_WIDTH, DF_FORM_ZOOM_POPUP_HORZ_HEIGHT)];
			[self addSubview:m_BgImageView];
			
			// increase button
			m_IncreaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[m_IncreaseBtn setFrame:CGRectMake(0,   //DF_FORM_ZOOM_POPUP_HORZ_INCREASE_SX, 
											   400, //DF_FORM_ZOOM_POPUP_HORZ_INCREASE_SY, 
											   320, //DF_FORM_ZOOM_POPUP_HORZ_INCREASE_WIDTH, 
											   67)];   // DF_FORM_ZOOM_POPUP_HORZ_INCREASE_HEIGHT)];
			[m_IncreaseBtn setBackgroundImage:RESOURCE_IMAGE(@"btn_zoom_in.png") forState:UIControlStateNormal];
			[m_IncreaseBtn setBackgroundImage:RESOURCE_IMAGE(@"btn_zoom_in_pressed.png") forState:UIControlStateHighlighted];
			[m_IncreaseBtn addTarget:self action:@selector(clickIncreaseBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:m_IncreaseBtn];
			
			// decrease button
			m_DecreaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[m_DecreaseBtn setFrame:CGRectMake(DF_FORM_ZOOM_POPUP_HORZ_DECREASE_SX, 
											   DF_FORM_ZOOM_POPUP_HORZ_DECREASE_SY, 
											   DF_FORM_ZOOM_POPUP_HORZ_DECREASE_WIDTH, 
											   DF_FORM_ZOOM_POPUP_HORZ_DECREASE_HEIGHT)];
			[m_DecreaseBtn setBackgroundImage:RESOURCE_IMAGE(@"btn_zoom_out.png") forState:UIControlStateNormal];
			[m_DecreaseBtn setBackgroundImage:RESOURCE_IMAGE(@"btn_zoom_out_pressed.png") forState:UIControlStateHighlighted];
			[m_DecreaseBtn addTarget:self action:@selector(clickDecreaseBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:m_DecreaseBtn];
		}
		else 
		{
			// background image
			m_BgImageView = [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"popup_zoom_backgournd.png")];
			//[m_BgImageView setFrame:CGRectMake(0.0f, 0.0f, DF_FORM_ZOOM_POPUP_VERT_WIDTH, DF_FORM_ZOOM_POPUP_VERT_HEIGHT)];
			[m_BgImageView setFrame:CGRectMake(0.0f, 0.0f, 320, 67)];
			[self addSubview:m_BgImageView];
			
			// increase button
			m_IncreaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[m_IncreaseBtn setFrame:CGRectMake(0,   // DF_FORM_ZOOM_POPUP_VERT_INCREASE_SX, 
											   8,   //DF_FORM_ZOOM_POPUP_VERT_INCREASE_SY, 
											   320, //DF_FORM_ZOOM_POPUP_VERT_INCREASE_WIDTH, 
											   67)]; //]DF_FORM_ZOOM_POPUP_VERT_INCREASE_HEIGHT)];
			[m_IncreaseBtn setBackgroundImage:RESOURCE_IMAGE(@"btn_zoom_in.png") forState:UIControlStateNormal];
			[m_IncreaseBtn setBackgroundImage:RESOURCE_IMAGE(@"btn_zoom_in_pressed.png") forState:UIControlStateHighlighted];
			[m_IncreaseBtn addTarget:self action:@selector(clickIncreaseBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:m_IncreaseBtn];
			
			// decrease button
			m_DecreaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[m_DecreaseBtn setFrame:CGRectMake(DF_FORM_ZOOM_POPUP_VERT_DECREASE_SX, 
											   DF_FORM_ZOOM_POPUP_VERT_DECREASE_SY, 
											   DF_FORM_ZOOM_POPUP_VERT_DECREASE_WIDTH, 
											   DF_FORM_ZOOM_POPUP_VERT_DECREASE_HEIGHT)];
			[m_DecreaseBtn setBackgroundImage:RESOURCE_IMAGE(@"btn_zoom_out.png") forState:UIControlStateNormal];
			[m_DecreaseBtn setBackgroundImage:RESOURCE_IMAGE(@"btn_zoom_out_pressed.png") forState:UIControlStateHighlighted];
			[m_DecreaseBtn addTarget:self action:@selector(clickDecreaseBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:m_DecreaseBtn];
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

- (IBAction) clickIncreaseBtn:(id)sender
{
	TRACE(@"");
	
	[m_Delegate zoomIncrease];
}

- (IBAction) clickDecreaseBtn:(id)sender
{
	TRACE(@"");
	
	[m_Delegate zoomDecrease];
}

@end
