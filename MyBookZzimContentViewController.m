    //
//  MyBookZzimContentViewController.m
//  PlayBook
//
//  Created by Daniel on 12. 5. 15..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/CALayer.h>
#import "MyBookZzimContentViewController.h"
#import "MyBookGallaryViewController.h"
#import "MyBookDownloadEventCell.h"
#import "IconImageDownloader.h"
#import "BookDetailViewController.h"
#import "PBDatabase.h"
#import "UserProfile.h"


#define _NEW_PACKAGE_WINDOW
#define _MAX_DOWNLOAD_COUNT			5


@implementation MyBookZzimContentViewController

@synthesize m_List;
@synthesize m_UserNo;

@synthesize m_IconDownloaders;



+(id) createWithUserNo:(NSString*)userNo
{
	MyBookZzimContentViewController* viewController = [[MyBookZzimContentViewController alloc] initWithNibName:@"MyBookContentViewController" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {
		return nil;
	}
	viewController.m_UserNo = userNo;
	
	return viewController;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 MyBookGallaryViewController* viewController = [[MyBookGallaryViewController alloc] initWithNibName:@"MyBookGallaryViewController" bundle:[NSBundle mainBundle]];
 if (viewController == nil) {		
 return nil;
 }
 
 return viewController;
 }
 */

- (BOOL) __isExpireContent:(NSDictionary*)dicItem 
{	
	NSString* status = [dicItem objectForKey:@"status"];
	
	if([status isEqualToString:@"F"] == YES) {
		return YES;
	}	
	return NO;	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNotification:) name:NOTIFY_DATACHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNotification:) name:NOTIFY_ZZIMCHANGED object:nil];
	
	
	[self setTitleText:@"찜한 작품"];
	[self setShowEditButton:NO];
	[self setShowHeader:YES];
	[self setShowFooter:YES];
	
	m_IsChangedOrder = NO;
	m_PageCount = DE_DEFAULT_PAGE_COUNT;
	m_ListCount = DF_DEFAULT_LIST_COUNT;
	
	m_IconDownloaders = [[NSMutableArray alloc] initWithCapacity:0];
	m_List = [[NSMutableArray alloc] initWithCapacity:0];
	
	m_TableView.hidden = YES;
	m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:m_Background orientation:UIDeviceOrientationPortrait];
	
	
	NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
	NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
	
	[m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"04" delegate:self];	
	
	m_Background.frame = VIEW_RECT_RIGHT;	
	
	CALayer * layer = [m_Background layer];
	UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:m_Background.bounds];
	[layer setMasksToBounds:NO];
	[layer setShadowColor:[[UIColor blackColor] CGColor]];
	[layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
	[layer setShadowOpacity:0.4f];
	[layer setShadowRadius:50.0f];
	[layer setShadowPath:shadowPath.CGPath];
	
	[UIView animateWithDuration:VIEW_ANI_DURATION
					 animations:^{
						 m_Background.frame = VIEW_RECT_NORMAL;
					 }
					 completion:^(BOOL finished){
						 //do nothing
					 }];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[m_List release];
	[m_IconDownloaders release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark LoginChanged Notification 
- (void)onReceiveNotification:(NSNotification *) notification
{
	NSLog (@"Notification NOTIFY_ZZIMCHANGED");
	
	if ([[notification name] isEqualToString:NOTIFY_DATACHANGED] == YES) 
	{
		if ([m_UserNo isEqualToString:[UserProfile getUserNo]] == NO) {
			
			if ([m_Request isDownloading] == YES) {
				[m_Request cancelConnection];
			}
			
			if (m_ActivityIndicator != nil) {
				m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
			}
			[self.view removeFromSuperview];	
			[self release];			
		}
	}
	else if ([[notification name] isEqualToString:NOTIFY_ZZIMCHANGED] == YES) 
	{
		NSDictionary* zzimDic  = [notification userInfo];
		NSString* zzimType     = getStringValue([zzimDic objectForKey:@"zzim_type"]);
		NSString* masterNumber = getStringValue([zzimDic objectForKey:@"master_no"]);
		
		if ([zzimType isEqualToString:BI_MARK_ZZIM] == YES) {	
			// Add 			
			if ([m_List count] == 0) {
				[m_TableView setHidden:NO];
				[self setHiddenStatusError];
			}
			
			for (int index = 0; index < [m_List count]; index++) {
				NSMutableDictionary* dicItem = [m_List objectAtIndex:index];
				
				NSString* masterComp = getStringValue([dicItem objectForKey:@"master_no"]);			
				if ([masterNumber isEqualToString:masterComp] == YES) {
					[dicItem setObject:[zzimDic objectForKey:@"zzim_no"] forKey:@"no"];
					return;
				}
			}
			[m_List insertObject:[zzimDic mutableCopy] atIndex:0];
			[m_TableView reloadData];
		}
		else {
			// Remove
			NSDictionary* zzimDic  = [notification userInfo];
			NSString* zzimType     = getStringValue([zzimDic objectForKey:@"zzim_type"]);
			NSString* masterNumber = getStringValue([zzimDic objectForKey:@"master_no"]);
			
			for (int index = 0; index < [m_List count]; index++) {
				NSMutableDictionary* dicItem = [m_List objectAtIndex:index];
				
				NSString* masterComp = getStringValue([dicItem objectForKey:@"master_no"]);			
				if ([masterNumber isEqualToString:masterComp] == YES) 
				{							
					MyBookZzimContentCell*  cell = nil; 
					
					NSArray* visiblePaths = [m_TableView indexPathsForVisibleRows];
					for(NSIndexPath* indexPath in visiblePaths) {
						if (indexPath.row == index) {
							cell = (MyBookZzimContentCell*) [m_TableView cellForRowAtIndexPath:indexPath];
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
}

#pragma mark -
#pragma mark SortOrder Button Delegate

- (void) clieckBtnSortOrder:(id)sender
{
	UIActionSheet *menuPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"전체", @"만화", @"장르소설", nil];
    menuPopup.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	
    [menuPopup showInView:m_TableView];
    [menuPopup release];	
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	NSLog(@"buttonIndex=[%d]", buttonIndex);
	
	
	if (buttonIndex == 0) {		 // [All]
		m_IsChangedOrder = [super setBtnSortOrderType:SortOrderAll];
		
		if (m_IsChangedOrder == YES) {
			m_PageCount = DE_DEFAULT_PAGE_COUNT;
			m_ListCount = DF_DEFAULT_LIST_COUNT;
			
			NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
			NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
			[m_IconDownloaders removeAllObjects];
			
			[m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"04" delegate:self];				
		}
	}
	else if (buttonIndex == 1) {		
		m_IsChangedOrder = [super setBtnSortOrderType:SortOrderCartoon];
		
		if (m_IsChangedOrder == YES) {
			m_PageCount = DE_DEFAULT_PAGE_COUNT;
			m_ListCount = DF_DEFAULT_LIST_COUNT;
			
			NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
			NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
			[m_IconDownloaders removeAllObjects];
			
			[m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"04" mainGroup:BI_MAIN_GROUP_TYPE_CARTOON delegate:self];
		}
	}
	else if (buttonIndex == 2) {
		m_IsChangedOrder = [super setBtnSortOrderType:SortOrderEpub];
		
		if (m_IsChangedOrder == YES) {
			m_PageCount = DE_DEFAULT_PAGE_COUNT;
			m_ListCount = DF_DEFAULT_LIST_COUNT;
			
			NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
			NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
			[m_IconDownloaders removeAllObjects];
			
			[m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"04" mainGroup:BI_MAIN_GROUP_TYPE_NOVEL delegate:self];
		}
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
	
	m_PageCount = [m_List count] / DF_DEFAULT_LIST_COUNT;	
	if (m_PageCount == 0) {
		m_PageCount = DE_DEFAULT_PAGE_COUNT;
	}
	[self stopLoadingMore];
	
	if ([m_List count] == 0) {
		[self setStatusError:RESC_STRING_NETWORK_FAIL status:ErrorStatusMyZzim];
	}
}

- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{
	
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	NSDictionary* dicInfo = (NSDictionary *) userInfo;
	
	switch (command) {
		case DF_URL_CMD_MY_VIEW_ZZIM_LIST:
			[self stopLoadingMore];
			{
			NSString* rtCode = [dicInfo objectForKey:@"result"];
			if ([rtCode isEqualToString:@"0"] == YES) {
				NSArray* rtEntry = [dicInfo objectForKey:@"contentInfo"];
				
				if (m_IsChangedOrder == YES) {
					[m_List removeAllObjects];
				}
				m_IsChangedOrder = NO;	
				
				for(NSDictionary* dicEntry in rtEntry) {
					[m_List addObject:[dicEntry mutableCopy]];
				}				
				[m_TableView reloadData];
			}
			else {
				m_PageCount = [m_List count] / DF_DEFAULT_LIST_COUNT;	
				if (m_PageCount == 0) {
					m_PageCount = DE_DEFAULT_PAGE_COUNT;
				}
			}
				
			if ([m_List count] == 0) {
				m_TableView.hidden = YES;
				[self setStatusError:RESC_STRING_NO_RECEIVE_DATA_ZZIM status:ErrorStatusMyZzim];
			}
			else {
				m_TableView.hidden = NO;
				[self setHiddenStatusError];
			}
			}
			break;		
			
		case DF_URL_CMD_GOOD_BAD_ZZIM:
			{	
			NSString* rtCode = [dicInfo objectForKey:@"result"];
			if ([rtCode isEqualToString:@"0"] == YES) {				
				NSMutableDictionary* dicItem = [m_List objectAtIndex:m_FaveriteIndex];
				NSString* masterNumber = [dicItem objectForKey:@"master_no"];
				
				NSString* zzimNumber = [dicInfo objectForKey:@"zzim_no"];								
				[dicItem setObject:zzimNumber forKey:@"no"];
				
				NSDictionary* zzimDic = [NSDictionary dictionaryWithObjectsAndKeys:BI_MARK_ZZIM, @"zzim_type", masterNumber, @"master_no", zzimNumber, @"zzim_no", nil];  
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ZZIMCHANGED object:nil userInfo:zzimDic];
				
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
	static NSString*    CellItentifier = @"MyBookZzimContentCell";
	MyBookZzimContentCell*  cell = (MyBookZzimContentCell*) [tableView dequeueReusableCellWithIdentifier:CellItentifier];
	
	if (cell == nil) {
		NSArray* cellObjectArray = [[NSBundle mainBundle] loadNibNamed:@"MyBookZzimContentCell" owner:nil options:nil]; 
		for (id currentObject in cellObjectArray) {
			if ([currentObject isKindOfClass:[MyBookZzimContentCell class]] == true) {
				cell = (MyBookZzimContentCell *) currentObject;
				break;
			}
		}
	}
	int lastIndex = [m_List count] - 1;
	
	if (lastIndex == indexPath.row) {
		cell.backgroundView = [[[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_end_off.png")] autorelease];  
		cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_end_on.png")] autorelease];		
	}
	else{
		cell.backgroundView = [[[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_off.png")] autorelease];  
		cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_on.png")] autorelease];
	}
	
	NSMutableDictionary* dicItem = [m_List objectAtIndex:indexPath.row];
	
	NSString* catergory = [dicItem objectForKey:@"category"];
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
	
	if ([BI_MAIN_GROUP_TYPE_CARTOON isEqualToString:[dicItem objectForKey:@"main_group"]] == YES) {
		[cell setImageTitleBounds:ContentTypeCartoon];
	}
	else {
		[cell setImageTitleBounds:ContentTypeEpub];
	}
	
	NSInteger favorite = [[dicItem objectForKey:@"no"] integerValue];		
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
		NSLog(@"ContentType=[%@], masterNo=[%@]", [content objectForKey:@"main_group"], [content objectForKey:@"master_no"]);
		
		NSString* masterNumber = [[content objectForKey:@"master_no"] stringValue];
		NSString* mainGroup = [content objectForKey:@"main_group"];

		PlayBookContentType contentType = [BI_MAIN_GROUP_TYPE_CARTOON isEqualToString:mainGroup] == YES ? ContentTypeCartoon : ContentTypeEpub;
		
		BookDetailViewController* bookDetailViewController = [BookDetailViewController createWithMasterNumber:masterNumber contentType:contentType subGroup:[content objectForKey:@"sub_group"]];		
		if (bookDetailViewController != nil) {		
			[self.view addSubview:bookDetailViewController.view];					
		}
	}
	
	//	NSLog(@"%@", dicItem);	
}

#pragma mark -
#pragma mark PullToReloadTableController delegate
- (void) loadMore 
{
	if (([m_List count] % DF_DEFAULT_LIST_COUNT) != 0) {
		[self stopLoadingMore];	return;
	}
	
	m_PageCount += 1;
	
	NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
	NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
	
	NSLog(@"call delegate... m_ListCount=[%d]", m_ListCount);
	
//	[m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"04" delegate:self];
    if (m_RecentSortOrder == SortOrderAll){
        [m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"04" delegate:self];
    }
    else{
        [m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"04"
                                  mainGroup:m_RecentSortOrder == SortOrderCartoon ? BI_MAIN_GROUP_TYPE_CARTOON : BI_MAIN_GROUP_TYPE_NOVEL
                                   delegate:self];
    }
}



#pragma mark -
#pragma mark request MyBookDownload delegate

- (void) requestMyBookDownload:(id)sender itemIndex:(NSInteger)index
{
	NSLog(@"Request Download, itemIndex=[%d]", index);
}


- (void) clickBtnClose:(id)sender
{
	if ([m_Request isDownloading] == YES) {
		[m_Request cancelConnection];
	}
	
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	[UIView animateWithDuration:VIEW_ANI_DURATION
					 animations:^{
						 self.view.frame = VIEW_RECT_RIGHT;
					 }
					 completion:^(BOOL finished){
						 [self.view removeFromSuperview];	
						 [self release];	
					 }];
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
	NSLog(@"");
	
	if ([m_IconDownloaders count] == 0 || ([m_List count] - 1) < indexPath.row) { 
		return; 
	}
	
	NSMutableDictionary* dicItem = [m_List objectAtIndex:indexPath.row];
	if (dicItem != nil) {
		[dicItem setObject:iconImage forKey:@"image_data"];
	}
	
	UITableViewCell* cell = [m_TableView cellForRowAtIndexPath:indexPath];
	if (cell != nil && [cell isKindOfClass:[MyBookZzimContentCell class]] == YES) {
		[((MyBookZzimContentCell*)cell).m_ImageTitle setImage:[UIImage imageWithData:iconImage]];
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

- (void) requestMyBookStream:(id)sender itemIndex:(NSInteger)index
{
	
}


#pragma mark -
#pragma mark Favorite Selected Delegate

- (void) zzimFavoriteSelected:(id)sender index:(NSInteger)index
{
	NSLog(@"index=[%d]", index);
	
	m_FaveriteIndex = index;
	
	NSMutableDictionary* dicItem = [m_List objectAtIndex:index];
	if (dicItem != nil) {
		UIButton* btnFavorite = (UIButton*) sender;
		
		NSInteger favorite = [[dicItem objectForKey:@"no"] integerValue];
		if (favorite == -1) {
			NSString* masterNumber = getStringValue([dicItem objectForKey:@"master_no"]);
			
			[btnFavorite setImage:RESOURCE_IMAGE(@"list_btn_favorit_on.png") forState:UIControlStateNormal];
			[m_Request goodBadZzimWithMasterNo:masterNumber userNo:[UserProfile getUserNo] eventType:BI_MARK_ZZIM];			
		}
		else {
			NSString* zzimNumber = getStringValue([dicItem objectForKey:@"no"]);
			
			[btnFavorite setImage:RESOURCE_IMAGE(@"list_btn_favorit_off.png") forState:UIControlStateNormal];			
			[m_Request myViewZzimDeleteWithNoList:zzimNumber myType:BI_UNMARK_ZZIM userNo:[UserProfile getUserNo]];
			
			[dicItem setObject:[NSNumber numberWithInteger:-1] forKey:@"no"];			
		}
	}
}


@end
