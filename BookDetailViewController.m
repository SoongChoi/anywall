//
//  BookDetailController.m
//  PlayBook
//
//  Created by Daniel on 12. 4. 2..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "BookDetailViewController.h"
#import "BookVolumeGridView.h"
#import "UserProfile.h"
#import "SettingPreference.h"
#import "NWAppUsageLogger.h"
#import "PlayyBookWebView.h"

#define __BTN_TAG_BACK		0
#define __BTN_TAG_FAVORITE	1
#define __BTN_TAG_GOOD		2
#define __BTN_TAG_BAD		3
#define __BTN_TAG_VIEWMORE  4

#define __DEFAULT_DESCRIPTION_LINE_Y	219.0f
#define __DESCRIPTION_MARGIN_HEIGHT		26.0f

#define __DEFAULT_DETAILVIEW_HEIGHT		230.0f
#define __DEFAULT_GRIDVIEW_HEIGHT		200.0f

#define __DEFAULT_DESCRIPTION_WIDTH		296
#define __DEFAULT_DESCRIPTION_HEIGHT	40



@implementation BookDetailViewController

@synthesize m_Background;
@synthesize m_DetailView;

@synthesize m_BtnClose;
@synthesize m_ImageTitle;
@synthesize m_Title;
@synthesize m_Writer;
@synthesize m_Painter;
@synthesize m_VolumeStatus;
@synthesize m_Cateregory;	

@synthesize m_Faverite;
@synthesize m_BtnLike;
@synthesize m_LikeImage;
@synthesize m_LabLikeCount;
@synthesize m_BtnUnLike;
@synthesize	m_UnLikeImage;
@synthesize m_LabUnLikeCount;

@synthesize m_BtnMoreView;
@synthesize m_Discription;
@synthesize m_BottomLine;

@synthesize m_ScrollView;
@synthesize m_VolumeGridView;
@synthesize m_BgGridView;
@synthesize m_VolumeGridBottomLine;
@synthesize m_SelectedVolume;

@synthesize m_Request;

@synthesize m_MasterNumber;
@synthesize m_ContentType;

@synthesize m_DetailDictionary;

@synthesize m_ContentDiscription;
@synthesize m_VolumeArray;


+ (id) createWithMasterNumber:(NSString *)masterNumber  contentType:(PlayBookContentType)contentType subGroup:(NSString *)subGroup
{
	if ([subGroup isEqualToString:@"AD"] == YES)
	{
		if ([UserProfile getLoginState] != YES)
		{
			[APPDELEGATE createLoginViewController];
			
			return nil;
		}
		
		if ([UserProfile getAdultCheck] != YES)
		{
			NSInteger webviewType = WEBVIEW_TYPE_ADULT;
			if ([UserProfile getRealnameCheck] != YES)
			{
				webviewType = WEBVIEW_TYPE_REALNAME;
			}
			PlayyBookWebView *asCenterViewController = [PlayyBookWebView createRealnameOrAdult:webviewType];
			[APPDELEGATE.m_Window addSubview:asCenterViewController.view];
			
			return nil;
		}
	}
	
	BookDetailViewController* viewController = nil;
	if (contentType == ContentTypeCartoon) {
		viewController = (BookDetailViewController *)[[BookDetailViewController alloc] initWithNibName:@"BookDetailCartoon" bundle:[NSBundle mainBundle]];
	}
	else {
		viewController = (BookDetailViewController *)[[BookDetailViewController alloc] initWithNibName:@"BookDetailEpub" bundle:[NSBundle mainBundle]];
	}
	
	if (viewController == nil) {		
		return nil;
	}
	viewController.m_MasterNumber = masterNumber;
	viewController.m_ContentType  = contentType;
	
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
	
	NSLog(@"m_MasterNumber=[%@]", m_MasterNumber);

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNotification:) name:NOTIFY_DATACHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNotification:) name:NOTIFY_ZZIMCHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNotification:) name:NOTIFY_READCHANGED object:nil];
	
	[m_Title setUserInteractionEnabled:YES];
	UITapGestureRecognizer *tapTitleGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapTitle)] autorelease];
	[m_Title addGestureRecognizer:tapTitleGesture];
	
	[m_BtnClose setImage:RESOURCE_IMAGE(@"view_top_btn_back_off.png") forState:UIControlStateNormal];
	[m_BtnClose setImage:RESOURCE_IMAGE(@"view_top_btn_back_on.png") forState:UIControlStateHighlighted];
	[m_BtnClose setImageEdgeInsets:UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f)];

	[m_Background setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];
	[m_DetailView setBackgroundColor:[UIColor clearColor]];
	
	[m_VolumeGridView setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]];

	[m_ScrollView setBackgroundColor:[UIColor clearColor]];	
	[m_ScrollView setScrollsToTop:YES];
	
	[m_BtnMoreView setBackgroundImage:RESOURCE_IMAGE(@"view_btn_more_off.png") forState:UIControlStateNormal];
	[m_BtnMoreView setBackgroundImage:RESOURCE_IMAGE(@"view_btn_more_on.png") forState:UIControlStateHighlighted];
	[m_BtnMoreView setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];
	
	[m_BgGridView setFrame:CGRectMake(0, 220, 320, __DEFAULT_GRIDVIEW_HEIGHT)]; 
	
	CGRect rect = m_BottomLine.frame;
	rect.origin.y = __DEFAULT_DESCRIPTION_LINE_Y;
	[m_BottomLine setFrame:rect];
	
	m_IsDataLoaded = NO;
	m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:m_Background orientation:UIDeviceOrientationPortrait];
	
	m_Request = [[PlayBookRequest alloc] init];
	if ([UserProfile getLoginState] == YES) {
		[m_Request contentInfoWithMasterNo:m_MasterNumber userNo:[UserProfile getUserNo] delegate:self];
	}
	else {
		[m_Request contentInfoWithMasterNo:m_MasterNumber delegate:self];	
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
					 }];
}

- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];	
}

- (IBAction) actionTapTitle
{
	[m_ScrollView setContentOffset:CGPointMake(0,0) animated:YES];
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

	NSLog(@"BookDetailViewController - dealloc");
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if([m_Request isDownloading] == YES) {
		[m_Request cancelConnection];
	}
	
	if(m_DetailDictionary != nil) {
		[m_DetailDictionary release];
	}
	
	[m_Request release];
	
	[m_VolumeArray release];
	
	
	[m_ImageTitle release];
	[m_Title release];
	[m_Writer release];
    [m_Painter release];
	[m_VolumeStatus release];
	[m_Cateregory release];	
	[m_BtnLike release];
	[m_BtnUnLike release];
	[m_BtnMoreView release];
	[m_Discription release];
	[m_BottomLine release];
	
	[m_ScrollView release];
	[m_VolumeGridView release];
	[m_BgGridView release];
	[m_VolumeGridBottomLine release];
	
	[m_BtnClose release];
	[m_Background release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark LoginChanged Notification 
- (void)onReceiveNotification:(NSNotification *) notification
{
	NSString* notifyName = [notification name];
	
	if ([notifyName isEqualToString:NOTIFY_DATACHANGED] == YES) {
		if (m_ActivityIndicator == nil) {			
			m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:m_Background orientation:UIDeviceOrientationPortrait];
		}
		m_IsDataLoaded = NO;
		
        [self.view removeFromSuperview];
        [self release];
        /*
		if ([UserProfile getLoginState] == YES) {
			[m_Request contentInfoWithMasterNo:m_MasterNumber userNo:[UserProfile getUserNo] delegate:self];
		}
		else {
			[m_Request contentInfoWithMasterNo:m_MasterNumber delegate:self];	
		}
         */
	}	
    else if ([notifyName isEqualToString:NOTIFY_ZZIMCHANGED] == YES) 
	{
		if (m_IsDataLoaded == NO) { return; }
		
		NSDictionary* zzimDic  = [notification userInfo];
		NSString* zzimType     = getStringValue([zzimDic objectForKey:@"zzim_type"]);
		NSString* masterComp = getStringValue([zzimDic objectForKey:@"master_no"]);
		
		if ([m_MasterNumber isEqualToString:masterComp] == YES) 
		{
			if ([zzimType isEqualToString:BI_MARK_ZZIM] == YES) {	
				NSString* zzimNumber = [zzimDic objectForKey:@"zzim_no"];
				
				[m_DetailDictionary setObject:zzimNumber forKey:@"zimm_no"];
				[m_Faverite setImage:RESOURCE_IMAGE(@"view_top_btn_favorite_on.png") forState:UIControlStateNormal];
			}
			else {
				[m_DetailDictionary setObject:@"-1" forKey:@"zimm_no"];
				[m_Faverite setImage:RESOURCE_IMAGE(@"view_top_btn_favorite_off.png") forState:UIControlStateNormal];	
			}
		}						
	}
    else if ([notifyName isEqualToString:NOTIFY_READCHANGED] == YES)
	{
        if (m_IsDataLoaded == NO) { return; }
		
		NSDictionary* readDic  = [notification userInfo];
		NSString* masterNo = getStringValue([readDic objectForKey:@"master_no"]);
		NSString* volumeNo = getStringValue([readDic objectForKey:@"volume_number"]);
		
        if ([m_MasterNumber isEqualToString:masterNo] == YES)
		{
            m_SelectedVolumeIndex = [volumeNo intValue] - 1;
            m_SelectedVolume = (UIButton *)[m_VolumeGridView viewWithTag:m_SelectedVolumeIndex];
            
            [self setReadContentWithVolume:m_SelectedVolume read:YES];
        }
    }
}


- (void) showGoodAnimation
{
	UIImageView* aniImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-72.0f, -77.0f, 143.0, 122.0f)];
	
	aniImageView.animationImages = [NSArray arrayWithObjects:	
									[UIImage imageNamed:@"up0001.png"],
									[UIImage imageNamed:@"up0002.png"],
									[UIImage imageNamed:@"up0003.png"],
									[UIImage imageNamed:@"up0004.png"],
									[UIImage imageNamed:@"up0005.png"],
									[UIImage imageNamed:@"up0006.png"],
									[UIImage imageNamed:@"up0007.png"],
									[UIImage imageNamed:@"up0008.png"],
									[UIImage imageNamed:@"up0009.png"],
									[UIImage imageNamed:@"up0010.png"],
									[UIImage imageNamed:@"up0011.png"],
									[UIImage imageNamed:@"up0012.png"],
									[UIImage imageNamed:@"up0013.png"],
									[UIImage imageNamed:@"up0014.png"],
									[UIImage imageNamed:@"up0015.png"],
									[UIImage imageNamed:@"up0016.png"],
									[UIImage imageNamed:@"up0017.png"],
									[UIImage imageNamed:@"up0018.png"],
									[UIImage imageNamed:@"up0019.png"],
									[UIImage imageNamed:@"up0020.png"],
									[UIImage imageNamed:@"up0021.png"],
									[UIImage imageNamed:@"up0022.png"],
									[UIImage imageNamed:@"up0023.png"],
									[UIImage imageNamed:@"up0024.png"], nil];
	
	[m_BtnUnLike addSubview:aniImageView];
	[m_BtnUnLike bringSubviewToFront:aniImageView];
	[m_BtnUnLike setNeedsDisplay];
	
	[m_LikeImage setHidden:YES];
	
	aniImageView.animationDuration = 0.88889;
	aniImageView.animationRepeatCount = 1;
	[aniImageView startAnimating];
	
	//Hide button image
	
	[[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(OnGoodAniEnd:) userInfo:nil repeats:NO] retain];
	
	[aniImageView release]; 
}

- (void) OnGoodAniEnd:(NSTimer *)timer
{	
	NSLog(@"Show button Image");
	
	[m_LikeImage setHidden:NO];
	[timer release];
}

- (void) showBadAnimation
{
	UIImageView* aniImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-75.0f, -77.0f, 143.0, 122.0f)];
	
	aniImageView.animationImages = [NSArray arrayWithObjects:	
									[UIImage imageNamed:@"down0001.png"],
									[UIImage imageNamed:@"down0002.png"],
									[UIImage imageNamed:@"down0003.png"],
									[UIImage imageNamed:@"down0004.png"],
									[UIImage imageNamed:@"down0005.png"],
									[UIImage imageNamed:@"down0006.png"],
									[UIImage imageNamed:@"down0007.png"],
									[UIImage imageNamed:@"down0008.png"],
									[UIImage imageNamed:@"down0009.png"],
									[UIImage imageNamed:@"down0010.png"],
									[UIImage imageNamed:@"down0011.png"],
									[UIImage imageNamed:@"down0012.png"],
									[UIImage imageNamed:@"down0013.png"],
									[UIImage imageNamed:@"down0014.png"],
									[UIImage imageNamed:@"down0015.png"],
									[UIImage imageNamed:@"down0016.png"],
									[UIImage imageNamed:@"down0017.png"],
									[UIImage imageNamed:@"down0018.png"],
									[UIImage imageNamed:@"down0019.png"],
									[UIImage imageNamed:@"down0020.png"],
									[UIImage imageNamed:@"down0021.png"],
									[UIImage imageNamed:@"down0022.png"],
									[UIImage imageNamed:@"down0023.png"],
									[UIImage imageNamed:@"down0024.png"], nil];
	
	[m_BtnUnLike addSubview:aniImageView];
	[m_BtnUnLike bringSubviewToFront:aniImageView];
	[m_BtnUnLike setNeedsDisplay];
	
	[m_UnLikeImage setHidden:YES];
	
	aniImageView.animationDuration = 0.88889;
	aniImageView.animationRepeatCount = 1;
	[aniImageView startAnimating];
	
	//Hide button image
	
	[[NSTimer scheduledTimerWithTimeInterval:0.9 target:self selector:@selector(OnBadAniEnd:) userInfo:nil repeats:NO] retain];
	
	[aniImageView release]; 
}

- (void) OnBadAniEnd:(NSTimer *)timer
{
	[m_UnLikeImage setHidden:NO];
	
	NSLog(@"Show button Image");
	[timer release];
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
	
	if (command == DF_URL_CMD_CHECK_BUY) 
	{		
		if (m_SelectedVolume != nil) {
			[self setReadContentWithVolume:m_SelectedVolume read:NO]; 
		}	
		m_SelectedVolume = nil;
	}
	
	NSLog(@"%@", error);
}

- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{	
	if (m_ActivityIndicator != nil) {
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation]; 
	}

	NSDictionary *dicInfo = (NSDictionary *) userInfo;
	
	if (command == DF_URL_CMD_CONTENT_INFO) {
		NSInteger rtCode = [[dicInfo objectForKey:@"result"] intValue];
		
		if (rtCode == 0) {
			NSDictionary *content = [dicInfo objectForKey:@"contentInfo"];
			
			if(m_DetailDictionary != nil) {
				[m_DetailDictionary release];
			}
			m_DetailDictionary = [content mutableCopy];
			
			[m_Title setText:[content objectForKey:@"title"]];
			         
            //[m_Writer setText:[content objectForKey:@"writer"]];
            //[m_Painter setText:@"그림작가"];
            NSString* writer = [content objectForKey:@"writer"];
            NSString* painter = [content objectForKey:@"painter"];
            
            if ([writer length] > 0 && [painter length] > 0){
                if ([writer isEqualToString:painter] == YES){
                    //set writer 글/그림 and move
                    [m_Writer setText:[NSString stringWithFormat:@"글/그림 : %@", writer]];
                    //have to move
                    CGRect rt = [m_Writer frame];
                    rt.origin.y = 21;
                    [m_Writer setFrame:rt];                    
                }
                else{
                    [m_Writer setText:[NSString stringWithFormat:@"글 : %@", writer]];
                    [m_Painter setText:[NSString stringWithFormat:@"그림 : %@", painter]];
                    //don't need to move
                }
            }
            else if ([writer length] > 0 && [painter length] == 0){
                //set writer 글 and move
                [m_Writer setText:[NSString stringWithFormat:@"글 : %@", writer]];
                //have to move
                CGRect rt = [m_Writer frame];
                rt.origin.y = 21;
                [m_Writer setFrame:rt];
            }
            else if ([painter length] > 0 && [writer length] == 0){
                //set writer 글 and move
                [m_Writer setText:[NSString stringWithFormat:@"그림 : %@", painter]];
                CGRect rt = [m_Writer frame];
                rt.origin.y = 21;
                [m_Writer setFrame:rt];
            }
            			
			NSData* imageData = [NSData dataWithContentsOfURL:URL_IMAGE_PATH([content objectForKey:@"file_path"])];
			if (imageData != nil) {
				[m_ImageTitle setImage:[UIImage imageWithData:imageData]];
				[m_DetailDictionary setObject:imageData forKey:@"image_data"];
			}
			
			//[m_VolumeStatus setText:[NSString stringWithFormat:@"%@권무료/%@권", [content objectForKey:@"free_count"], [content objectForKey:@"total_count"]]];
			[m_VolumeStatus setText:[content objectForKey:@"service_date"]];
			//BOOL complate = [[content objectForKey:@"complete_yn"] boolValue];
			//NSString* catergory = [content objectForKey:@"sub_group"];			
			//[m_Cateregory setText:[NSString stringWithFormat:@"%@, %@", getStringWithCode(catergory), (complate == YES ? @"완결" : @"미완결")]];
			
			NSString* catergory = getStringWithCode([content objectForKey:@"category"]);
			NSString* subGroup = [content objectForKey:@"sub_group"];
			NSString* strComplete = @" 연재중";
			if ([subGroup isEqualToString:@"AD"] == YES){
				subGroup = @", 성인";
			}
			else {
				subGroup = @"";
			}
			BOOL complate = [[content objectForKey:@"complete_yn"] boolValue];
			if (complate == YES){
				strComplete = @"완결";
			}
			
			[m_Cateregory setText:[NSString stringWithFormat:@"%@%@, %@권 %@", catergory, subGroup, [content objectForKey:@"total_count"], strComplete]];
			
			[m_LabLikeCount setText:getStringValue([content objectForKey:@"good_count"])];
			[m_LabUnLikeCount setText:getStringValue([content objectForKey:@"bad_count"])];	
			
			m_LikcCount = [[content objectForKey:@"good_count"] integerValue];
			m_UnLikcCount = [[content objectForKey:@"bad_count"] integerValue]; 
				
			NSInteger zzimNaumber = [[content objectForKey:@"zzim_no"] integerValue];
			if (zzimNaumber == -1) {
				[m_Faverite setImage:RESOURCE_IMAGE(@"view_top_btn_favorite_off.png") forState:UIControlStateNormal];
			}
			else {
				[m_Faverite setImage:RESOURCE_IMAGE(@"view_top_btn_favorite_on.png") forState:UIControlStateNormal];	
			}	
				
			if ([[content objectForKey:@"bad_yn"] isEqualToString:@"N"] == YES && [[content objectForKey:@"good_yn"] isEqualToString:@"N"] == YES) {
				m_IsExGoodBadAction = YES;
			}
			else {
				m_IsExGoodBadAction = NO;
			}
				
			m_ContentDiscription = [content objectForKey:@"content"];
			m_ContentDiscription = [m_ContentDiscription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; 

			[m_Discription setText:m_ContentDiscription];
				
			CGSize maximumLabelSize = CGSizeMake(__DEFAULT_DESCRIPTION_WIDTH, 9999);	
			//CGSize theTextSize = [m_Discription.text sizeWithFont:m_Discription.font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeTailTruncation];
			CGSize theTextSize = [m_Discription.text sizeWithFont:m_Discription.font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
            
			if (theTextSize.height < __DEFAULT_DESCRIPTION_HEIGHT) {
				m_DescriptionHeight = __DEFAULT_DESCRIPTION_HEIGHT;
			}
			else {
				m_DescriptionHeight = theTextSize.height;
			}
			
			m_VolumeArray = [[dicInfo objectForKey:@"fileInfo"] mutableCopy];
			{
			UIView* volumeGridView = [BookVolumeGridView createWithDelegate:m_VolumeArray delegate:self];	
			[m_VolumeGridView addSubview:volumeGridView];
			
			CGFloat height = volumeGridView.frame.size.height + 30.0f;
			if (height < __DEFAULT_GRIDVIEW_HEIGHT) {
				height = __DEFAULT_GRIDVIEW_HEIGHT;
			}
			[m_BgGridView setFrame:CGRectMake(0, 220, 320, height)];	
			[m_VolumeGridBottomLine setFrame:CGRectMake(0, m_VolumeGridView.frame.origin.y + height, 320, 1)];
				
			[m_ScrollView setFrame:CGRectMake(0, 40, 320, 420)];	
			[m_ScrollView setContentSize:CGSizeMake(320, height + 230.0f + 20.0f)];
				
			NSLog(@"viewDidLoad - width=[%f], height=[%f], descriptionHeight=[%d]", volumeGridView.frame.size.width, height + 230.0f, m_DescriptionHeight);
 
			m_IsDataLoaded = YES;	
			}			
		}

		{
			NWAppUsageLogger *logger = [NWAppUsageLogger logger];
			[logger fireUsageLog:@"MENU_CLICK" andEventDesc:m_MasterNumber andCategoryId:nil];
		}
		
	}
	else if (command == DF_URL_CMD_GOOD_BAD_ZZIM) {
		NSInteger rtCode = [[dicInfo objectForKey:@"result"] intValue];		
		if (rtCode == 0) {
			NSInteger eventResult = [[dicInfo objectForKey:@"event_result"] integerValue];
			NSString* eventType   = getStringValue([dicInfo objectForKey:@"event_type"]);			
			
			if (eventResult == 0 || eventResult == 2) {
				if ([eventType isEqualToString:BI_MARK_GOOD] == YES) {					
					[m_LabLikeCount setText:getStringValue([NSNumber numberWithInteger:(m_LikcCount+=1)])];
					m_IsExGoodBadAction = NO;
				}
				else if ([eventType isEqualToString:BI_MARK_BAD] == YES) {
					[m_LabUnLikeCount setText:getStringValue([NSNumber numberWithInteger:(m_UnLikcCount+=1)])];					
					m_IsExGoodBadAction = NO;
				}
				else if ([eventType isEqualToString:BI_MARK_ZZIM] == YES) {
					NSString* zzimNumber = [dicInfo objectForKey:@"zzim_no"];
					NSString* contentType = BI_MAIN_GROUP_TYPE_CARTOON;
					
					if (m_ContentType != ContentTypeCartoon) {
						contentType = BI_MAIN_GROUP_TYPE_NOVEL;
					}					  
					[m_DetailDictionary setObject:BI_MARK_ZZIM forKey:@"zzim_type"];
					[m_DetailDictionary setObject:zzimNumber forKey:@"zzim_no"];
					[m_DetailDictionary setObject:contentType forKey:@"main_group"];

					[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ZZIMCHANGED object:nil userInfo:m_DetailDictionary];
					
					NSDictionary* zzimDic = [NSDictionary dictionaryWithObjectsAndKeys:BI_MARK_ZZIM, @"zzim_type", m_MasterNumber, @"master_no", [dicInfo objectForKey:@"zzim_no"], @"zzim_no", nil];  
					[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ZZIMCHANGED object:nil userInfo:zzimDic];
				}
			}
			else if (eventResult == 1) //중복등록
			{
				m_IsExGoodBadAction = NO;
				if ([eventType isEqualToString:BI_MARK_GOOD] == YES || [eventType isEqualToString:BI_MARK_BAD] == YES)
				{				
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"알림" 
																		message:@"이미 등록 되어 있습니다" 
																	   delegate:nil cancelButtonTitle:@"확인" 
															  otherButtonTitles:nil];
					[alertView show];
					[alertView release];
				}
			}	
		}
	}
	else if (command == DF_URL_CMD_MY_VIEW_ZZIM_DELETE) {
		NSInteger rtCode = [[dicInfo objectForKey:@"result"] intValue];		
		if (rtCode == 0) {
			NSString* myType = getStringValue([dicInfo objectForKey:@"my_type"]);
			if (myType != nil && [myType isEqualToString:BI_UNMARK_ZZIM] == YES) {
				[m_DetailDictionary setObject:@"-1" forKey:@"zzim_no"];

				NSDictionary* zzimDic = [NSDictionary dictionaryWithObjectsAndKeys:BI_UNMARK_ZZIM, @"zzim_type", m_MasterNumber, @"master_no", nil]; 
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ZZIMCHANGED object:nil userInfo:zzimDic];
			}
		}	
		else {
			[m_Faverite setImage:RESOURCE_IMAGE(@"view_top_btn_favorite_on.png") forState:UIControlStateNormal];
		}

	}
	else if (command == DF_URL_CMD_CHECK_BUY) {
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
						NSString* contentType    = [dicInfo objectForKey:@"content_type"];
						NSString* preDRM		 = [dicInfo objectForKey:@"pre_drm"];
						NSString* filePath       = [fileDictionary valueForKey:@"file_path"];
						NSString* bookNumber	 = getStringValue([fileDictionary valueForKey:@"book_no"]);
						
						NSMutableDictionary* content = [fileDictionary mutableCopy];
						[content setObject:m_Title.text forKey:@"title"]; 
						[content setObject:contentType forKey:@"content_type"];
						[content setObject:preDRM forKey:@"pre_drm"];
						[content setObject:filePath forKey:@"file_path_remote"];
						[content setObject:m_MasterNumber forKey:@"master_no"];
						[content setObject:bookNumber forKey:@"book_no"];
						if (exbuy_type == 3)
							[content setObject:getStringValue([dicResult valueForKey:@"sample_count"]) forKey:@"sample_count"];
						else {
							[content setObject:@"0" forKey:@"sample_count"];
						}
						
						if (m_ContentType == ContentTypeCartoon) {
							CartoonViewController* cartoonViewController = [CartoonViewController createWithContentsStreaming:content];		
							if (cartoonViewController != nil) {
								[APPDELEGATE.m_Window addSubview:cartoonViewController.view];
							}
						}
						else {
							EpubViewController* epubViewController = [EpubViewController createWithContentsStreaming:content];
							if (epubViewController != nil) {
								[APPDELEGATE.m_Window addSubview:epubViewController.view];
							}
						}
						return;
					}					
				}
			}
			else 
			{
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"안내" 
																	message:RESC_STRING_NO_AUTHORITY 
																   delegate:nil cancelButtonTitle:@"확인" 
														  otherButtonTitles:nil];
				[alertView show];
				[alertView release];
			}
			
			if (m_SelectedVolume != nil) {
				[self setReadContentWithVolume:m_SelectedVolume read:NO]; 
			}	
			m_SelectedVolume = nil;
		}
		else {
			NSLog(@"Resoult Isnot OK... rtCode=[%d]", rtCode);
		}

	}

}

#pragma mark -
#pragma mark ScrollView scrollDelegate

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
	NSLog(@"toTop YES");
	return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
}



- (void) setReadContentWithVolume:(UIButton*)volumeButton read:(BOOL)isRead
{
	if (isRead == YES) {
		[volumeButton setBackgroundImage:RESOURCE_IMAGE(@"view_table_on.png") forState:UIControlStateNormal];
	}
	else {
		
		[volumeButton setBackgroundImage:RESOURCE_IMAGE(@"view_table_off.png") forState:UIControlStateNormal];
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
#pragma mark Volume Item Click Delegate
- (void) selectVolumeItem:(id)sender itemIndex:(int)itemIndex
{
	NSDictionary* content = [m_VolumeArray objectAtIndex:itemIndex];

	NSLog(@"itemIndex=[%d], content=[%@]", itemIndex, content);

	if ([UserProfile getLoginState] == YES) {
		
		NetworkUseType networkUseType = [self getNetworkEnableUsed];
		if (networkUseType == NetworkUseAllEnable) {
			
			NSString* fileNumber = getStringValue([content objectForKey:@"file_no"]);
			BOOL isEnable = [[content objectForKey:@"exbuy_yn"] isEqualToString:@"Y"];
			BOOL isRead = [[content objectForKey:@"user_no"] length] == 0 ? NO : YES; 
			BOOL isSample = ([[content objectForKey:@"sample_count"] integerValue] == 0) ? NO : YES;
			
			if (isSample == YES) { isEnable = YES; }
			
			if (isEnable == YES && isRead == NO) {
				m_SelectedVolume = (UIButton*) sender;
				[self setReadContentWithVolume:m_SelectedVolume read:YES]; 
			}
			
			[m_Request checkBuyWithDomain:BI_PURCHASE_DOMAIN userNo:[UserProfile getUserNo]	fileNo:fileNumber delegate:self];
		}
		else {
			m_SelectedVolume = (UIButton*) sender;
			m_SelectedVolumeIndex = itemIndex;
			
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
		[APPDELEGATE createLoginViewController];
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
			if (buttonIndex == 0) {
				if (alertId == ALERT_ID_NETWORK_3G_ENABLE_QUESTION) {
					[SettingPreference setUse3G:YES];
				}
				
				NSDictionary* content = [m_VolumeArray objectAtIndex:m_SelectedVolumeIndex];
				
				NSString* fileNumber = getStringValue([content objectForKey:@"file_no"]);
				BOOL isEnable = [[content objectForKey:@"exbuy_yn"] isEqualToString:@"Y"];
				BOOL isRead = [[content objectForKey:@"user_no"] length] == 0 ? NO : YES; 
				BOOL isSample = ([[content objectForKey:@"sample_count"] integerValue] == 0) ? NO : YES;
				
				if (isSample == YES) { isEnable = YES; }
				
				if (isEnable == YES && isRead == NO) {
					if (m_SelectedVolume != nil) {
						[self setReadContentWithVolume:m_SelectedVolume read:NO];
					}

					[self setReadContentWithVolume:m_SelectedVolume read:YES]; 
				}
				
				[m_Request checkBuyWithDomain:BI_PURCHASE_DOMAIN userNo:[UserProfile getUserNo]	fileNo:fileNumber delegate:self];
			}
			else {
				m_SelectedVolume = nil;
				m_SelectedVolumeIndex = -1;
			}

			break;

		default:
			break;
	}	
}

#pragma mark -
#pragma mark Button Click Delegate

- (void) clickBtnItems:(id)sender
{
	NSInteger tag = ((UIView*) sender).tag;

	if (m_IsDataLoaded == NO && tag != __BTN_TAG_BACK) { 
		return; 
	}
	
	if ([UserProfile getLoginState] == NO) {
		if (tag == __BTN_TAG_FAVORITE || tag == __BTN_TAG_GOOD || tag == __BTN_TAG_BAD) {
			[APPDELEGATE createLoginViewController];
			return;
		}
	}
	
	switch(tag) {
		case __BTN_TAG_BACK:
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
			break;
			
		case __BTN_TAG_FAVORITE:	
			{			
			NSString* zzimNumber = getStringValue([m_DetailDictionary objectForKey:@"zzim_no"]);		
				
			NSLog(@"zzimNumber=[%@]", zzimNumber);	
			if (zzimNumber != nil && [zzimNumber integerValue] == -1) {
				[m_Faverite setImage:RESOURCE_IMAGE(@"view_top_btn_favorite_on.png") forState:UIControlStateNormal];
				[m_Request goodBadZzimWithMasterNo:m_MasterNumber userNo:[UserProfile getUserNo] eventType:BI_MARK_ZZIM];			
				
				showZzimAnimation();
			}
			else {
				[m_DetailDictionary setObject:@"-1" forKey:@"zzim_no"];
				
				[m_Faverite setImage:RESOURCE_IMAGE(@"view_top_btn_favorite_off.png") forState:UIControlStateNormal];
				[m_Request myViewZzimDeleteWithNoList:zzimNumber myType:BI_UNMARK_ZZIM userNo:[UserProfile getUserNo]];
			}			
			}
			break;

		case __BTN_TAG_GOOD:
			if (m_IsExGoodBadAction == YES) {
				[m_Request goodBadZzimWithMasterNo:m_MasterNumber userNo:[UserProfile getUserNo] eventType:BI_MARK_GOOD];
				[self showGoodAnimation];
			}
			else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"알림" 
																	message:@"이미 등록 되어 있습니다" 
																   delegate:nil cancelButtonTitle:@"확인" 
														  otherButtonTitles:nil];
				[alertView show];
				[alertView release];
			}
			break;			
		case __BTN_TAG_BAD:
			if (m_IsExGoodBadAction == YES) {
				[m_Request goodBadZzimWithMasterNo:m_MasterNumber userNo:[UserProfile getUserNo] eventType:BI_MARK_BAD];				
				[self showBadAnimation];
			}	
			else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"알림" 
																	message:@"이미 등록 되어 있습니다" 
																   delegate:nil cancelButtonTitle:@"확인" 
														  otherButtonTitles:nil];
				[alertView show];
				[alertView release];
			}
			break;
			
		case __BTN_TAG_VIEWMORE:
			{
			CGRect discriptionRect = m_Discription.frame;
				
			if (discriptionRect.size.height > __DEFAULT_DESCRIPTION_HEIGHT) {
				[UIView animateWithDuration:VIEW_ANI_DURATION - 0.3
								 animations:^{
									 CGRect rect = m_VolumeGridView.frame;	
									 
									 [m_VolumeGridView setFrame:CGRectMake(rect.origin.x, rect.origin.y - m_DescriptionHeight, rect.size.width, rect.size.height)];
						 			 [m_VolumeGridBottomLine setFrame:CGRectMake(0, m_VolumeGridView.frame.origin.y + rect.size.height, 320, 1)];
									 
									 [m_DetailView setFrame:CGRectMake(0, 0, 320, __DEFAULT_DETAILVIEW_HEIGHT)];	
									 [m_Discription setFrame:CGRectMake(12, 182, 240, __DEFAULT_DESCRIPTION_HEIGHT)];	
									 
									 CGFloat lineY = rect.origin.y - m_DescriptionHeight;
									 rect = m_BottomLine.frame;
									 rect.origin.y = lineY;
									 [m_BottomLine setFrame:rect];
									 
									 CGSize size = m_ScrollView.contentSize;				
									 [m_ScrollView setContentSize:CGSizeMake(320, size.height - m_DescriptionHeight)];
								 }
								 completion:^(BOOL finished){
									 //do nothing
								 }];

			}
			else {				
				NSLog(@"m_DescriptionHeight=[%d]", m_DescriptionHeight);
				
				[UIView animateWithDuration:VIEW_ANI_DURATION - 0.3
								 animations:^{
									 [m_BtnMoreView setHidden:YES];
									 
									 CGRect rect = m_DetailView.frame;
									 [m_DetailView setFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height + m_DescriptionHeight)];	
									 
									 rect = m_Discription.frame;
									 [m_Discription setFrame:CGRectMake(rect.origin.x, rect.origin.y, 320 - (rect.origin.x*2), rect.size.height + m_DescriptionHeight)];
									 
									 rect = m_VolumeGridView.frame;									
									 [m_VolumeGridView setFrame:CGRectMake(rect.origin.x, rect.origin.y + m_DescriptionHeight, rect.size.width, rect.size.height)];
						 			 [m_VolumeGridBottomLine setFrame:CGRectMake(0, m_VolumeGridView.frame.origin.y + rect.size.height, 320, 1)];
									 
 									 rect = m_BottomLine.frame;
 									 CGFloat lineY = rect.origin.y + m_DescriptionHeight - rect.size.height;
									 rect.origin.y = lineY;
									 [m_BottomLine setFrame:rect];
									 
									 CGSize size = m_ScrollView.contentSize;				
									 [m_ScrollView setContentSize:CGSizeMake(size.width, size.height + m_DescriptionHeight)];
								 }
								 completion:^(BOOL finished){
									 //do nothing
								 }];
			}
			}
			break;
	}
}

@end
