    //
//  MyBookFixRateTicket.m
//  PlayBook
//
//  Created by Daniel on 12. 5. 27..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/CALayer.h>
#import "MyBookFixRateTicketViewController.h"
#import "MyBookFixRateTicketCell.h"
#import "UserProfile.h"


@implementation MyBookFixRateTicketViewController

@synthesize m_List;
@synthesize m_UserNumber;


+ (id)createWithUserNumber:(NSString*)userNumber
{
	MyBookFixRateTicketViewController* viewController = [[MyBookFixRateTicketViewController alloc] initWithNibName:@"MyBookContentViewController" bundle:[NSBundle mainBundle]];
	if (viewController == nil) {
		return nil;
	}
	viewController.m_UserNumber = userNumber;
	
	return viewController;
}

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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNotification:) name:NOTIFY_DATACHANGED object:nil];
	
	[self setTitleText:@"정액 이용권"];
	[self setShowEditButton:NO];
	[self setShowHeader:NO];
	[self setShowFooter:YES];
	
	m_PageCount = DE_DEFAULT_PAGE_COUNT;
	m_ListCount = DF_DEFAULT_LIST_COUNT;
	
	m_List = [[NSMutableArray alloc] initWithCapacity:0];
	
	m_TableView.hidden = YES;
	m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:m_Background orientation:UIDeviceOrientationPortrait];
	
	
	NSString* pageCount = [[NSNumber numberWithInteger:m_PageCount]stringValue];
	NSString* listCount = [[NSNumber numberWithInteger:m_ListCount]stringValue];
	
	[m_Request buyListWithUserNo:m_UserNumber pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_FLATRATE delegate:self];
	
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
	
    [super dealloc];
}


#pragma mark -
#pragma mark LoginChanged Notification 
- (void)onReceiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:NOTIFY_DATACHANGED] == YES) 
	{
		if ([m_UserNumber isEqualToString:[UserProfile getUserNo]] == NO) {
			
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
		[self setStatusError:RESC_STRING_NETWORK_FAIL status:ErrorStatusMyFixRate];
	}
}

- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
	
	NSDictionary* dicInfo = (NSDictionary *) userInfo;
	
	if (command == DF_URL_CMD_BUY_LIST) {
		[self stopLoadingMore];

		NSString* rtCode = [dicInfo objectForKey:@"result"];
		if ([rtCode isEqualToString:@"0"] == YES) {
			NSArray* rtEntry = [dicInfo objectForKey:@"contentInfo"];
			
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
			[self setStatusError:RESC_STRING_NO_RECEIVE_DATA_TICKET status:ErrorStatusMyFixRate];
		}
		else {
			m_TableView.hidden = NO;		
			[self setHiddenStatusError];
		} 
	}
}

- (BOOL) __isExpireContent:(NSDictionary*)dicItem 
{	
	NSString* status = [dicItem objectForKey:@"status"];
	
	if([status isEqualToString:@"F"] == YES) {
		return YES;
	}	
	return NO;	
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
	static NSString*    CellItentifier = @"MyBookFixRateUsingCell";
	
	NSMutableDictionary* dicItem = [m_List objectAtIndex:indexPath.row];
	BOOL isExpire = [self __isExpireContent:dicItem];
	
	MyBookFixRateTicketCell* cell = (MyBookFixRateTicketCell*) [tableView dequeueReusableCellWithIdentifier:CellItentifier];	
	if (cell == nil) {
		NSArray* cellObjectArray = nil;
		if (isExpire == YES) {
			cellObjectArray = [[NSBundle mainBundle] loadNibNamed:@"MyBookFixRateExpiredCell" owner:nil options:nil]; 
		}
		else {
			cellObjectArray = [[NSBundle mainBundle] loadNibNamed:@"MyBookFixRateUsingCell" owner:nil options:nil]; 
		}

		for (id currentObject in cellObjectArray) {
			if ([currentObject isKindOfClass:[MyBookFixRateTicketCell class]] == true) {
				cell = (MyBookFixRateTicketCell *) currentObject;
				break;
			}
		}
	}

	UIImage* backgroundImage = nil;
	NSString* expireDate = nil;
	NSString* expireDateStatus = getStringValue([dicItem objectForKey:@"expiredt"]);
	
	int lastIndex = [m_List count] - 1;
	if (isExpire == YES) {

        if (lastIndex == 0) {
            backgroundImage = RESOURCE_IMAGE(@"list_fixrate_ticket_expired_one_bg.png");  
        }
        else {
            if (indexPath.row == 0) {
                backgroundImage = RESOURCE_IMAGE(@"list_fixrate_ticket_expired_top_bg.png");  
            }
            else if (indexPath.row == lastIndex) {
                backgroundImage = RESOURCE_IMAGE(@"list_fixrate_ticket_expired_bottom_bg.png");  
            }
            else {
                backgroundImage = RESOURCE_IMAGE(@"list_fixrate_ticket_expired_bg.png");  
            }            
        }
//		backgroundImage = RESOURCE_IMAGE(@"list_fixrate_ticket_expired_bg.png");  
		
		expireDate = [NSString stringWithFormat:@"만료일 : %@.%@.%@ 만료됨", 
					  [expireDateStatus substringWithRange:NSMakeRange(0, 4)],
					  [expireDateStatus substringWithRange:NSMakeRange(4, 2)],
					  [expireDateStatus substringWithRange:NSMakeRange(6, 2)]];		
	}
	else {

        if (lastIndex == 0) {
            backgroundImage = RESOURCE_IMAGE(@"list_fixrate_ticket_one_bg.png");  
        }
        else {
            if (indexPath.row == 0) {
                backgroundImage = RESOURCE_IMAGE(@"list_fixrate_ticket_top_bg.png");  
            }
            else if (indexPath.row == lastIndex) {
                backgroundImage = RESOURCE_IMAGE(@"list_fixrate_ticket_bottom_bg.png");  
            }
            else {
                backgroundImage = RESOURCE_IMAGE(@"list_fixrate_ticket_bg.png");  
            }
        }
        
//		backgroundImage = RESOURCE_IMAGE(@"list_fixrate_ticket_bg.png");  
		
		expireDate = [NSString stringWithFormat:@"만료일 : %@.%@.%@", 
					  [expireDateStatus substringWithRange:NSMakeRange(0, 4)],
					  [expireDateStatus substringWithRange:NSMakeRange(4, 2)],
					  [expireDateStatus substringWithRange:NSMakeRange(6, 2)]];
	}
	cell.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];  
			
	[cell.m_TicketTitle setText:[dicItem objectForKey:@"title"]];
	[cell.m_ExpireDate setText:expireDate];
	
	return cell;		
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSMutableDictionary* dicItem = [m_List objectAtIndex:indexPath.row];

	int lastIndex = [m_List count] - 1;

    if (lastIndex == 0) {
        return 73.0f;
    }
    
	if (indexPath.row == lastIndex) {
		return 71.0f;
	}
	return 68.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
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
	
	[m_Request buyListWithUserNo:m_UserNumber pageCount:pageCount listCount:listCount myType:BI_PURCHASE_TYPE_FLATRATE delegate:self];	
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


@end
