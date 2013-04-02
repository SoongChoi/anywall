//
//  UserProfile.m
//  PlayBook
//
//  Created by 전명곤 on 11. 11. 7..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserProfile.h"
#import "JMDevKit.h"

NSString * const DF_PROFILE_FILE_NAME		= @"userprofile.plist";

NSString * const DF_PROFILE_ATKEY			= @"atkey";
NSString * const DF_PROFILE_EXPIREDT		= @"expiredt";
NSString * const DF_PROFILE_IDDOMAIN		= @"iddomain";
NSString * const DF_PROFILE_IDTYPE			= @"idtype";
NSString * const DF_PROFILE_NICKNAME		= @"nickname";
NSString * const DF_PROFILE_RTCODE			= @"rtcode";
NSString * const DF_PROFILE_RTMSG			= @"rtmsg";
NSString * const DF_PROFILE_USERNM			= @"usernm";
NSString * const DF_PROFILE_USERNO			= @"userno";
NSString * const DF_PROFILE_DEVICE_TOKEN	= @"devicetoken";
NSString * const DF_PROFILE_LOGIN_STATE		= @"loginstate";
NSString * const DF_PROFILE_CS				= @"cs";
NSString * const DF_PROFILE_MC				= @"mc";
NSString * const DF_PROFILE_SAVE_USER_ID	= @"saveuserid";
NSString * const DF_PROFILE_AUTO_LOGIN		= @"autologin";
NSString * const DF_PROFILE_USER_ID			= @"userid";
NSString * const DF_PROFILE_REALNAME_CHECK	= @"realnamecheck";
NSString * const DF_PROFILE_ADULT_CHECK		= @"adultcheck";


@implementation UserProfile

+ (BOOL) __saveProfile:(NSMutableDictionary *)profile
{
	NSString *		path	= [JMDevKit appDocumentFilePath:DF_PROFILE_FILE_NAME];
	
	if (profile == nil)
	{
		return NO;
	}
	
	[profile writeToFile:path atomically:YES];
	
	return YES;
}

+ (BOOL) existsProfile
{
	NSFileManager *	fm		= [NSFileManager defaultManager];
	NSString *		path	= [JMDevKit appDocumentFilePath:DF_PROFILE_FILE_NAME];
	
	if ([fm fileExistsAtPath:path] == YES)
	{
		[fm release];
        
		return YES;
	}
    
	[fm release];
    
	return NO;
}

+ (BOOL) initProfile
{
	NSFileManager *	fm		= [NSFileManager defaultManager];
	NSString *		path	= [JMDevKit appDocumentFilePath:DF_PROFILE_FILE_NAME];
    
	if ([self existsProfile] == YES)
	{
		[fm removeItemAtPath:path error:nil];
	}
	
	[fm release];
	
	NSMutableDictionary	*	profile	= [NSMutableDictionary dictionaryWithCapacity:0];
	
	[profile setObject:[NSString string] forKey:DF_PROFILE_ATKEY];
	[profile setObject:[NSString string] forKey:DF_PROFILE_EXPIREDT];
	[profile setObject:[NSString string] forKey:DF_PROFILE_IDDOMAIN];
	[profile setObject:[NSNumber numberWithInteger:0] forKey:DF_PROFILE_IDTYPE];
	[profile setObject:[NSString string] forKey:DF_PROFILE_NICKNAME];
	[profile setObject:[NSNumber numberWithInteger:0] forKey:DF_PROFILE_RTCODE];
	[profile setObject:[NSString string] forKey:DF_PROFILE_RTMSG];
	[profile setObject:[NSString string] forKey:DF_PROFILE_USERNM];
	[profile setObject:[NSString string] forKey:DF_PROFILE_USERNO];
	[profile setObject:[NSString string] forKey:DF_PROFILE_DEVICE_TOKEN];
	[profile setObject:[NSNumber numberWithBool:YES] forKey:DF_PROFILE_SAVE_USER_ID];
	[profile setObject:[NSNumber numberWithBool:YES] forKey:DF_PROFILE_AUTO_LOGIN];
	[profile setObject:[NSString string] forKey:DF_PROFILE_USER_ID];
	
	[profile writeToFile:path atomically:YES];
	
	return YES;
}

+ (void) removeProfile
{
	if ([self existsProfile] == YES)
	{
		NSFileManager *	fm		= [NSFileManager defaultManager];
		NSString *		path	= [JMDevKit appDocumentFilePath:DF_PROFILE_FILE_NAME];
		
		[fm removeItemAtPath:path error:nil];
        
		[fm release];
	}
}

+ (NSMutableDictionary *) getProfile
{
	if ([self existsProfile] == NO)
	{
		return nil;
	}
	
	NSString *				path	= [JMDevKit appDocumentFilePath:DF_PROFILE_FILE_NAME];
	NSMutableDictionary	*	profile	= [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
	return profile;
}

+ (NSString *) getAtKey
{
	if ([self existsProfile] == NO)
	{
		return nil;
	}
    
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [profile objectForKey:DF_PROFILE_ATKEY];
}

+ (NSString *) getExpiredt
{
	if ([self existsProfile] == NO)
	{
		return nil;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [profile objectForKey:DF_PROFILE_EXPIREDT];
}

+ (NSString *) getIdDomain
{
	if ([self existsProfile] == NO)
	{
		return nil;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [profile objectForKey:DF_PROFILE_IDDOMAIN];
}

+ (NSInteger)  getIdType
{
	if ([self existsProfile] == NO)
	{
		return -1;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [[profile objectForKey:DF_PROFILE_IDTYPE] integerValue];
}

+ (NSString *) getNickName
{
	if ([self existsProfile] == NO)
	{
		return nil;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [profile objectForKey:DF_PROFILE_NICKNAME];
}

+ (NSInteger)  getRtCode
{
	if ([self existsProfile] == NO)
	{
		return -1;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [[profile objectForKey:DF_PROFILE_RTCODE] integerValue];
}

+ (NSString *) getRtMsg
{
	if ([self existsProfile] == NO)
	{
		return nil;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [profile objectForKey:DF_PROFILE_RTMSG];
}

+ (NSString *) getUserName
{
	if ([self existsProfile] == NO)
	{
		return nil;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
    
	NSString *strHex = [profile objectForKey:DF_PROFILE_USERNM];
	
	return [[[NSString alloc] initWithData:[JMDevKit AES128Decrypt:[JMDevKit decodeHexString:strHex]] 
								  encoding:NSUTF8StringEncoding] autorelease];
	
	//return [profile objectForKey:DF_PROFILE_USERNM];
}

+ (NSString *) getUserNo
{
	if ([self existsProfile] == NO)
	{
		return nil;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
    
	NSString *strHex = [profile objectForKey:DF_PROFILE_USERNO];
	
	return [[[NSString alloc] initWithData:[JMDevKit AES128Decrypt:[JMDevKit decodeHexString:strHex]] 
								  encoding:NSUTF8StringEncoding] autorelease];
	
	
	//return [profile objectForKey:DF_PROFILE_USERNO];
}

+ (NSString *) getDeviceToken
{
	if ([self existsProfile] == NO)
	{
		return nil;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [profile objectForKey:DF_PROFILE_DEVICE_TOKEN];
}

+ (BOOL) getLoginState
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
    
	return [[profile objectForKey:DF_PROFILE_LOGIN_STATE] boolValue];
}

+ (NSString *) getCS
{
	if ([self existsProfile] == NO)
	{
		return nil;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [profile objectForKey:DF_PROFILE_CS];
}

+ (NSString *) getMC
{
	if ([self existsProfile] == NO)
	{
		return nil;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [profile objectForKey:DF_PROFILE_MC];
}

+ (BOOL) getSavedUserId
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
    
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [[profile objectForKey:DF_PROFILE_SAVE_USER_ID] boolValue];
}

+ (BOOL) getAutoLogin
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [[profile objectForKey:DF_PROFILE_AUTO_LOGIN] boolValue];
}

+ (NSString *) getUserID
{
	if ([self existsProfile] == NO)
	{
		return nil;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
    
	//	return [profile objectForKey:DF_PROFILE_USER_ID];
	
	NSString *strHex = [profile objectForKey:DF_PROFILE_USER_ID];
	
	return [[[NSString alloc] initWithData:[JMDevKit AES128Decrypt:[JMDevKit decodeHexString:strHex]] 
								  encoding:NSUTF8StringEncoding] autorelease];
}

+ (BOOL) getRealnameCheck
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [[profile objectForKey:DF_PROFILE_REALNAME_CHECK] boolValue];
}

+ (BOOL) getAdultCheck
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile = [self getProfile];
	
	return [[profile objectForKey:DF_PROFILE_ADULT_CHECK] boolValue];
}


+ (BOOL) setAtKey:(NSString *)atkey
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	if (atkey == nil)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:atkey forKey:DF_PROFILE_ATKEY];	
	
	return [self __saveProfile:profile];
}

+ (BOOL) setExpiredt:(NSString *)expiredt
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	if (expiredt == nil)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:expiredt forKey:DF_PROFILE_EXPIREDT];	
	
	return [self __saveProfile:profile];
}

+ (BOOL) setIdDomain:(NSString *)iddomain
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	if (iddomain == nil)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:iddomain forKey:DF_PROFILE_IDDOMAIN];	
	
	return [self __saveProfile:profile];
}

+ (BOOL) setIdType:(NSInteger)idtype
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:[NSNumber numberWithInteger:idtype] forKey:DF_PROFILE_IDTYPE];
	
	return [self __saveProfile:profile];
}

+ (BOOL) setNickName:(NSString *)nickname
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	if (nickname == nil)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:nickname forKey:DF_PROFILE_NICKNAME];	
	
	return [self __saveProfile:profile];
}

+ (BOOL) setRtCode:(NSInteger)rtcode
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:[NSNumber numberWithInteger:rtcode] forKey:DF_PROFILE_RTCODE];
	
	return [self __saveProfile:profile];
}

+ (BOOL) setRtMsg:(NSString *)rtmsg
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	if (rtmsg == nil)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:rtmsg forKey:DF_PROFILE_RTMSG];	
	
	return [self __saveProfile:profile];
}

+ (BOOL) setUserName:(NSString *)usernm
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	if (usernm == nil)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:[JMDevKit hexEncode:[JMDevKit AES128Encrypt:[usernm dataUsingEncoding:NSUTF8StringEncoding]]] forKey:DF_PROFILE_USERNM];	
	
	return [self __saveProfile:profile];
}

+ (BOOL) setUserNo:(NSString *)userno
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	if (userno == nil)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
    //	[profile setObject:userno forKey:DF_PROFILE_USERNO];	
	[profile setObject:[JMDevKit hexEncode:[JMDevKit AES128Encrypt:[userno dataUsingEncoding:NSUTF8StringEncoding]]] forKey:DF_PROFILE_USERNO];	
    
	
	return [self __saveProfile:profile];
}

+ (BOOL) setDeviceToken:(NSString *)deviceToken
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	if (deviceToken == nil)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:deviceToken forKey:DF_PROFILE_DEVICE_TOKEN];	
	
	return [self __saveProfile:profile];
}

+ (BOOL) setLoginState:(BOOL)bLogin
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:[NSNumber numberWithBool:bLogin] forKey:DF_PROFILE_LOGIN_STATE];
	
	return [self __saveProfile:profile];
}

+ (BOOL) setCS:(NSString *)cs
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	if (cs == nil)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:cs forKey:DF_PROFILE_CS];	
	
	return [self __saveProfile:profile];
}

+ (BOOL) setMC:(NSString *)mc
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	if (mc == nil)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:mc forKey:DF_PROFILE_MC];	
	
	return [self __saveProfile:profile];
}

+ (BOOL) setSavedUserId:(BOOL)savedUserId
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:[NSNumber numberWithBool:savedUserId] forKey:DF_PROFILE_SAVE_USER_ID];
	
	return [self __saveProfile:profile];
}

+ (BOOL) setAutoLogin:(BOOL)autoLogin
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:[NSNumber numberWithBool:autoLogin] forKey:DF_PROFILE_AUTO_LOGIN];
	
	return [self __saveProfile:profile];
}

+ (BOOL) setUserId:(NSString *)userID
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	if (userID == nil)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	//[profile setObject:userID forKey:DF_PROFILE_USER_ID];	
	
	[profile setObject:[JMDevKit hexEncode:[JMDevKit AES128Encrypt:[userID dataUsingEncoding:NSUTF8StringEncoding]]] forKey:DF_PROFILE_USER_ID];	
	
	return [self __saveProfile:profile];
}

+ (BOOL) setRealnameCheck:(BOOL)checked
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:[NSNumber numberWithBool:checked] forKey:DF_PROFILE_REALNAME_CHECK];
	
	return [self __saveProfile:profile];
}

+ (BOOL) setAdultCheck:(BOOL)checked
{
	if ([self existsProfile] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getProfile];
	
	[profile setObject:[NSNumber numberWithBool:checked] forKey:DF_PROFILE_ADULT_CHECK];
	
	return [self __saveProfile:profile];
}


@end
