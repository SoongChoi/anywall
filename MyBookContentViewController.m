    //
//  MyBookContentViewController.m
//  PlayBook
//
//  Created by Daniel on 12. 4. 25..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyBookContentViewController.h"


#define REFRESH_FOOTER_HEIGHT 50.0f


@implementation MyBookContentViewController

@synthesize m_Background;
@synthesize m_BtnClose;

@synthesize m_TitleBarLayout;
@synthesize m_TitleLabel;

@synthesize m_HeaderBar;
@synthesize m_TopShowLine;
@synthesize m_TableView;

@synthesize m_BtnEditMode;
@synthesize m_EditBottomBar;
@synthesize m_BtnSortOrder;

@synthesize m_ViewStatusError;
@synthesize m_ImageError;
@synthesize m_StatusError;

@synthesize m_Request;

@synthesize m_FooterSpinner;

@synthesize m_RefreshFooterView;
@synthesize m_ImageFooter;

@synthesize m_FooterLabel;

@synthesize m_TextLoading;
@synthesize m_TextMore;


- (void) __addLoadMoreFooter
{
	m_RefreshFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, m_TableView.contentSize.height, 320, REFRESH_FOOTER_HEIGHT)];
    m_RefreshFooterView.backgroundColor = [UIColor clearColor];
    
    if (m_IsLoading == NO) {
		m_ImageFooter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadmore_logo.png"]];
				[m_ImageFooter setFrame:CGRectMake(50, 0, 220, 50)];
		
        m_FooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_FOOTER_HEIGHT)];
        m_FooterLabel.backgroundColor = [UIColor clearColor];
        m_FooterLabel.font = [UIFont boldSystemFontOfSize:12.0];
        m_FooterLabel.textAlignment = UITextAlignmentCenter;
        m_FooterLabel.textColor = [UIColor blackColor];
        //m_FooterLabel.text = m_TextMore;
		m_FooterLabel.text = @"";
        
        m_FooterSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        m_FooterSpinner.frame = CGRectMake(150, floorf((REFRESH_FOOTER_HEIGHT - 20) / 2), 20, 20);
    }	
	
    [m_RefreshFooterView addSubview:m_ImageFooter];
    [m_RefreshFooterView addSubview:m_FooterLabel];
    [m_RefreshFooterView addSubview:m_FooterSpinner];
	
	[m_TableView setTableFooterView:m_RefreshFooterView];
	
	m_IsPullLoad = YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self setupStrings];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        [self setupStrings];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	UIColor* bgColor = [UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")];
	{
	[m_Background setBackgroundColor:bgColor];	
	[m_TitleBarLayout setBackgroundColor:[UIColor clearColor]];	
	
	[m_TopShowLine setHidden:YES];	
		
	[m_HeaderBar setBackgroundColor:bgColor];
	[m_TableView setBackgroundColor:[UIColor clearColor]];	
	}
	
	[m_TitleLabel setUserInteractionEnabled:YES];
	UITapGestureRecognizer *tapTitleGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapTitle)] autorelease];
	[m_TitleLabel addGestureRecognizer:tapTitleGesture];
	
	
	[m_BtnClose setImage:RESOURCE_IMAGE(@"view_top_btn_back_off.png") forState:UIControlStateNormal];
	[m_BtnClose setImage:RESOURCE_IMAGE(@"view_top_btn_back_on.png") forState:UIControlStateHighlighted];
	[m_BtnClose setImageEdgeInsets:UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f)];
	
	[m_BtnSortOrder setImage:[UIImage imageNamed:@"my_vlist_btn_all_off.png"] forState:UIControlStateNormal];
	[m_BtnSortOrder setImage:[UIImage imageNamed:@"my_vlist_btn_all_on.png"] forState:UIControlStateHighlighted];

	[m_ViewStatusError setHidden:YES];
	
	m_TableView.scrollsToTop = YES;
	
	m_Request = [[PlayBookRequest alloc] init];
	m_RecentSortOrder = SortOrderAll;
	
	[self __addLoadMoreFooter];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (IBAction) actionTapTitle
{
	NSLog(@"Tap Title Label");
	[m_TableView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
	if([m_Request isDownloading] == YES) {
		[m_Request cancelConnection];
	}	
	[m_Request release];
	
	[m_HeaderBar release];
	[m_TopShowLine release];
	[m_TableView release];	
	[m_BtnEditMode release];
	[m_BtnSortOrder release];
	
    [m_ImageFooter release];
    [m_FooterLabel release];
    [m_FooterSpinner release];
    [m_TextLoading release];
    [m_TextMore release];

	[m_BtnClose release];
	
	[m_ImageError release];
	[m_StatusError release];
	[m_ViewStatusError release];
	
	[m_RefreshFooterView release];
	[m_Background release];
	
    [super dealloc];
}


- (void)setupStrings
{
    m_TextLoading = [[NSString alloc] initWithString:@"로딩 중..."];
    m_TextMore    = [[NSString alloc] initWithString:@"25개 더 받아오기"];	
}

- (void)refresh {
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self performSelector:@selector(finishLoading) withObject:nil afterDelay:2.0];
}

- (void) startLoadingMore
{
	if (m_IsPullLoad == NO) { return; }
	
    m_IsLoading = YES;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(updateText)];
	
    m_TableView.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_FOOTER_HEIGHT, 0);
    
	[self setBeforeLoading];
    [UIView commitAnimations];
    
    [self loadMore];
}

- (void) loadMore
{
    [self performSelector:@selector(stopLoadingMore) withObject:nil afterDelay:2.0];
}

- (void)stopLoadingMore
{
    [self finishLoading];
}

- (void)stopLoadingMoreComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self resetAfterLoading];
}


#pragma Mark - Common methods

- (void) setBeforeLoading
{    
    // Set the footer
    m_FooterLabel.hidden = YES;
    
	[m_FooterSpinner startAnimating];
}

- (void) finishLoading
{
    m_IsLoading = NO;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(resetAfterLoading)];
	
    m_TableView.contentInset = UIEdgeInsetsZero;
	
    [UIView commitAnimations];
}

- (void) resetAfterLoading
{
    // Reset the footer
    m_FooterLabel.hidden = NO;
	
    [m_FooterSpinner stopAnimating];
}

#pragma Mark - UISCrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (m_IsLoading) return;
    m_IsDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	//NSLog(@"Y=[%f], H=[%f]", scrollView.contentOffset.y + super.m_TableView.frame.size.height, super.m_TableView.contentSize.height);

	if (scrollView.contentOffset.y > 0) {
		[m_TopShowLine setHidden:NO];
	}
	else {
		[m_TopShowLine setHidden:YES];
	}
	
    if (m_IsLoading == YES) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y + m_TableView.frame.size.height >= m_TableView.contentSize.height) {
            m_TableView.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_FOOTER_HEIGHT, 0);        
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	//NSLog(@"Y=[%d], H=[%d]", scrollView.contentOffset.y + super.m_TableView.frame.size.height, super.m_TableView.contentSize.height);
	
    if (m_IsLoading == YES) return;
    m_IsDragging = NO;
    
	if (scrollView.contentOffset.y + m_TableView.frame.size.height >= m_TableView.contentSize.height + REFRESH_FOOTER_HEIGHT) {
        // Released below the footer
        [self startLoadingMore];
    }
}

- (void) setTitleText:(NSString*)titleText
{
	[m_TitleLabel setText:titleText];
}

- (void) setShowHeader:(BOOL) showHeader
{
	if (showHeader == NO) { 
		[m_TableView setTableHeaderView:nil];
	}
}

- (void) setShowFooter:(BOOL) showFooter
{
	UIView* tabFooterView = m_TableView.tableFooterView;
	
	if (showFooter == NO) { 
		tabFooterView.frame = CGRectMake(tabFooterView.frame.size.width, 0.0f, tabFooterView.frame.origin.x, tabFooterView.frame.origin.y);
		tabFooterView.hidden = YES;	
	}
	m_IsPullLoad = showFooter;
}

- (void) setShowEditButton:(BOOL) showEdit;
{
	if (showEdit == NO) { 
		m_BtnEditMode.hidden = YES;
	}
	else {
		m_BtnEditMode.hidden = NO;
	}
	m_EditBottomBar.hidden = YES;
}

- (BOOL) setBtnSortOrderType:(SortOrderTypes) recentOrder
{
	if (m_RecentSortOrder == recentOrder) { return NO; }
	m_RecentSortOrder = recentOrder;
	
	if (m_RecentSortOrder == SortOrderCartoon) {
		[m_BtnSortOrder setFrame:CGRectMake(m_BtnSortOrder.frame.origin.x, m_BtnSortOrder.frame.origin.y, 45.0f, 25.0f)];
		[m_BtnSortOrder setImage:[UIImage imageNamed:@"my_vlist_btn_comic_off.png"] forState:UIControlStateNormal];
		[m_BtnSortOrder setImage:[UIImage imageNamed:@"my_vlist_btn_comic_on.png"] forState:UIControlStateHighlighted];
	}
	else if (m_RecentSortOrder == SortOrderEpub) {
		[m_BtnSortOrder setFrame:CGRectMake(m_BtnSortOrder.frame.origin.x, m_BtnSortOrder.frame.origin.y, 66.0f, 25.0f)];		
		[m_BtnSortOrder setImage:[UIImage imageNamed:@"my_vlist_btn_novel_off.png"] forState:UIControlStateNormal];
		[m_BtnSortOrder setImage:[UIImage imageNamed:@"my_vlist_btn_novel_on.png"] forState:UIControlStateHighlighted];
	}
	else {
		[m_BtnSortOrder setFrame:CGRectMake(m_BtnSortOrder.frame.origin.x, m_BtnSortOrder.frame.origin.y, 45.0f, 25.0f)];		
		[m_BtnSortOrder setImage:[UIImage imageNamed:@"my_vlist_btn_all_off.png"] forState:UIControlStateNormal];
		[m_BtnSortOrder setImage:[UIImage imageNamed:@"my_vlist_btn_all_on.png"] forState:UIControlStateHighlighted];
	}
	
	return YES;
}

- (void) setStatusError:(NSString*)errMessage status:(ErrorStatus)status
{
	[m_ViewStatusError setHidden:NO];
	
	switch(status) {
		case ErrorStatusMyRead:
			[m_ImageError setImage:RESOURCE_IMAGE(@"blank_image_my01.png")];			
			break;
		case ErrorStatusMyZzim:
			[m_ImageError setImage:RESOURCE_IMAGE(@"blank_image_my02.png")];			
			break;			
		case ErrorStatusMyFixRate:
			[m_ImageError setImage:RESOURCE_IMAGE(@"blank_image_my03.png")];			
			break;			
		case ErrorStatusMyStream:
			[m_ImageError setImage:RESOURCE_IMAGE(@"blank_image_my04.png")];			
			break;			
		case ErrorStatusMyDownload:
			[m_ImageError setImage:RESOURCE_IMAGE(@"blank_image_my05.png")];			
			break;			
		default:
			[m_ImageError setImage:RESOURCE_IMAGE(@"blank_image_etc.png")];			
			break;
	}
	[m_StatusError setText:errMessage];
}

- (void) setHiddenStatusError
{
	[m_ViewStatusError setHidden:YES];
}

- (NetworkUseType) getNetworkEnableUsed
{
	if (APPDELEGATE.m_NetworkSatus != NetworkWifi) {
		if ([SettingPreference getUse3G] == YES && [SettingPreference getUse3GPopup] == YES) {
			return NetworkUse3GNotify;
		}
		else if ([SettingPreference getUse3G] == NO) {
			return NetworkUse3GDiable;
		}
	}
	return NetworkUseAllEnable;
}

- (void) clickBtnEditMode:(id)sender
{
	NSLog(@"clieck Edit Button");	
}

- (void) clieckBtnSortOrder:(id)sender
{
	NSLog(@"click SortOrder Button[super]");
}

- (void) clickBtnClose:(id)sender
{
}

- (void) clickBtnSelectAll:(id)sender
{
}

- (void) clickBtnDelete:(id)sender
{
}

@end
