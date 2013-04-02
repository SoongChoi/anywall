    //
//  MyBookGallaryMain.m
//  PlayBook
//
//  Created by Daniel on 12. 4. 16..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "PlayyBookWebView.h"
#import "PlayyBookSettings.h"
#import "MyBookMainViewController.h"
#import "MyBookReadContentViewController.h"
#import "MyBookZzimContentViewController.h"
#import "MyBookFixRateTicketViewController.h"
#import "MyBookGallaryViewController.h"
#import "MyBookStreamViewController.h"
#import "MyBookDownloadViewController.h"
#import "UserProfile.h"

#import "MyBookMainItemCell.h"


#define _MYBOOK_ITEM_READ_CONTENT		0
#define _MYBOOK_ITEM_ZZIM_CONTENT		1
#define _MYBOOK_ITEM_FIXRATE_CONTENT	2
#define _MYBOOK_ITEM_STREAM_CONTENT	    3
#define _MYBOOK_ITEM_DOWNLOAD_CONTENT	4
#define _MYBOOK_ITEM_BOOKGALLARY		5
#define _MYBOOK_ITEM_MAX_COUNT			6

@implementation MyBookMainViewController

@synthesize m_TableView;


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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[self.view setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];
	
	[m_TableView setBackgroundColor:[UIColor clearColor]];
	//[m_TableView setSeparatorColor:[UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:1.0f]];
	[m_TableView setScrollsToTop:NO];
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


- (void)dealloc {
	[m_TableView release];
	
    [super dealloc];
}



- (void) clickBtnAsCenter:(id)sender
{
//	PlayyBookWebView *asCenterViewController = [PlayyBookWebView createRealnameOrAdult:WEBVIEW_TYPE_ADULT];
//	[APPDELEGATE.m_Window addSubview:asCenterViewController.view];
	
	PlayyBookWebView* asCenterViewController = [PlayyBookWebView createWithCloseButtonType:CloseButtonRight titleName:@"고객센터" reqURL:@"http://help.paran.com/faq/mobile/wk/mIndex.jsp?nodeId=NODE0000001156&TBID=TBOX20100805000001"];
	if (asCenterViewController != nil) {
		[APPDELEGATE.m_Window addSubview:asCenterViewController.view];
	}
}

- (void) clickBtnSettings:(id)sender
{
	PlayyBookSettings* settingsViewController = [PlayyBookSettings createSettings];
	if (settingsViewController != nil) {
		[APPDELEGATE.m_MyBookMainViewController.view addSubview:settingsViewController.view];		
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
	return _MYBOOK_ITEM_MAX_COUNT;
}


// Customize the appearance of table view cells.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString* CellItentifier = @"MyBookMainItemCell";
	
	MyBookMainItemCell* cell = (MyBookMainItemCell*) [tableView dequeueReusableCellWithIdentifier:CellItentifier];	
	if (cell == nil) {
		NSArray* cellObjectArray = [[NSBundle mainBundle] loadNibNamed:@"MyBookMainItemCell" owner:nil options:nil]; 
		for (id currentObject in cellObjectArray) {
			if ([currentObject isKindOfClass:[MyBookMainItemCell class]] == true) {
				cell = (MyBookMainItemCell*) currentObject;
				break;
			}
		}	
	}
	
	if (_MYBOOK_ITEM_READ_CONTENT == indexPath.row) {
		cell.backgroundView = [ [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"mybook_list_item_bg_top_off.png")] autorelease];
	}
	else {
		cell.backgroundView = [ [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"mybook_list_item_bg_off.png")] autorelease];		
	}
	cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"mybook_list_item_bg_on.png")] autorelease];
	
	switch (indexPath.row) {
		case _MYBOOK_ITEM_READ_CONTENT:
			[cell setTitleWithIcon:RESOURCE_IMAGE(@"mybook_icon_read.png") itemTitle:@"내가 본 작품"];
			break;
		case _MYBOOK_ITEM_ZZIM_CONTENT:
			[cell setTitleWithIcon:RESOURCE_IMAGE(@"mybook_icon_zzim.png") itemTitle:@"찜한작품"];
			break;
		case _MYBOOK_ITEM_FIXRATE_CONTENT:
			[cell setTitleWithIcon:RESOURCE_IMAGE(@"mybook_icon_fixrate.png") itemTitle:@"정액이용권"];
			break;			
		case _MYBOOK_ITEM_STREAM_CONTENT:
			[cell setTitleWithIcon:RESOURCE_IMAGE(@"mybook_icon_stream.png") itemTitle:@"스트리밍으로 구매한 작품"];
			break;			
		case _MYBOOK_ITEM_DOWNLOAD_CONTENT:
			[cell setTitleWithIcon:RESOURCE_IMAGE(@"mybook_icon_download.png") itemTitle:@"다운로드로 구매한 작품"];
			break;			
		case _MYBOOK_ITEM_BOOKGALLARY:
			[cell setTitleWithIcon:RESOURCE_IMAGE(@"mybook_icon_gallary.png") itemTitle:@"다운로드 보관함"];
			break;
	}
	
	return cell;	
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row ==  _MYBOOK_ITEM_READ_CONTENT) {
		return 55.0f;
	}
	return 53.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row != _MYBOOK_ITEM_BOOKGALLARY) {
		if ([UserProfile getLoginState] == NO) {
			[APPDELEGATE createLoginViewController];
			return;
		}
	}
	
	switch (indexPath.row) {
		case _MYBOOK_ITEM_READ_CONTENT:		
		{
			MyBookReadContentViewController* readContentViewController = [MyBookReadContentViewController createWithUserNo:[UserProfile getUserNo]];
			if (readContentViewController != nil) {
				[APPDELEGATE.m_MyBookMainViewController.view addSubview:readContentViewController.view];		
			}
		}
		break;
		case _MYBOOK_ITEM_ZZIM_CONTENT:
		{
			MyBookZzimContentViewController* zzimContentViewController = [MyBookZzimContentViewController createWithUserNo:[UserProfile getUserNo]];
			if (zzimContentViewController != nil) {
				[APPDELEGATE.m_MyBookMainViewController.view addSubview:zzimContentViewController.view];		
			}
		}
		break;
		case _MYBOOK_ITEM_FIXRATE_CONTENT:
		{
			MyBookFixRateTicketViewController* ticketViewController = [MyBookFixRateTicketViewController createWithUserNumber:[UserProfile getUserNo]];
			if (ticketViewController != nil) {
				[APPDELEGATE.m_MyBookMainViewController.view addSubview:ticketViewController.view];		
			}
		}
			break;			
		case _MYBOOK_ITEM_STREAM_CONTENT:
		{
			MyBookStreamViewController* streamViewController = [MyBookStreamViewController createWithUserNo:[UserProfile getUserNo]];
			if (streamViewController != nil) {
				[APPDELEGATE.m_MyBookMainViewController.view addSubview:streamViewController.view];		
			}
		}
		break;			
		case _MYBOOK_ITEM_DOWNLOAD_CONTENT:
		{
			MyBookDownloadViewController* downloadViewController = [MyBookDownloadViewController createWithUserNo:[UserProfile getUserNo]];
			if (downloadViewController != nil) {
				[APPDELEGATE.m_MyBookMainViewController.view addSubview:downloadViewController.view];		
			}
		}
		break;			
		case _MYBOOK_ITEM_BOOKGALLARY:
		{
			MyBookGallaryViewController* gallaryViewController = [MyBookGallaryViewController createWithDelegate:nil];
			if (gallaryViewController != nil) {		
				[APPDELEGATE.m_MyBookMainViewController.view addSubview:gallaryViewController.view];		
			}
		}
		break;
	}

}


@end
