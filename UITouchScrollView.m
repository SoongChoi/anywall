//
//  UITouchScrollView.m
//  PlayBook
//
//  Created by 전명곤 on 11. 11. 16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UITouchScrollView.h"


@implementation UITouchScrollView


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

- (void)dealloc {
    [super dealloc];
}

- (void) setTouchDelegate:(id)delegate
{
	m_Delegate = delegate;
}

#pragma mark -
#pragma mark [UIResponder] Touches,,,

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	//UIDeviceOrientation orientation		= [[UIDevice currentDevice] orientation];
    UIDeviceOrientation orientation     = [m_Delegate getCurrentOrientation];
	UITouch	*			touch			= [[touches allObjects] objectAtIndex:0];
	CGPoint				touchPoint		= [touch locationInView:touch.view];
	CGFloat				touchPosition	= touchPoint.x - self.contentOffset.x;
	NSInteger			pos				= 0;
	/*
    if (orientation == UIDeviceOrientationLandscapeLeft ||
        orientation == UIDeviceOrientationLandscapeRight||
        orientation == UIDeviceOrientationPortrait      ||
        orientation == UIDeviceOrientationPortraitUpsideDown){
        m_CurrentOrientation = orientation;
    }*/
    
	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		if (touchPosition >= 0.0f && touchPosition < 160.0f)
		{
			pos = 1;
		}
		else if (touchPosition >= 320.0f && touchPosition <= 479.0f)
		{
			pos = 3;
		}
		else 
		{
			pos = 2;
		}
	}
	else 
	{
		if (touchPosition >= 0.0f && touchPosition < 106.0f)
		{
			pos = 1;
		}
		else if (touchPosition >= 214.0f && touchPosition <= 319.0f)
		{
			pos = 3;
		}
		else 
		{
			pos = 2;
		}
	}
	
	m_BeginPos = pos;
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
//	UIDeviceOrientation orientation		= [[UIDevice currentDevice] orientation];
    UIDeviceOrientation orientation     = [m_Delegate getCurrentOrientation];
	UITouch	*			touch			= [[touches allObjects] objectAtIndex:0];
	CGPoint				touchPoint		= [touch locationInView:touch.view];
	CGFloat				touchPosition	= touchPoint.x - self.contentOffset.x;
	NSInteger			pos				= 0;
    /*
    if (orientation == UIDeviceOrientationLandscapeLeft ||
        orientation == UIDeviceOrientationLandscapeRight||
        orientation == UIDeviceOrientationPortrait      ||
        orientation == UIDeviceOrientationPortraitUpsideDown){
        m_CurrentOrientation = orientation;
    }*/
    
	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		if (touchPosition >= 0.0f && touchPosition < 160.0f)
		{
			switch (m_BeginPos) {
				case 3:
				case 2:
					pos = 3;					
					break;
				case 1:
					pos = 1;
					break;
			}			
		}
		else if (touchPosition >= 320.0f && touchPosition <= 479.0f)
		{
			switch (m_BeginPos) {
				case 1:
				case 2:
					pos = 1;					
					break;
				case 3:
					pos = 3;
					break;
			}			
		}
		else 
		{
			switch (m_BeginPos) {
				case 1:
					pos = 1;
					break;
				case 2:
					pos = 2;					
					break;
				case 3:
					pos = 3;
					break;
			}			
		}
	}
	else 
	{
		if (touchPosition >= 0.0f && touchPosition < 106.0f)
		{
			switch (m_BeginPos) {
				case 3:
				case 2:
					pos = 3;					
					break;
				case 1:
					pos = 1;
					break;
			}			
		}
		else if (touchPosition >= 214.0f && touchPosition <= 319.0f)
		{
			switch (m_BeginPos) {
				case 1:
				case 2:
					pos = 1;					
					break;
				case 3:
					pos = 3;
					break;
			}			
		}
		else 
		{
			switch (m_BeginPos) {
				case 1:
					pos = 1;
					break;
				case 2:
					pos = 2;					
					break;
				case 3:
					pos = 3;
					break;
			}			
		}
	}
	
	[m_Delegate touchScrollViewWithPos:pos];
}

@end
