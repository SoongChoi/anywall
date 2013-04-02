    //
//  ContentViewController.m
//  PlayBook
//
//  Created by Daniel on 12. 3. 19..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ContentViewController.h"
#import "SettingPreference.h"


@implementation ContentViewController

@synthesize m_NavigationBar;
@synthesize m_TopShowLine;
@synthesize m_TableView;

@synthesize m_HeaderBar;
@synthesize m_BtnSortOrder;
@synthesize m_BtnSearch;

@synthesize m_ViewStatusError;
@synthesize m_ImageError;
@synthesize m_StatusError;



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[self viewWillAppear:YES];
		NSLog(@"");
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	m_IsDataChanged = NO;
	m_IsRecentOrder = YES;	
	
	[m_TopShowLine setHidden:YES];
	[m_HeaderBar setBackgroundColor:[UIColor clearColor]];
	[m_TableView setBackgroundColor:[UIColor clearColor]];
	[m_TableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[m_TableView setScrollsToTop:YES];
	
	[m_BtnSortOrder setBackgroundImage:RESOURCE_IMAGE(@"list_btn_new_off.png") forState:UIControlStateNormal];
	[m_BtnSortOrder setBackgroundImage:RESOURCE_IMAGE(@"list_btn_new_on.png") forState:UIControlStateHighlighted];

	[m_BtnSearch setBackgroundImage:RESOURCE_IMAGE(@"list_btn_search_off.png") forState:UIControlStateNormal];
	[m_BtnSearch setBackgroundImage:RESOURCE_IMAGE(@"list_btn_search_on.png") forState:UIControlStateHighlighted];
	
	[m_ViewStatusError setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
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


- (void)dealloc {
    [super dealloc];
	
	[m_NavigationBar release];
	
	[m_BtnSortOrder release];
	[m_BtnSearch release];
	[m_HeaderBar release];
	
	[m_TopShowLine release];
	[m_TableView release];

	[m_ImageError release];
	[m_StatusError release];	
	[m_ViewStatusError release];	
}

- (void) setShowHeader:(BOOL) showHeader
{
	UIView* tableHeaderView = m_TableView.tableHeaderView;
	
	if (showHeader == NO) { 
		tableHeaderView.frame = CGRectMake(tableHeaderView.frame.size.width, 0.0f, tableHeaderView.frame.origin.x, tableHeaderView.frame.origin.y);
		tableHeaderView.hidden = YES;	
	}
}

- (void) setShowFooter:(BOOL) showFooter
{
	UIView* tabFooterView = m_TableView.tableFooterView;
	
	if (showFooter == NO) { 
		tabFooterView.frame = CGRectMake(tabFooterView.frame.size.width, 0.0f, tabFooterView.frame.origin.x, tabFooterView.frame.origin.y);
		tabFooterView.hidden = YES;	
	}
}

- (void) setShowSearchButton:(BOOL) showSearch
{
	if (showSearch == NO) { 
		m_BtnSearch.hidden = YES;
	}
	else {
		m_BtnSearch.hidden = NO;
	}
}

- (BOOL)isDataChanged
{
	return m_IsDataChanged;
}

- (void)setDataChanged:(BOOL)isChanged
{
	m_IsDataChanged = isChanged;
}

- (BOOL)requestReloadData:(id)sender {
	return YES;
}

- (void) setControllerSelected:(NSInteger)pageIndex
{
	[m_TableView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
}

- (BOOL) setBtnSortOrderType:(BOOL) isRecentOrder
{
	if (m_IsRecentOrder == isRecentOrder) { return NO; }
	m_IsRecentOrder = isRecentOrder;
	
	if (m_IsRecentOrder == YES) {
		[m_BtnSortOrder setBackgroundImage:RESOURCE_IMAGE(@"list_btn_new_off.png") forState:UIControlStateNormal];
		[m_BtnSortOrder setBackgroundImage:RESOURCE_IMAGE(@"list_btn_new_on.png") forState:UIControlStateHighlighted];
	}
	else {
		[m_BtnSortOrder setBackgroundImage:[UIImage imageNamed:@"list_btn_popular_off.png"] forState:UIControlStateNormal];
		[m_BtnSortOrder setBackgroundImage:[UIImage imageNamed:@"list_btn_popular_on.png"] forState:UIControlStateHighlighted];
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

- (void) clieckBtnSortOrder:(id)sender
{
	NSLog(@"click SortOrder Button[super]");
}

- (void) clickBtnSearch:(id)sender 
{
	NSLog(@"click Search Button[super]");
}

@end
