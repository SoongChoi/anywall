//
//  ContentController.m
//  PlayBook
//
//  Created by Daniel on 12. 3. 15..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StorePaidContentController.h"
#import "StorePaidViewController.h"
#import "StorePaidCartoonViewController.h"
#import "StorePaidEpubViewController.h"


static NSUInteger kNumberOfPages = 3;

#define _TITLE_ORIGIN_LEFT		0.f
#define _TITLE_ORIGIN_TITLE		128.f
#define _TITLE_ORIGIN_RIGHT		256.f

#define _TAG_TITLE_CARTOON		1
#define _TAG_RIGHT_RECOMMEND	2

#define _TAG_LEFT_CARTOON		3
#define _TAG_TITLE_RECOMMEND	4
#define _TAG_RIGHT_EPUB			5

#define _TAG_LEFT_RECOMMEND		6
#define _TAG_TITLE_EPUB			7


#define VIEW_CONTROLLER_CARTOON     0
#define VIEW_CONTROLLER_MAIN		1
#define VIEW_CONTROLLER_EPUB		2

@implementation StorePaidContentController


@synthesize m_ContentList;

@synthesize m_TitleView;
@synthesize m_ScrollView;
@synthesize m_TitleViewList;
@synthesize m_ViewControllers;



- (void) __loadScrollViewWithPage:(int)page
{
	//NSLog(@"load ScrollView Page, page=[%d]", page, m_ScrollView.frame.origin);
	
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
		
    // replace the placeholder if necessary
    UIViewController *controller = [m_ViewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) 
	{
		switch (page) {
			case VIEW_CONTROLLER_CARTOON:
				controller = [[StorePaidCartoonViewController alloc] initWithNibName:@"ContentViewController" bundle:nil];
				break;
			case VIEW_CONTROLLER_MAIN:
				controller = [[StorePaidViewController alloc] initWithNibName:@"ContentViewController" bundle:nil];
				break;				
			case VIEW_CONTROLLER_EPUB:
				controller = [[StorePaidEpubViewController alloc] initWithNibName:@"ContentViewController" bundle:nil];				
				break;				
		}
				
        [m_ViewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
	
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) 
	{
        CGRect frame = m_ScrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
		
        [m_ScrollView addSubview:controller.view];        
    }
}


#define _SCROLL_OBJ_HEIGHT			50.0
#define _SCROLL_OBJ_WIDTH			64.0
#define _ITEM_ARROW_HEIGHT			32.0
#define _NUMBER_OF_IMAGES			7



- (NSString*) __getImageName:(NSInteger) index on:(Boolean) on
{
	switch(index) {
		case _TAG_TITLE_CARTOON:
			return @"top_label_comic.png";
		case _TAG_TITLE_RECOMMEND:
			return @"top_label_recommend.png";
		case _TAG_TITLE_EPUB:		
			return @"top_label_novel.png";
		case _TAG_LEFT_CARTOON:
			if (on == YES) {
				return @"top_btn_comic_on.png";
			}
			return @"top_btn_comic_off.png";
		case _TAG_RIGHT_RECOMMEND:
			if (on == YES) {
				return @"top_btn_recommend_right_on.png";
			}			
			return @"top_btn_recommend_right_off.png";		
		case _TAG_RIGHT_EPUB:
			if (on == YES) {
				return @"top_btn_novel_on.png";
			}
			return @"top_btn_novel_off.png";		
		case _TAG_LEFT_RECOMMEND:
			if (on == YES) {
				return @"top_btn_recommend_left_on.png";
			}
			return @"top_btn_recommend_left_off.png";		
	}
	
	return @"top_btn_recommend_left_off.png";
}


- (UIView*) __loadTitleView:(NSInteger) index 
{
	switch (index) {
		case _TAG_TITLE_CARTOON:
		case _TAG_TITLE_EPUB:
		case _TAG_TITLE_RECOMMEND:
		{
			UIImage* image = [UIImage imageNamed:[self __getImageName:index on:NO]];
			UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
			
			CGRect rect = imageView.frame;
			rect.size.height = _SCROLL_OBJ_HEIGHT;
			rect.size.width  = _SCROLL_OBJ_WIDTH;
			rect.origin.x = _TITLE_ORIGIN_TITLE;
			imageView.frame  = rect;
			imageView.tag    = index;	// tag our images for later use when we place them in serial fashion	
			if (index == _TAG_TITLE_CARTOON || index == _TAG_TITLE_EPUB) {
				[imageView setAlpha:0.0f];
			}
			
			[imageView setUserInteractionEnabled:YES];
			UITapGestureRecognizer *tapTitleGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapTitle)] autorelease];
			[imageView addGestureRecognizer:tapTitleGesture];
			
			return imageView;
		}
			
		case _TAG_RIGHT_RECOMMEND:
		case _TAG_RIGHT_EPUB:
		case _TAG_LEFT_RECOMMEND:
		case _TAG_LEFT_CARTOON:
		{	
			UIImage* image = [UIImage imageNamed:[self __getImageName:index on:NO]];
			UIImage* imageTouch = [UIImage imageNamed:[self __getImageName:index on:YES]];
			
			float xOrigin = 0.0f;
			
			if (index == _TAG_RIGHT_RECOMMEND || index == _TAG_RIGHT_EPUB)
				xOrigin = _TITLE_ORIGIN_RIGHT;
			
			UIButton* btnArrow = [[UIButton alloc] initWithFrame:CGRectMake(xOrigin, 7.0f, _SCROLL_OBJ_WIDTH, _ITEM_ARROW_HEIGHT)];
			[btnArrow setImage:image forState:UIControlStateNormal];
			[btnArrow setImage:imageTouch forState:UIControlStateHighlighted];
			[btnArrow addTarget:self action:@selector(arrowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
			btnArrow.tag = index;
			[btnArrow setUserInteractionEnabled:YES];
			
			if (index == _TAG_RIGHT_RECOMMEND || index == _TAG_LEFT_RECOMMEND) {
				[btnArrow setAlpha:0.0f];
			}
			return btnArrow;
			
		}
			
	}
	return nil;
}

- (IBAction) actionTapTitle
{
	NSLog(@"Tap Title Ribbon");
	
	ContentViewController* controller = [m_ViewControllers objectAtIndex:m_CurentPage];
	[controller setControllerSelected:m_CurentPage];
}

- (void)arrowBtnClicked:(id)sender
{
	UIButton *btn = sender;
    NSLog(@"Select index: %d",btn.tag);
	CGFloat xOrigin = 0.0f;
	
	switch (btn.tag)
	{
		case _TAG_LEFT_CARTOON:
			xOrigin = 0.0f;
			break;
		case _TAG_RIGHT_RECOMMEND:
		case _TAG_LEFT_RECOMMEND:
			xOrigin = 320.0f;
			break;
		case _TAG_RIGHT_EPUB:
			xOrigin = 640.0f;
			break;
	}
	
	[UIView animateWithDuration:0.5f
					 animations:^{
						 [m_ScrollView setContentOffset:CGPointMake(xOrigin, 0.0f)];
					 }
					 completion:^(BOOL finished){
						 if (m_CurentPage == VIEW_CONTROLLER_MAIN) 
						 {
							 ContentViewController* controller = [m_ViewControllers objectAtIndex:m_CurentPage];						
							 [controller setControllerSelected:m_CurentPage];
						 }
					 }];
	
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")];
	
	// view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++) 
	{
		[controllers addObject:[NSNull null]];
    }
	self.m_ViewControllers = controllers;
    [controllers release];  
	
    // a page is the width of the scroll view
    m_ScrollView.pagingEnabled = YES;
    m_ScrollView.contentSize = CGSizeMake(m_ScrollView.frame.size.width * kNumberOfPages, 0);
    m_ScrollView.showsHorizontalScrollIndicator = NO;
    m_ScrollView.showsVerticalScrollIndicator = NO;
    m_ScrollView.scrollsToTop = NO;
    m_ScrollView.delegate = self;
	m_ScrollView.alwaysBounceVertical = NO;
    
	[m_ScrollView setContentOffset:CGPointMake(m_ScrollView.frame.size.width, 0.0f) animated:NO];
	[m_ScrollView setBackgroundColor:[UIColor clearColor]];
	
	// pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
	m_CurentPage = VIEW_CONTROLLER_MAIN;
	
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];
    [self __loadScrollViewWithPage:VIEW_CONTROLLER_CARTOON];	
    [self __loadScrollViewWithPage:VIEW_CONTROLLER_MAIN];

	// 
	[m_TitleView setBackgroundColor:[UIColor clearColor]];
	
	NSUInteger i;
	for (i = 1; i <= _NUMBER_OF_IMAGES; i++)
	{
		UIView* viewTitle = [self __loadTitleView:i];		
		[m_TitleView addSubview:viewTitle];		
		[viewTitle release];
	}
}

- (void)dealloc
{
    [m_ContentList release];
	[m_ViewControllers release];
    [m_ScrollView release];
	[m_TitleView release];
	
    [super dealloc];
}


- (void)requestDataChanged:(NSInteger)tapIndex;
{
	for(ContentViewController* controller in m_ViewControllers) {
		[controller setDataChanged:YES];		
	}
	
	if (tapIndex == TAB_INDEX_PAID_STORE) {
	
		ContentViewController* controller = [m_ViewControllers objectAtIndex:m_CurentPage];
		
		NSLog(@"requestDataChanged=[YES], isDataChanged=[%@]", [controller isDataChanged] ? @"YES" : @"NO");
		if ([controller isDataChanged] == YES) {	
			[controller requestReloadData:self];
		}
		
		if (m_CurentPage == VIEW_CONTROLLER_MAIN) {
			[controller setControllerSelected:m_CurentPage];
		}
	}
}

- (void)selectedDataChanged
{
	ContentViewController* controller = [m_ViewControllers objectAtIndex:m_CurentPage];
	
	if ([controller isDataChanged] == YES) {	
		[controller requestReloadData:self];
	}
}

/*
- (UIView *)view
{
	NSLog(@"view, selfView=[m_ScrollView]");
    return self.m_ScrollView;
}
*/

- (IBAction)changePage:(id)sender
{
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self __loadScrollViewWithPage:m_CurentPage - 1];
    [self __loadScrollViewWithPage:m_CurentPage];
    [self __loadScrollViewWithPage:m_CurentPage + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = m_ScrollView.frame;
    frame.origin.x = frame.size.width * m_CurentPage;
    frame.origin.y = 0;
	[m_ScrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    m_PageControlUsed = YES;
}


#pragma mark -
#pragma mark ScrollView scrollDelegate

#define OPAQUE_WIDTH	64

- (void)scrollViewDidScroll:(UIScrollView *)sender
{	
	CGPoint	p = m_ScrollView.contentOffset;
	
	//NSLog(@"scrollView DidScroll, x = %f, y = %f", p.x, p.y);
	//x : 0 - 320 - 640 범위에서 움직임
	
	
	UIImageView *View1 = (UIImageView*)[m_TitleView viewWithTag:_TAG_TITLE_CARTOON];
	UIImageView *View2 = (UIImageView*)[m_TitleView viewWithTag:_TAG_RIGHT_RECOMMEND];
	UIImageView *View3 = (UIImageView*)[m_TitleView viewWithTag:_TAG_LEFT_CARTOON];
	UIImageView *View4 = (UIImageView*)[m_TitleView viewWithTag:_TAG_TITLE_RECOMMEND];
	UIImageView *View5 = (UIImageView*)[m_TitleView viewWithTag:_TAG_RIGHT_EPUB];
	UIImageView *View6 = (UIImageView*)[m_TitleView viewWithTag:_TAG_LEFT_RECOMMEND];
	UIImageView *View7 = (UIImageView*)[m_TitleView viewWithTag:_TAG_TITLE_EPUB];
	
	double tmpX = p.x;
	double fx = 0.f;
	NSInteger overlap = 320 - (OPAQUE_WIDTH * 2);
	
	if (tmpX > -OPAQUE_WIDTH && tmpX < OPAQUE_WIDTH){					//12 고정영역
		[View1 setAlpha:1.0f];
		[View2 setAlpha:1.0f];
		[View3 setAlpha:0.0f];
		[View4 setAlpha:0.0f];
		[View5 setAlpha:0.0f];		
	}
	else if (tmpX >= OPAQUE_WIDTH && tmpX <= 320 - OPAQUE_WIDTH){		//12 345 가변영역
		fx = fabs(tmpX - OPAQUE_WIDTH);
		[View1 setAlpha:1.0f - (fx / overlap)];	//사라지고
		[View2 setAlpha:1.0f - (fx / overlap)];
		[View3 setAlpha:(fx / overlap)];			//나타남
		[View4 setAlpha:(fx / overlap)];		
		[View5 setAlpha:(fx / overlap)];
	}
	else if (tmpX > 320 - OPAQUE_WIDTH && tmpX < 320 + OPAQUE_WIDTH){		
		[View1 setAlpha:0.0f];
		[View2 setAlpha:0.0f];
		[View3 setAlpha:1.0f];
		[View4 setAlpha:1.0f];
		[View5 setAlpha:1.0f];		
		[View6 setAlpha:0.0f];
		[View7 setAlpha:0.0f];		
	}
	else if (tmpX >= 320 + OPAQUE_WIDTH && tmpX <= 640 - OPAQUE_WIDTH){
		//345 사라지고 67 나타남
		fx = fabs(tmpX - (OPAQUE_WIDTH + 320));
		[View3 setAlpha:1.0f - (fx / overlap)];	//사라지고
		[View4 setAlpha:1.0f - (fx / overlap)];
		[View5 setAlpha:1.0f - (fx / overlap)];
		[View6 setAlpha:(fx / overlap)];			//나타남
		[View7 setAlpha:(fx / overlap)];		
	}
	else if (tmpX > 640 - OPAQUE_WIDTH && tmpX < 640 + OPAQUE_WIDTH){		
		[View3 setAlpha:0.0f];
		[View4 setAlpha:0.0f];
		[View5 setAlpha:0.0f];		
		[View6 setAlpha:1.0f];
		[View7 setAlpha:1.0f];		
	}
	
	if (m_PageControlUsed) {
		return;
	}
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = m_ScrollView.frame.size.width;
    m_CurentPage = floor((m_ScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self __loadScrollViewWithPage:m_CurentPage - 1];
    [self __loadScrollViewWithPage:m_CurentPage];
    [self __loadScrollViewWithPage:m_CurentPage + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    m_PageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    m_PageControlUsed = NO;
	
	NSLog(@"m_CurentPage=[%d]", m_CurentPage);
	
	ContentViewController* controller = [m_ViewControllers objectAtIndex:m_CurentPage];
	if ([controller isDataChanged] == YES) {
		[controller requestReloadData:self];
	}
	
	if (m_CurentPage == VIEW_CONTROLLER_MAIN) {
		[controller setControllerSelected:m_CurentPage];
	}
}


@end
