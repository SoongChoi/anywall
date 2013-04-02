    //
//  MyBookStreamViewController.m
//  PlayBook
//
//  Created by Daniel on 12. 5. 11..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/CALayer.h>
#import "MyBookStreamViewController.h"
#import "MyBookGallaryViewController.h"
#import "MyBookDownloadEventCell.h"
#import "IconImageDownloader.h"
#import "PBDatabase.h"
#import "UserProfile.h"


#define _NEW_PACKAGE_WINDOW
#define _MAX_DOWNLOAD_COUNT			5




typedef enum {
	CellTypeStream,
	CellTypeEvent,
	CellTypeExpireStream,
	CellTypeExpireEvent,	
} CellType;


@implementation MyBookStreamViewController

@synthesize m_List;

@synthesize m_UserNo;
@synthesize m_BillCode;
@synthesize m_Title;

@synthesize m_PackageStatus;
@synthesize m_PackageExpireDate;

@synthesize m_IconDownloaders;


+(id) createWithUserNo:(NSString*)userNo
{
	MyBookStreamViewController* viewController = [[MyBookStreamViewController alloc] initWithNibName:@"MyBookContentViewController" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {
		return nil;
	}
	[viewController setIsPackage:NO];
	
	viewController.m_UserNo = userNo;

	return viewController;
}

+(id) createPackageWithUserNo:(NSString*)userNo billCode:(NSString*)billCode bookTitle:(NSString*)bookTitle status:(NSString*)status expire:(NSString*)expire
{
	MyBookStreamViewController* viewController = [[MyBookStreamViewController alloc] initWithNibName:@"MyBookContentViewController" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {
		return nil;
	}
	[viewController setIsPackage:YES];
	
	viewController.m_UserNo = userNo;
	viewController.m_BillCode = billCode;
	viewController.m_Title = bookTitle;
	
	viewController.m_PackageStatus = status;
	viewController.m_PackageExpireDate = expire;
	
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

- (void) setIsPackage:(BOOL)isPackage
{
	m_IsPackage = isPackage;
}

- (CellType) __getCellType:(NSDictionary*)dicItem 
{	
	NSString* status   = [dicItem objectForKey:@"status"];
	NSString* goodskid = [dicItem objectForKey:@"goodskind"];
	
	if([status isEqualToString:@"S"] == YES) {
		return CellTypeStream;
	}
	else if([status isEqualToString:@"P"] == YES) {
		return CellTypeEvent;
	}
	else if([status isEqualToString:@"F"] == YES) {
		BOOL isPackage = (goodskid != nil && [goodskid isEqualToString:BI_PURCHASE_BOOK_PACKAGE] == YES) ? YES : NO;
		if (isPackage == YES) {
			return CellTypeExpireEvent;
		}		
		return CellTypeExpireStream;
	}
	
	return CellTypeStream;
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
		[self setTitleText:@"스트리밍"];
		[self setShowEditButton:NO];
		[self setShowHeader:YES];
		[self setShowFooter:YES];
		
		NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
		NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
		
		[m_Request buyListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_STREAM delegate:self];	
	}	
	else {
		[self setTitleText:m_Title];
		[self setShowEditButton:NO];
		[self setShowHeader:NO];
		[self setShowFooter:NO];
		
		[m_Request buyDetailWithUserNo:m_UserNo myType:BI_PURCHASE_TYPE_STREAM billCode:m_BillCode delegate:self];		
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
			
			[m_Request buyListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_STREAM delegate:self];
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
			
			[m_Request buyListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_STREAM mainGroup:BI_MAIN_GROUP_TYPE_CARTOON delegate:self];
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
			
			[m_Request buyListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_STREAM mainGroup:BI_MAIN_GROUP_TYPE_NOVEL delegate:self];
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
		[self setStatusError:RESC_STRING_NETWORK_FAIL status:ErrorStatusMyStream];
	}
}

- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	NSDictionary* dicInfo = (NSDictionary *) userInfo;
	
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
					[self setStatusError:RESC_STRING_NO_RECEIVE_DATA_STREAMING status:ErrorStatusMyStream];
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
						NSMutableDictionary* entry = [dicEntry mutableCopy];

						[entry setObject:m_PackageStatus forKey:@"status"];							
						[entry setObject:m_PackageExpireDate forKey:@"expiredt"];
						
						[m_List addObject:[entry mutableCopy]];
						
					}				
					NSLog(@"listCount=[%d]", [m_List count]);
				}				
			}
				
			if ([m_List count] == 0) {	
				m_TableView.hidden = YES;
				[self setStatusError:RESC_STRING_NO_RECEIVE_DATA_STREAMING status:ErrorStatusMyStream];
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

							NSString* masterNumber = getStringValue([playyDictionary objectForKey:@"master_no"]);
							NSString* fileNumber   = getStringValue([fileDictionary valueForKey:@"file_no"]);
							NSString* filePath     = [fileDictionary valueForKey:@"file_path"];
							NSString* bookNumber   = getStringValue([fileDictionary valueForKey:@"book_no"]);
							
							NSMutableDictionary* dicItem = [m_List objectAtIndex:m_SelectedItemIndex];						
							[dicItem setObject:masterNumber forKey:@"master_no"];
							[dicItem setObject:fileNumber forKey:@"file_no"];							
							[dicItem setObject:filePath forKey:@"file_path_remote"];
							[dicItem setObject:[dicInfo objectForKey:@"pre_drm"] forKey:@"pre_drm"];
							
							[dicItem setObject:bookNumber forKey:@"book_no"];
							if (exbuy_type == 3)
								[dicItem setObject:getStringValue([dicResult valueForKey:@"sample_count"]) forKey:@"sample_count"];
							else {
								[dicItem setObject:@"0" forKey:@"sample_count"];
							}
							
							if ([BI_MAIN_GROUP_TYPE_CARTOON isEqualToString:[dicItem objectForKey:@"main_group"]] == YES) {
								CartoonViewController*  cartoonViewController = [CartoonViewController createWithContentsStreaming:dicItem];
								if (cartoonViewController != nil)
								{
									[APPDELEGATE.m_Window addSubview:cartoonViewController.view];								
								}
							}
							else {
								EpubViewController* epubViewController = [EpubViewController createWithContentsStreaming:dicItem];
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
	static NSString*    CellItentifier = @"MyBookStreamCell";
	static NSString*	EvenItentifier = @"MyBookDownloadEventCell";
	
	NSMutableDictionary* dicItem = [m_List objectAtIndex:indexPath.row];
	
	NSInteger typeOfCell = [self __getCellType:dicItem];
	
	if ((typeOfCell == CellTypeStream || typeOfCell == CellTypeExpireStream) || m_IsPackage == YES) 
	{
		MyBookStreamCell* cell = (MyBookStreamCell*) [tableView dequeueReusableCellWithIdentifier:CellItentifier];
		
		if (cell == nil) {
			NSArray* cellObjectArray = [[NSBundle mainBundle] loadNibNamed:@"MyBookStreamCell" owner:nil options:nil]; 
			for (id currentObject in cellObjectArray) {
				if ([currentObject isKindOfClass:[MyBookStreamCell class]] == true) {
					cell = (MyBookStreamCell *) currentObject;
					break;
				}
			}
		}
		int lastIndex = [m_List count] - 1;
		if (typeOfCell == CellTypeExpireStream) {
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
		
		PlayBookContentType contentType = [BI_MAIN_GROUP_TYPE_CARTOON isEqualToString:[dicItem objectForKey:@"main_group"]] ? ContentTypeCartoon: ContentTypeEpub;
		
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
		
		NSString* expireDateString = getStringValue([dicItem objectForKey:@"expiredt"]);
		NSString* expireDateStatus = expireDateString;
		if ([expireDateString length] > 8) 
		{
			expireDateStatus = [NSString stringWithFormat:@"%@.%@.%@", 
								[expireDateStatus substringWithRange:NSMakeRange(0, 4)],
								[expireDateStatus substringWithRange:NSMakeRange(4, 2)],
								[expireDateStatus substringWithRange:NSMakeRange(6, 2)]];
		}
		else {
			expireDateStatus = @"-";
		}

		
		if (typeOfCell == CellTypeStream) {			
			NSString* replayPageNumber = getStringValue([dicItem objectForKey:@"replay_no"]);
			
			[cell setPageWithStatus:contentType pages:replayPageNumber status:expireDateStatus];
		}
		else {
			[cell setContentExpire:expireDateStatus];
		}
		[cell setImageTitleBounds:contentType];
		
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

		return cell;	
	}
	else 
	{
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
		switch(typeOfCell) 
		{
			case CellTypeStream:									
				{
				NetworkUseType networkUseType = [self getNetworkEnableUsed];
					
				if (networkUseType == NetworkUseAllEnable) {
					NSString* userNumber = [UserProfile getUserNo];
					NSString* fileNumber = getStringValue([dicItem objectForKey:@"file_no"]);
					
					[m_Request checkBuyWithDomain:BI_PURCHASE_DOMAIN userNo:userNumber fileNo:fileNumber];						
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
				break;
				
			case CellTypeEvent:
			case CellTypeExpireEvent:
				{
				NSString* status = @"S";
				if (typeOfCell == CellTypeExpireEvent) {
					status = @"F";				
				}
				NSString* expire = getStringValue([dicItem objectForKey:@"expiredt"]);
				
				MyBookStreamViewController* packageViewCotroller = [MyBookStreamViewController createPackageWithUserNo:m_UserNo 
																											  billCode:[dicItem objectForKey:@"billcode"] 
																											 bookTitle:[dicItem objectForKey:@"title"] 
																												status:status
																												expire:expire];	
				if (packageViewCotroller != nil) {
					[APPDELEGATE.m_MyBookMainViewController.view addSubview:packageViewCotroller.view];		
				}
				}					
				break;
				
			case CellTypeExpireStream:
				{
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"안내" 
																	message:RESC_STRING_EXPIRED_CONTENT 
																   delegate:nil cancelButtonTitle:@"확인" 
														  otherButtonTitles:nil];
				[alertView show];
				[alertView release];
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
					
					[m_Request checkBuyWithDomain:BI_PURCHASE_DOMAIN userNo:userNumber fileNo:fileNumber];	
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
        [m_Request buyListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_STREAM delegate:self];
    }
    else{
        [m_Request buyListWithUserNo:m_UserNo pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_STREAM
                           mainGroup:m_RecentSortOrder == SortOrderCartoon ? BI_MAIN_GROUP_TYPE_CARTOON : BI_MAIN_GROUP_TYPE_NOVEL
                            delegate:self];
    }
}

#pragma mark -
#pragma mark request MyBookDownload delegate

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
	if (cell != nil && [cell isKindOfClass:[MyBookStreamCell class]] == YES) {
		[((MyBookStreamCell*)cell).m_ImageTitle setImage:[UIImage imageWithData:iconImage]];
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


@end
