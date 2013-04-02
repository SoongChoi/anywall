//
//  PagePopup.m
//  PlayBook
//
//  Created by Daniel on 12. 5. 20..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PageSlidePopup.h"


@implementation PageSlidePopup


@synthesize m_BgImageView;
@synthesize m_MaxPageNumber;
@synthesize m_MinPageNumber;
@synthesize m_SlidePage;


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
	
	[m_MaxPageNumber release];
	[m_MinPageNumber release];
	[m_SlidePage release];
	
	[m_BgImageView removeFromSuperview];
	[m_BgImageView release];
	
    [super dealloc];
}

+ (id) createWithDelegate:(id)delegate orientation:(UIDeviceOrientation)orientation
{
	PageSlidePopup* pageSlidePopup = [[PageSlidePopup alloc] initWithDelegate:delegate orientation:orientation];
	if (pageSlidePopup == nil)
	{
		return nil;
	}
	
	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		[pageSlidePopup setFrame:CGRectMake(0.0f, 320.0f - (36.0f * 2), 480.0f, 36.0f)];
	}
	else 
	{
		[pageSlidePopup setFrame:CGRectMake(0.0f, 480.0f - (45.0f * 2), 320.0f, 45.0f)];
	}
	
	return pageSlidePopup;
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
			[m_BgImageView setFrame:CGRectMake(0.0f, 0.0f, 480.0f, 36.0f)];
			[self addSubview:m_BgImageView];
			
			UILabel* labPageName = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 3.0f, 50.0f, 30.0f)];
			[labPageName setBackgroundColor:[UIColor clearColor]];
			[labPageName setTextColor:[UIColor whiteColor]];
			[labPageName setFont:[labPageName.font fontWithSize:13.0f]];
			[labPageName setTextAlignment:UITextAlignmentLeft];		
			[labPageName setText:@"페이지"];		
			[self addSubview:labPageName];
			[labPageName release];
			
			UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"vi_footer_config_line_on.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			UIImage *stetchRightTrack	= [[UIImage imageNamed:@"vi_footer_config_line_off.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			
			// page slider
			m_SlidePage = [[UISlider alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 3.0f, 5.0f, 330.0f, 26.0f)];
			[m_SlidePage setBackgroundColor:[UIColor clearColor]];
			[m_SlidePage setThumbImage: [UIImage imageNamed:@"vi_footer_pointer.png"] forState:UIControlStateNormal];
			[m_SlidePage setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
			[m_SlidePage setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
			m_SlidePage.minimumValue = 0.0f;
			m_SlidePage.maximumValue = 0.0f;
			m_SlidePage.continuous = YES;
			m_SlidePage.value = 0.0f;
			
			[m_SlidePage addTarget:self action:@selector(sliderActionTouchUp:) forControlEvents:UIControlEventTouchUpInside];			
			[m_SlidePage addTarget:self action:@selector(sliderActionTouchUp:) forControlEvents:UIControlEventTouchUpOutside];			
			[m_SlidePage addTarget:self action:@selector(sliderActionValueChanged:) forControlEvents:UIControlEventValueChanged];			
			[self addSubview:m_SlidePage];
			
			
			m_MinPageNumber = [[UILabel alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 330.0f, 3.0f, 40.0f, 30.0f)];
			[m_MinPageNumber setBackgroundColor:[UIColor clearColor]];
			[m_MinPageNumber setTextColor:[UIColor whiteColor]];
			[m_MinPageNumber setFont:[m_MinPageNumber.font fontWithSize:13.0f]];
			[m_MinPageNumber setTextAlignment:UITextAlignmentRight];		
			[m_MinPageNumber setText:@"0"];			
			[self addSubview:m_MinPageNumber];
			
			
			m_MaxPageNumber = [[UILabel alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 330.0f + 40.0f, 3.0f, 40.0f, 30.0f)];
			[m_MaxPageNumber setBackgroundColor:[UIColor clearColor]];
			[m_MaxPageNumber setTextColor:[UIColor redColor]];
			[m_MaxPageNumber setFont:[m_MaxPageNumber.font fontWithSize:13.0f]];
			[m_MaxPageNumber setTextAlignment:UITextAlignmentLeft];		
			[m_MaxPageNumber setText:@"/0"];
			
			[self addSubview:m_MaxPageNumber];
		}
		else 
		{
			// background image
			m_BgImageView = [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_footer_bg_bar_novel2depth.png")];
			//[m_BgImageView setFrame:CGRectMake(0.0f, 0.0f, DF_FORM_ZOOM_POPUP_VERT_WIDTH, DF_FORM_ZOOM_POPUP_VERT_HEIGHT)];
			[m_BgImageView setFrame:CGRectMake(0.0f, 0.0f, 320, 45.0f)];
			[self addSubview:m_BgImageView];			
			
			UILabel* labPageName = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 8.0f, 50.0f, 30.0f)];
			[labPageName setBackgroundColor:[UIColor clearColor]];
			[labPageName setTextColor:[UIColor whiteColor]];
			[labPageName setFont:[labPageName.font fontWithSize:13.0f]];
			[labPageName setTextAlignment:UITextAlignmentLeft];		
			[labPageName setText:@"페이지"];		
			[self addSubview:labPageName];
			[labPageName release];

			UIImage *stetchLeftTrack	= [[UIImage imageNamed:@"vi_footer_config_line_on.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			UIImage *stetchRightTrack	= [[UIImage imageNamed:@"vi_footer_config_line_off.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
			
			// page slider
			m_SlidePage = [[UISlider alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 5.0f, 10.0f, 173.0f, 30.0f)];
			[m_SlidePage setBackgroundColor:[UIColor clearColor]];
			[m_SlidePage setThumbImage: [UIImage imageNamed:@"vi_footer_pointer.png"] forState:UIControlStateNormal];
			[m_SlidePage setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
			[m_SlidePage setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
			m_SlidePage.minimumValue = 0.0f;
			m_SlidePage.maximumValue = 0.0f;
			m_SlidePage.continuous = YES;
			m_SlidePage.value = 0.0f;
			
			[m_SlidePage addTarget:self action:@selector(sliderActionTouchUp:) forControlEvents:UIControlEventTouchUpInside];			
   			[m_SlidePage addTarget:self action:@selector(sliderActionTouchUp:) forControlEvents:UIControlEventTouchUpOutside];	
			[m_SlidePage addTarget:self action:@selector(sliderActionValueChanged:) forControlEvents:UIControlEventValueChanged];			
			[self addSubview:m_SlidePage];
	
			
			m_MinPageNumber = [[UILabel alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 173.0f, 8.0f, 40.0f, 30.0f)];
			[m_MinPageNumber setBackgroundColor:[UIColor clearColor]];
			[m_MinPageNumber setTextColor:[UIColor whiteColor]];
			[m_MinPageNumber setFont:[m_MinPageNumber.font fontWithSize:13.0f]];
			[m_MinPageNumber setTextAlignment:UITextAlignmentRight];		
			[m_MinPageNumber setText:@"0"];			
			[self addSubview:m_MinPageNumber];
			

			m_MaxPageNumber = [[UILabel alloc] initWithFrame:CGRectMake(15.0f + 50.0f + 173.0f + 40.0f, 8.0f, 40.0f, 30.0f)];
			[m_MaxPageNumber setBackgroundColor:[UIColor clearColor]];
			[m_MaxPageNumber setTextColor:[UIColor redColor]];
			[m_MaxPageNumber setFont:[m_MaxPageNumber.font fontWithSize:13.0f]];
			[m_MaxPageNumber setTextAlignment:UITextAlignmentLeft];		
			[m_MaxPageNumber setText:@"/0"];
			
			[self addSubview:m_MaxPageNumber];

		}
	}
	
	return self;
}

- (void) resize:(UIInterfaceOrientation)toInterfaceOrientation
{
}

- (void) setPageWithMin:(CGFloat)min max:(CGFloat)max
{
	[m_SlidePage setMinimumValue:min];
	[m_SlidePage setMaximumValue:max];

	[m_MinPageNumber setText:[NSString stringWithFormat:@"%d", (NSInteger)min]];
	[m_MaxPageNumber setText:[NSString stringWithFormat:@"/%d", (NSInteger)max]];
}

- (CGFloat) setCurrentPage:(CGFloat)pageNumber 
{
	CGFloat preValue = m_SlidePage.value;
	
	[m_SlidePage setValue:1.0f];
	[m_SlidePage setValue:pageNumber];
	
	[m_MinPageNumber setText:[NSString stringWithFormat:@"%d", (NSInteger)pageNumber]];
	[m_MaxPageNumber setText:[NSString stringWithFormat:@"/%d", (NSInteger)m_SlidePage.maximumValue]];
	
	return preValue;
}

#pragma mark -
#pragma mark UISlider action
- (void)sliderActionTouchUp:(id)sender
{ 
	TRACE(@"slide value = %d", (NSInteger)m_SlidePage.value);
	
	[m_Delegate pageSildeValueChanged:m_SlidePage.value];
}

- (void)sliderActionValueChanged:(id)sender
{ 
	TRACE(@"slide value = %d", (NSInteger)m_SlidePage.value);
	
	[m_MinPageNumber setText:[NSString stringWithFormat:@"%d", (NSInteger)m_SlidePage.value]];
	[m_MaxPageNumber setText:[NSString stringWithFormat:@"/%d", (NSInteger)m_SlidePage.maximumValue]];
}

@end
