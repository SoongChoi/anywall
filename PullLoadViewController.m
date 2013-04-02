    //
//  PullToReloadTableViewController.m
//  PlayBook
//
//  Created by Daniel on 12. 4. 15..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PullLoadViewController.h"

#define REFRESH_FOOTER_HEIGHT 50.0f

@implementation PullLoadViewController

@synthesize m_FooterSpinner;

@synthesize m_RefreshFooterView;
@synthesize m_ImageFooter;

@synthesize m_FooterLabel;

@synthesize m_TextLoading;
@synthesize m_TextMore;


- (void) __addLoadMoreFooter
{
	m_RefreshFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, super.m_TableView.contentSize.height, 320, REFRESH_FOOTER_HEIGHT)];
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
	[self __addLoadMoreFooter];
}

- (void)dealloc
{
    [m_ImageFooter release];
    [m_FooterLabel release];
    [m_FooterSpinner release];
    [m_TextLoading release];
    [m_TextMore release];
	
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
    m_IsLoading = YES;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(updateText)];
	
    super.m_TableView.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_FOOTER_HEIGHT, 0);
    
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
	
    super.m_TableView.contentInset = UIEdgeInsetsZero;
	
    [UIView commitAnimations];
}

- (void) resetAfterLoading
{
    // Reset the footer
    m_FooterLabel.hidden = NO;
	
    [m_FooterSpinner stopAnimating];
}

#pragma Mark - UISCrollViewDelegate

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
	NSLog(@"toTop YES");
	return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (m_IsLoading) return;
    m_IsDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	//NSLog(@"Y=[%f], H=[%f]", scrollView.contentOffset.y + super.m_TableView.frame.size.height, super.m_TableView.contentSize.height);
	//NSLog(@"y=[%f]", scrollView.contentOffset.y);
	
	if (scrollView.contentOffset.y > 0) {
		[m_TopShowLine setHidden:NO];
	}
	else {
		[m_TopShowLine setHidden:YES];
	}
	
    if (m_IsLoading == YES) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y + super.m_TableView.frame.size.height >= super.m_TableView.contentSize.height) {
            super.m_TableView.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_FOOTER_HEIGHT, 0);        
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	//NSLog(@"Y=[%d], H=[%d]", scrollView.contentOffset.y + super.m_TableView.frame.size.height, super.m_TableView.contentSize.height);
	
    if (m_IsLoading == YES) return;
    m_IsDragging = NO;
    
	if (scrollView.contentOffset.y + super.m_TableView.frame.size.height >= super.m_TableView.contentSize.height + REFRESH_FOOTER_HEIGHT) {
        // Released below the footer
        [self startLoadingMore];
    }
}


@end
