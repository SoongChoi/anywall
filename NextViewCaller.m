//
//  NextViewCaller.m
//  PlayBook
//
//  Created by 황 호성 on 12. 5. 25..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NextViewCaller.h"
#import "PBDatabase.h"
#import "UserProfile.h"

@implementation NextViewCaller

@synthesize mCurrentStatus;
@synthesize mNextReadVolume_FileNumber;
@synthesize mNextReadVolume_VolumeNumber;
@synthesize mGoodsVolumes;


- (NextViewCaller *) initWithContentType:(NSInteger) ctype
{
	(ctype == CARTOON_CONTENT_TYPE_STREAM) ? mIsStreaming = YES : NO;
	mCurrentStatus = CALLER_STATUS_NONE;
	mHasNextVolume = NO;
	
	return self;	
}

- (void) dealloc
{
	[super dealloc];
}

- (BOOL) isCompleteSeriese
{
	return cnt_bComplete_yn;
}

- (BOOL) isContentClosed
{
	return (cnt_total_cnt == 0) ? true : false;
}

- (BOOL) hasNextVolume
{
	return mHasNextVolume;
}

- (NSString*) getNextVolumeFileNumber
{
	if (mHasNextVolume == false) {
		return nil;
	}
	return mNextReadVolume_FileNumber;
}

- (NSString*)  getNextVolumeVolumeNumber
{
	if (mHasNextVolume == false) {
		return nil;
	}
	return mNextReadVolume_VolumeNumber;
}


- (NSInteger) getNextStatue
{
	if ([self hasNextVolume] == YES) {
		return NEXT_STATUS_NEXT_EXIST;
	}
	else {
		if ([self isCompleteSeriese] == YES) {
			return NEXT_STATUS_FINISH_SERIESE;
		}
		
		if ([self isContentClosed] == YES) {
			return NEXT_STATUS_CLOSED_CONTENT;
		}
	}
	return NEXT_STATUS_NONE_NEXT_SERIESE;
}


- (NSInteger) getExcuteStatue:(NSString *) masterNumber
{
	if (mIsStreaming == NO) {		
		if ([PBDatabase existsBookContent:masterNumber fileNumber:[self getNextVolumeFileNumber]]){
			return EXE_STATUS_LOAD_DBCONTENT;			
		}
	}
	
	if ([UserProfile getLoginState] == NO){
		return EXE_STATUS_REQUEST_LOGIN;
	}
	
	return EXE_STATUS_CHECK_PURCHASE;
	
}

- (void) setGoodsVolumes:(NSDictionary *)goodsVolumes
{
	if (mGoodsVolumes != nil){
		[mGoodsVolumes release];
	}
	
	mGoodsVolumes = goodsVolumes;
}

- (void) loadNextVolumes:(NSString *)fileNumber bookVolume:(NSString *)bookVolume
{
	[self setNextVolumes:mGoodsVolumes fileNumber:fileNumber bookVolume:bookVolume];
}

- (void) setNextVolumes:(NSDictionary *)goodsVolumes fileNumber:(NSString *)fileNumber bookVolume:(NSString *) bookVolume
{
	if (goodsVolumes != nil) 
	{
		NSDictionary *data = [goodsVolumes objectForKey:@"data"];
		
		NSInteger rCode = [[data objectForKey:@"result_code"] intValue];
		
		NSLog(@"result_code : %d", rCode);
		NSLog(@"result_msg : %@", [data objectForKey:@"result_msg"]);
		
		if (rCode == 0){				
			NSDictionary *result = [data objectForKey:@"result"];
			
			if ([[result objectForKey:@"complete_yn"] isEqualToString:@"Y"] == YES)
				cnt_bComplete_yn = YES;
			else 
				cnt_bComplete_yn = NO;
			
			cnt_total_cnt = [[result objectForKey:@"total_cnt"] intValue];
			
			if (cnt_total_cnt <= [bookVolume intValue])
			{
				mHasNextVolume = NO;
				
				self.mNextReadVolume_FileNumber = nil;
				self.mNextReadVolume_VolumeNumber = nil;
				
				return;
			}
			
			NSArray *list = [result objectForKey:@"list"];
			for (int i = 0; i < [list count]; i++){				
				if ([fileNumber isEqualToString:[[list objectAtIndex:i] objectForKey:@"file_no"]] == YES &&
					[bookVolume isEqualToString:[[list objectAtIndex:i] objectForKey:@"book_no"]] == YES)
				{
					NSDictionary *next = [list objectAtIndex:i+1];
					if (next != nil)
					{
						mHasNextVolume = YES;
						
						self.mNextReadVolume_FileNumber = getStringValue([next objectForKey:@"file_no"]);
						self.mNextReadVolume_VolumeNumber = getStringValue([next objectForKey:@"book_no"]);
						
						break;
					}
				}				
			}
		}
	}
}

@end


