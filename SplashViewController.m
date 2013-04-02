//
//  SplashViewController.m
//  PlayBook
//
//  Created by 전명곤 on 11. 11. 14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"
#import "PlayBookDefines.h"
#import "UserProfile.h"

#import "StoreFreeViewController.h"
#import "StoreFreeCartoonViewController.h"
#import "StoreFreeEpubViewController.h"

#import <sys/time.h>



#define _SPLASH_INTERVAL					1

#define _CMD_RECOMMEND_INVALID				-1
#define _CMD_CHECK_APP_NEW_VERSION			0
#define _CMD_REQUEST_COOKIE					1
#define _CMD_SECURE_TIME					2
#define _CMD_RECOMMEND_CONTENT_LIST_FREE	3
#define _CMD_RECOMMEND_CONTENT_LIST_PAID	4
#define _CMD_CONTENT_LIST_FREE_CARTOON		5
#define _CMD_CONTENT_LIST_FREE_EPUB			6
#define _CMD_CONTENT_LIST_PAID_CARTOON		7
#define _CMD_CONTENT_LIST_PAID_EPUB			8
#define _CMD_INTRO_INFO                     9


#define _SPLASH_START_TIME_INTERVAL			(1000 * 60) * 60 * 2



@implementation SplashViewController

@synthesize m_ImageView;
@synthesize m_NotiDic;
@synthesize m_CloseButton;

- (void) __startTimer
{
	m_Timer = [NSTimer scheduledTimerWithTimeInterval:_SPLASH_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:NO];
}

- (void) __stopTimer
{
/*	
	if (m_Timer != nil) {
		[m_Timer invalidate];
		[m_Timer release];
		m_Timer = nil;
	}*/
	
}

- (void) onTimer:(NSTimer *)timer
{
	[self.view removeFromSuperview];
	[APPDELEGATE.m_Window addSubview:APPDELEGATE.m_SwitchViewController.view];
	[self release];
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

- (BOOL) __existCommand
{
	return ([m_ReqQueue count] > 0) ? YES : NO;
}

- (void) __putCommand:(int) command
{
	NSNumber* numCommand = [[NSNumber alloc] initWithInt:command];
	[m_ReqQueue addObject:numCommand];
}

- (int) __peekCommand
{
	if ([self __existCommand] == YES) 
	{	
		NSNumber* numCommand = [m_ReqQueue objectAtIndex:0];		
		return [numCommand intValue];
	}
	return -1;
}

- (int) __popCommand
{
	if ([self __existCommand] == YES) 
	{	
		NSNumber* numCommand = [m_ReqQueue objectAtIndex:0];
		[m_ReqQueue removeObjectAtIndex:0];
		
		return [numCommand intValue];
	}
	return -1;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	APPDELEGATE.m_NewVersionNumber = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	m_ActivityIndicator = nil;
	m_IsCompletely = NO;
	m_IsSplashStarted = NO;
	m_bLayerMode = NO;
    m_bBlocking = NO;
    
	m_Request  = [[PlayBookRequest alloc] init];
	m_ReqQueue = [[NSMutableArray alloc] initWithCapacity:0];

	//[self __putCommand:_CMD_CHECK_APP_NEW_VERSION];
    [self __putCommand:_CMD_INTRO_INFO];
	[self __putCommand:_CMD_SECURE_TIME];
	if ([UserProfile getAutoLogin] == YES) {		
		[self __putCommand:_CMD_REQUEST_COOKIE];
	}
	
    BOOL bTest = NO;
    NSString *uid = [UserProfile getUserID];
    if ([uid isEqualToString:@"comicmaster"] == YES){
        bTest = YES;
    }
    
    NSString* nowVersionNumber = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
    [m_Request introInfoWithVersion:nowVersionNumber test:(bTest == YES) ? @"Y" : @"N" delegate:self];

    [UserProfile setLoginState:NO];

	//[m_Request checkAppNewVersionWithScreenType:@"03" test:@"Y" delegate:self];

//	[self __startTimer];
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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:self.view];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if (m_ActivityIndicator != nil)
	{
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
	}
}

- (void)dealloc {
    [self __stopTimer];
	NSLog(@"dealloc");
	
	[m_ReqQueue removeAllObjects];
	[m_ReqQueue release];
	
	[super dealloc];
}


-(BOOL) isCompletely
{
	return m_IsCompletely;
}

-(BOOL) isBlocking
{
    return m_bBlocking;
}

+ (long long)currentTimeMillis
{
    struct timeval t;
    gettimeofday(&t, NULL);
	
    return (((long long) t.tv_sec) * 1000) + (((long long) t.tv_usec) / 1000);
}

-(void) startSplahController
{
    [m_ImageView setImage:RESOURCE_IMAGE(@"intro.png")];
    [m_CloseButton setHidden:YES];
    long long currentTime = [SplashViewController currentTimeMillis];
	
	if ((currentTime - m_LastSyncTime) < _SPLASH_START_TIME_INTERVAL || [self isCompletely] == YES) {
		NSLog(@"Last SycmTime Is Small=[%d], Skipping....", (currentTime - m_LastSyncTime));
		return;
	}
	
	m_IsSplashStarted = YES;
	m_IsCompletely = NO;
	
	if ([m_Request isDownloading] == YES) {
		[m_Request cancelConnection];
	}
	[m_ReqQueue removeAllObjects];
	
//	[self __putCommand:_CMD_CHECK_APP_NEW_VERSION];
    [self __putCommand:_CMD_INTRO_INFO];
	[self __putCommand:_CMD_SECURE_TIME];
	if ([UserProfile getAutoLogin] == YES) {
		[UserProfile setLoginState:NO];
		[self __putCommand:_CMD_REQUEST_COOKIE];
	}
    
    BOOL bTest = NO;
    NSString *uid = [UserProfile getUserID];
    if ([uid isEqualToString:@"comicmaster"] == YES){
        bTest = YES;
    }
//	[m_Request checkAppNewVersionWithScreenType:@"03" test:@"Y" delegate:self];
    NSString* nowVersionNumber = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
    //[m_Request introInfoWithVersion:nowVersionNumber test:@"Y" delegate:self];
    [m_Request introInfoWithVersion:nowVersionNumber test:(bTest == YES) ? @"Y" : @"N" delegate:self];

	
	if (m_ActivityIndicator == nil) {
		m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:self.view];
	}
	[APPDELEGATE.m_Window addSubview:self.view];	
}

-(void) stopSplashController
{	
	if ([m_Request isDownloading] == YES) {
		[m_Request cancelConnection];
	}
	[m_ReqQueue removeAllObjects];
	
	if (m_ActivityIndicator != nil)	{
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];				
		
		[self.view removeFromSuperview];
	}	
}

-(void) startAnimationLoading
{
	if (m_ActivityIndicator == nil) {
		m_ActivityIndicator = [ActivityIndicatorPopup startAnimationWithSuperView:self.view];
		[APPDELEGATE.m_Window addSubview:self.view];
	}
}

-(void) stopAnimationLoading
{
	if (m_ActivityIndicator != nil)	{
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
		
		[self.view removeFromSuperview];		
	}
}

-(void) stopAnimation
{
	if (m_ActivityIndicator != nil)	{
		m_ActivityIndicator = [m_ActivityIndicator stopAnimation];		
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
	
	int nextCommand = [self __peekCommand];
	if (nextCommand <= DF_URL_CMD_REQUEST_COOKIE) {
		[UserProfile setLoginState:NO];
	}
	m_IsCompletely = YES;
	
	[self.view removeFromSuperview];
	
	if (m_IsSplashStarted == NO) {
		[APPDELEGATE.m_Window addSubview:APPDELEGATE.m_SwitchViewController.view];	
		[self release];
	}	
}


- (void) pbrDidFinishLoadingWithCommand:(NSInteger)command userInfo:(id)userInfo response:(NSURLResponse *)response
{
	NSDictionary *	dicInfo = (NSDictionary *)userInfo;

	int recvCommand = [self __popCommand];
	int nextCommand = [self __peekCommand];

	
	NSInteger rtCode = -1;
	
	NSLog(@"command=[%d], rectCommand=[%d], nextCommand=[%d]", command, recvCommand, nextCommand);
	
	
	switch (command) {
		case DF_URL_CMD_CHECK_APP_NEW_VERSION:
			rtCode = [[dicInfo objectForKey:@"result_code"] integerValue];
			if (rtCode == 0) 
			{
				NSDictionary* data   = [dicInfo objectForKey:@"data"];
				if (data == nil) { break; }
				
				NSDictionary* result = [data objectForKey:@"result"];
				if (result != nil) {
					NSString* newVersionNumber = getStringValue([result objectForKey:@"version"]);
					if (newVersionNumber != nil) {
						APPDELEGATE.m_NewVersionNumber = newVersionNumber;
						
						NSString* nowVersionNumber = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
						
						NSLog(@"newVersion=[%@], nowVersion=[%@]", newVersionNumber, nowVersionNumber);						
                        
                        //if ([nowVersionNumber isEqualToString:newVersionNumber] == NO) {
                        if ([nowVersionNumber floatValue] < [newVersionNumber floatValue]){
							[APPDELEGATE showMessageBox:ALERT_ID_CHECK_NEW_VERSION_QUESTION message:RESC_STRING_CHECK_NEW_VERSION_QUESTION];
						}
					}
				}
				
				if ([UserProfile getLoginState] == NO) {
				}
			}
			break;
                        
        case DF_URL_CMD_INTRO_INFO:
            rtCode = [[dicInfo objectForKey:@"result_code"] integerValue];
			if (rtCode == 0)
			{
                NSDictionary* updatedata   = [dicInfo objectForKey:@"update_info"];
				if (updatedata != nil){
                    NSLog(@"[DF_URL_CMD_INTRO_INFO] updatedata : %@", updatedata);
                    NSString* updateLink = getStringValue([updatedata objectForKey:@"link"]);
                    NSString* updateVer = getStringValue([updatedata objectForKey:@"ver"]);
                    NSString* updateType = getStringValue([updatedata objectForKey:@"type"]);
                    //NSString* updateDate = getStringValue([updatedata objectForKey:@"date"]);
                    NSString* updateMsg = getStringValue([updatedata objectForKey:@"msg"]);
                    
                    if (updateVer){
                        APPDELEGATE.m_NewVersionNumber = updateVer;
                        APPDELEGATE.m_UpdateLink = updateLink;
                        APPDELEGATE.m_UpdateType = updateType;
						
						NSString* nowVersionNumber = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
						
						NSLog(@"newVersion=[%@], nowVersion=[%@]", updateVer, nowVersionNumber);
                        
                        //if ([nowVersionNumber isEqualToString:newVersionNumber] == NO) {
                        if ([nowVersionNumber floatValue] < [updateVer floatValue]){
                            if ([updateMsg length] <= 0){
                                if ([updateType isEqualToString:@"compulsion"] == YES){
                                    updateMsg = RESC_STRING_CHECK_NEW_VERSION_QUESTION_COMPLUSION;
                                }
                                else{
                                    updateMsg = RESC_STRING_CHECK_NEW_VERSION_QUESTION;
                                }
                            }
                            
							[APPDELEGATE showMessageBox:ALERT_ID_CHECK_NEW_VERSION_QUESTIONV2
                                                message:updateMsg];
                            
                            if ([updateType isEqualToString:@"compulsion"] == YES){                                
                                [m_ReqQueue removeAllObjects];
                                m_bBlocking = YES;
                                return;
                            }
						}
                    }
                }
                
                NSArray* notiArray = [dicInfo objectForKey:@"noti_info"];
                for (NSDictionary* notiDic in notiArray)
                {
                    //m_NotiDic = notiDic;
                    //m_NotiDic = [NSDictionary dictionaryWithDictionary:notiDic];
                    m_NotiDic = [[NSDictionary alloc] initWithDictionary:notiDic];
                    break;
                }    
            }
            break;
		
		case DF_URL_CMD_REQUEST_COOKIE:
			rtCode = [[dicInfo objectForKey:@"rtcode"] integerValue];
			if (rtCode == 0) {
				[UserProfile setLoginState:YES];
			}
			break;
			
		case _CMD_SECURE_TIME:	
			if (dicInfo != nil) {
				[APPDELEGATE.m_LicenseChecker setSecureTimeData:dicInfo]; 				
			}
			break;
			
		case DF_URL_CMD_RECOMMEND_CONTENT_LIST:
			if (dicInfo != nil) {
				if (recvCommand == _CMD_RECOMMEND_CONTENT_LIST_FREE) {								
				}
				else if (recvCommand == _CMD_RECOMMEND_CONTENT_LIST_PAID) {				
				}
				else {
					NSLog(@"[DF_URL_CMD_RECOMMEND_CONTENT_LIST] Cannot Find Out recvCommand in Queue");
				}
			}
			break;		
	}

	switch (nextCommand) {
		case _CMD_REQUEST_COOKIE:
			[m_Request requestCookieWithCt:@"json" AtKey:[UserProfile getAtKey] delegate:self];	
			break;
		case _CMD_SECURE_TIME:
			[m_Request safeTimeWithDelegate:self];
			break;
		case _CMD_RECOMMEND_CONTENT_LIST_FREE:
			if ([UserProfile getLoginState] == YES) {
				[m_Request recommendContentListWithMenuType:BI_MENU_TYPE_FREE delegate:self];
			}
			else {
				[m_Request recommendContentListWithMenuType:BI_MENU_TYPE_FREE delegate:self];
			}
			break;
		case _CMD_RECOMMEND_CONTENT_LIST_PAID:
			if ([UserProfile getLoginState] == YES) {			
				[m_Request recommendContentListWithMenuType:BI_MENU_TYPE_CHARGE delegate:self];
			}
			else {
				[m_Request recommendContentListWithMenuType:BI_MENU_TYPE_CHARGE delegate:self];
			}
			break;
			
		default:
			/*
			if ([m_Timer isValid] == YES) {
				[self.view removeFromSuperview];
				[APPDELEGATE.m_Window addSubview:APPDELEGATE.m_SwitchViewController.view];
			}
			else {
				m_IsCompletely = YES;
			}
			 */
            
            //every network job done. check noti information

            if (m_NotiDic != nil){
                NSString *notiType = getStringValue([m_NotiDic objectForKey:@"type"]);
                NSString *notiAction = getStringValue([m_NotiDic objectForKey:@"action"]);
                NSString *notiMsg = getStringValue([m_NotiDic objectForKey:@"msg"]);
                
                m_bBlocking = ([notiType isEqualToString:@"pm"] == YES);
                
                //webview(바로 웹뷰로이동), toast(ios에서는업음), alert, layer(image띄움), appmenu
                if ([notiAction isEqualToString:@"alert"] == YES){
                    if ([notiMsg length] <= 0){
                        notiMsg = @"no message";
                    }
                    [APPDELEGATE showMessageBox:ALERT_ID_EVENT_ACTION_ALERT message:notiMsg];
                }
                else if([notiAction isEqualToString:@"layer"] == YES){      //ignore pm
                    NSString *notiLink = getStringValue([m_NotiDic objectForKey:@"img"]);
                    NSURL *url = [NSURL URLWithString:notiLink];
                    NSData *imageData = [NSData dataWithContentsOfURL:url];
                    UIImage *image = [UIImage imageWithData:imageData];
                    [m_ImageView setImage:image];
                    [m_CloseButton setHidden:(m_bBlocking ? YES : NO)];
                    
                    [self stopAnimation];
                    m_bLayerMode = YES;
                    
                    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
                    [m_ImageView addGestureRecognizer:singleTap];
                    [m_ImageView setMultipleTouchEnabled:YES];
                    [m_ImageView setUserInteractionEnabled:YES];

                    [m_ReqQueue removeAllObjects];
                    return;
                }
                else if([notiAction isEqualToString:@"appmenu"] == YES){    //ignore pm
                    
                }
//              else if([notiAction isEqualToString:@"webview"] == YES){} //not support yet
                else{
                    
                }

                if (m_bBlocking){
                    [m_ReqQueue removeAllObjects];
                    return;
                }
            }


			m_LastSyncTime = [SplashViewController currentTimeMillis];
			
			m_IsCompletely = YES;			
			[m_ReqQueue removeAllObjects];
			
			if (m_ActivityIndicator != nil)	{
				m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
			}
			
			[self.view removeFromSuperview];
			
			UIView* parentView = [APPDELEGATE.m_SwitchViewController.view superview];
			if (parentView == nil) {
				[APPDELEGATE.m_Window addSubview:APPDELEGATE.m_SwitchViewController.view];	
				[self release];
			}
 
			break;
	}
	
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    NSLog(@"Touch event on view");
    NSString *notiType = getStringValue([m_NotiDic objectForKey:@"type"]);
    NSString *notiTarget = getStringValue([m_NotiDic objectForKey:@"target"]);
    
    BOOL bPM = ([notiType isEqualToString:@"pm"] == YES);

    if ([notiTarget isEqualToString:@"browser"] == YES){
        [m_ImageView setImage:RESOURCE_IMAGE(@"intro.png")];
        [m_CloseButton setHidden:YES];
        m_bLayerMode = NO;
        NSString *notiURL = getStringValue([m_NotiDic objectForKey:@"link"]);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:notiURL]];
        //test
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.daum.net"]];
    }
    else if ([notiTarget isEqualToString:@"webview"] == YES){
        [m_ImageView setImage:RESOURCE_IMAGE(@"intro.png")];
        [m_CloseButton setHidden:YES];
        m_bLayerMode = NO;
        NSString *notiURL = getStringValue([m_NotiDic objectForKey:@"link"]);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:notiURL]];
        //test
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.daum.net"]];
    }
    else if ([notiTarget isEqualToString:@"appmenu"] == YES){
        APPDELEGATE.m_AppMenu = getStringValue([m_NotiDic objectForKey:@"link"]);
    }
    else if ([notiTarget isEqualToString:@"pass"] == YES){
        
    }
    
    if (bPM == NO){
        m_LastSyncTime = [SplashViewController currentTimeMillis];
        
        m_IsCompletely = YES;
        [m_ReqQueue removeAllObjects];
        
        if (m_ActivityIndicator != nil)	{
            m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
        }
        
        [self.view removeFromSuperview];
        
        UIView* parentView = [APPDELEGATE.m_SwitchViewController.view superview];
        if (parentView == nil) {
            [APPDELEGATE.m_Window addSubview:APPDELEGATE.m_SwitchViewController.view];
            [self release];
        }
    }
}

- (IBAction) clickBtnItems:(id)sender
{
	NSInteger tag = ((UIView*) sender).tag;
    
    if (tag == 1){ //close button
        NSLog(@"Touch event on view");
        NSString *notiType = getStringValue([m_NotiDic objectForKey:@"type"]);
        
        BOOL bPM = ([notiType isEqualToString:@"pm"] == YES);
        
        if (bPM == NO){
            m_LastSyncTime = [SplashViewController currentTimeMillis];
            
            m_IsCompletely = YES;
            [m_ReqQueue removeAllObjects];
            
            if (m_ActivityIndicator != nil)	{
                m_ActivityIndicator = [m_ActivityIndicator stopAnimation];
            }
            
            [self.view removeFromSuperview];
            
            UIView* parentView = [APPDELEGATE.m_SwitchViewController.view superview];
            if (parentView == nil) {
                [APPDELEGATE.m_Window addSubview:APPDELEGATE.m_SwitchViewController.view];
                [self release];
            }
        }
    }
}

@end
