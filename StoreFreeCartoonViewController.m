//
//  StoreFreeCartoonViewerController.m
//  PlayBook
//
//  Created by Daniel on 12. 3. 8..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreFreeCartoonViewController.h"
#import "StoreFreeListCell.h"
#import "UserProfile.h"

@implementation StoreFreeCartoonViewController

@synthesize m_Request;
@synthesize m_List;

@synthesize m_IconDownloaders;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNotification:) name:NOTIFY_ZZIMCHANGED object:nil];
	
	[self setShowHeader:YES];
	[self setShowSearchButton:NO];
	[self setShowFooter:YES];
	
	m_IsChangedOrder = NO;
	
	m_PageCount = DE_DEFAULT_PAGE_COUNT;
	m_ListCount = DF_DEFAULT_LIST_COUNT;
	
	m_Request = [[PlayBookRequest alloc] initWithDelegate:self];	
	m_List = (NSMutableArray*) [[NSMutableArray alloc] initWithCapacity:0];

	
	m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:APPDELEGATE.m_StoreFreeNavController.view orientation:UIDeviceOrientationPortrait];
	[m_TableView setHidden:YES];

	NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
	NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
	
	if ([UserProfile getLoginState] == YES) {
		[m_Request contentListWithMenuType:BI_MENU_TYPE_FREE mainGroup:BI_MAIN_GROUP_TYPE_CARTOON pageCount:pageCount listCount:listCount orderType:BI_ORDER_TYPE_RECENT viewType:BI_VIEW_TYPE_LIST userNo:[UserProfile getUserNo]];
	}
	else {
		[m_Request contentListWithMenuType:BI_MENU_TYPE_FREE mainGroup:BI_MAIN_GROUP_TYPE_CARTOON pageCount:pageCount listCount:listCount orderType:BI_ORDER_TYPE_RECENT viewType:BI_VIEW_TYPE_LIST];
	}
	
	m_IconDownloaders = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSLog(@"");
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[m_IconDownloaders release];
	
	[m_Request release];
	[m_List release];
	
    [super dealloc];	
}

- (BOOL)requestReloadData:(id)sender;
{
	if (m_IsDataChanged == YES) 
	{
		NSLog(@"This is Sub... isChanged=[YES]");
        
        int iPageCount = m_PageCount;
        int iListCount = m_ListCount;
        
        if (iPageCount > 1){
            iListCount = iPageCount * iListCount;
            iPageCount = 1;
        }
		NSString* pageCount = [[NSNumber numberWithInteger:iPageCount]stringValue];
        NSString* listCount = [[NSNumber numberWithInteger:iListCount]stringValue];
        
		//NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
		//NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
        
		if (m_ActivityIndicator == nil) {
			m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:((UIViewController*)sender).view orientation:UIDeviceOrientationPortrait];
		}
		
		if ([m_List count] ==  0) {
			[m_TableView setHidden:YES];
		}
		
		m_IsChangedOrder = YES;	
		
		NSString* orderType = m_IsRecentOrder ? BI_ORDER_TYPE_RECENT : BI_ORDER_TYPE_POPULARITY;
		if ([UserProfile getLoginState] == YES) {
			[m_Request contentListWithMenuType:BI_MENU_TYPE_FREE mainGroup:BI_MAIN_GROUP_TYPE_CARTOON pageCount:pageCount listCount:listCount orderType:orderType viewType:BI_VIEW_TYPE_LIST userNo:[UserProfile getUserNo]];
		}
		else {
			[m_Request contentListWithMenuType:BI_MENU_TYPE_FREE mainGroup:BI_MAIN_GROUP_TYPE_CARTOON pageCount:pageCount listCount:listCount orderType:orderType viewType:BI_VIEW_TYPE_LIST];
		}
		m_IsDataChanged = NO;
	}
	
	return YES;
}

#pragma mark -
#pragma mark LoginChanged Notification 
- (void)onReceiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:NOTIFY_ZZIMCHANGED] == YES) {
		NSLog (@"Notification NOTIFY_ZZIMCHANGED");
		
		NSDictionary* zzimDic  = [notification userInfo];
		NSString* zzimType     = getStringValue([zzimDic objectForKey:@"zzim_type"]);
		NSString* masterNumber = getStringValue([zzimDic objectForKey:@"master_no"]);
		
		for (int index = 0; index < [m_List count]; index++) {
			NSMutableDictionary* dicItem = [m_List objectAtIndex:index];
			
			NSString* masterComp = getStringValue([dicItem objectForKey:@"master_no"]);			
			if ([masterNumber isEqualToString:masterComp] == YES) 
			{							
				StoreFreeListCell*  cell = nil; 
				
				NSArray* visiblePaths = [m_TableView indexPathsForVisibleRows];
				for(NSIndexPath* indexPath in visiblePaths) {
					if (indexPath.row == index) {
						cell = (StoreFreeListCell*) [m_TableView cellForRowAtIndexPath:indexPath];
						break;
					}
				}
				
				if ([zzimType isEqualToString:BI_MARK_ZZIM] == YES) {					
					[dicItem setObject:[zzimDic objectForKey:@"zzim_no"] forKey:@"zzim_no"];					
					if (cell != nil) {
						[cell.m_BtnFavorite setImage:RESOURCE_IMAGE(@"list_btn_favorit_on.png") forState:UIControlStateNormal];
					}
				}
				else {
					[dicItem setObject:[NSNumber numberWithInt:-1] forKey:@"zzim_no"];					
					if (cell != nil) {
						[cell.m_BtnFavorite setImage:RESOURCE_IMAGE(@"list_btn_favorit_off.png") forState:UIControlStateNormal];	
					}
				}		
				break;
			}
		}				
	}
}

#pragma mark -
#pragma mark SortOrder Button Delegate

- (void) clieckBtnSortOrder:(id)sender
{
	UIActionSheet *menuPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"최신순", @"인기순", nil];
    menuPopup.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	
    [menuPopup showInView:m_TableView];
    [menuPopup release];	
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	NSLog(@"buttonIndex=[%d]", buttonIndex);
		
	if (buttonIndex == 0) {		 // [Recent Order]
		m_IsChangedOrder = [super setBtnSortOrderType:YES];
		
		if (m_IsChangedOrder == YES) {
			m_PageCount = DE_DEFAULT_PAGE_COUNT;
			m_ListCount = DF_DEFAULT_LIST_COUNT;
			
			NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
			NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
			[m_IconDownloaders removeAllObjects];
			
			if ([UserProfile getLoginState] == YES) {
				[m_Request contentListWithMenuType:BI_MENU_TYPE_FREE mainGroup:BI_MAIN_GROUP_TYPE_CARTOON pageCount:pageCount listCount:listCount orderType:BI_ORDER_TYPE_RECENT viewType:BI_VIEW_TYPE_LIST userNo:[UserProfile getUserNo]];
			}
			else {
				[m_Request contentListWithMenuType:BI_MENU_TYPE_FREE mainGroup:BI_MAIN_GROUP_TYPE_CARTOON pageCount:pageCount listCount:listCount orderType:BI_ORDER_TYPE_RECENT viewType:BI_VIEW_TYPE_LIST];	
			}
		}
	}
	else if (buttonIndex == 1) {		
		m_IsChangedOrder = [super setBtnSortOrderType:NO];
		
		if (m_IsChangedOrder == YES) {
			m_PageCount = DE_DEFAULT_PAGE_COUNT;
			m_ListCount = DF_DEFAULT_LIST_COUNT;
			
			NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
			NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
			[m_IconDownloaders removeAllObjects];
			
			if ([UserProfile getLoginState] == YES) {
				[m_Request contentListWithMenuType:BI_MENU_TYPE_FREE mainGroup:BI_MAIN_GROUP_TYPE_CARTOON pageCount:pageCount listCount:listCount orderType:BI_ORDER_TYPE_POPULARITY viewType:BI_VIEW_TYPE_LIST userNo:[UserProfile getUserNo]];
			}
			else {
				[m_Request contentListWithMenuType:BI_MENU_TYPE_FREE mainGroup:BI_MAIN_GROUP_TYPE_CARTOON pageCount:pageCount listCount:listCount orderType:BI_ORDER_TYPE_POPULARITY viewType:BI_VIEW_TYPE_LIST];	
			}
		}
	}
	else if (buttonIndex == 2) {
	}	
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
	NSLog(@"%@", error);
	
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	if (command == DF_URL_CMD_CONTENT_LIST && [m_List count] == 0) {
		m_IsDataChanged = YES;
	}
	
	m_PageCount = [m_List count] / DF_DEFAULT_LIST_COUNT;
	if (m_PageCount == 0) {
		m_PageCount = DE_DEFAULT_PAGE_COUNT;
	}
	[self stopLoadingMore];
	
	if ([m_List count] == 0) {
		[self setStatusError:RESC_STRING_NETWORK_FAIL status:ErrorStatusEtc];		
	}
}

- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{
	NSDictionary* dicInfo = (NSDictionary *) userInfo;
	
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	switch (command) {
		case DF_URL_CMD_CONTENT_LIST:
			[self stopLoadingMore];
			{
			NSString* rtCode = [dicInfo objectForKey:@"result"];
			if ([rtCode isEqualToString:@"0"] == YES) {
				NSLog(@"menu_type: %@", [dicInfo objectForKey:@"menu_type"]);				
				NSArray *contents = [dicInfo objectForKey:@"contentInfo"];
				
				if(contents != nil) {

					if (m_IsChangedOrder == YES) {
						[m_IconDownloaders removeAllObjects];
						[m_List removeAllObjects];						
					}
					m_IsChangedOrder = NO;	
					
					for(NSDictionary* dic in contents) {
						[m_List addObject:[dic mutableCopy]];
					}					
				}					
			}
			else {
				m_PageCount = [m_List count] / DF_DEFAULT_LIST_COUNT;
				if (m_PageCount == 0) {
					m_PageCount = DE_DEFAULT_PAGE_COUNT;
				}
			}
				
			if ([m_List count] == 0) {
				[m_TableView setHidden:YES];
				[self setStatusError:RESC_STRING_NO_RECEIVE_DATA status:ErrorStatusEtc];					
				
				m_IsDataChanged = YES;
			}
			else {
				[self setHiddenStatusError];
				
				[m_TableView setHidden:NO];
				[m_TableView reloadData];
			}			
			}
			break;
			
		case DF_URL_CMD_GOOD_BAD_ZZIM:
			{
			NSString* rtCode = [dicInfo objectForKey:@"result"];
			if ([rtCode isEqualToString:@"0"] == YES) {		
				NSMutableDictionary* zzimDic = [m_List objectAtIndex:m_FaveriteIndex];
				if (zzimDic != nil) {

					NSString* zzimNumber = [dicInfo objectForKey:@"zzim_no"];
					[zzimDic setObject:BI_MARK_ZZIM forKey:@"zzim_type"];
					[zzimDic setObject:zzimNumber forKey:@"zzim_no"];
					[zzimDic setObject:BI_MAIN_GROUP_TYPE_CARTOON forKey:@"main_group"];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ZZIMCHANGED object:nil userInfo:zzimDic];
				}
				
				showZzimAnimation();
			}
			}
			break;
			
		case DF_URL_CMD_MY_VIEW_ZZIM_DELETE:
			{
			NSString* rtCode = [dicInfo objectForKey:@"result"];
			if ([rtCode isEqualToString:@"0"] == YES) {				
				NSString* myType = getStringValue([dicInfo objectForKey:@"my_type"]);
				if (myType != nil && [myType isEqualToString:BI_UNMARK_ZZIM] == YES) {
					NSDictionary* dicItem = [m_List objectAtIndex:m_FaveriteIndex];
					NSString* masterNumber = [dicItem objectForKey:@"master_no"];
					
					NSDictionary* zzimDic = [NSDictionary dictionaryWithObjectsAndKeys:BI_UNMARK_ZZIM, @"zzim_type", masterNumber, @"master_no", nil]; 
					[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ZZIMCHANGED object:nil userInfo:zzimDic];
				}
			}					
			}
			break;
	}
}


#pragma mark -
#pragma mark Table view data source

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
	static NSString*    CellItentifier = @"StoreFreeListCell";
	StoreFreeListCell*  cell = (StoreFreeListCell*) [tableView dequeueReusableCellWithIdentifier:CellItentifier];
	
	if (cell == nil) {
		NSArray* cellObjectArray = [[NSBundle mainBundle] loadNibNamed:@"StoreFreeListCellCartoon" owner:nil options:nil]; 
		for (id currentObject in cellObjectArray) {
			if ([currentObject isKindOfClass:[StoreFreeListCell class]] == true) {
				cell = (StoreFreeListCell *) currentObject;
				break;
			}
		}
	}	
	
	int lastIndex = [m_List count] - 1;
	
	if (lastIndex == indexPath.row) {
		cell.backgroundView = [[[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_end_off.png")] autorelease];  
		cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_end_on.png")] autorelease];		
	}
	else {
		cell.backgroundView = [[[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_off.png")] autorelease];  
		cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_on.png")] autorelease];		
	}

	NSMutableDictionary* dicItem = [m_List objectAtIndex:indexPath.row];
	
	//[dicItem objectForKey:@"complete_yn"]
	
	
	NSString* catergory = [dicItem objectForKey:@"category"];
	NSString* volume = [NSString stringWithFormat:@"%@ | %@권 무료", getStringWithCode(catergory), [dicItem objectForKey:@"free_count"]];
	
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

	NSInteger favorite = [[dicItem objectForKey:@"zzim_no"] integerValue];		
	if (favorite == -1) {
		[cell.m_BtnFavorite setImage:RESOURCE_IMAGE(@"list_btn_favorit_off.png") forState:UIControlStateNormal];
	}
	else {
		[cell.m_BtnFavorite setImage:RESOURCE_IMAGE(@"list_btn_favorit_on.png") forState:UIControlStateNormal];	
	}
	cell.m_BtnFavorite.tag = indexPath.row;	
	cell.m_Delegate = self;

	return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int lastIndex = [m_List count] - 1;
	
	if (lastIndex == indexPath.row) {
		return 77.0f;
	}
	return 74.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	NSDictionary* content = [m_List objectAtIndex:indexPath.row];
	if (content != nil) {
		NSLog(@"ContentType=[%@], masterNo=[%@] sub_group=[%@]", [content objectForKey:@"main_group"], [content objectForKey:@"master_no"], [content objectForKey:@"sub_group"]);
		
		NSString* masterNumber = [[content objectForKey:@"master_no"] stringValue];
		
		BookDetailViewController* bookDetailViewController = [BookDetailViewController createWithMasterNumber:masterNumber contentType:ContentTypeCartoon subGroup:[content objectForKey:@"sub_group"]];		
		if (bookDetailViewController != nil) {		
			[APPDELEGATE.m_StoreFreeNavController.view addSubview:bookDetailViewController.view];					
		}		
	}	
}

#pragma mark -
#pragma mark PullToReloadTableController delegate
- (void) loadMore 
{
	if (([m_List count] % DF_DEFAULT_LIST_COUNT) != 0) {
		[self stopLoadingMore]; return;
	}
	
	m_PageCount += 1;
	
	NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
	NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
	NSString* ordetType = (m_IsRecentOrder == YES ? BI_ORDER_TYPE_RECENT : BI_ORDER_TYPE_POPULARITY);
	
	NSLog(@"call delegate... m_ListCount=[%d]", m_ListCount);
	
	if ([UserProfile getLoginState] == YES) {
		[m_Request contentListWithMenuType:BI_MENU_TYPE_FREE mainGroup:BI_MAIN_GROUP_TYPE_CARTOON pageCount:pageCount listCount:listCount orderType:ordetType viewType:BI_VIEW_TYPE_LIST userNo:[UserProfile getUserNo]];
	}
	else {
		[m_Request contentListWithMenuType:BI_MENU_TYPE_FREE mainGroup:BI_MAIN_GROUP_TYPE_CARTOON pageCount:pageCount listCount:listCount orderType:ordetType viewType:BI_VIEW_TYPE_LIST];
	}
}

#pragma mark -
#pragma mark Title Click Delegate

-(void) moveTitleClick:(id)sender direction:(NSInteger)direction
{
}

-(void) orderTitleClick:(id)sender
{
}

#pragma mark -
#pragma mark Favorite Selected Delegate

- (void) storeFreeFavoriteSelected:(id)sender index:(NSInteger)index
{
	NSLog(@"index=[%d]", index);
	
	if ([UserProfile getLoginState] == NO) {
		UIAlertView	*pAlertView;
		
		pAlertView = [[UIAlertView alloc] initWithTitle:@"로그인이 필요한 서비스" message:@"로그인 하시겠습니까?" delegate:self cancelButtonTitle:@"예" otherButtonTitles:@"아니오", nil];
		[pAlertView show];
		
		[pAlertView release];
		return;
	}
	m_FaveriteIndex = index;
	
	
	NSMutableDictionary* dicItem = [m_List objectAtIndex:index];
	if (dicItem != nil) {
		UIButton* btnFavorite = (UIButton*) sender;

		NSInteger favorite = [[dicItem objectForKey:@"zzim_no"] integerValue];
		if (favorite == -1) {
			NSString* masterNumber = getStringValue([dicItem objectForKey:@"master_no"]);
			
			[btnFavorite setImage:RESOURCE_IMAGE(@"list_btn_favorit_on.png") forState:UIControlStateNormal];
			[m_Request goodBadZzimWithMasterNo:masterNumber userNo:[UserProfile getUserNo] eventType:BI_MARK_ZZIM];			
		}
		else {
			NSString* zzimNumber = getStringValue([dicItem objectForKey:@"zzim_no"]);
			
			[btnFavorite setImage:RESOURCE_IMAGE(@"list_btn_favorit_off.png") forState:UIControlStateNormal];			
			[m_Request myViewZzimDeleteWithNoList:zzimNumber myType:BI_UNMARK_ZZIM userNo:[UserProfile getUserNo]];
			
			[dicItem setObject:[NSNumber numberWithInteger:-1] forKey:@"zzim_no"];			
		}
	}
}

#pragma mark -
#pragma mark MessageBox Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"buttonIndex=[%d]", buttonIndex);
	if (buttonIndex == 0) {
		[APPDELEGATE createLoginViewController];
	}
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
	
	StoreFreeListCell* cell = (StoreFreeListCell*) [m_TableView cellForRowAtIndexPath:indexPath];
	if (cell != nil) {
		[cell.m_ImageTitle setImage:[UIImage imageWithData:iconImage]];
	}
	
	NSMutableDictionary* dicItem = [m_List objectAtIndex:indexPath.row];
	if (dicItem != nil) {
		[dicItem setObject:iconImage forKey:@"image_data"];
	}
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];	
    if (decelerate == NO) {
        [self setIconImageToVisibleCells];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setIconImageToVisibleCells];
}


@end