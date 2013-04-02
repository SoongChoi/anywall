    //
//  MyBookGallaryViewController.m
//  PlayBook
//
//  Created by Daniel on 12. 4. 16..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/CALayer.h>
#import "PBDatabase.h"
#import "MyBookGallaryViewController.h"
#import "MyBookGallaryIconLineCell.h"
#import "SettingPreference.h"


#define GRID_COLUMN_COUNT			3
#define DEFAULT_LIST_ITEM_COUNT		9
#define INVALID_ITEM_INDEX			-1



@implementation MyBookGallaryViewController

@synthesize m_Background;
@synthesize m_TitleLabel;
@synthesize m_BtnClose;

@synthesize m_TableView;
@synthesize m_List;
@synthesize m_CheckedList;

@synthesize m_TitleTopBar;
@synthesize m_EditBottomBar;
@synthesize m_BtnEditMode;

@synthesize m_DownloadRequestList;


+ (id) createWithDelegate:(id)delegate
{
	if (APPDELEGATE.m_GallaryViewController != nil) {
		[(MyBookGallaryViewController *)APPDELEGATE.m_GallaryViewController close];
	}
	
	MyBookGallaryViewController* viewController = [[MyBookGallaryViewController alloc] initWithNibName:@"MyBookGallaryViewController" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {	
		return nil;
	}
	viewController.m_DownloadRequestList = [[NSMutableArray alloc] initWithCapacity:0];
	
	return viewController;
}

+ (id) createWithContentDownload:(NSMutableDictionary*)downloadRequest
{
	if (APPDELEGATE.m_GallaryViewController != nil) {
		[(MyBookGallaryViewController *)APPDELEGATE.m_GallaryViewController close];
	}
	
	MyBookGallaryViewController* viewController = [[MyBookGallaryViewController alloc] initWithNibName:@"MyBookGallaryViewController" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {		
		return nil;
	}
	viewController.m_DownloadRequestList = [[NSMutableArray alloc] initWithCapacity:0];	
	[viewController.m_DownloadRequestList addObject:[downloadRequest mutableCopy]];
	
	return viewController;
}


-(int)__lineCount
{
	int itemCount = [m_List count];	
	return (itemCount / GRID_COLUMN_COUNT) + (itemCount % GRID_COLUMN_COUNT == 0 ? 0 : 1);
}

-(void)__addEmptyItems
{
	int emptyCount = DEFAULT_LIST_ITEM_COUNT - [m_List count];
	
	if (emptyCount > 0) {
		for(int index = 0; index < emptyCount; index++) {
			NSMutableDictionary* itemEmpty = [NSMutableDictionary dictionaryWithCapacity:0];
			[m_List addObject:itemEmpty];
		}
	}	
}


-(void)__setCheckedItemCell:(MyBookGallaryIconLineCell*)itemLineCell itemIndex:(NSInteger)index
{
	NSNumber* numIndex = [NSNumber numberWithInt:index]; 
	
	if ([m_CheckedList containsObject:numIndex] == YES) {
		[itemLineCell setCheckGallaryItem:index checked:YES];
	}
	else {
		[itemLineCell setCheckGallaryItem:index checked:NO];
	}
}	

-(int)__getItemIndexWithMasterNumber:(NSString*)masterNumber fileNumber:(NSString*)fileNumber
{
	
	int lenght = [m_List count];	
	for(int index = 0; index < lenght; index++) {
		NSDictionary* item = [m_List objectAtIndex:index];
		
		if ([masterNumber isEqualToString:[item objectForKey:@"master_no"]] == YES && [fileNumber isEqualToString:[item objectForKey:@"file_no"]] == YES) {
			return index;
		}
	}
	
	return INVALID_ITEM_INDEX;
}

-(int)__getItemIndexWithMasterNumber:(NSDictionary*)dicItem 
{
	int dwonloadItemIndex = m_DownloadItemIndex;
	
	if (dwonloadItemIndex == INVALID_ITEM_INDEX) {
		NSString* masterNumber = getStringValue([dicItem objectForKey:@"master_no"]);
		NSString* fileNumber   = getStringValue([dicItem objectForKey:@"file_no"]);
		
		dwonloadItemIndex = [self __getItemIndexWithMasterNumber:masterNumber fileNumber:fileNumber];		
	}
	
	return dwonloadItemIndex;
}


-(void)__readContentFromLocale
{	
	if ([m_DownloadRequestList count] > 0) {
		for(NSMutableDictionary* downloadRequest in m_DownloadRequestList) {
			[APPDELEGATE putContentDownloadRequest:downloadRequest];
		}
	}

	
	NSMutableArray* items = [PBDatabase getBookContentItems];
	if (items != nil) {
		int lastIndex = [items count] - 1; 
		for(int index = lastIndex; index >= 0; index--) {
			[m_List addObject:[[items objectAtIndex:index] mutableCopy]];
		}
	}
	[self __addEmptyItems];
	
	m_LastLine = [self __lineCount] - 1;
	
	[m_Background setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];
	
//	[m_TitleTopBar setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];	
	[m_TableView setBackgroundColor:[UIColor clearColor]];

//	[m_EditBottomBar setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];	
	[m_EditBottomBar setHidden:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		m_List = [[NSMutableArray alloc] initWithCapacity:0];
		m_CheckedList = [[NSMutableArray alloc] initWithCapacity:0];

		m_IsEditMode = NO;
		m_DownloadItemIndex = INVALID_ITEM_INDEX;	
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[m_TitleLabel setUserInteractionEnabled:YES];
	UITapGestureRecognizer *tapTitleGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapTitle)] autorelease];
	[m_TitleLabel addGestureRecognizer:tapTitleGesture];
	
	[m_BtnClose setImage:RESOURCE_IMAGE(@"view_top_btn_back_off.png") forState:UIControlStateNormal];
	[m_BtnClose setImage:RESOURCE_IMAGE(@"view_top_btn_back_on.png") forState:UIControlStateHighlighted];
	[m_BtnClose setImageEdgeInsets:UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f)];
	
	APPDELEGATE.m_GallaryViewController = self; 
	[APPDELEGATE setContneDownloadDelegate:self];
	[self __readContentFromLocale];
	
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

- (void)viewDidUnload {

}

- (void)dealloc {
	
	APPDELEGATE.m_GallaryViewController = nil;
	[APPDELEGATE setContneDownloadDelegate:nil];
	
	[m_TableView release];
	[m_TitleTopBar release];
	
	[m_BtnEditMode release];
	[m_EditBottomBar release];
	
	[m_BtnClose release];
	
	[m_DownloadRequestList release];	
	[m_List release];
	[m_CheckedList release];
	
	[m_Background release];
	
    [super dealloc];
}

- (IBAction) actionTapTitle
{
	[m_TableView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self __lineCount];
}


// Customize the appearance of table view cells.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
//	NSLog(@"startIndex=[%d]", (indexPath.row * GRID_COLUMN_COUNT));
	
	static NSString*    CellItentifier = @"MyBookGallaryIconLineCell";
	MyBookGallaryIconLineCell*  cell = (MyBookGallaryIconLineCell*) [tableView dequeueReusableCellWithIdentifier:CellItentifier];
	
	if (cell == nil) {
		NSArray* cellObjectArray = [[NSBundle mainBundle] loadNibNamed:@"MyBookGallaryIconLineCell" owner:nil options:nil]; 
		for (id currentObject in cellObjectArray) {
			if ([currentObject isKindOfClass:[MyBookGallaryIconLineCell class]] == true) {
				cell = (MyBookGallaryIconLineCell *) currentObject;
				break;
			}
		}
	}
	
	int length = (indexPath.row * GRID_COLUMN_COUNT) + GRID_COLUMN_COUNT;
	int lastIndex = ([m_List count] == 0) ? 0 : [m_List count] - 1;
	for(int index = (indexPath.row * GRID_COLUMN_COUNT); index < length; index++) {
		int position = index % GRID_COLUMN_COUNT;
		if (lastIndex >= index) {
			NSMutableDictionary* dicItem = [m_List objectAtIndex:index];		
			
			NSString* contentType = [dicItem objectForKey:@"main_group"];
			NSData* imageData = [dicItem objectForKey:@"title_image"];
			NSString* volumeNumber = [NSString stringWithFormat:@"%@권 | ", [dicItem objectForKey:@"volume_number"]];
			
			NSString* drmType = [dicItem objectForKey:@"drm_type"];
			NSString* expireDate = getStringValue([dicItem objectForKey:@"enddt"]);
			NSString* counter = getStringValue([dicItem objectForKey:@"counter"]);
			
			if ([BI_MAIN_GROUP_TYPE_CARTOON isEqualToString:contentType] == YES) {			
				[cell addBookGallaryItem:position title:[dicItem objectForKey:@"title"] titleImage:[UIImage imageWithData:imageData] volume:volumeNumber itemIndex:index];
				[cell setExpireDate:position drmType:drmType expireDate:expireDate counter:counter];
				
				[self __setCheckedItemCell:cell itemIndex:index];
			}
			else if ([BI_MAIN_GROUP_TYPE_NOVEL isEqualToString:contentType] == YES) {			
				[cell addBookGallaryItem:position titleImage:[UIImage imageWithData:imageData] volume:volumeNumber itemIndex:index];
				[cell setExpireDate:position drmType:drmType expireDate:expireDate counter:counter];
				
				[self __setCheckedItemCell:cell itemIndex:index];				
			}
			else {
				[cell clearBookGallaryItem:position];
			}
		}
		else {
			[cell clearBookGallaryItem:position];
		}
	}
	cell.m_Delegate = self;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

	if (m_LastLine == indexPath.row) {
		return (148.0f + 38.0f);
	}

	return 148.0f;
}


#pragma mark -
#pragma mark MyBookGallaryItemSelected Delegate 

- (void) selectedGallaryItem:(id)sender lineCell:(UITableViewCell*)lineCell itemIndex:(NSInteger)index
{
	
	if (m_IsEditMode == YES) {	
		NSLog(@"itemIndex=[%d]", index);
		
		if ([APPDELEGATE isDownloading] == YES) { return; }
		
		NSNumber* numIndex = [NSNumber numberWithInt:index]; 
		
		MyBookGallaryIconLineCell* itemLineCell = (MyBookGallaryIconLineCell*)lineCell; 	
		if ([m_CheckedList containsObject:numIndex] == YES) {
			[m_CheckedList removeObject:numIndex];
			[itemLineCell setCheckGallaryItem:index checked:NO];
		}
		else {
			[m_CheckedList addObject:numIndex];
			[itemLineCell setCheckGallaryItem:index checked:YES];
		}
	}
	else {
		
		NSMutableDictionary* content = [m_List objectAtIndex:index];
		ContentDownloadStatus downloadStatus = (ContentDownloadStatus) [[content objectForKey:@"download_status"] integerValue];
		
		[content setObject:getStringValue([content valueForKey:@"volume_number"]) forKey:@"book_no"];
		
		if (downloadStatus == ContentDownloadStatusDone) {
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
				EpubViewController* epubViewController = (EpubViewController *)[EpubViewController createWithContentsOfFile:filePathLocal title:[content objectForKey:@"title"] dicDownload:content];
				if (epubViewController != nil)
				{
					[APPDELEGATE.m_Window addSubview:epubViewController.view];
				}				
			}

			m_SelectedIndex = index;
		}
		else {
			NSString* masterNumber = getStringValue([content objectForKey:@"master_no"]);
			NSString* fileNumber   = getStringValue([content objectForKey:@"file_no"]);
			
			if ([APPDELEGATE existDownload:masterNumber fileNumber:fileNumber] == NO) 
			{	
				NetworkUseType networkUseType = [self getNetworkEnableUsed];
				
				if (networkUseType == NetworkUseAllEnable) {
					[APPDELEGATE putContentDownloadRequest:content];	
				}
				else {
					m_SelectedIndex = index;
					
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
		}
		
	}
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
				
				NSMutableDictionary* content = [m_List objectAtIndex:m_SelectedIndex];			
				if (content != nil) {
					[APPDELEGATE putContentDownloadRequest:content];
				}
			}
			break;
			
		default:
			break;
	}	
}


-(void) close
{
	if (m_IsEditMode = YES) {
		[APPDELEGATE.m_SwitchViewController hidesTabBar:NO animated:YES];
	}
	[self.view removeFromSuperview];	
	[self release];
}

-(void) clickBtnClose:(id)sender
{
	if (m_IsEditMode = YES) {
		[APPDELEGATE.m_SwitchViewController hidesTabBar:NO animated:YES];
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

-(void) clickBtnEditMode:(id)sender
{
	NSLog(@"clieck Edit Button");	
	
	if ([APPDELEGATE isDownloading] == YES) { return; }
	
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
	
	BOOL isReload = ([m_CheckedList count] == 0) ? NO : YES;
	
	[m_CheckedList removeAllObjects];	
	if (isReload == YES) {
		[m_TableView reloadData];
	}
	
}

-(void) clickBtnSelectAll:(id)sender
{
	[m_CheckedList removeAllObjects];
	
	for(int index = 0; index < [m_List count]; index++) {
		[m_CheckedList addObject:[NSNumber numberWithInt:index]]; 
	}	
	[m_TableView reloadData];	
}

-(void) clickBtnDelete:(id)sender
{
	if ([m_CheckedList count] > 0) 
	{ 	
		for(NSNumber* itemIndex in m_CheckedList) {
			NSDictionary* itemDelete = [m_List objectAtIndex:[itemIndex integerValue]];
			if (itemDelete != nil && [itemDelete count] > 0) {
				NSString* masterNumber = getStringValue([itemDelete objectForKey:@"master_no"]);
				NSString* fileNumber   = getStringValue([itemDelete objectForKey:@"file_no"]);
				NSString* fileName	   = [itemDelete objectForKey:@"file_path_local"];
				NSString* filePathLocal= [JMDevKit appDocumentFilePath:fileName]; 
				
				BOOL retValue = [PBDatabase deleteBookContent:masterNumber fileNumber:fileNumber];
				if (retValue == YES) {
					if ([[NSFileManager defaultManager] fileExistsAtPath:filePathLocal]) {
						NSError* error = [[NSError alloc] init];
						if ([[NSFileManager defaultManager] removeItemAtPath:filePathLocal error:&error] == NO) {
							NSLog(@"%@",error);
						}
					}
				}				
			}
		}	
		
		[m_List removeAllObjects];
		
		NSMutableArray* items = [PBDatabase getBookContentItems];
		if (items != nil) {
			int length = [items count];
			for(int index = 0; index < length; index++) {
				[m_List addObject:[[items objectAtIndex:index] mutableCopy]];
			}
		}
		[self __addEmptyItems];
		
		m_LastLine = [self __lineCount] - 1;
		
		[m_TableView reloadData];
	}
	[self clickBtnEditMode:m_BtnEditMode];
}

#pragma mark -
#pragma mark ContentDownloadRequestDelegate Delegate 

- (void) drawDownloadProgress:(NSInteger)downloadItemIndex show:(BOOL)isShow percent:(CGFloat)percent
{
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:((downloadItemIndex == 0) ? 0 : (downloadItemIndex / GRID_COLUMN_COUNT)) inSection:0];
	
	MyBookGallaryIconLineCell* itemLineCell = (MyBookGallaryIconLineCell*) [m_TableView cellForRowAtIndexPath:indexPath];	
	if (itemLineCell != nil) {
		int position = (downloadItemIndex == 0) ? 0 : downloadItemIndex % GRID_COLUMN_COUNT;
		
		[itemLineCell setProgressHidden:position isHidden:!isShow];
		[itemLineCell setProgressPercent:position percent:percent];	
		
		//NSLog(@"position=[%d], percent=[%f]", position, percent);
	}
}

- (void) cdrDidReceiveResponse:(id)dicData contentLength:(NSUInteger)contentLength
{			
	m_DownloadItemIndex = [self __getItemIndexWithMasterNumber:(NSDictionary*)dicData];
	if (m_DownloadItemIndex == INVALID_ITEM_INDEX) { return; }
	
	NSMutableDictionary* content = [m_List objectAtIndex:m_DownloadItemIndex];	
	[content setObject:[NSNumber numberWithInteger:contentLength] forKey:@"content_length"];

	[self drawDownloadProgress:m_DownloadItemIndex show:YES percent:0];
}

- (void) cdrDidReceiveData:(id)dicData receiveLength:(NSUInteger)receiveLength totalLength:(long long)totalLength
{
	m_DownloadItemIndex = [self __getItemIndexWithMasterNumber:(NSDictionary*)dicData];
	if (m_DownloadItemIndex == INVALID_ITEM_INDEX) { return; }

	CGFloat percentDownload	= (CGFloat)receiveLength / (CGFloat)totalLength;	
	[self drawDownloadProgress:m_DownloadItemIndex show:YES percent:percentDownload];	
}

- (void) cdrDidFailWithError:(id)dicData error:(NSError*)error
{
	NSLog(@"ContentDownload error....");
	
	m_DownloadItemIndex = [self __getItemIndexWithMasterNumber:(NSDictionary*)dicData];
	if (m_DownloadItemIndex == INVALID_ITEM_INDEX) { return; }

	[self drawDownloadProgress:m_DownloadItemIndex show:NO percent:0];

	m_DownloadItemIndex = INVALID_ITEM_INDEX;
}

- (void) cdrDidFinishLoadingWithCommand:(id)dicData
{	
	m_DownloadItemIndex = [self __getItemIndexWithMasterNumber:(NSDictionary*)dicData];
	if (m_DownloadItemIndex == INVALID_ITEM_INDEX) { return; }
	
	NSMutableDictionary* content = [m_List objectAtIndex:m_DownloadItemIndex];
	if (content != nil) {
		[content setObject:[NSNumber numberWithInteger:ContentDownloadStatusDone] forKey:@"download_status"];
	}
	[self drawDownloadProgress:m_DownloadItemIndex show:NO percent:0];

	m_DownloadItemIndex = INVALID_ITEM_INDEX;
}


@end
