    //
//  MyBookReadContentViewController.m
//  PlayBook
//
//  Created by Daniel on 12. 5. 11..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/CALayer.h>
#import "BookDetailViewController.h"
#import "MyBookReadContentViewController.h"
#import "MyBookGallaryViewController.h"
#import "MyBookDownloadEventCell.h"
#import "IconImageDownloader.h"
#import "PBDatabase.h"
#import "UserProfile.h"



#define _MAX_DOWNLOAD_COUNT			5

#define __LABEL_VOLUME_Y			20.0f
#define __LABEL_PAGE_Y				33.0f
#define __LABEL_VOLUME_SINGLE_Y		26.0f
	

@implementation MyBookReadContentViewController


@synthesize m_List;
@synthesize m_CheckedList;
@synthesize m_UserNo;

@synthesize m_IconDownloaders;


+(id) createWithUserNo:(NSString*)userNo
{
	MyBookReadContentViewController* viewController = [[MyBookReadContentViewController alloc] initWithNibName:@"MyBookContentViewController" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {
		return nil;
	}
	viewController.m_UserNo = userNo;
	
	return viewController;
}



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
	
	[self setTitleText:@"내가 본 작품"];
	[self setShowEditButton:YES];
	[self setShowHeader:YES];
	[self setShowFooter:YES];
	
	m_IsChangedOrder = NO;
	m_IsEditMode = NO;
	m_PageCount = DE_DEFAULT_PAGE_COUNT;
	m_ListCount = DF_DEFAULT_LIST_COUNT;
	
	m_IconDownloaders = [[NSMutableArray alloc] initWithCapacity:0];
	m_List = [[NSMutableArray alloc] initWithCapacity:0];
	m_CheckedList = [[NSMutableArray alloc] initWithCapacity:0];

	m_TableView.hidden = YES;
	m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:m_Background orientation:UIDeviceOrientationPortrait];
	
	NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
	NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
	
	[m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"03" delegate:self];
	
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
    
	NSLog(@"Low Memory !!!!!!");
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
	
	if (m_IsEditMode = YES) {
		[APPDELEGATE.m_SwitchViewController hidesTabBar:NO animated:YES];
	}
	
	[m_List release];
	[m_IconDownloaders release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark LoginChanged Notification 
- (void)onReceiveNotification:(NSNotification *) notification
{
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
			
			[m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"03" delegate:self];
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
			
			[m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"03" mainGroup:BI_MAIN_GROUP_TYPE_CARTOON delegate:self];
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

			[m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"03" mainGroup:BI_MAIN_GROUP_TYPE_NOVEL delegate:self];
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
		[self setStatusError:RESC_STRING_NETWORK_FAIL status:ErrorStatusMyRead];
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
				[self setStatusError:RESC_STRING_NO_RECEIVE_DATA_READ status:ErrorStatusMyRead];
			}	
			else {
				m_TableView.hidden = NO;
				[self setHiddenStatusError];
			}
			}
			break;		
			
		case DF_URL_CMD_MY_VIEW_ZZIM_DELETE:
			break;
			
		case DF_URL_CMD_BUY_DETAIL:
			{
			NSMutableDictionary* dicItem = [m_List objectAtIndex:m_SelectedItemIndex];						
			
			NSString* rtCode = [dicInfo objectForKey:@"result"];
			if ([rtCode isEqualToString:@"0"] == YES) {				
				NSArray* rtEntry = [dicInfo objectForKey:@"contentInfo"];
				
				int startIndex = m_SelectedItemIndex + 1;
				int itemCount = [rtEntry count];
				
				NSMutableArray* package = [[NSMutableArray alloc] initWithCapacity:0];
				for (int itemIndex = 0; itemIndex < itemCount; itemIndex++) {
					NSMutableDictionary* dicEntry = [[rtEntry objectAtIndex:itemIndex] mutableCopy];
					
					[package addObject:dicEntry];
					[m_List insertObject:dicEntry atIndex:(NSInteger) (startIndex + itemIndex)];
				}
				[dicItem setObject:package forKey:@"package"];
				
				[m_TableView reloadData];
			}		
			}
			break;
			
		case DF_URL_CMD_CHECK_BUY:
			{
			NSInteger rtCode = [[dicInfo objectForKey:@"result_code"] intValue];	

			if(rtCode == 0) {
				NSDictionary* dicData   = [dicInfo objectForKey:@"data"];
				NSDictionary* dicResult = [dicData objectForKey:@"result"];
				
				BOOL bExbuy_yn = [[dicResult objectForKey:@"exbuy_yn"] isEqualToString:@"Y"];
				NSInteger exbuy_type = [[dicResult objectForKey:@"exbuy_type"] intValue];
				
				//exbuy_yn Y이고 0(마스터유저), 1(스트리밍무료), 3(맛보기상품)인 경우 보인다.
				if (bExbuy_yn && ((exbuy_type == 0) || (exbuy_type == 1) || (exbuy_type == 3) || (exbuy_type == 100))) 
				{					
					NSArray *playyArray = [dicInfo objectForKey:@"playy_info"];
					for (NSDictionary *playyDictionary in playyArray)
					{
						NSArray *fileinfoArray = [playyDictionary objectForKey:@"file_info"];					
						for (NSDictionary *fileDictionary in fileinfoArray)
						{
							NSDictionary* dicItem = [m_List objectAtIndex:m_SelectedItemIndex];
							
							NSString* titleContent   = [dicItem objectForKey:@"title"];
							NSString* masterNumber	 = getStringValue([dicItem objectForKey:@"master_no"]);
							NSString* fileNumber	 = getStringValue([dicItem objectForKey:@"file_no"]);
							NSString* contentType    = [dicInfo objectForKey:@"content_type"];
							NSString* preDRM		 = [dicInfo objectForKey:@"pre_drm"];
							NSString* filePath       = [fileDictionary valueForKey:@"file_path"];
							NSString* bookNumber	 = getStringValue([fileDictionary valueForKey:@"book_no"]);
							
							NSMutableDictionary* content = [[NSMutableDictionary alloc] initWithCapacity:0];
							[content setObject:titleContent forKey:@"title"];
							[content setObject:fileNumber forKey:@"file_no"];
							[content setObject:contentType forKey:@"content_type"];
							[content setObject:preDRM forKey:@"pre_drm"];
							[content setObject:filePath forKey:@"file_path_remote"];
							[content setObject:masterNumber forKey:@"master_no"];
							[content setObject:bookNumber forKey:@"book_no"];
							
							if (exbuy_type == 3)
								[content setObject:getStringValue([dicResult valueForKey:@"sample_count"]) forKey:@"sample_count"];
							else {
								[content setObject:@"0" forKey:@"sample_count"];
							}

							NSString* mainGroup = [dicItem objectForKey:@"main_group"];
							 
							if ([BI_MAIN_GROUP_TYPE_CARTOON isEqualToString:mainGroup] == YES) {
								CartoonViewController* cartoonViewController = [CartoonViewController createWithContentsStreaming:content];
								if (cartoonViewController != nil)
								{
									[APPDELEGATE.m_Window addSubview:cartoonViewController.view];								
								}
							}
							else {
								EpubViewController* epubViewController = [EpubViewController createWithContentsStreaming:content];
								if (epubViewController != nil)
								{
									[APPDELEGATE.m_Window addSubview:epubViewController.view];
								}				
							}
						}
						return;
					}
				}
				else {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"안내" 
																		message:RESC_STRING_NO_AUTHORITY 
																	   delegate:nil cancelButtonTitle:@"확인" 
															  otherButtonTitles:nil];
					[alertView show];
					[alertView release];
				}
				NSLog(@"[DF_URL_CMD_CHECK_BUY] playyArray is not one or nil !!!");				
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
	static NSString*    CellItentifier = @"MyBookReadContentCell";
	
	NSMutableDictionary* dicItem = [m_List objectAtIndex:indexPath.row];
	
	BOOL isExpired = [self __isExpireContent:dicItem];	
	MyBookReadContentCell* cell = (MyBookReadContentCell*) [tableView dequeueReusableCellWithIdentifier:CellItentifier];
	
	if (m_IsEditMode == NO) {		
		if (cell == nil) {
			NSArray* cellObjectArray = [[NSBundle mainBundle] loadNibNamed:@"MyBookReadContentCell" owner:nil options:nil]; 
			for (id currentObject in cellObjectArray) {
				if ([currentObject isKindOfClass:[MyBookReadContentCell class]] == true) {
					cell = (MyBookReadContentCell*) currentObject;
					break;
				}
			}
		}				
	}
	else {
		if (cell == nil) {
			NSArray* cellObjectArray = [[NSBundle mainBundle] loadNibNamed:@"MyBookReadContentEditCell" owner:nil options:nil]; 
			for (id currentObject in cellObjectArray) {
				if ([currentObject isKindOfClass:[MyBookReadContentCell class]] == true) {
					cell = (MyBookReadContentCell*) currentObject;
					break;
				}
			}
		}

		NSNumber* numIndex = [NSNumber numberWithInt:indexPath.row]; 
		if ([m_CheckedList containsObject:numIndex] == YES) {
			[cell.m_ImageSelect setImage:RESOURCE_IMAGE(@"IsSelected.png")];			
		}
		else {
			[cell.m_ImageSelect setImage:RESOURCE_IMAGE(@"NotSelected.png")];
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

	[cell.m_Title setText:[dicItem objectForKey:@"title"]];
	//[cell.m_Writer setText:[dicItem objectForKey:@"writer"]];
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
    
    [cell.m_Writer setText:author];

	if ([BI_MAIN_GROUP_TYPE_CARTOON isEqualToString:[dicItem objectForKey:@"main_group"]] == YES) {
		[cell.m_LabVolume setText:[NSString stringWithFormat:@"%@권", getStringValue([dicItem objectForKey:@"last_file"])]];
		[cell setBtnPages:indexPath.row pages:[NSString stringWithFormat:@"P%@", getStringValue([dicItem objectForKey:@"replay_no"])]];
		[cell setImageTitleBounds:ContentTypeCartoon isEidtMode:m_IsEditMode];		
		
		CGRect rectPage = cell.m_LabPages.frame;
		rectPage.origin.y = __LABEL_PAGE_Y;
		[cell.m_LabPages setFrame:rectPage];
		
		CGRect rectVolm = cell.m_LabVolume.frame;
		rectVolm.origin.y = __LABEL_VOLUME_Y;
		[cell.m_LabVolume setFrame:rectVolm];
		
		if (m_IsEditMode == NO) {
			[cell.m_LabPages setHidden:NO];
			[cell.m_LabVolume setHidden:NO];
		}
		else {
			[cell.m_LabPages setHidden:YES];			
			[cell.m_LabVolume setHidden:YES];		
		}
	}
	else {
		[cell.m_LabVolume setText:[NSString stringWithFormat:@"%@권", getStringValue([dicItem objectForKey:@"last_file"])]];
		[cell setBtnPages:indexPath.row pages:[NSString stringWithFormat:@"P%@", getStringValue([dicItem objectForKey:@"replay_no"])]];
		[cell setImageTitleBounds:ContentTypeEpub isEidtMode:m_IsEditMode];				
		
		CGRect rectVolm = cell.m_LabVolume.frame;
		rectVolm.origin.y = __LABEL_VOLUME_SINGLE_Y;
		[cell.m_LabVolume setFrame:rectVolm];

		if (m_IsEditMode == NO) {
			[cell.m_LabPages setHidden:YES];			
			[cell.m_LabVolume setHidden:NO];			
		}
		else {
			[cell.m_LabPages setHidden:YES];			
			[cell.m_LabVolume setHidden:YES];		
		}
	}

	
	cell.m_Delegate = self;
	
	NSData* imageData = [dicItem objectForKey:@"title_image"];
	if (imageData == nil) {
		if (m_TableView.dragging == NO && m_TableView.decelerating == NO) {
			NSURL* imageUrlPath = URL_IMAGE_PATH([dicItem objectForKey:@"file_path"]);
			[self startIconImageDownload:indexPath imageUrl:imageUrlPath];
		}
	}
	else {
		[cell.m_ImageTitle setImage:[UIImage imageWithData:imageData]];
	}	

	{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy.MM.dd"];

	NSDate* lastDate = [dateFormatter dateFromString:getStringValue([dicItem objectForKey:@"last_date"])];
	[dateFormatter release];

	NSInteger dayDiff = fabsf((int)[lastDate timeIntervalSinceNow] / (60*60*24));
	
	NSString *strText = nil;
	
	if (dayDiff == 0){
		strText = @"오늘 읽음";
	}
	else if (dayDiff > 0 && dayDiff < 100){
		strText = [NSString stringWithFormat:@"%d일 전에 읽음", dayDiff];
	}
	else {
		strText = @"오래전에 읽음";
	}
	
	[cell.m_StatusLabel setText:strText];
	}
	
	return cell;	
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int lastIndex = [m_List count] - 1;
	if (lastIndex == indexPath.row) {
		return 80.0f;
	}
	return 74.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (m_IsEditMode == NO) { return; }

	MyBookReadContentCell* editCell = (MyBookReadContentCell*) [m_TableView cellForRowAtIndexPath:indexPath];	
	m_SelectedItemIndex = indexPath.row;
	
	NSNumber* numIndex = [NSNumber numberWithInt:m_SelectedItemIndex]; 
	if ([m_CheckedList containsObject:numIndex] == YES) {
		[m_CheckedList removeObject:numIndex];
		
		if (editCell != nil) {
			[editCell.m_ImageSelect setImage:RESOURCE_IMAGE(@"NotSelected.png")];
		}
	}
	else {
		[m_CheckedList addObject:numIndex];
		if (editCell != nil) {
			[editCell.m_ImageSelect setImage:RESOURCE_IMAGE(@"IsSelected.png")];
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
	
//	[m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"03" delegate:self];
    if (m_RecentSortOrder == SortOrderAll){
        [m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"03" delegate:self];
    }
    else{
        [m_Request myViewZzimListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:@"03"
                                   mainGroup:m_RecentSortOrder == SortOrderCartoon ? BI_MAIN_GROUP_TYPE_CARTOON : BI_MAIN_GROUP_TYPE_NOVEL
                                   delegate:self];
    }
}

#pragma mark -
#pragma mark request MyBookReadContent delegate

- (void) requestMyBookReadContent:(id)sender readType:(ContentReadType)readType itemIndex:(NSInteger)index;
{
	m_SelectedItemIndex = index;
	
	NSMutableDictionary* content = [m_List objectAtIndex:m_SelectedItemIndex];	
	if (content == nil) { return; }
	
	if (readType == ContentReadViewer) {	
		NetworkUseType networkUseType = [self getNetworkEnableUsed];
		
		if (networkUseType == NetworkUseAllEnable) {						
			NSString* fileNumber = getStringValue([content objectForKey:@"file_no"]);
			
			[m_Request checkBuyWithDomain:BI_PURCHASE_DOMAIN userNo:[UserProfile getUserNo]	fileNo:fileNumber delegate:self];
		}
		else {
			if (networkUseType == NetworkUse3GNotify) {
				UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@"안내" message:RESC_STRING_NETWORK_3G_NOTIFY_QUESTION delegate:self cancelButtonTitle:@"예" otherButtonTitles:@"아니오", nil];
				pAlertView.tag = ALERT_ID_NETWORK_3G_NOTIFY_QUESTION;
				[pAlertView show];	
				[pAlertView release];
			}
			else {
				UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@"안내" message:RESC_STRING_NETWORK_3G_ENABLE_QUESTION delegate:self cancelButtonTitle:@"예" otherButtonTitles:@"아니오", nil];
				pAlertView.tag = ALERT_ID_NETWORK_3G_ENABLE_QUESTION;
				[pAlertView show];	
				[pAlertView release];				
			}
		}
	}
	else {
		NSString* mainGroup = [content objectForKey:@"main_group"];

		if ([self __isExpireContent:content] == NO) {			
			NSString* masterNumber = getStringValue([content objectForKey:@"master_no"]); 			
			PlayBookContentType contentType = ([BI_MAIN_GROUP_TYPE_CARTOON isEqualToString:mainGroup] == YES) ? ContentTypeCartoon : ContentTypeEpub;
			
			BookDetailViewController* bookDetailViewController = [BookDetailViewController createWithMasterNumber:masterNumber contentType:contentType subGroup:[content objectForKey:@"sub_group"]];		
			if (bookDetailViewController != nil) {		
				[self.view addSubview:bookDetailViewController.view];					
			}						
		}				
	}
}

#pragma mark -
#pragma mark MessageBox Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSInteger alertId = alertView.tag;
	
	switch (alertId) {
		case ALERT_ID_NETWORK_3G_NOTIFY_QUESTION:
		case ALERT_ID_NETWORK_3G_ENABLE_QUESTION:
			if (buttonIndex == 0) 
			{
				if (alertId == ALERT_ID_NETWORK_3G_ENABLE_QUESTION) {
					[SettingPreference setUse3G:YES];
				}
				
				NSMutableDictionary* content = [m_List objectAtIndex:m_SelectedItemIndex];	
				if (content != nil) {
					NSString* fileNumber = getStringValue([content objectForKey:@"file_no"]);					
					[m_Request checkBuyWithDomain:BI_PURCHASE_DOMAIN userNo:[UserProfile getUserNo]	fileNo:fileNumber delegate:self];
				}
			}
			break;
			
		default:
			break;
	}	
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
		if (dicItem != nil && [dicItem objectForKey:@"title_image"] == nil) {	
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
	
	NSMutableDictionary* dicItem = [m_List objectAtIndex:indexPath.row];
	if (dicItem != nil) {
		[dicItem setObject:iconImage forKey:@"title_image"];
	}
	
	UITableViewCell* cell = [m_TableView cellForRowAtIndexPath:indexPath];
	if (cell != nil) {
		[((MyBookReadContentCell*)cell).m_ImageTitle setImage:[UIImage imageWithData:iconImage]];
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

- (void) clickBtnEditMode:(id)sender
{
	UIButton* btnEditMode = (UIButton*) sender;
	
	m_IsEditMode = (m_IsEditMode == YES) ? NO : YES;	
	if (m_IsEditMode == YES) {
		[btnEditMode setBackgroundImage:RESOURCE_IMAGE(@"my_keep_btn_cancel_off.png") forState:UIControlStateNormal];
		[m_EditBottomBar setHidden:NO];
		[APPDELEGATE.m_SwitchViewController hidesTabBar:YES animated:YES];
	}
	else {
		[btnEditMode setBackgroundImage:RESOURCE_IMAGE(@"my_vlist_top_btn_modify_off.png") forState:UIControlStateNormal];
		[APPDELEGATE.m_SwitchViewController hidesTabBar:NO animated:YES];
		[m_EditBottomBar setHidden:YES];
	}

	[m_CheckedList removeAllObjects];	
	[m_TableView reloadData];
}

- (void) clickBtnSelectAll:(id)sender
{
	[m_CheckedList removeAllObjects];	
	
	for(int index=0; index < [m_List count]; index++) {
		NSNumber* numIndex = [NSNumber numberWithInt:index]; 		
		[m_CheckedList addObject:numIndex];
	}		
	[m_TableView reloadData];	
}

- (void) clickBtnDelete:(id)sender
{
	if ([m_CheckedList count] == 0) { return; }
	
	int lastIndex = [m_CheckedList count] - 1;	
	
	NSMutableString* deleteIds = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
	for(int index = 0; index < [m_CheckedList count]; index++) {
		NSNumber* numIndex = [m_CheckedList objectAtIndex:index];
		
		NSDictionary* dicItem = [m_List objectAtIndex:[numIndex intValue]];
		NSString* conentNumber = getStringValue([dicItem objectForKey:@"no"]); 
		
		if(index != lastIndex) {
			[deleteIds appendFormat:@"%@|", conentNumber];
		}
		else {
			[deleteIds appendFormat:@"%@", conentNumber];
		}
	}
	[m_Request myViewZzimDeleteWithNoList:deleteIds myType:@"03" userNo:m_UserNo delegate:self];
	
	
	for(int index = lastIndex; index >= 0; index--) {
		NSNumber* numIndex = [m_CheckedList objectAtIndex:index];
		
		[m_List removeObjectAtIndex:[numIndex integerValue]];		
	}
	[m_CheckedList removeAllObjects];
	
	[m_TableView reloadData];
}


@end
