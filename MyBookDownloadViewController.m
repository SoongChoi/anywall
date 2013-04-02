    //
//  MyBookDownload.m
//  PlayBook
//
//  Created by Daniel on 12. 4. 25..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/CALayer.h>
#import "MyBookDownloadVIewController.h"
#import "MyBookGallaryViewController.h"
#import "MyBookDownloadCell.h"
#import "MyBookDownloadEventCell.h"
#import "UserProfile.h"
#import "PBDatabase.h"


#define _NEW_PACKAGE_WINDOW
#define _MAX_DOWNLOAD_COUNT			5


typedef enum {
	CellTypeDownload,
	CellTypeEvent,
	CellTypeExpireDownload,
	CellTypeExpireEvent,
} CellType;

@implementation MyBookDownloadViewController


@synthesize m_List;

@synthesize m_UserNo;
@synthesize m_BillCode;
@synthesize m_Title;

@synthesize m_IconDownloaders;


+ (id) createWithUserNo:(NSString*)userNo
{
	MyBookDownloadViewController* viewController = [[MyBookDownloadViewController alloc] initWithNibName:@"MyBookContentViewController" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {
		return nil;
	}
	[viewController setIsPackage:NO];
	
	viewController.m_UserNo = userNo;
	
	return viewController;
}


+ (id) createPackageWithUserNo:(NSString*)userNo billCode:(NSString*)billCode bookTitle:(NSString*)bookTitle;
{
	MyBookDownloadViewController* viewController = [[MyBookDownloadViewController alloc] initWithNibName:@"MyBookContentViewController" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {
		return nil;
	}
	[viewController setIsPackage:YES];
	
	viewController.m_UserNo = userNo;
	viewController.m_BillCode = billCode;
	viewController.m_Title = bookTitle;
	
	return viewController;	
}


- (void) setIsPackage:(BOOL)isPackage
{
	m_IsPackage = isPackage;
}

- (CellType) __getCellType:(NSDictionary*)dicItem 
{	
	NSString* status = [dicItem objectForKey:@"status"];
	NSString* goodskid = [dicItem objectForKey:@"goodskind"];
	
	if([status isEqualToString:@"S"] == YES) {
		return CellTypeDownload;
	}
	else if([status isEqualToString:@"P"] == YES) {
		return CellTypeEvent;
	}
	else if([status isEqualToString:@"F"] == YES) {
		BOOL isPackage = (goodskid != nil && [goodskid isEqualToString:BI_PURCHASE_BOOK_PACKAGE] == YES) ? YES : NO;
		if (isPackage == YES) {
			return CellTypeExpireEvent;			
		}		
		return CellTypeExpireDownload;
	}
	
	return CellTypeDownload;	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNotification:) name:NOTIFY_DATACHANGED object:nil];
	
	m_IsChangedOrder = NO;
	m_PageCount = DE_DEFAULT_PAGE_COUNT;
	m_ListCount = DF_DEFAULT_LIST_COUNT;

	m_IconDownloaders = [[NSMutableArray alloc] initWithCapacity:0];
	m_List = [[NSMutableArray alloc] initWithCapacity:0];
	
	
	m_TableView.hidden = YES;
	m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:m_Background orientation:UIDeviceOrientationPortrait];
	
	if (m_IsPackage == NO) {
		[self setTitleText:@"다운로드"];
		[self setShowEditButton:NO];
		[self setShowHeader:YES];
		[self setShowFooter:YES];
		
		NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
		NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];

		[m_Request buyListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_DOWNLOAD delegate:self];	
	}	
	else {
		[self setTitleText:m_Title];
		[self setShowEditButton:NO];
		[self setShowHeader:NO];
		[self setShowFooter:NO];
		
		[m_Request buyDetailWithUserNo:m_UserNo myType:BI_PURCHASE_TYPE_DOWNLOAD billCode:m_BillCode delegate:self];		
	}
	
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

- (ContentStatusType) getContentStatusType:(CellType)typeOfCell masterNumber:(NSString*)masterNumber fileNumber:(NSString*)fileNumber 
{
	ContentDownloadStatus dwonloadStauts = [PBDatabase getBookContentDownloadStatus:masterNumber fileNumber:fileNumber] ;
	ContentStatusType contentStatus = ContentStatusExpire;

	if (dwonloadStauts == ContentDownloadStatusDone) {						
		contentStatus = ContentStatusSaved;
	}
	else if (typeOfCell == CellTypeDownload) {			
		contentStatus = ContentStatusDownload;
	}
	return contentStatus;
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
			
			[m_Request buyListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_DOWNLOAD delegate:self];
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
			
			[m_Request buyListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_DOWNLOAD mainGroup:BI_MAIN_GROUP_TYPE_CARTOON delegate:self];
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

			[m_Request buyListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_DOWNLOAD mainGroup:BI_MAIN_GROUP_TYPE_NOVEL delegate:self];			
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
		[self setStatusError:RESC_STRING_NETWORK_FAIL status:ErrorStatusMyDownload];
	}
}

- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{
	NSDictionary* dicInfo = (NSDictionary *) userInfo;
	
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	switch (command) {
		case DF_URL_CMD_BUY_LIST:
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
				
				if ([m_List count] == 0) {
					m_TableView.hidden = YES;
					[self setStatusError:RESC_STRING_NO_RECEIVE_DATA_DOWNLOAD status:ErrorStatusMyDownload];
				}
				else {
					m_TableView.hidden = NO;
					[self setHiddenStatusError];
				}				
				[m_TableView reloadData];
			}
			else {
				m_PageCount = [m_List count] / DF_DEFAULT_LIST_COUNT;	
				if (m_PageCount == 0) {
					m_PageCount = DE_DEFAULT_PAGE_COUNT;
				}
			}
			}
			break;		
		
		case DF_URL_CMD_BUY_DETAIL:
			{
			NSString* rtCode = [dicInfo objectForKey:@"result"];
			if ([rtCode isEqualToString:@"0"] == YES) {				
				if (m_IsPackage == NO) {		
					NSMutableDictionary* dicItem = [m_List objectAtIndex:m_SelectedItemIndex];						
					
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
				}
				else {
					NSArray* rtEntry = [dicInfo objectForKey:@"contentInfo"];
					
					for(NSDictionary* dicEntry in rtEntry) {
						[m_List addObject:[dicEntry mutableCopy]];
					}				
					NSLog(@"listCount=[%d]", [m_List count]);
				}
			}		
				
			if ([m_List count] == 0) {
				m_TableView.hidden = YES;
				[self setStatusError:RESC_STRING_NO_RECEIVE_DATA_DOWNLOAD status:ErrorStatusMyDownload];
			}
			else {
				m_TableView.hidden = NO;
				[self setHiddenStatusError];
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
							
							NSString* drmType = [dicResult objectForKey:@"drm_type"];
							NSString* expireDate = @"00000000";
							NSString* counter = @"0";
							
							if ([BI_DRM_TYPE_UNLIMITE isEqualToString:drmType] == YES) {
								counter = @"-1";
							}
							else if ([BI_DRM_TYPE_PERIOD isEqualToString:drmType] == YES) {
								NSString* drmValue = [dicResult objectForKey:@"drm_value"];				
								NSArray* expireString = [drmValue componentsSeparatedByString:@"-"];
								
								if ([expireString count] == 2) {
									NSString* dateString = [expireString objectAtIndex:0];
									NSString* period = [expireString objectAtIndex:1];
									NSString* startString = [dateString substringWithRange:NSMakeRange(0, 8)];
									
									NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
									[dateFormatter setDateFormat:@"yyyyMMdd"];
									
									NSDate* startDate = [dateFormatter dateFromString:startString];	
									NSDate* endDate = [startDate dateByAddingTimeInterval:((60*60*24) * [period integerValue])]; 
									
									expireDate = [dateFormatter stringFromDate:endDate];
									[dateFormatter release];
									
									NSLog(@"dateString=[%@], expireString=[%@]", drmValue, expireDate);
								}
							}
							else {
								counter = getStringValue([dicResult objectForKey:@"drm_value"]);
							}
							
	//						NSString* masterNumber = [playyDictionary objectForKey:@"master_no"];
	//						NSString* fileNumber   = [fileDictionary valueForKey:@"file_no"];
							NSString* filePath       = [fileDictionary valueForKey:@"file_path"];
							
							NSMutableDictionary* dicItem = [m_List objectAtIndex:m_SelectedItemIndex];						
							NSData* imageData = [dicItem objectForKey:@"title_image"];
							if (imageData == nil) {
								imageData = [NSData dataWithContentsOfURL:URL_IMAGE_PATH([dicItem objectForKey:@"file_path"])];
								
								[dicItem setObject:imageData forKey:@"title_image"];
							}
							[dicItem setObject:[dicInfo objectForKey:@"pre_drm"] forKey:@"pre_drm"];
							[dicItem setObject:filePath forKey:@"file_path_remote"];
							
							[dicItem setObject:drmType forKey:@"drm_type"];
							[dicItem setObject:expireDate forKey:@"expiredt"];	
							[dicItem setObject:counter forKey:@"counter"];
							
							MyBookGallaryViewController* gallaryViewController = [MyBookGallaryViewController createWithContentDownload:dicItem];
							if (gallaryViewController != nil) {		
								[APPDELEGATE.m_MyBookMainViewController.view addSubview:gallaryViewController.view];		
							}
							
							NSInteger downloadCount = [[dicItem objectForKey:@"down_cnt"] integerValue];
							[dicItem setObject:[NSNumber numberWithInteger:(downloadCount - 1)] forKey:@"down_cnt"];
							return;
						}
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
	static NSString*    CellItentifier = @"MyBookDownloadCell";
	static NSString*	EvenItentifier = @"MyBookDownloadEventCell";
	
	NSMutableDictionary* dicItem = [m_List objectAtIndex:indexPath.row];
	
	NSInteger typeOfCell = [self __getCellType:dicItem];
	
	if ((typeOfCell == CellTypeDownload || typeOfCell == CellTypeExpireDownload) || m_IsPackage == YES) 
	{
		MyBookDownloadCell* cell = (MyBookDownloadCell*) [tableView dequeueReusableCellWithIdentifier:CellItentifier];
		
		if (cell == nil) {
			NSArray* cellObjectArray = [[NSBundle mainBundle] loadNibNamed:@"MyBookDownloadCell" owner:nil options:nil]; 
			for (id currentObject in cellObjectArray) {
				if ([currentObject isKindOfClass:[MyBookDownloadCell class]] == true) {
					cell = (MyBookDownloadCell *) currentObject;
					break;
				}
			}
		}	
		
		int lastIndex = [m_List count] - 1;
		if (typeOfCell == CellTypeExpireDownload) {
			if (lastIndex == indexPath.row) {
				cell.backgroundView = [[[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_end_disable.png")] autorelease];  
			}
			else{
				if (m_IsPackage == true && indexPath.row == 0) {
					cell.backgroundView = [[[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_top_disable.png")] autorelease];
				}
				else {
					cell.backgroundView = [[[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_disable.png")] autorelease];  					
				}
			}
		}
		else {
			if (lastIndex == indexPath.row) {
				cell.backgroundView = [[[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_end_off.png")] autorelease];  
				cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_end_on.png")] autorelease];		
			}
			else{
				if (m_IsPackage == true && indexPath.row == 0) {
					cell.backgroundView = [[[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_top_off.png")] autorelease];  
					cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_top_on.png")] autorelease];					
				}
				else {
					cell.backgroundView = [[[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_off.png")] autorelease];  
					cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_background_3line_on.png")] autorelease];					
				}
			}
		}
		
		NSString* masterNumber = getStringValue([dicItem objectForKey:@"master_no"]);
		NSString* fileNumber   = getStringValue([dicItem objectForKey:@"file_no"]);
		NSInteger downloadCount = [[dicItem objectForKey:@"down_cnt"] integerValue];
		
		ContentStatusType contentStatus = [self getContentStatusType:typeOfCell masterNumber:masterNumber fileNumber:fileNumber];
		
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
        
        [cell setContentWithTitle:[dicItem objectForKey:@"title"] writer:author downloadCount:downloadCount contentStatus:contentStatus];
		
		if ([BI_MAIN_GROUP_TYPE_CARTOON isEqualToString:[dicItem objectForKey:@"main_group"]] == YES) {
			[cell setImageTitleBounds:ContentTypeCartoon];
		}
		else {
			[cell setImageTitleBounds:ContentTypeEpub];
		}

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
		
		BOOL isExpire = (typeOfCell == CellTypeExpireDownload) ? YES : NO;
		NSString* drmType  = [dicItem objectForKey:@"dn_drm_type"];
		NSString* drmValue = [dicItem objectForKey:@"dn_drm_value"]; 
		
		[cell setExpireDateStatus:isExpire drmType:drmType drmValue:drmValue];
		
		return cell;	
	}
	else {
		MyBookDownloadEventCell* cell = (MyBookDownloadEventCell*) [tableView dequeueReusableCellWithIdentifier:EvenItentifier];
		
		if (cell == nil) {
			NSArray* cellObjectArray = [[NSBundle mainBundle] loadNibNamed:@"MyBookDownloadEventCell" owner:nil options:nil]; 
			for (id currentObject in cellObjectArray) {
				if ([currentObject isKindOfClass:[MyBookDownloadEventCell class]] == true) {
					cell = (MyBookDownloadEventCell *) currentObject;
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
		
		[cell.m_TitleEvent setText:[dicItem objectForKey:@"title"]];
		[cell setExtend:[[dicItem objectForKey:@"extend"] boolValue]];
		
		return cell;	
	}		
	
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
	
	m_SelectedItemIndex = indexPath.row;
	
	NSMutableDictionary* dicItem = [m_List objectAtIndex:m_SelectedItemIndex];
	if (dicItem != nil) {		
		NSInteger typeOfCell = [self __getCellType:dicItem];
		switch(typeOfCell) {
			case CellTypeDownload:
				{
				NSString* userNumber = [UserProfile getUserNo];
				NSString* masterNumber = getStringValue([dicItem objectForKey:@"master_no"]); 
				NSString* fileNumber = getStringValue([dicItem objectForKey:@"file_no"]);
				
				ContentStatusType contentStatus = [self getContentStatusType:typeOfCell masterNumber:masterNumber fileNumber:fileNumber];	
				if (contentStatus == ContentStatusDownload) {
					
					if ([APPDELEGATE existDownload:masterNumber fileNumber:fileNumber] == NO) 
					{									
						NSInteger downloadCount = [[dicItem objectForKey:@"down_cnt"] integerValue];
						if (downloadCount <= 0) 
						{
							UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"안내" 
																				message:RESC_STRING_NO_AUTHORITY 
																			   delegate:nil cancelButtonTitle:@"확인" 
																	  otherButtonTitles:nil];
							[alertView show];
							[alertView release];
							return;
						}		
						
						NetworkUseType networkUseType = [self getNetworkEnableUsed];
						
						if (networkUseType == NetworkUseAllEnable) {
							[m_Request checkBuyWithDomain:BI_PURCHASE_DOMAIN userNo:userNumber fileNo:fileNumber];
							
							MyBookDownloadCell* cell = (MyBookDownloadCell*) [m_TableView cellForRowAtIndexPath:indexPath];	
							if (cell != nil && [cell isKindOfClass:[MyBookDownloadCell class]] == YES) {
								[cell setContentStatus:ContentStatusSaved];
								[cell setDownloadCount:(downloadCount - 1)];
							}	
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
						MyBookGallaryViewController* gallaryViewController = [MyBookGallaryViewController createWithDelegate:nil];
						if (gallaryViewController != nil) {		
							[APPDELEGATE.m_MyBookMainViewController.view addSubview:gallaryViewController.view];		
						}						
					}

				}
				else if (contentStatus == ContentStatusSaved) {
					NSDictionary* content = [PBDatabase getBookContent:masterNumber fileNumber:fileNumber] ;
					if (content == nil) { return; }
					
					NSString* filePathLocal = getStringValue([content objectForKey:@"file_path_local"]);
					
					NSLog(@"content fileName=[%@]", filePathLocal); 
					
					LicenseChecker *lc = [(PlayBookAppDelegate*)[[UIApplication sharedApplication] delegate] getLicenseChecker];
					XDRM_RESULT dr = [lc checkLocalFileLicense:filePathLocal];
					
					if (dr != XDRM_SUCCESS)
					{
						switch (dr) {
							case XDRM_S_FALSE:				//작업이 실패했다
							case XDRM_E_FAIL:				//작업이 실패했다
							case XDRM_E_INVALIDARG:			//인자가 유효하지 않다
							case XDRM_E_OUTOFMEMORY:		//메모리를 할당할수 없다
							case XDRM_ERR_NOTPROTECTED:		//DRM 형식이 아니다
							case XDRM_ERR_NOTSUPPORTED:		//지원할 수 없는 DRM 형식이다
								{
								UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"안내" 
																					message:@"DRM 형식이 아닙니다." 
																				   delegate:nil cancelButtonTitle:@"확인" 
																		  otherButtonTitles:nil];
								[alertView show];
								[alertView release];
								}
								return;
							case XDRM_ERR_LIC_INVALIDRIGHT:	//라이센스 정책이 유효하지 않다
							case XDRM_ERR_LIC_EXPIRED:		//라이센스가 만료되었다
							case XDRM_ERR_LIC_ROLLBACK:		//라이센스가 Rollback되었다
								//라이센스가 만료되었습니다
								{
								UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"안내" 
																					message:RESC_STRING_EXPIRED_CONTENT 
																				   delegate:nil cancelButtonTitle:@"확인" 
																		  otherButtonTitles:nil];
								[alertView show];
								[alertView release];
								}
								return;
							default:
								break;
						}
					}
					
					
					if ([BI_MAIN_GROUP_TYPE_CARTOON isEqualToString:[content objectForKey:@"main_group"]] == YES) {					
						CartoonViewController* cartoonViewController = [CartoonViewController createWithContentsOfFile:filePathLocal title:[content objectForKey:@"title"] dicDownload:content];
						if (cartoonViewController != nil)
						{
							[APPDELEGATE.m_Window addSubview:cartoonViewController.view];
						}
					}
					else {
						EpubViewController* epubViewController = [EpubViewController createWithContentsOfFile:filePathLocal title:[content objectForKey:@"title"] dicDownload:content];
						if (epubViewController != nil)
						{
							[APPDELEGATE.m_Window addSubview:epubViewController.view];
						}				
					}
				}
				else {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"안내" 
																		message:RESC_STRING_EXPIRED_CONTENT 
																	   delegate:nil cancelButtonTitle:@"확인" 
															  otherButtonTitles:nil];
					[alertView show];
					[alertView release];
				}
				}
				break;
				
			case CellTypeExpireDownload:
				{
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"안내" 
																	message:RESC_STRING_EXPIRED_CONTENT 
																   delegate:nil cancelButtonTitle:@"확인" 
														  otherButtonTitles:nil];
				[alertView show];
				[alertView release];
				}
				break;

			case CellTypeEvent:
				{
				MyBookDownloadViewController* downloadViewController = [MyBookDownloadViewController createPackageWithUserNo:m_UserNo billCode:[dicItem objectForKey:@"billcode"] bookTitle:[dicItem objectForKey:@"title"]];					
				if (downloadViewController != nil) {
					[APPDELEGATE.m_MyBookMainViewController.view addSubview:downloadViewController.view];		
				}
				}					
				break;
		}
				
	}	
	
//	NSLog(@"%@", dicItem);	
}

#pragma mark -
#pragma mark MessageBox Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSInteger alertId = alertView.tag;
	
	switch (alertId) {
		case ALERT_ID_NETWORK_3G_NOTIFY_QUESTION:
		case ALERT_ID_NETWORK_3G_ENABLE_QUESTION:
			if (buttonIndex == 0) {
				if (alertId == ALERT_ID_NETWORK_3G_ENABLE_QUESTION) {
					[SettingPreference setUse3G:YES];
				}
				
				NSMutableDictionary* dicItem = [m_List objectAtIndex:m_SelectedItemIndex];
				
				if (dicItem != nil) {
					NSString* userNumber = [UserProfile getUserNo];
					NSString* fileNumber = getStringValue([dicItem objectForKey:@"file_no"]);
					NSInteger downloadCount = [[dicItem objectForKey:@"down_cnt"] integerValue];
					
					[m_Request checkBuyWithDomain:BI_PURCHASE_DOMAIN userNo:userNumber fileNo:fileNumber];
				
					NSArray* indexPathRows = [m_TableView indexPathsForVisibleRows];
					for (NSIndexPath* indexPath in indexPathRows) {
						if (indexPath.row == m_SelectedItemIndex) {
							MyBookDownloadCell* cell = (MyBookDownloadCell*) [m_TableView cellForRowAtIndexPath:indexPath];	
							if (cell != nil && [cell isKindOfClass:[MyBookDownloadCell class]] == YES) {
								[cell setContentStatus:ContentStatusSaved];
								[cell setDownloadCount:(downloadCount - 1)];
							}
							break;							
						}
					}					
				}
			}
			break;
			
		default:
			break;
	}	
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
	
    if (m_RecentSortOrder == SortOrderAll){
        [m_Request buyListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_DOWNLOAD delegate:self];
    }
    else{
        [m_Request buyListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_DOWNLOAD
                           mainGroup:m_RecentSortOrder == SortOrderCartoon ? BI_MAIN_GROUP_TYPE_CARTOON : BI_MAIN_GROUP_TYPE_NOVEL
                            delegate:self];
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
	if (cell != nil && [cell isKindOfClass:[MyBookDownloadCell class]] == YES) {
		[((MyBookDownloadCell*)cell).m_ImageTitle setImage:[UIImage imageWithData:iconImage]];
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
