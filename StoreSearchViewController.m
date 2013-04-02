    //
//  StoreSearchViewController.m
//  PlayBook
//
//  Created by Daniel on 12. 5. 11..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreSearchViewController.h"
#import "IconImageDownloader.h"
#import "StoreSearchCell.h"
#import "BookDetailViewController.h"
#import "NWAppUsageLogger.h"

#define REFRESH_FOOTER_HEIGHT		50.0f


@implementation StoreSearchViewController


@synthesize m_SearchTextField;

@synthesize m_BtnSearchCancel;
@synthesize m_BtnSearchDelete;

@synthesize m_BtnSearchCartoon;
@synthesize m_BtnSearchEpub;

@synthesize m_TableView;
@synthesize m_ErrorImage;
@synthesize m_ErrorStatus;

@synthesize m_Request;	
@synthesize m_List;
@synthesize m_IconDownloaders;

@synthesize m_FooterSpinner;

@synthesize m_RefreshFooterView;
@synthesize m_ImageFooter;
@synthesize m_FooterLabel;

@synthesize m_TextLoading;
@synthesize m_TextMore;



- (void) __addLoadMoreFooter
{
	m_RefreshFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0f, 320, REFRESH_FOOTER_HEIGHT)];
    m_RefreshFooterView.backgroundColor = [UIColor clearColor];
    
//    if (m_IsLoading == NO) {
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
//    }	
	
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (m_SearchType == SEARCH_TYPE_CARTOON) {
		[m_BtnSearchCartoon setBackgroundImage:RESOURCE_IMAGE(@"search_btn_left_on.png") forState:UIControlStateNormal];
		[m_BtnSearchCartoon setTitleColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
		[m_BtnSearchEpub setBackgroundImage:RESOURCE_IMAGE(@"search_btn_right_off.png") forState:UIControlStateNormal];		
		[m_BtnSearchEpub setTitleColor:[UIColor colorWithRed:127.0f/255.0f green:127.0f/255.0f blue:127.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
	}
	else {
		[m_BtnSearchEpub setBackgroundImage:RESOURCE_IMAGE(@"search_btn_right_on.png") forState:UIControlStateNormal];
		[m_BtnSearchEpub setTitleColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
		[m_BtnSearchCartoon setBackgroundImage:RESOURCE_IMAGE(@"search_btn_left_off.png") forState:UIControlStateNormal];
		[m_BtnSearchCartoon setTitleColor:[UIColor colorWithRed:127.0f/255.0f green:127.0f/255.0f blue:127.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
	}
	
	m_Request = [[PlayBookRequest alloc] initWithDelegate:self];	
	
	m_List = [[NSMutableArray alloc] initWithCapacity:0];
	m_IconDownloaders = [[NSMutableArray alloc] initWithCapacity:0];

	[m_SearchTextField setReturnKeyType:UIReturnKeySearch];	
	m_SearchTextField.text = @"검색어를 입력해 주세요";
	m_SearchTextField.textColor = [UIColor lightGrayColor];
	
	m_TableView.scrollsToTop = YES;	
	m_TableView.hidden = YES;
	
	m_ErrorStatus.hidden = YES;
	m_ErrorImage.hidden = YES;
	
	m_IsLoading  = NO;
	m_IsPullLoad = YES;
	[self __addLoadMoreFooter];
	
	self.view.frame = VIEW_RECT_BOTTOM;	
	[UIView animateWithDuration:VIEW_ANI_DURATION
					 animations:^{
						 self.view.frame = VIEW_RECT_NORMAL;
					 }
					 completion:^(BOOL finished){
						 //do nothing
					 }];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	NSLog(@"Cartoon ViewController");
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
	
	[m_Request release];
	
	[m_TableView release];	
	[m_ErrorStatus release];
	[m_ErrorImage release];
	
	[m_FooterSpinner release];
	
	[m_RefreshFooterView release];
	[m_ImageFooter release];
	[m_FooterLabel release];
	
	[m_TextLoading release];
	[m_TextMore release];
	
	[m_List removeAllObjects];
	[m_List release];	
	
	[m_IconDownloaders removeAllObjects];
	[m_IconDownloaders release];
	
    [super dealloc];
}

- (void) setStatusError:(NSString*)message
{
	[m_ErrorStatus setHidden:NO];
	[m_ErrorStatus setText:message];
	[m_ErrorImage setHidden:NO];
}

- (void) setSearchType:(NSInteger)searchType
{
	m_SearchType = searchType;
}

#pragma mark -
#pragma mark CloseButton Delegate
- (void) clickCloseButton:(id)sender
{
	[self hideKeyboard];
	
	if ([m_Request isDownloading] == YES) {
		[m_Request cancelConnection];
	}
	
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	[UIView animateWithDuration:VIEW_ANI_DURATION
					 animations:^{
						 self.view.frame = VIEW_RECT_BOTTOM;
					 }
					 completion:^(BOOL finished){						
					 }];
}

#pragma mark -
#pragma mark Search Tap Delegate
- (void) clickSearchTapButton:(id)sender
{
	if (m_bShowKeyboard == YES) {
		[self hideKeyboard];
	}
	
	NSInteger idTag = ((UIButton*) sender).tag;
	
	if (m_SearchType == idTag) { return; }
	
	if (idTag == SEARCH_TYPE_CARTOON) {
		m_SearchType = SEARCH_TYPE_CARTOON;
		
		[m_BtnSearchCartoon setBackgroundImage:RESOURCE_IMAGE(@"search_btn_left_on.png") forState:UIControlStateNormal];
		[m_BtnSearchCartoon setTitleColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
		[m_BtnSearchEpub setBackgroundImage:RESOURCE_IMAGE(@"search_btn_right_off.png") forState:UIControlStateNormal];		
		[m_BtnSearchEpub setTitleColor:[UIColor colorWithRed:127.0f/255.0f green:127.0f/255.0f blue:127.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
	}
	else {
		m_SearchType = SEARCH_TYPE_EPUB;

		[m_BtnSearchEpub setBackgroundImage:RESOURCE_IMAGE(@"search_btn_right_on.png") forState:UIControlStateNormal];
		[m_BtnSearchEpub setTitleColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
		[m_BtnSearchCartoon setBackgroundImage:RESOURCE_IMAGE(@"search_btn_left_off.png") forState:UIControlStateNormal];
		[m_BtnSearchCartoon setTitleColor:[UIColor colorWithRed:127.0f/255.0f green:127.0f/255.0f blue:127.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
	}	
	
	NSString* searchWord = m_SearchTextField.text;
	NSString* contentType = (m_SearchType == SEARCH_TYPE_CARTOON) ? BI_MAIN_GROUP_TYPE_CARTOON : BI_MAIN_GROUP_TYPE_NOVEL;	
	
	NSLog(@"searchWord=[%@]", searchWord);
	
	m_PageCount = DE_DEFAULT_PAGE_COUNT;
	m_ListCount = (DF_DEFAULT_LIST_COUNT * 2);
	
	NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
	NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
	
	m_IsReloadOrder = YES;
	
	if (m_ActivityIndicator == nil) {
		m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:self.view orientation:UIDeviceOrientationPortrait]; 	
	}
	[m_Request searchListWithKeyword:searchWord pageCount:pageCount listCount:listCount mainGroup:contentType orderType:BI_ORDER_TYPE_RECENT];
}


#pragma mark -
#pragma mark PlayBookRequest Delegate
- (void) pbrDidReceiveResponse:(NSURLResponse *)response command:(NSInteger)command
{
	
}

- (void) pbrDidReceiveData:(NSData *)data response:(NSURLResponse *)response command:(NSInteger)command
{
}

- (void) pbrDidFailWithError:(NSError *)error command:(NSInteger)command
{
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}

	NSLog(@"%@", error);
	
	m_PageCount = [m_List count] / (DF_DEFAULT_LIST_COUNT * 2);
	if (m_PageCount == 0) {
		m_PageCount = DE_DEFAULT_PAGE_COUNT;
	}
	[self stopLoadingMore];
	
	if ([m_List count] == 0) {
		[self setStatusError:RESC_STRING_NETWORK_FAIL];
	}
}

- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{	
	NSDictionary* dicInfo = (NSDictionary *) userInfo;
	
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	switch (command) {
		case DF_URL_CMD_SEARCH_LIST:
			[self stopLoadingMore];
			{
			NSString* rtCode = [dicInfo objectForKey:@"result"];
			if ([rtCode isEqualToString:@"0"] == YES) {
				NSArray* rtEntry = [dicInfo objectForKey:@"contentInfo"];
				
				if (m_IsReloadOrder == YES) {
					[m_IconDownloaders removeAllObjects];
					[m_List removeAllObjects];
				}
				
				for(NSDictionary* dicEntry in rtEntry) {
					[m_List addObject:[dicEntry mutableCopy]];
				}				
				[m_TableView reloadData];
				
				if (m_IsReloadOrder == YES) {	
					[m_TableView setContentOffset:CGPointMake(0, 0) animated:YES];
				}
				m_IsReloadOrder = NO;	
			}
			else {		
				if (m_IsReloadOrder == YES) {
					[m_IconDownloaders removeAllObjects];
					[m_List removeAllObjects];
				}
				m_IsReloadOrder = NO;	
				
				m_PageCount = [m_List count] / (DF_DEFAULT_LIST_COUNT * 2);	
				if (m_PageCount == 0) {
					m_PageCount = DE_DEFAULT_PAGE_COUNT;
				}
			}

			if ([m_List count] == 0) {
				m_TableView.hidden = YES;
				[self setStatusError:@"검색 결과가 없습니다."];
			}
			else {
				m_TableView.hidden = NO;
				m_ErrorStatus.hidden = YES;
				m_ErrorImage.hidden = YES;
			}
				
			{
				NSString* searchWord = m_SearchTextField.text;
				NWAppUsageLogger *logger = [NWAppUsageLogger logger];
				[logger fireUsageLog:@"SEARCH" andEventDesc:searchWord andCategoryId:nil];
			}

			}			
			break;
	}
}


#pragma mark -
#pragma mark Tableview dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [m_List count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	NSLog(@"tableView cell is called - indexPath=[%d]", indexPath.row);
	
	static NSString* CellItentifer = @"StoreSearchCell";
	StoreSearchCell* cell = (StoreSearchCell*) [tableView dequeueReusableCellWithIdentifier:CellItentifer];
	
	if (cell == nil) {
		NSArray* cellObjectArray = [[NSBundle mainBundle] loadNibNamed:@"StoreSearchCell" owner:nil options:nil]; 
		for (id currentObject in cellObjectArray) {
			if ([currentObject isKindOfClass:[StoreSearchCell class]] == true) {
				cell = (StoreSearchCell *) currentObject;
				break;
			}
		}
	}
	cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_off.png")] autorelease];
	
	NSMutableDictionary* dicItem = [m_List objectAtIndex:indexPath.row];
	
	NSString* catergory = [dicItem objectForKey:@"sub_group"];
	NSString* updateDate = [dicItem objectForKey:@"service_date"];
	NSString* volume = [NSString stringWithFormat:@"%@ | %@", getStringWithCode(catergory), updateDate];
	
	[cell.m_LabelTitle setText:[dicItem objectForKey:@"title"]];
	NSString* writer = [dicItem objectForKey:@"writer"];
    NSString* painter = [dicItem objectForKey:@"painter"];
    NSMutableString* author = nil;
    if ([writer isEqualToString:painter] == YES){
        author = [NSMutableString stringWithFormat:@"글/그림 : %@", writer];
    }
    else{
        author = [NSMutableString stringWithString:@""];
        if ([writer length] > 0){
            [author appendFormat:@"글 : %@", writer];
            
            if ([painter length] > 0){
                [author appendFormat:@" / "];
            }
        }
        
        if ([painter length] > 0){
            [author appendFormat:@"그림 : %@", painter];
        }
    }
    
	[cell.m_LabelWriter setText:author];
	[cell.m_LabelVolume setText:volume];
	
	NSData* imageData = [dicItem objectForKey:@"image_data"];
	if (imageData == nil) {
		if (m_TableView.dragging == NO && m_TableView.decelerating == NO) {
			NSURL* imageUrlPath = URL_IMAGE_PATH([dicItem objectForKey:@"file_path"]);
			[self startIconImageDownload:indexPath imageUrl:imageUrlPath];
		}
	}
	else {
		[cell.m_ImageTitle setImage:[UIImage imageWithData:imageData]];
	}	
	
	NSString* contentType = (m_SearchType == SEARCH_TYPE_CARTOON) ? BI_MAIN_GROUP_TYPE_CARTOON : BI_MAIN_GROUP_TYPE_NOVEL;
	
	if ([BI_MAIN_GROUP_TYPE_CARTOON isEqualToString:contentType] == YES) {
		[cell setImageTitleBounds:ContentTypeCartoon];
	}
	else {
		[cell setImageTitleBounds:ContentTypeEpub];
	}
	
	return cell;
}

#pragma mark -
#pragma mark TableView tableDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary* content = [m_List objectAtIndex:indexPath.row];
	if (content != nil) {

		NSString* masterNumber = getStringValue([content objectForKey:@"master_no"]);		
		PlayBookContentType contentType = (m_SearchType == SEARCH_TYPE_CARTOON) ? ContentTypeCartoon : ContentTypeEpub;
		
		BookDetailViewController* bookDetailViewController = [BookDetailViewController createWithMasterNumber:masterNumber contentType:contentType subGroup:[content objectForKey:@"sub_group"]];		
		if (bookDetailViewController != nil) {		
			[self.view addSubview:bookDetailViewController.view];					
		}				
	}
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 74.0f;
}

#pragma mark -
#pragma mark IconImageDownloader operation

- (IconImageDownloader*) __existIconImageDownloader:(NSIndexPath*)indexPath
{
	for(IconImageDownloader* downloader in m_IconDownloaders) {
		if (downloader.m_IndexPath.row == indexPath.row) {
			return downloader;
		}
	}
	return nil;
}

- (void) startIconImageDownload:(NSIndexPath*)indexPath imageUrl:(NSURL*)imageUrl
{	
	IconImageDownloader* downloader = [self __existIconImageDownloader:indexPath];
	if (downloader != nil) { 		
		if ([downloader isDownloading] == NO) {
			[downloader startDownload];
		}
	}
	else {
		downloader = [IconImageDownloader createWithIndexPath:indexPath imageUrl:imageUrl delegate:self];
		if(downloader != nil) {
			[m_IconDownloaders addObject:downloader];
			[downloader startDownload];
		}
	}
}

- (void) setIconImageToVisibleCells
{
	if ([m_List count] == 0) { return; }
	
	NSArray* visiblePaths = [m_TableView indexPathsForVisibleRows];
	for(NSIndexPath* indexPath in visiblePaths) {
		NSMutableDictionary* dicItem = [m_List objectAtIndex:indexPath.row];
		if (dicItem != nil && [dicItem objectForKey:@"image_data"] == nil) {	
			NSURL* imageUrlPath = URL_IMAGE_PATH([dicItem objectForKey:@"file_path"]);
			[self startIconImageDownload:indexPath imageUrl:imageUrlPath];
		}
	}
}

- (void) iconImageDidLoad:(NSIndexPath *)indexPath iconImage:(NSData*)iconImage
{
	if ([m_IconDownloaders count] == 0 || ([m_List count] - 1) < indexPath.row) { 
		return; 
	}
	
	StoreSearchCell* cell = (StoreSearchCell*) [m_TableView cellForRowAtIndexPath:indexPath];
	if (cell != nil) {
		[cell.m_ImageTitle setImage:[UIImage imageWithData:iconImage]];
	}
	
	NSMutableDictionary* dicItem = [m_List objectAtIndex:indexPath.row];
	if (dicItem != nil) {
		[dicItem setObject:iconImage forKey:@"image_data"];
	}				
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
	
	NSString* searchWord = m_SearchTextField.text;
	NSString* contentType = (m_SearchType == SEARCH_TYPE_CARTOON) ? BI_MAIN_GROUP_TYPE_CARTOON : BI_MAIN_GROUP_TYPE_NOVEL;	
	
	if ([searchWord length] == 0) { return; }	
	NSLog(@"searchWord=[%@]", searchWord);

	NSInteger countList = [m_List count];
	if (countList > 0 && (countList % (DF_DEFAULT_LIST_COUNT *2)) == 0) {
		m_PageCount += 1;
        NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
        NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
        
        [m_Request searchListWithKeyword:searchWord pageCount:pageCount listCount:listCount mainGroup:contentType orderType:BI_ORDER_TYPE_RECENT];
	}
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
	//NSLog(@"Y=[%f], H=[%f]", scrollView.contentOffset.y + m_TableView.frame.size.height, m_TableView.contentSize.height);
	
    if (m_IsLoading == YES) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y + m_TableView.frame.size.height >= m_TableView.contentSize.height) {
            m_TableView.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_FOOTER_HEIGHT, 0);        
		}
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setIconImageToVisibleCells];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	NSLog(@"Y=[%d], H=[%d], m_IsLoading=[%d]", scrollView.contentOffset.y + m_TableView.frame.size.height, m_TableView.contentSize.height, m_IsLoading);

    if (m_IsLoading == NO) {
		m_IsDragging = NO;
		
		if (scrollView.contentOffset.y + m_TableView.frame.size.height >= m_TableView.contentSize.height + REFRESH_FOOTER_HEIGHT) {
			// Released below the footer
			[self startLoadingMore];
		}
	}
	
	if (decelerate == NO) {
        [self setIconImageToVisibleCells];
    }
}


#pragma mark -
#pragma mark UITextField notification
- (void) textFieldDidChangeNotification:(NSNotification *)notification
{
}

- (void) clickClearSearchWordButton:(id)sender
{
	m_SearchTextField.text = @"";
}


#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	m_SearchTextField.text = @"";
	m_SearchTextField.textColor = [UIColor blackColor];
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	m_bShowKeyboard = YES;
	
	NSNotificationCenter	*nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(textFieldDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	NSLog(@"search done");

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];	
	
	return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSLog(@"search done");
}

 -(void) textViewDidChange:(UITextView *)textView
{
	if(m_SearchTextField.text.length == 0){
		m_SearchTextField.textColor = [UIColor lightGrayColor];
		m_SearchTextField.text = @"검색어를 입력해 주세요";
		
		[m_SearchTextField resignFirstResponder];
	}
}

/*
 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
 {
 return YES;
 }
 
 - (BOOL)textFieldShouldClear:(UITextField *)textField
 {
 return YES;
 }
 */

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSString* searchWord = m_SearchTextField.text;
	NSString* contentType = (m_SearchType == SEARCH_TYPE_CARTOON) ? BI_MAIN_GROUP_TYPE_CARTOON : BI_MAIN_GROUP_TYPE_NOVEL;	

	if ([searchWord length] == 0) {
		return NO;
	}
	
	m_bShowKeyboard = NO;	
	[m_SearchTextField resignFirstResponder];
	
	NSLog(@"searchWord=[%@]", searchWord);
	
	m_PageCount = DE_DEFAULT_PAGE_COUNT;
	m_ListCount = (DF_DEFAULT_LIST_COUNT * 2);
	
	NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
	NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
	
	m_IsReloadOrder = YES;
	
	if (m_ActivityIndicator == nil) {
		m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:self.view orientation:UIDeviceOrientationPortrait]; 			
	}
	[m_Request searchListWithKeyword:searchWord pageCount:pageCount listCount:listCount mainGroup:contentType orderType:BI_ORDER_TYPE_RECENT];
	
	return YES;
}

- (void) setNotification
{
	NSNotificationCenter	*nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(textFieldDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void) hideKeyboard
{
	m_bShowKeyboard = NO;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[m_SearchTextField resignFirstResponder];
}

@end
