    //
//  StoreFreeViewController.m
//  PlayBook
//
//  Created by Daniel on 12. 3. 6..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreFreeViewController.h"
#import "StoreFreeContentCell.h"


#define FOOTER_HEADER_HEIGHT		80


@implementation StoreFreeViewController

@synthesize m_Request;
@synthesize m_ViewControllers;
@synthesize m_List;

@synthesize m_IconDownloaders;

@synthesize m_FreeContentCell;
@synthesize m_LogoFooterView;
@synthesize m_ImageLogo;


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

- (void) __addPlayBookLogoFooter
{
	m_ImageLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_logo.png"]];
	[m_ImageLogo setFrame:CGRectMake(82, 20, 137, 35)];
	
	m_LogoFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, FOOTER_HEADER_HEIGHT)];
	[m_LogoFooterView setBackgroundColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.0]];	
	[m_LogoFooterView addSubview:m_ImageLogo];
	
	[m_TableView setTableFooterView:m_LogoFooterView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	m_Request = [[PlayBookRequest alloc] initWithDelegate:self];	
	
	m_List = [[NSMutableArray alloc] initWithCapacity:0];
	m_IconDownloaders = [[NSMutableArray alloc] initWithCapacity:0];

	m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:APPDELEGATE.m_StoreFreeNavController.view orientation:UIDeviceOrientationPortrait]; 
	[m_Request recommendContentListWithMenuType:BI_MENU_TYPE_FREE];		
	
	
	CGRect rect = m_TopShowLine.frame;
	[m_TopShowLine setFrame:CGRectMake(rect.origin.x + 2, rect.origin.y, rect.size.width - 4, rect.size.height)];
	
	m_TableView.separatorColor = [UIColor clearColor];
	[self setShowHeader:NO];
	[self setShowFooter:YES];
	
	NSLog(@"m_List retainCount=[%d]", [m_List retainCount]); 
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
	
	[m_List removeAllObjects];
	[m_List release];	
	
	[m_IconDownloaders removeAllObjects];
	[m_IconDownloaders release];
	
	[m_FreeContentCell release];
	[m_ImageLogo release];
	[m_LogoFooterView release];
	
    [super dealloc];
}

- (BOOL)requestReloadData:(id)sender
{	
	if (m_IsDataChanged == YES) {
		NSLog(@"This is Sub... isChanged=[YES]");
		
		if (m_ActivityIndicator == nil) {
			m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:((UIViewController*)sender).view orientation:UIDeviceOrientationPortrait]; 
		}
		
		[m_Request recommendContentListWithMenuType:BI_MENU_TYPE_FREE];
		m_IsDataChanged = NO;
	}
	return YES;
}

-(void)setTagImage:(UIImageView*)tagImageView content:(NSDictionary*)content
{
	NSString* tagType = getStringValue([content objectForKey:@"tag_type"]);
	
	if ([tagType isEqualToString:@"N"] == YES) {
		[tagImageView setImage:RESOURCE_IMAGE(@"main_icon_new.png")];
		[tagImageView setHidden:NO];
	}
	else if([tagType isEqualToString:@"H"] == YES) {
		[tagImageView setImage:RESOURCE_IMAGE(@"main_icon_hot.png")];
		[tagImageView setHidden:NO];		
	}
	else if([tagType isEqualToString:@"F"] == YES) { 
		[tagImageView setImage:RESOURCE_IMAGE(@"main_icon_free.png")];
		[tagImageView setHidden:NO];			
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
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	m_IsDataChanged = YES;
	NSLog(@"%@", error);
}

- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{	
	NSDictionary* dicInfo = (NSDictionary *) userInfo;
	
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	switch (command) {
		case DF_URL_CMD_RECOMMEND_CONTENT_LIST:
			[m_List removeAllObjects];
			[m_IconDownloaders removeAllObjects];
			
			NSLog(@"result: %@", [dicInfo objectForKey:@"result"]);
			NSLog(@"menu_type: %@", [dicInfo objectForKey:@"menu_type"]);				

			NSArray *content = [dicInfo objectForKey:@"contentInfo"];			
			if(content != nil) {
				m_List = [content mutableCopy];
			}
			m_IsDataChanged = NO;
			
			[m_TableView reloadData];

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
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	NSLog(@"tableView cell is called - indexPath=[%d]", indexPath.row);
	
	static NSString* CellItentifer = @"StoreFreeContentCell";
	StoreFreeContentCell* cell = (StoreFreeContentCell*) [tableView dequeueReusableCellWithIdentifier:CellItentifer];
	
	if (cell == nil) {
		NSArray* cellObjectArray = [[NSBundle mainBundle] loadNibNamed:@"StoreFreeContentCell" owner:nil options:nil]; 
		for (id currentObject in cellObjectArray) {
			if ([currentObject isKindOfClass:[StoreFreeContentCell class]] == true) {
				cell = (StoreFreeContentCell *) currentObject;
				break;
			}
		}
	}
	cell.m_Delegate = self;
	
	cell.m_IconItem_1.hidden = YES;
	cell.m_IconItem_2.hidden = YES;
	cell.m_IconItem_3.hidden = YES;
	cell.m_IconItem_4.hidden = YES;
	cell.m_IconItem_5.hidden = YES;
	cell.m_IconItem_6.hidden = YES;
	cell.m_IconItem_7.hidden = YES;
	cell.m_IconItem_8.hidden = YES;
	cell.m_IconItem_9.hidden = YES;	

	[cell.m_BtnItem_1 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_comic.png") forState:UIControlStateNormal];
	[cell.m_BtnItem_1 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_comic_on.png") forState:UIControlStateHighlighted];
	[cell.m_BtnItem_2 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_novel.png") forState:UIControlStateNormal];
	[cell.m_BtnItem_2 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_novel_on.png") forState:UIControlStateHighlighted];
	[cell.m_BtnItem_3 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_comic.png") forState:UIControlStateNormal];
	[cell.m_BtnItem_3 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_comic_on.png") forState:UIControlStateHighlighted];
	[cell.m_BtnItem_4 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_novel.png") forState:UIControlStateNormal];
	[cell.m_BtnItem_4 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_novel_on.png") forState:UIControlStateHighlighted];
	[cell.m_BtnItem_5 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_comic.png") forState:UIControlStateNormal];
	[cell.m_BtnItem_5 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_comic_on.png") forState:UIControlStateHighlighted];
	[cell.m_BtnItem_6 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_comic.png") forState:UIControlStateNormal];
	[cell.m_BtnItem_6 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_comic_on.png") forState:UIControlStateHighlighted];
	[cell.m_BtnItem_7 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_comic.png") forState:UIControlStateNormal];
	[cell.m_BtnItem_7 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_comic_on.png") forState:UIControlStateHighlighted];
	[cell.m_BtnItem_8 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_comic.png") forState:UIControlStateNormal];
	[cell.m_BtnItem_8 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_comic_on.png") forState:UIControlStateHighlighted];
	[cell.m_BtnItem_9 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_novel.png") forState:UIControlStateNormal];
	[cell.m_BtnItem_9 setBackgroundImage:RESOURCE_IMAGE(@"main_thum_box_novel_on.png") forState:UIControlStateHighlighted];
	
	
	for(int index = 0; index < [m_List count]; index++) {
		
		NSMutableDictionary* content = [m_List objectAtIndex:index];
		
		NSData* imageData = [content objectForKey:@"image_data"];
		if (imageData == nil) {
			if (m_TableView.dragging == NO && m_TableView.decelerating == NO) {
				NSURL* imageUrlPath = URL_IMAGE_PATH([content objectForKey:@"file_path"]);
				[self startIconImageDownload:[NSIndexPath indexPathForRow:index inSection:0] imageUrl:imageUrlPath];								
			}
		}
		
		switch(index) {
			case 0:
				[cell.m_Title_1 setText:(NSString *) [content objectForKey:@"title"]];
				if (imageData != nil) {
					[cell.m_ImageItem_1 setImage:[UIImage imageWithData:imageData]];
				}
				[self setTagImage:cell.m_IconItem_1 content:content];				
				break;
			case 1:
				if (imageData != nil) {
					[cell.m_ImageItem_2 setImage:[UIImage imageWithData:imageData]]; 
				}
				[self setTagImage:cell.m_IconItem_2 content:content];
				break;
			case 2:
				[cell.m_Title_3 setText:(NSString *) [content objectForKey:@"title"]];					
				if (imageData != nil) {
					[cell.m_ImageItem_3 setImage:[UIImage imageWithData:imageData]]; 
				}
				[self setTagImage:cell.m_IconItem_3 content:content];
				break;
			case 3:
				if (imageData != nil) {
					[cell.m_ImageItem_4 setImage:[UIImage imageWithData:imageData]]; 
				}
				[self setTagImage:cell.m_IconItem_4 content:content];
				break;
			case 4:
				[cell.m_Title_5 setText:(NSString *) [content objectForKey:@"title"]];						
				if (imageData != nil) {
					[cell.m_ImageItem_5 setImage:[UIImage imageWithData:imageData]]; 
				}
				[self setTagImage:cell.m_IconItem_5 content:content];
				break;
			case 5:
				[cell.m_Title_6 setText:(NSString *) [content objectForKey:@"title"]];						
				if (imageData != nil) {
					[	cell.m_ImageItem_6 setImage:[UIImage imageWithData:imageData]]; 
				}
				[self setTagImage:cell.m_IconItem_6 content:content];
				break;
			case 6:
				[cell.m_Title_7 setText:(NSString *) [content objectForKey:@"title"]];						
				if (imageData != nil) {
					[cell.m_ImageItem_7 setImage:[UIImage imageWithData:imageData]]; 
				}
				[self setTagImage:cell.m_IconItem_7 content:content];
				break;
			case 7:
				[cell.m_Title_8 setText:(NSString *) [content objectForKey:@"title"]];						
				if (imageData != nil) {			
					[cell.m_ImageItem_8 setImage:[UIImage imageWithData:imageData]]; 
				}
				[self setTagImage:cell.m_IconItem_8 content:content];
				break;
			case 8:
				if (imageData != nil) {
					[cell.m_ImageItem_9 setImage:[UIImage imageWithData:imageData]]; 
				}
				[self setTagImage:cell.m_IconItem_9 content:content];
				break;				
		}

	}

	return cell;
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

- (void) iconImageDidLoad:(NSIndexPath *)indexPath iconImage:(NSData*)iconImage
{
	if ([m_IconDownloaders count] == 0 || ([m_List count] - 1) < indexPath.row) { 
		return; 
	}
	
	NSLog(@"row=[%d]", indexPath.row);
	StoreFreeContentCell* cell = (StoreFreeContentCell*) [m_TableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	
	switch(indexPath.row) {
		case 0:
			[cell.m_ImageItem_1 setImage:[UIImage imageWithData:iconImage]];
			break;
		case 1:
			[cell.m_ImageItem_2 setImage:[UIImage imageWithData:iconImage]]; 
			break;
		case 2:
			[cell.m_ImageItem_3 setImage:[UIImage imageWithData:iconImage]]; 
			break;
		case 3:
			[cell.m_ImageItem_4 setImage:[UIImage imageWithData:iconImage]]; 
			break;
		case 4:
			[cell.m_ImageItem_5 setImage:[UIImage imageWithData:iconImage]]; 
			break;
		case 5:
			[cell.m_ImageItem_6 setImage:[UIImage imageWithData:iconImage]]; 
			break;
		case 6:
			[cell.m_ImageItem_7 setImage:[UIImage imageWithData:iconImage]]; 
			break;
		case 7:
			[cell.m_ImageItem_8 setImage:[UIImage imageWithData:iconImage]]; 
			break;
		case 8:
			[cell.m_ImageItem_9 setImage:[UIImage imageWithData:iconImage]]; 
			break;				
	}					
}


#pragma mark -
#pragma mark TableView tableDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 474.0f + 41.0f;
}

#pragma mark -
#pragma mark Cartoon/Epub ViewItem Selected Delegate

- (void) selectedStoreFreeContentItem:(id)sender index:(NSInteger)index
{
	NSLog(@"index=[%d], listCount=[%d]", index, [m_List count]);
	
	if (([m_List count] - 1) < index || [m_List count] == 0) { return; }
	
	NSDictionary* content = [m_List objectAtIndex:index];
	if (content != nil) {
		NSLog(@"ContentType=[%@], masterNo=[%@]", [content objectForKey:@"main_group"], [content objectForKey:@"master_no"]);
				
		NSString* masterNumber = [[content objectForKey:@"master_no"] stringValue];
		NSString* contentType = [content objectForKey:@"main_group"];
		
		BookDetailViewController* bookDetailViewController = nil;
		if ([BI_MAIN_GROUP_TYPE_CARTOON isEqualToString:contentType] == YES) {
			bookDetailViewController = [BookDetailViewController createWithMasterNumber:masterNumber contentType:ContentTypeCartoon subGroup:[content objectForKey:@"sub_group"]];
		}
		else {
			bookDetailViewController = [BookDetailViewController createWithMasterNumber:masterNumber contentType:ContentTypeEpub subGroup:[content objectForKey:@"sub_group"]];			
		}

		if (bookDetailViewController != nil) {		
			[APPDELEGATE.m_StoreFreeNavController.view addSubview:bookDetailViewController.view];					
		}		
	}
	
}

#pragma Mark - UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView.contentOffset.y > 0) {
		[m_TopShowLine setHidden:NO];
	}
	else {
		[m_TopShowLine setHidden:YES];
	}

}

@end
