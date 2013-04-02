//
//  SettingPreference.m
//  PlayBook
//
//  Created by 황 호성 on 12. 6. 1..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingPreference.h"
#import "JMDevKit.h"

NSString * const DF_PREFERENCE_FILE_NAME		= @"settingpreference.plist";

NSString * const DF_PREFERENCE_DEVICEKEY		= @"devicekey";
NSString * const DF_PREFERENCE_USE3G			= @"use3g";
NSString * const DF_PREFERENCE_USE3GPOPUP		= @"use3gpopup";
NSString * const DF_PREFERENCE_USEPUSH			= @"usepush";
NSString * const DF_PREFERENCE_SHOWGUIDE_CARTTON= @"showguildecartton";
NSString * const DF_PREFERENCE_SHOWGUIDE_EPUB	= @"showguildeepub";

@implementation SettingPreference

//ok
+ (BOOL) __savePreference:(NSMutableDictionary *)profile
{
	NSString *		path	= [JMDevKit appDocumentFilePath:DF_PREFERENCE_FILE_NAME];
	
	if (profile == nil)
	{
		return NO;
	}
	
	[profile writeToFile:path atomically:YES];
	
	return YES;
}

//ok
+ (BOOL) existsPreference
{
	NSFileManager *	fm		= [NSFileManager defaultManager];
	NSString *		path	= [JMDevKit appDocumentFilePath:DF_PREFERENCE_FILE_NAME];
	
	if ([fm fileExistsAtPath:path] == YES)
	{
		[fm release];
		
		return YES;
	}
	
	[fm release];
	
	return NO;
}

+ (NSString *)GetUUID
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	NSString * string = (NSString *)CFUUIDCreateString(NULL, theUUID);
	
	NSMutableString *mString = [NSMutableString stringWithString:string];
	
	[mString replaceOccurrencesOfString:@"-" withString:@"" options:0 range:NSMakeRange(0, [mString length])];

	CFRelease(theUUID);
	return mString;
}

+ (BOOL) initPreference
{
	NSFileManager *	fm		= [NSFileManager defaultManager];
	NSString *		path	= [JMDevKit appDocumentFilePath:DF_PREFERENCE_FILE_NAME];
	
	if ([self existsPreference] == YES)
	{
		[fm removeItemAtPath:path error:nil];
	}
	
	[fm release];
	
	NSMutableDictionary	*	preference	= [NSMutableDictionary dictionaryWithCapacity:0];
	
	[preference setObject:[self GetUUID] forKey:DF_PREFERENCE_DEVICEKEY];
 	[preference setObject:[NSNumber numberWithBool:YES] forKey:DF_PREFERENCE_USE3G];
	[preference setObject:[NSNumber numberWithBool:YES] forKey:DF_PREFERENCE_USE3GPOPUP];
	[preference setObject:[NSNumber numberWithBool:YES] forKey:DF_PREFERENCE_USEPUSH];
	
	[preference writeToFile:path atomically:YES];
	
	return YES;
}

//ok
+ (void) removePreference
{
	if ([self existsPreference] == YES)
	{
		NSFileManager *	fm		= [NSFileManager defaultManager];
		NSString *		path	= [JMDevKit appDocumentFilePath:DF_PREFERENCE_FILE_NAME];
		
		[fm removeItemAtPath:path error:nil];
		
		[fm release];
	}
}

//ok
+ (NSMutableDictionary *) getPreference
{
	if ([self existsPreference] == NO)
	{
		return nil;
	}
	
	NSString *				path	= [JMDevKit appDocumentFilePath:DF_PREFERENCE_FILE_NAME];
	NSMutableDictionary	*	profile	= [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
	return profile;
}

+ (NSString *) getDeviceKey
{
	if ([self existsPreference] == NO)
	{
		return nil;
	}
	
	NSMutableDictionary	*	profile = [self getPreference];
	
	return [profile objectForKey:DF_PREFERENCE_DEVICEKEY];
}

+ (BOOL) getUse3G
{
	if ([self existsPreference] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile = [self getPreference];
	
	return [[profile objectForKey:DF_PREFERENCE_USE3G] boolValue];
}

+ (BOOL) getUse3GPopup
{
	if ([self existsPreference] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile = [self getPreference];
	
	return [[profile objectForKey:DF_PREFERENCE_USE3GPOPUP] boolValue];
}

+ (BOOL) getUsePush
{
	if ([self existsPreference] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile = [self getPreference];
	
	return [[profile objectForKey:DF_PREFERENCE_USEPUSH] boolValue];
}

+ (BOOL) getShowScreenGuide:(BOOL)bCartoon
{
	if ([self existsPreference] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile = [self getPreference];
	
	if (bCartoon == YES) {
		return [[profile objectForKey:DF_PREFERENCE_SHOWGUIDE_CARTTON] boolValue];
	}
	return [[profile objectForKey:DF_PREFERENCE_SHOWGUIDE_EPUB] boolValue];
}

+ (BOOL) setDeviceKey:(NSString *)devicekey
{
	if ([self existsPreference] == NO)
	{
		return NO;
	}
	
	if (devicekey == nil)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getPreference];
	
	[profile setObject:devicekey forKey:DF_PREFERENCE_DEVICEKEY];	
	
	return [self __savePreference:profile];
	
}

+ (BOOL) setUse3G:(BOOL)bUse
{
	if ([self existsPreference] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getPreference];
	
	[profile setObject:[NSNumber numberWithBool:bUse] forKey:DF_PREFERENCE_USE3G];
	
	return [self __savePreference:profile];
}

+ (BOOL) setUse3GPopup:(BOOL)bUse
{
	if ([self existsPreference] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getPreference];
	
	[profile setObject:[NSNumber numberWithBool:bUse] forKey:DF_PREFERENCE_USE3GPOPUP];
	
	return [self __savePreference:profile];
}

+ (BOOL) setUsePush:(BOOL)bUse
{
	if ([self existsPreference] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getPreference];
	
	[profile setObject:[NSNumber numberWithBool:bUse] forKey:DF_PREFERENCE_USEPUSH];
	
	return [self __savePreference:profile];
}

+ (BOOL) setShowScreenGuide:(BOOL)bCartoon bShow:(BOOL)bShow
{
	if ([self existsPreference] == NO)
	{
		return NO;
	}
	
	NSMutableDictionary	*	profile	= [self getPreference];
	
	if (bCartoon == YES) {
		[profile setObject:[NSNumber numberWithBool:bShow] forKey:DF_PREFERENCE_SHOWGUIDE_CARTTON];
	}
	else {
		[profile setObject:[NSNumber numberWithBool:bShow] forKey:DF_PREFERENCE_SHOWGUIDE_EPUB];
	}

	return [self __savePreference:profile];
}




@end
