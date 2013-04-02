//
//  ActivityIndicatorPopup.m
//  PlayBook
//
//  Created by 전명곤 on 11. 12. 21..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityIndicatorPopup.h"
#import "ActivityIndicatorPopupForm.h"
#import <QuartzCore/CAAnimation.h>

@implementation ActivityIndicatorPopup

@synthesize m_Spiner;
@synthesize m_TextInd;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) 
	{
        // Initialization code.
		self.userInteractionEnabled = NO;
		
		[self setBackgroundColor:[UIColor clearColor]];
		[[self layer] setCornerRadius:10];
		[self setClipsToBounds:YES];

		
		if (m_TextInd != nil) {
			m_BackgroundImageView = [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"indicator_bg.png")];
			[m_BackgroundImageView setFrame:CGRectMake(0.0f, 0.0f, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT)];
			[m_BackgroundImageView setBackgroundColor:[UIColor clearColor]];
			m_BackgroundImageView.alpha = 0.5f;

			[self addSubview:m_BackgroundImageView];
			
			m_Spiner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[m_Spiner setCenter:CGPointMake(DF_FORM_AIP_INDICATOR_CX, DF_FORM_AIP_INDICATOR_CY)];
			m_Spiner.hidesWhenStopped = YES;
			[self addSubview:m_Spiner];
			[m_Spiner stopAnimating];
			
			m_Text = [[UILabel alloc] initWithFrame:CGRectMake(DF_FORM_AIP_TEXT_SX, DF_FORM_AIP_TEXT_SY, DF_FORM_AIP_TEXT_WIDTH, DF_FORM_AIP_TEXT_HEIGHT)];
			//[m_Text setBackgroundColor:[UIColor clearColor]];
			[m_Text setTextColor:[UIColor darkGrayColor]];
			m_Text.font = [m_Text.font fontWithSize:14.0f];
			[m_Text setText:m_TextInd];
			[self addSubview:m_Text];
		}
		else {
			m_Spiner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[m_Spiner setCenter:CGPointMake((DF_FORM_AIP_FRAME_WIDTH / 2), DF_FORM_AIP_INDICATOR_CY)];
			m_Spiner.hidesWhenStopped = YES;
			[self addSubview:m_Spiner];
			[m_Spiner stopAnimating];
		}

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

- (void)dealloc {
    [super dealloc];
}

+ (id) startAnimationWithSuperView:(id)superView
{
	ActivityIndicatorPopup *	indicatorPopup	= nil;
	UIDeviceOrientation			orientation		= [[UIDevice currentDevice] orientation];
	
	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		indicatorPopup = (ActivityIndicatorPopup *)[[ActivityIndicatorPopup alloc] initWithFrame:CGRectMake(DF_FORM_AIP_HORZ_FRAME_SX, DF_FORM_AIP_HORZ_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT)];
		
		NSLog(@"x=[%f], y=[%f], width=[%f], height=[%f]", DF_FORM_AIP_HORZ_FRAME_SX, DF_FORM_AIP_HORZ_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT);
	}
	else 
	{
		indicatorPopup = (ActivityIndicatorPopup *)[[ActivityIndicatorPopup alloc] initWithFrame:CGRectMake(DF_FORM_AIP_VERT_FRAME_SX, DF_FORM_AIP_VERT_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT)];

		NSLog(@"x=[%f], y=[%f], width=[%f], height=[%f]", DF_FORM_AIP_VERT_FRAME_SX, DF_FORM_AIP_VERT_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT);
	}
	
	[superView addSubview:indicatorPopup];
	[indicatorPopup.m_Spiner startAnimating];
	
	return indicatorPopup;
}

+ (id) startAnimationWithSuperView:(id)superView orientation:(UIDeviceOrientation)orientation
{
	ActivityIndicatorPopup *	indicatorPopup	= nil;

	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		indicatorPopup = (ActivityIndicatorPopup *)[[ActivityIndicatorPopup alloc] initWithFrame:CGRectMake(DF_FORM_AIP_HORZ_FRAME_SX, DF_FORM_AIP_HORZ_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT)];
		
		NSLog(@"x=[%f], y=[%f], width=[%f], height=[%f]", DF_FORM_AIP_HORZ_FRAME_SX, DF_FORM_AIP_HORZ_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT);
	}
	else 
	{
		indicatorPopup = (ActivityIndicatorPopup *)[[ActivityIndicatorPopup alloc] initWithFrame:CGRectMake(DF_FORM_AIP_VERT_FRAME_SX, DF_FORM_AIP_VERT_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT)];
		
		NSLog(@"x=[%f], y=[%f], width=[%f], height=[%f]", DF_FORM_AIP_VERT_FRAME_SX, DF_FORM_AIP_VERT_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT);
	}
	
	[superView addSubview:indicatorPopup];
	[indicatorPopup.m_Spiner startAnimating];
	
	return indicatorPopup;
}


+ (id) startAnimationWithSuperView:(id)superView textInd:(NSString*)textInd
{
	ActivityIndicatorPopup *	indicatorPopup	= nil;
	UIDeviceOrientation			orientation		= [[UIDevice currentDevice] orientation];
	
	indicatorPopup = [ActivityIndicatorPopup alloc];
	indicatorPopup.m_TextInd = textInd;
												
	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		[indicatorPopup initWithFrame:CGRectMake(DF_FORM_AIP_HORZ_FRAME_SX, DF_FORM_AIP_HORZ_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT)];
		
		NSLog(@"x=[%f], y=[%f], width=[%f], height=[%f]", DF_FORM_AIP_HORZ_FRAME_SX, DF_FORM_AIP_HORZ_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT);
	}
	else 
	{
		[indicatorPopup initWithFrame:CGRectMake(DF_FORM_AIP_VERT_FRAME_SX, DF_FORM_AIP_VERT_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT)];
		
		NSLog(@"x=[%f], y=[%f], width=[%f], height=[%f]", DF_FORM_AIP_VERT_FRAME_SX, DF_FORM_AIP_VERT_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT);
	}

	[superView addSubview:indicatorPopup];
	[indicatorPopup.m_Spiner startAnimating];
	
	return indicatorPopup;
}

+ (id) startAnimationWithSuperView:(id)superView textInd:(NSString*)textInd orientation:(UIDeviceOrientation)orientation
{
	ActivityIndicatorPopup *	indicatorPopup	= nil;
	
	indicatorPopup = [ActivityIndicatorPopup alloc];
	indicatorPopup.m_TextInd = textInd;
	
	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		[indicatorPopup initWithFrame:CGRectMake(DF_FORM_AIP_HORZ_FRAME_SX, DF_FORM_AIP_HORZ_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT)];
		
		NSLog(@"x=[%f], y=[%f], width=[%f], height=[%f]", DF_FORM_AIP_HORZ_FRAME_SX, DF_FORM_AIP_HORZ_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT);
	}
	else 
	{
		[indicatorPopup initWithFrame:CGRectMake(DF_FORM_AIP_VERT_FRAME_SX, DF_FORM_AIP_VERT_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT)];
		
		NSLog(@"x=[%f], y=[%f], width=[%f], height=[%f]", DF_FORM_AIP_VERT_FRAME_SX, DF_FORM_AIP_VERT_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT);
	}

    [superView addSubview:indicatorPopup];
	[indicatorPopup.m_Spiner startAnimating];
	
	return indicatorPopup;
}

- (void) setTextInd:(NSString*)textInd
{
	m_TextInd = textInd; 
	[m_Text setText:textInd];
}

- (void) resize:(UIDeviceOrientation)orientation
{
	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		[self setFrame:CGRectMake(DF_FORM_AIP_HORZ_FRAME_SX, DF_FORM_AIP_HORZ_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT)];
	}
	else 
	{
		[self setFrame:CGRectMake(DF_FORM_AIP_VERT_FRAME_SX, DF_FORM_AIP_VERT_FRAME_SY, DF_FORM_AIP_FRAME_WIDTH, DF_FORM_AIP_FRAME_HEIGHT)];

	}
}



- (id) stopAnimation
{
	[self.m_Spiner stopAnimating];
	[self removeFromSuperview];
	[self release];
	
	return nil;
}

@end
