//
//  PlayBookDefines.m
//  PlayBook
//
//  Created by 전명곤 on 11. 12. 9..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayBookDefines.h"


NSString * const BI_PLATFORM_TYPE_PC		= @"00";
NSString * const BI_PLATFORM_TYPE_MOBILE	= @"01"; 


NSString * const BI_CONTENT_TYPE_DOWNLOAD	= @"DN";	// 다운로드
NSString * const BI_CONTENT_TYPE_STREAM		= @"ST";	// 스트리밍

NSString * const BI_MAIN_GROUP_TYPE_CARTOON	= @"CO";	// 만화
NSString * const BI_MAIN_GROUP_TYPE_NOVEL	= @"NO";	// 소설

NSString * const BI_SUB_GROUP_TYPE_GENERAL	= @"GE";	// 일반
NSString * const BI_SUB_GROUP_TYPE_ADULT	= @"AD";	// 성인
NSString * const BI_SUB_GROUP_TYPE_FREE		= @"FR";	// 무료

NSString * const BI_CATEGORY_TYPE_MARTIAL	= @"CA01";	// 무협
NSString * const BI_CATEGORY_TYPE_ACTION	= @"CA02";	// 액션 
NSString * const BI_CATEGORY_TYPE_DRAMA		= @"CA03";	// 드라마
NSString * const BI_CATEGORY_TYPE_LOMANCE	= @"CA04";	// 순정/로맨스
NSString * const BI_CATEGORY_TYPE_SPORT		= @"CA05";	// 스포츠
NSString * const BI_CATEGORY_TYPE_SF		= @"CA06";	// SF/판타지
NSString * const BI_CATEGORY_TYPE_DETECTIVE	= @"CA07";	// 추리소설
NSString * const BI_CATEGORY_TYPE_SEXY		= @"CA08";	// 섹시
NSString * const BI_CATEGORY_TYPE_YAOI		= @"CA09";	// 야오이	

NSString * const BI_DRM_TYPE_UNLIMITE		= @"R00";
NSString * const BI_DRM_TYPE_PERIOD			= @"R01";
NSString * const BI_DRM_TYPE_COUNTER		= @"R02";

NSString * const BI_MARK_GOOD				= @"00";
NSString * const BI_MARK_BAD				= @"01";
NSString * const BI_MARK_ZZIM				= @"02";
NSString * const BI_UNMARK_MARK				= @"03";
NSString * const BI_UNMARK_ZZIM				= @"04";


NSString * const BI_MENU_TYPE_FREE			= @"00";
NSString * const BI_MENU_TYPE_CHARGE		= @"01";

NSString * const BI_ORDER_TYPE_RECENT		= @"00";
NSString * const BI_ORDER_TYPE_POPULARITY   = @"01";

NSString * const BI_VIEW_TYPE_LIST			= @"00";
NSString * const BI_VIEW_TYPE_THUMB			= @"01";

NSString * const BI_PURCHASE_TYPE_FLATRATE  = @"00";
NSString * const BI_PURCHASE_TYPE_STREAM    = @"01";
NSString * const BI_PURCHASE_TYPE_DOWNLOAD  = @"02";

NSString * const BI_PURCHASE_BOOK			= @"NR"; // 단권
NSString * const BI_PURCHASE_BOOK_PACKAGE   = @"GR"; //팩키지


NSString * const BI_PURCHASE_DOMAIN			= @"kth";

NSString * const NOTIFY_DATACHANGED  = @"NotificationDataChanged";
NSString * const NOTIFY_ZZIMCHANGED  = @"NotificationZzimChanged";
NSString * const NOTIFY_READCHANGED  = @"NotificationReadChanged";

NSString * const APPSTORE_LINK_URL = @"itms-apps://itunes.apple.com/app/peulleibug-playy-book/id540230162";

NSString* getStringValue(id value) {
	if ([value respondsToSelector:@selector(stringValue)] == YES) {
		return [value stringValue];
	}
	return value;
}


void showZzimAnimation()
{
	UIImageView* aniImageView = [[UIImageView alloc] initWithFrame:CGRectMake(235.0f, 402.0f, 60.0f, 60.0f)];
	
	aniImageView.animationImages = [NSArray arrayWithObjects:	
									[UIImage imageNamed:@"mybook0001.png"],
									[UIImage imageNamed:@"mybook0002.png"],
									[UIImage imageNamed:@"mybook0003.png"],
									[UIImage imageNamed:@"mybook0004.png"],
									[UIImage imageNamed:@"mybook0005.png"],
									[UIImage imageNamed:@"mybook0006.png"],
									[UIImage imageNamed:@"mybook0007.png"],
									[UIImage imageNamed:@"mybook0008.png"],
									[UIImage imageNamed:@"mybook0009.png"],
									[UIImage imageNamed:@"mybook0010.png"],
									[UIImage imageNamed:@"mybook0011.png"],
									[UIImage imageNamed:@"mybook0012.png"],
									[UIImage imageNamed:@"mybook0013.png"],
									[UIImage imageNamed:@"mybook0014.png"],
									[UIImage imageNamed:@"mybook0015.png"],
									[UIImage imageNamed:@"mybook0016.png"],
									[UIImage imageNamed:@"mybook0017.png"],
									[UIImage imageNamed:@"mybook0018.png"], nil];
	
	aniImageView.animationDuration = 0.66667;
	aniImageView.animationRepeatCount = 1;
	[aniImageView startAnimating];
	[APPDELEGATE.m_Window addSubview:aniImageView];
	[aniImageView release]; 
}


NSString* getStringWithCode(NSString *code)
{
	if ([code isEqualToString:BI_MAIN_GROUP_TYPE_CARTOON] == YES)
	{
		return [NSString stringWithString:@"만화"];
	}
	else if ([code isEqualToString:BI_MAIN_GROUP_TYPE_NOVEL] == YES)
	{
		return [NSString stringWithString:@"소설"];
	}
	else if ([code isEqualToString:BI_SUB_GROUP_TYPE_GENERAL] == YES)
	{
		return [NSString stringWithString:@"일반"];
	}
	else if ([code isEqualToString:BI_SUB_GROUP_TYPE_ADULT] == YES)
	{
		return [NSString stringWithString:@"성인"];
	}
	else if ([code isEqualToString:BI_SUB_GROUP_TYPE_FREE] == YES)
	{
		return [NSString stringWithString:@"무료"];
	}
	else if ([code isEqualToString:BI_CATEGORY_TYPE_MARTIAL] == YES)
	{
		return [NSString stringWithString:@"무협"];
	}
	else if ([code isEqualToString:BI_CATEGORY_TYPE_ACTION] == YES)
	{
		return [NSString stringWithString:@"액션"];
	}
	else if ([code isEqualToString:BI_CATEGORY_TYPE_DRAMA] == YES)
	{
		return [NSString stringWithString:@"드라마"];
	}
	else if ([code isEqualToString:BI_CATEGORY_TYPE_LOMANCE] == YES)
	{
		return [NSString stringWithString:@"순정/로맨스"];
	}
	else if ([code isEqualToString:BI_CATEGORY_TYPE_SPORT] == YES)
	{
		return [NSString stringWithString:@"스포츠"];
	}
	else if ([code isEqualToString:BI_CATEGORY_TYPE_SF] == YES)
	{
		return [NSString stringWithString:@"SF/판타지"];
	}
	else if ([code isEqualToString:BI_CATEGORY_TYPE_DETECTIVE] == YES)
	{
		return [NSString stringWithString:@"추리소설"];
	}
	else if ([code isEqualToString:BI_CATEGORY_TYPE_SEXY] == YES)
	{
		return [NSString stringWithString:@"섹시"];
	}
	else if ([code isEqualToString:BI_CATEGORY_TYPE_YAOI] == YES)
	{
		return [NSString stringWithString:@"야오이"];
	}
	else if ([code isEqualToString:BI_CONTENT_TYPE_DOWNLOAD] == YES)
	{
		return [NSString stringWithString:@"다운로드"];
	}
	else if ([code isEqualToString:BI_CONTENT_TYPE_STREAM] == YES)
	{
		return [NSString stringWithString:@"스트리밍"];
	}
	
	return nil;
}
