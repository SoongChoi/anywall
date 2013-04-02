//
//  PlayBookRequest.m
//  PlayBook
//
//  Created by 전명곤 on 11. 11. 7..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayBookRequest.h"
#import "JSON.h"
#import "APXML.h"
#import "JMDevKit.h"
#import "Base64.h"
#import "UserProfile.h"
#import <CommonCrypto/CommonCryptor.h>
#import "NSDataAdditions.h"
#import "XMLReader.h"
#include "DES128.h"


NSString * const DF_PLAY_BOOK_MAIN_URL			= @"https://main.playy.co.kr/";
NSString * const DF_PLAY_BOOK_API_URL			= @"http://api.book.playy.co.kr/api/";
//NSString * const DF_PLAY_BOOK_API_URL			= @"http://211.45.130.95/api/";
NSString * const DF_PLAY_BOOK_USER_URL			= @"https://user.paran.com/";
NSString * const DF_PLAY_BOOK_CHARGE_COMIC		= @"http://chargecomic.paran.com/dps/";

NSString * const DF_PLAY_BOOK_CSKEY				= @"playy.paran.com";

// REST 연동 시 사용
NSString * const DF_PLAY_BOOK_API_CSKEY			= @"api.playy.paran.com";
NSString * const DF_PLAY_BOOK_API_SECRET		= @"de06711809f58ac148a754f10e486700e5a5e5bc";

// AES 암복호화 시 필요
NSString * const DF_PLAY_BOOK_PARAN_AUTH_KEY	= @"34e37563de703919514c070df494cfe7";
NSString * const DF_PLAY_BOOK_PARAN_AUTH_IV		= @"a230438e29f1795868e3eb468858ea70";
NSString * const DF_PLAY_BOOK_AES_TYPE			= @"PKCS5Padding";

NSString * const PBR_XML_ELEMENT_NAME			= @"element_name";	
NSString * const PBR_XML_ELEMENT_VALUE			= @"element_value";
NSString * const PBR_XML_ELEMENT_ATTRIBUTES		= @"element_attributes";
NSString * const PBR_XML_ELEMENT_CHILDS			= @"element_childs";
NSString * const PBR_XML_ATTRIBUTE_NAME			= @"attribute_name";
NSString * const PBR_XML_ATTRIBUTE_VALUE		= @"attribute_value";


static const NSTimeInterval kTimeoutInterval = 30.0;

@implementation PlayBookRequest

@synthesize m_Response;
@synthesize m_Connect;
@synthesize m_ReceiveData;

- (APElement *) __elementWithDictionary:(NSDictionary *)dicInfo
{
	if (dicInfo == nil)
	{
		return nil;
	}
	
	NSString *	name		= [dicInfo objectForKey:PBR_XML_ELEMENT_NAME];
	NSString *	value		= [dicInfo objectForKey:PBR_XML_ELEMENT_VALUE];
	NSArray *	attributes	= [dicInfo objectForKey:PBR_XML_ELEMENT_ATTRIBUTES];
	NSArray *	childs		= [dicInfo objectForKey:PBR_XML_ELEMENT_CHILDS];
	
	if (name == nil)
	{
		return nil;
	}
	
	APElement *		element = [APElement elementWithName:name];
	
	if (value != nil)
	{
		[element appendValue:value];
	}
	
	if (attributes != nil)
	{
		for (NSDictionary *attribute in attributes)
		{
			[element addAttributeNamed:[attribute objectForKey:PBR_XML_ATTRIBUTE_NAME] withValue:[attribute objectForKey:PBR_XML_ATTRIBUTE_VALUE]];
		}
	}
	
	if (childs != nil)
	{
		for (NSDictionary *child in childs)
		{
			APElement *	childElement = [self __elementWithDictionary:child];
			
			if (childElement != nil)
			{
				[element addChild:childElement];
			}
		}
	}
	
	return element;
}

- (id) init
{
	if ((self = [super init]) != nil)
	{
		m_Delegate		= nil;
		
		m_Response		= nil;
		m_Connect		= nil;
		m_ReceiveData	= [[NSMutableData alloc] initWithCapacity:0];
		
		m_IsDownLoading	= NO;
		m_Command		= DF_URL_CMD_NONE;
	}
	
	return self;
}

- (id) initWithDelegate:(id)delegate
{
	if ((self = [super init]) != nil)
	{
		m_Delegate		= delegate;
		
		m_Response		= nil;
		m_Connect		= nil;
		m_ReceiveData	= [[NSMutableData alloc] initWithCapacity:0];
		
		m_IsDownLoading	= NO;
		m_Command		= DF_URL_CMD_NONE;
	}
	
	return self;
}

- (void) dealloc
{
	if (m_IsDownLoading == YES)
	{		
		[m_Connect release];
	}
	[m_Connect cancel];
	
	if (m_ReceiveData != nil)
	{
		[m_ReceiveData release];
	}
	
	[super dealloc];
}


//---------------------------------------------------------------------------------------------------

- (NSDictionary *) __convertLoginXMLtoDictionary:(NSData *)data
{
	NSMutableDictionary *	userInfo		= [[NSMutableDictionary alloc] initWithCapacity:0];
	NSString *				xmlStr			= [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
	APDocument *			doc				= [APDocument documentWithXMLString:xmlStr];
	APElement *				rootElement		= [doc rootElement];
	NSArray *				childElements	= [rootElement childElements];
	
	for (APElement *child in childElements)
	{
		if ([child.name isEqualToString:@"result_code"])
		{
			[userInfo setObject:[NSNumber numberWithInteger:[[child value] integerValue]] forKey:child.name];
		}
		else if ([child.name isEqualToString:@"result_msg"])
		{
			[userInfo setObject:[child value] forKey:child.name];
		}
		else if ([child.name isEqualToString:@"result"])
		{
			NSMutableArray *		arrList		= [[NSMutableArray alloc] initWithCapacity:0];
			NSMutableDictionary *	dicResult	= [[NSMutableDictionary alloc] initWithCapacity:0];
			NSArray *				subElements	= [child childElements];
			
			for (APElement *resultElement in subElements)
			{
				if ([resultElement.name isEqualToString:@"list"])
				{
					NSMutableDictionary *	dicList			= [[NSMutableDictionary alloc] initWithCapacity:0];
					NSArray *				listElements	= [resultElement childElements];
					
					for (APElement *listElement in listElements)
					{
						if ([listElement value] != nil)
						{
							[dicList setObject:[listElement value] forKey:listElement.name];
						}
					}
					
					[arrList addObject:dicList];
				}
				else 
				{
					if ([resultElement value] != nil)
					{
						[dicResult setObject:[resultElement value] forKey:resultElement.name];
					}
				}
			}
			
			if ([arrList count] > 0)
			{
				[dicResult setObject:arrList forKey:@"list"];
			}
			
			[userInfo setObject:dicResult forKey:@"result"];
		}
	}
	
	return (NSDictionary *)userInfo;
}

- (NSDictionary *) __retLoginRest:(NSData *)data
{
	SBJSON			*json		= [SBJSON new];
	json.humanReadable = YES;
	
	NSString		*strInfo	= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary	*dicInfo	= [json objectWithString:strInfo];
	
	NSInteger		rtCode		= [[dicInfo objectForKey:@"rtcode"] integerValue];
	NSString *		rtMsg		= [dicInfo objectForKey:@"rtmsg"];
	
	if (rtCode == 0)
	{
		// successed login
		[UserProfile setAtKey:[dicInfo objectForKey:@"atkey"]];
		[UserProfile setExpiredt:[dicInfo objectForKey:@"expiredt"]];
		[UserProfile setIdDomain:[dicInfo objectForKey:@"iddomain"]];
		[UserProfile setIdType:[[dicInfo objectForKey:@"idtype"] integerValue]];
		[UserProfile setNickName:[dicInfo objectForKey:@"nickname"]];
		[UserProfile setUserName:[dicInfo objectForKey:@"usernm"]];
		[UserProfile setUserNo:[dicInfo objectForKey:@"userno"]];
		
		[UserProfile setLoginState:YES];
	}
	else 
	{
		[UserProfile setLoginState:NO];
	}
	
	[UserProfile setRtCode:rtCode];
	[UserProfile setRtMsg:rtMsg];
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:rtCode], @"rtcode", rtMsg, @"rtmsg", nil];
	
	return userInfo;
}

- (NSDictionary *) __retRequestCookie:(NSData *)data
{
	SBJSON			*json		= [SBJSON new];
	json.humanReadable = YES;
	
	NSString		*strInfo	= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary	*dicInfo	= [json objectWithString:strInfo];
	
	NSInteger		rtCode		= [[dicInfo objectForKey:@"rtcode"] integerValue];
	NSString *		rtMsg		= [dicInfo objectForKey:@"rtmsg"];
	
	if (rtCode == 0)
	{
		[UserProfile setCS:[dicInfo objectForKey:@"cs"]];
		[UserProfile setMC:[dicInfo objectForKey:@"mc"]];
		[UserProfile setIdType:[[dicInfo objectForKey:@"idtype"] integerValue]];
	}
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:rtCode], @"rtcode", rtMsg, @"rtmsg", nil];
	
	return userInfo;
}

- (NSDictionary *) __retRequestToken:(NSData *)data
{
	SBJSON			*json		= [SBJSON new];
	json.humanReadable = YES;
	
	NSString		*strInfo	= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary	*dicInfo	= [json objectWithString:strInfo];
	
	NSInteger		rtCode		= [[dicInfo objectForKey:@"rtcode"] integerValue];
	NSString *		rtMsg		= [dicInfo objectForKey:@"rtmsg"];
	
	if (rtCode == 0)
	{
		NSString* fullUserId = [dicInfo objectForKey:@"iddomain"];
		
		NSArray* arrayUserId = [fullUserId componentsSeparatedByString:@"@"];
		if ([arrayUserId count] == 2) {
			[UserProfile setAtKey:[dicInfo objectForKey:@"atkey"]];
			[UserProfile setExpiredt:[dicInfo objectForKey:@"expiredt"]];
			[UserProfile setUserId:[arrayUserId objectAtIndex:0]];
			[UserProfile setIdDomain:[arrayUserId objectAtIndex:1]];
			[UserProfile setIdType:[[dicInfo objectForKey:@"idtype"] integerValue]];
			[UserProfile setUserName:[dicInfo objectForKey:@"usernm"]];
			[UserProfile setUserNo:[dicInfo objectForKey:@"userno"]];	
		}	
		else {
			rtCode = 200;
		}

	}
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:rtCode], @"rtcode", rtMsg, @"rtmsg", nil];
	
	return userInfo;
}

/*
 - (APElement *) __retLoginOAuth:(NSData *)data
 {
 NSString *		xmlStr		= [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
 APDocument *	doc			= [APDocument documentWithXMLString:xmlStr];
 APElement *		rootElement	= [doc rootElement];
 
 return rootElement;
 }
 */

- (NSDictionary *) __convertJSONtoDictionary:(NSData *)data
{
	SBJSON			*json		= [SBJSON new];
	json.humanReadable = YES;
	
	NSString		*strInfo	= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary	*dicInfo	= [json objectWithString:strInfo];
	
	return dicInfo;
}

- (NSDictionary *) __convertXMLtoDictionary:(NSData *)data
{
	NSError *parseError = nil;
	NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:data error:&parseError];
	
	// Print the dictionary
#ifdef DEBUG_PROTO_LOG
	NSLog(@"%@", xmlDictionary);
#endif
	
	return xmlDictionary;
}



- (NSDictionary *) __retCheckAppNewVersion:(NSData *)data
{
	return [self __convertXMLtoDictionary:data];
}

- (NSDictionary *) __retIntroInfo:(NSData *)data
{
	return [self __convertJSONtoDictionary:data];
}

- (NSDictionary *) __retNewBookInfo:(NSData *)data
{
	return [self __convertXMLtoDictionary:data];
}

- (NSDictionary *) __retGoodsInfo:(NSData *)data
{
	return [self __convertXMLtoDictionary:data];
}

- (NSDictionary *) __retGoodsCnt:(NSData *)data
{
	return [self __convertXMLtoDictionary:data];
}

- (NSDictionary *) __retContinueViewIns:(NSData *)data
{
	return [self __convertXMLtoDictionary:data];
}

- (NSDictionary *) __retContinueView:(NSData *)data
{
	return [self __convertXMLtoDictionary:data];
}
/*
- (NSDictionary *) __retCheckBuy:(NSData *)data
{
	NSDictionary *tmpDict = [self __convertXMLtoDictionary:data];
	NSDictionary *mdata = [tmpDict objectForKey:@"data"];
	NSInteger rCode = [[mdata objectForKey:@"result_code"] intValue];
	//NSLog(@"result_code : %d", rCode);
	
	if (rCode == 0){				
		NSDictionary *result = [mdata objectForKey:@"result"];
		NSDictionary *dict = [self __convertJSONtoDictionary:[[result objectForKey:@"playy_info"] dataUsingEncoding:NSUTF8StringEncoding]];
		
		NSMutableDictionary *retDict = [[tmpDict mutableCopy] autorelease];
		[retDict addEntriesFromDictionary:dict];

#ifdef DEBUG_PROTO_LOG		
		NSLog(@"%@", retDict);
#endif
		
		return retDict;
	}
	
	return tmpDict;
}
*/
/*
- (NSDictionary *) __retCheckBuy:(NSData *)data
{
 NSDictionary *tmpDict = [self __convertXMLtoDictionary:data];
	NSDictionary *mdata = [tmpDict objectForKey:@"data"];
	NSInteger rCode = [[mdata objectForKey:@"result_code"] intValue];
	NSLog(@"result_code : %d", rCode);
	
	if (rCode == 0){				
		NSDictionary *result = [mdata objectForKey:@"result"];
		NSDictionary *dict = [self __convertJSONtoDictionary:[[result objectForKey:@"playy_info"] dataUsingEncoding:NSUTF8StringEncoding]];
		NSMutableDictionary *mutableDict = [[dict mutableCopy] autorelease];		 
		[mutableDict setObject:[mdata objectForKey:@"result_code"] forKey:@"result_code"];
		[mutableDict setObject:[mdata objectForKey:@"result_msg"] forKey:@"result_msg"];
		[mutableDict setObject:[result objectForKey:@"exbuy_yn"] forKey:@"exbuy_yn"];
		
		return mutableDict;
	}
	
	return tmpDict;
}
*/
- (NSDictionary *) __retCompletedDownload:(NSData *)data
{
	return [self __convertXMLtoDictionary:data];
}

- (NSDictionary *) __retPushDeviceInfo:(NSData *)data
{
	return [self __convertXMLtoDictionary:data];
}

- (NSDictionary *) __retRecommendContentList:(NSData *)data
{
	return [self __convertJSONtoDictionary:data];
}

- (NSDictionary *) __retContentList:(NSData *)data
{
	return [self __convertJSONtoDictionary:data];
}

- (NSDictionary *) __retSearchList:(NSData *)data
{
	return [self __convertJSONtoDictionary:data];
}

- (NSDictionary *) __retContentInfo:(NSData *)data
{
	return [self __convertJSONtoDictionary:data];
}

- (NSDictionary *) __retGoodBadZzim:(NSData *)data
{
	return [self __convertJSONtoDictionary:data];
}

- (NSDictionary *) __retBuyList:(NSData *)data
{
	return [self __convertJSONtoDictionary:data];
}

- (NSDictionary *) __retBuyDetail:(NSData *)data
{
	return [self __convertJSONtoDictionary:data];
}

- (NSDictionary *) __retMyViewZzimList:(NSData *)data
{
	return [self __convertJSONtoDictionary:data];
}

- (NSDictionary *) __retMyViewZzimDelete:(NSData *)data
{
	return [self __convertJSONtoDictionary:data];
}

- (NSDictionary *) __retPlayViewLog:(NSData *)data
{
	return [self __convertJSONtoDictionary:data];
}

- (NSDictionary *) __retLoginInfo:(NSData *)data
{
	return [self __convertXMLtoDictionary:data];
}

- (NSData *) __decryptDES:(NSString *)str
{
	NSString *key = @"34e37563de703919";
	const void *vkey = (const void *) [key UTF8String];
	
	//test data
	//NSString *strText = @"NTA2QUNFRjZFRUNERDQwMUE1QkM0QkY1RkZBQTkzQzY0NzUxODRENDdBMkE2NjE1RjhDRjYzMkJENzQ2QzcyQThDQ0I5QTgzNTI5RjEzOTJDMDUxOUY2RTczOTYzRkI1MkQwMzdGQkE2Q0I2OEFCOTMxNUZFRDhBMkE5NkJENTVENDVEQTkwNTUzQkNFNURBRUQ1RThBOTE4NERGNkE2RTU2MjlDMzI5MTZERTI0MzUyNkZDQTg1NjQ0OTM5NkU2OUE0MzIxNUFGMzgxRUQ1RkYyNDU0NkE5NDEyRDVFNDQ3MDFCNzE=";
	//NSData *decodedData = [NSData dataWithBase64EncodedString:strText]; 
	
	NSData *decodedData = [NSData dataWithBase64EncodedString:str]; 
	
	//NSLog(@"base64decoded : %s", [decodedData bytes]);
	
	unsigned char *output =(unsigned char *)calloc([decodedData length] + 1, sizeof(unsigned char));
	
	_GetDecrypt((char *)vkey, (char *)[decodedData bytes], (char *)output);
	
	if (output != NULL)
	{
		NSData *myData = [NSData dataWithBytes:output length:[decodedData length] + 1];		
		
		NSLog(@"__decryptDES result : %@", [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding]);
		
		return myData;
	}
	
	return nil;
}

- (NSDictionary *) __retSafeTime:(NSData *)data
{
	NSDictionary *rd;
	
	@try {
		NSString* strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSData *result = [self __decryptDES:strData];
		NSMutableData *mData = [[[NSMutableData alloc] initWithData:result] autorelease];
		
		NSLog(@"%@", [[NSString alloc] initWithData:mData encoding:NSUTF8StringEncoding]);
		
		NSString *strString = [[[NSString alloc] initWithData:mData encoding:NSUTF8StringEncoding] autorelease];
		
		NSRange range = [strString rangeOfString:@"</data>"];
		NSString *sub = [strString substringWithRange:NSMakeRange(0, range.location + strlen("</data>"))];
		
		NSData* aData = [sub dataUsingEncoding: NSUTF8StringEncoding];
		
		rd = [self __convertXMLtoDictionary:aData];	
	}
	@catch (NSException * e) {
		NSLog(@"__retSafeTime exception=[%@]", e);
	}
	@finally {
		return rd;
	}
}


- (NSDictionary *) __retCheckBuy:(NSData *)data
{
	NSDictionary *rd;
	
	@try {
		NSString* strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSData *result = [self __decryptDES:strData];
		NSMutableData *mData = [[[NSMutableData alloc] initWithData:result] autorelease];
		
		NSLog(@"%@", [[NSString alloc] initWithData:mData encoding:NSUTF8StringEncoding]);
		
		NSString *strString = [[[NSString alloc] initWithData:mData encoding:NSUTF8StringEncoding] autorelease];
		NSRange range = [strString rangeOfString:@"</data>"];
		NSString *sub = [strString substringWithRange:NSMakeRange(0, range.location + strlen("</data>"))];
		
		NSData* aData = [sub dataUsingEncoding: NSUTF8StringEncoding];
		
		NSDictionary *tmpDict = [self __convertXMLtoDictionary:aData];
		NSDictionary *mdata = [tmpDict objectForKey:@"data"];
		NSInteger rCode = [[mdata objectForKey:@"result_code"] intValue];
		
		if (rCode == 0){				
			NSDictionary *result = [mdata objectForKey:@"result"];
			NSDictionary *dict = [self __convertJSONtoDictionary:[[result objectForKey:@"playy_info"] dataUsingEncoding:NSUTF8StringEncoding]];
			
			NSMutableDictionary *retDict = [[tmpDict mutableCopy] autorelease];
			[retDict addEntriesFromDictionary:dict];
			
			NSLog(@"%@", retDict);
			rd = retDict;
		}
		else {
			rd = tmpDict;
		}
		
	}
	@catch (NSException * e) {
		NSLog(@"__retCheckBuy exception=[%@]", e);
	}
	@finally {
		return rd;
	}
}

//---------------------------------------------------------------------------------------------------
- (BOOL) __headerRequest:(NSMutableURLRequest *)request method:(NSString *)method contentType:(NSString *)contentType
{
	[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
	
	[request setHTTPMethod:method];
	
	if ([UserProfile getLoginState] == YES && 
		m_Command != DF_URL_CMD_LOGIN_REST &&
		m_Command != DF_URL_CMD_REQUEST_COOKIE)
	{
		[request setValue:[UserProfile getMC] forHTTPHeaderField:@"MC"];
		[request setValue:[UserProfile getCS] forHTTPHeaderField:@"CS"];
		//[request setValue:[[UIDevice currentDevice] model] forHTTPHeaderField:@"model_name"];
		//[request setValue:[[UIDevice currentDevice] version] forHTTPHeaderField:@"os_ver"];
		[request setValue:@"galaxy s" forHTTPHeaderField:@"model_name"];
		[request setValue:@"android 2.2.1" forHTTPHeaderField:@"os_ver"];
	}
	
	return YES;
}

- (BOOL) __headerRequest:(NSMutableURLRequest *)request method:(NSString *)method contentType:(NSString *)contentType bodyLength:(NSInteger)bodyLength
{
	if (bodyLength > 0 && [method isEqualToString:@"POST"] == YES)
	{
		NSString *	strBodyLength = [NSString stringWithFormat:@"%d", bodyLength];
		[request setValue:strBodyLength forHTTPHeaderField:@"Content-Length"];
	}
	
	[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
	
	[request setHTTPMethod:method];
	
	return YES;
}

- (NSMutableData *) __bodyRequest:(NSDictionary *)parameter
{
	if (parameter == nil)
	{
		return nil;
	}
	
	NSMutableData *	body = [[NSMutableData alloc] initWithCapacity:0];
	
	for (id key in parameter)
	{
		id	value = [parameter objectForKey:key];		
		//NSLog(@"key = %@, value = %@", key, value);
		
		if ([body length] > 0)
		{
			[body appendData:[[NSString stringWithString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		
		NSString *urlEncorded = (NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) value, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 ); 
		
#ifdef DEBUG_PROTO_LOG			
		NSLog(@"key = %@, value = %@", key, urlEncorded);
#endif
		
		//[body appendData:[[NSString stringWithFormat:@"%@=%@", key, value] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"%@=%@", key, urlEncorded] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	return body;
}

//---------------------------------------------------------------------------------------------------
- (BOOL) requestWithMethod:(NSString *)method path:(NSString *)path parameter:(NSDictionary *)parameter delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self requestWithMethod:method path:path parameter:parameter];
}

- (BOOL) requestWithMethod:(NSString *)method path:(NSString *)path parameter:(NSDictionary *)parameter
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_IsDownLoading = YES;
	
	UIApplication *		app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	
	if (method == nil)
	{
		app.networkActivityIndicatorVisible = NO;
		
		m_IsDownLoading = NO;
		m_Command		= DF_URL_CMD_NONE;
		
		return NO;
	}
	
	if (path == nil)
	{
		app.networkActivityIndicatorVisible = NO;
		
		m_IsDownLoading	= NO;
		m_Command		= DF_URL_CMD_NONE;
		
		return NO;
	}
	
	NSMutableURLRequest *	request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path] 
															cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
														timeoutInterval:kTimeoutInterval];
	if (request == nil)
	{
		NSLog(@"requestWithMethod : could not create url request from string %@", path);
		app.networkActivityIndicatorVisible = NO;
		
		m_IsDownLoading = NO;
		m_Command		= DF_URL_CMD_NONE;
		
		return NO;
	}
	
	NSLog(@"\n=============================================");
	NSLog(@"=============================================");
	switch (m_Command) 
	{
		case DF_URL_CMD_LOGIN_REST:
			NSLog(@"requestWithMethod (command) : %@", @"rest login");
			break;
			
		case DF_URL_CMD_LOGIN_OAUTH:
			NSLog(@"requestWithMethod (command) : %@", @"oauth login");
			break;
			
		case DF_URL_CMD_REQUEST_COOKIE:
			NSLog(@"requestWithMethod (command) : %@", @"request cookie");
			break;
			
		case DF_URL_CMD_REQUEST_TOKEN:
			NSLog(@"requestWithMethod (command) : %@", @"request token");
			break;
			
		case DF_URL_CMD_LOGOUT:
			NSLog(@"requestWithMethod (command) : %@", @"logout");
			break;
			
		case DF_URL_CMD_CHECK_APP_NEW_VERSION:
			NSLog(@"requestWithMethod (command) : %@", @"check app version");
			break;

		case DF_URL_CMD_INTRO_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"intro info");
			break;
			
		case DF_URL_CMD_NEW_BOOK_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"new book inof");
			break;
			
		case DF_URL_CMD_GOODS_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"goods info");
			break;
			
		case DF_URL_CMD_GOODS_CNT:
			NSLog(@"requestWithMethod (command) : %@", @"goods cnt");
			break;
			
		case DF_URL_CMD_CONTINUE_VIEW_INS:
			NSLog(@"requestWithMethod (command) : %@", @"continue view ins");
			break;
			
		case DF_URL_CMD_CONTINUE_VIEW:
			NSLog(@"requestWithMethod (command) : %@", @"continue view");
			break;
			
		case DF_URL_CMD_CHECK_BUY:
			NSLog(@"requestWithMethod (command) : %@", @"check buy");
			break;
			
		case DF_URL_CMD_COMPLETED_DOWNLOAD:
			NSLog(@"requestWithMethod (command) : %@", @"completed download");
			break;
			
		case DF_URL_CMD_PUSH_DEVICE_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"push device info");
			break;
		case DF_URL_CMD_CONTENT_DOWNLOAD:
			NSLog(@"requestWithMethod (command) : %@", @"download contents");
			break;
			
		case DF_URL_CMD_RECOMMEND_CONTENT_LIST:
			NSLog(@"requestWithMethod (command) : %@", @"recommand content list");
			break;
			
		case DF_URL_CMD_CONTENT_LIST:
			NSLog(@"requestWithMethod (command) : %@", @"content list");
			break;

		case DF_URL_CMD_CONTENT_LIST_CARTOON:
			NSLog(@"requestWithMethod (command) : %@", @"content list cartoon");
			break;			

		case DF_URL_CMD_CONTENT_LIST_EPUB:
			NSLog(@"requestWithMethod (command) : %@", @"content list epub");
			break;			
			
		case DF_URL_CMD_SEARCH_LIST:
			NSLog(@"requestWithMethod (command) : %@", @"search list");
			break;
			
		case DF_URL_CMD_CONTENT_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"content info");
			break;
			
		case DF_URL_CMD_GOOD_BAD_ZZIM:
			NSLog(@"requestWithMethod (command) : %@", @"good bad zzim");
			break;
			
		case DF_URL_CMD_BUY_LIST:
			NSLog(@"requestWithMethod (command) : %@", @"buy list");
			break;
			
		case DF_URL_CMD_BUY_DETAIL:
			NSLog(@"requestWithMethod (command) : %@", @"buy detail");
			break;
			
		case DF_URL_CMD_MY_VIEW_ZZIM_LIST:
			NSLog(@"requestWithMethod (command) : %@", @"view zzim list");
			break;
			
		case DF_URL_CMD_MY_VIEW_ZZIM_DELETE:
			NSLog(@"requestWithMethod (command) : %@", @"view zzim delete");
			break;
			
		case DF_URL_CMD_PLAY_VIEW_LOG:
			NSLog(@"requestWithMethod (command) : %@", @"play view log");
			break;
			
		case DF_URL_CMD_LOGININFO:
			NSLog(@"requestWithMethod (command) : %@", @"logininfo");
			break;
			
		case DF_URL_CMD_SAFE_TIME:
			NSLog(@"requestWithMethod (command) : %@", @"safe time");
			break;
			
		default:
			NSLog(@"requestWithMethod (command) : %@", @"unknown command");
			break;
	}
	
	NSLog(@"requestWithMethod (method)  : %@", method);
	NSLog(@"requestWithMethod (path)    : %@", path);
	NSLog(@"requestWithMethod (param)   : %@", parameter);
	NSLog(@"----------------------------------------------\n");
	
	// set header.
	[self __headerRequest:request method:method contentType:@"application/x-www-form-urlencoded"];
	
	// set body.
	if (parameter != nil)
	{
		NSMutableData *body = [self __bodyRequest:parameter];
		[request setHTTPBody:body];
	}
	
	
	[m_ReceiveData release];
	m_ReceiveData	= [[NSMutableData alloc] initWithCapacity:0];
	m_Response		= nil;
	
	// create connection
	m_Connect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (m_Connect == nil)
	{
		NSLog(@"requestWithMethod : url connection failed for string %@", path);
		app.networkActivityIndicatorVisible = NO;
		
		m_IsDownLoading = NO;
		m_Command		= DF_URL_CMD_NONE;
		
		return NO;
	}
	
	[m_Connect scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	
	return YES;
}

- (BOOL) requestWithMethod:(NSString *)method path:(NSString *)path json:(NSDictionary *)json delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self requestWithMethod:method path:path json:json];
}

- (BOOL) requestWithMethod:(NSString *)method path:(NSString *)path json:(NSDictionary *)json
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_IsDownLoading = YES;
	
	UIApplication *		app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	
	if (method == nil)
	{
		app.networkActivityIndicatorVisible = NO;
		
		m_IsDownLoading = NO;
		m_Command		= DF_URL_CMD_NONE;
		
		return NO;
	}
	
	if (path == nil)
	{
		app.networkActivityIndicatorVisible = NO;
		
		m_IsDownLoading	= NO;
		m_Command		= DF_URL_CMD_NONE;
		
		return NO;
	}
	
	NSMutableURLRequest *	request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path] 
															cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
														timeoutInterval:kTimeoutInterval];
	if (request == nil)
	{
		NSLog(@"requestWithMethod : could not create url request from string %@", path);
		app.networkActivityIndicatorVisible = NO;
		
		m_IsDownLoading = NO;
		m_Command		= DF_URL_CMD_NONE;
		
		return NO;
	}
	
	NSLog(@"\n=============================================");
	NSLog(@"=============================================");
	switch (m_Command) 
	{
		case DF_URL_CMD_LOGIN_REST:
			NSLog(@"requestWithMethod (command) : %@", @"rest login");
			break;
			
		case DF_URL_CMD_LOGIN_OAUTH:
			NSLog(@"requestWithMethod (command) : %@", @"oauth login");
			break;
			
		case DF_URL_CMD_REQUEST_COOKIE:
			NSLog(@"requestWithMethod (command) : %@", @"request cookie");
			break;
			
		case DF_URL_CMD_REQUEST_TOKEN:
			NSLog(@"requestWithMethod (command) : %@", @"request token");
			break;
			
		case DF_URL_CMD_LOGOUT:
			NSLog(@"requestWithMethod (command) : %@", @"logout");
			break;
			
		case DF_URL_CMD_CHECK_APP_NEW_VERSION:
			NSLog(@"requestWithMethod (command) : %@", @"check app version");
			break;
			
		case DF_URL_CMD_INTRO_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"intro info");
			break;

		case DF_URL_CMD_NEW_BOOK_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"new book inof");
			break;
			
		case DF_URL_CMD_GOODS_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"goods info");
			break;
			
		case DF_URL_CMD_GOODS_CNT:
			NSLog(@"requestWithMethod (command) : %@", @"goods cnt");
			break;
			
		case DF_URL_CMD_CONTINUE_VIEW_INS:
			NSLog(@"requestWithMethod (command) : %@", @"continue view ins");
			break;
			
		case DF_URL_CMD_CONTINUE_VIEW:
			NSLog(@"requestWithMethod (command) : %@", @"continue view");
			break;
			
		case DF_URL_CMD_CHECK_BUY:
			NSLog(@"requestWithMethod (command) : %@", @"check buy");
			break;
			
		case DF_URL_CMD_COMPLETED_DOWNLOAD:
			NSLog(@"requestWithMethod (command) : %@", @"completed download");
			break;
			
		case DF_URL_CMD_PUSH_DEVICE_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"push device info");
			break;
		case DF_URL_CMD_CONTENT_DOWNLOAD:
			NSLog(@"requestWithMethod (command) : %@", @"download contents");
			break;
			
		case DF_URL_CMD_RECOMMEND_CONTENT_LIST:
			NSLog(@"requestWithMethod (command) : %@", @"recommand content list");
			break;
			
		case DF_URL_CMD_CONTENT_LIST:
			NSLog(@"requestWithMethod (command) : %@", @"content list");
			break;

		case DF_URL_CMD_CONTENT_LIST_CARTOON:
			NSLog(@"requestWithMethod (command) : %@", @"content list cartoon");
			break;

		case DF_URL_CMD_CONTENT_LIST_EPUB:
			NSLog(@"requestWithMethod (command) : %@", @"content list epub");
			break;
			
		case DF_URL_CMD_SEARCH_LIST:
			NSLog(@"requestWithMethod (command) : %@", @"search list");
			break;
			
		case DF_URL_CMD_CONTENT_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"content info");
			break;
			
		case DF_URL_CMD_GOOD_BAD_ZZIM:
			NSLog(@"requestWithMethod (command) : %@", @"good bad zzim");
			break;
			
		case DF_URL_CMD_BUY_LIST:
			NSLog(@"requestWithMethod (command) : %@", @"buy list");
			break;
			
		case DF_URL_CMD_BUY_DETAIL:
			NSLog(@"requestWithMethod (command) : %@", @"buy detail");
			break;
			
		case DF_URL_CMD_MY_VIEW_ZZIM_LIST:
			NSLog(@"requestWithMethod (command) : %@", @"view zzim list");
			break;
			
		case DF_URL_CMD_MY_VIEW_ZZIM_DELETE:
			NSLog(@"requestWithMethod (command) : %@", @"view zzim delete");
			break;
			
		case DF_URL_CMD_PLAY_VIEW_LOG:
			NSLog(@"requestWithMethod (command) : %@", @"play view log");
			break;
			
		case DF_URL_CMD_LOGININFO:
			NSLog(@"requestWithMethod (command) : %@", @"logininfo");
			break;
			
		case DF_URL_CMD_SAFE_TIME:
			NSLog(@"requestWithMethod (command) : %@", @"safe time");
			break;			
			
		default:
			NSLog(@"requestWithMethod (command) : %@", @"unknown command");
			break;
	}
	
	NSLog(@"requestWithMethod (method)  : %@", method);
	NSLog(@"requestWithMethod (path)    : %@", path);
	NSLog(@"requestWithMethod (json)    : %@", json);
	NSLog(@"----------------------------------------------\n");
	
	// set header.
	[self __headerRequest:request method:method contentType:@"application/x-www-form-urlencoded"];
	
	// set body.
	if (json != nil)
	{
		SBJSON *	sbjson = [SBJSON new];
		sbjson.humanReadable = YES;
		
		NSString *jsonString = [NSString stringWithString:[json JSONFragment]];
		
		NSData *body = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
		[request setHTTPBody:body];
	}
	
	
	[m_ReceiveData release];
	m_ReceiveData	= [[NSMutableData alloc] initWithCapacity:0];
	m_Response		= nil;
	
	// create connection
	m_Connect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (m_Connect == nil)
	{
		NSLog(@"requestWithMethod : url connection failed for string %@", path);
		app.networkActivityIndicatorVisible = NO;
		
		m_IsDownLoading = NO;
		m_Command		= DF_URL_CMD_NONE;
		
		return NO;
	}
	
	[m_Connect scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	
	return YES;
}

- (BOOL) requestWithMethod:(NSString *)method path:(NSString *)path xml:(NSDictionary *)xml delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self requestWithMethod:method path:path xml:xml];
}

- (BOOL) requestWithMethod:(NSString *)method path:(NSString *)path xml:(NSDictionary *)xml
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_IsDownLoading = YES;
	
	UIApplication *		app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	
	if (method == nil)
	{
		app.networkActivityIndicatorVisible = NO;
		
		m_IsDownLoading = NO;
		m_Command		= DF_URL_CMD_NONE;
		
		return NO;
	}
	
	if (path == nil)
	{
		app.networkActivityIndicatorVisible = NO;
		
		m_IsDownLoading	= NO;
		m_Command		= DF_URL_CMD_NONE;
		
		return NO;
	}
	
	NSMutableURLRequest *	request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path] 
															cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
														timeoutInterval:kTimeoutInterval];
	if (request == nil)
	{
		NSLog(@"requestWithMethod : could not create url request from string %@", path);
		app.networkActivityIndicatorVisible = NO;
		
		m_IsDownLoading = NO;
		m_Command		= DF_URL_CMD_NONE;
		
		return NO;
	}
	
	NSLog(@"\n=============================================");
	NSLog(@"=============================================");
	switch (m_Command) 
	{
		case DF_URL_CMD_LOGIN_REST:
			NSLog(@"requestWithMethod (command) : %@", @"rest login");
			break;
			
		case DF_URL_CMD_LOGIN_OAUTH:
			NSLog(@"requestWithMethod (command) : %@", @"oauth login");
			break;
			
		case DF_URL_CMD_REQUEST_COOKIE:
			NSLog(@"requestWithMethod (command) : %@", @"request cookie");
			break;
			
		case DF_URL_CMD_REQUEST_TOKEN:
			NSLog(@"requestWithMethod (command) : %@", @"request token");
			break;
			
		case DF_URL_CMD_LOGOUT:
			NSLog(@"requestWithMethod (command) : %@", @"logout");
			break;
			
		case DF_URL_CMD_CHECK_APP_NEW_VERSION:
			NSLog(@"requestWithMethod (command) : %@", @"check app version");
			break;
			
		case DF_URL_CMD_INTRO_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"intro info");
			break;

		case DF_URL_CMD_NEW_BOOK_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"new book inof");
			break;
			
		case DF_URL_CMD_GOODS_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"goods info");
			break;
			
		case DF_URL_CMD_GOODS_CNT:
			NSLog(@"requestWithMethod (command) : %@", @"goods cnt");
			break;
			
		case DF_URL_CMD_CONTINUE_VIEW_INS:
			NSLog(@"requestWithMethod (command) : %@", @"continue view ins");
			break;
			
		case DF_URL_CMD_CONTINUE_VIEW:
			NSLog(@"requestWithMethod (command) : %@", @"continue view");
			break;
			
		case DF_URL_CMD_CHECK_BUY:
			NSLog(@"requestWithMethod (command) : %@", @"check buy");
			break;
			
		case DF_URL_CMD_COMPLETED_DOWNLOAD:
			NSLog(@"requestWithMethod (command) : %@", @"completed download");
			break;
			
		case DF_URL_CMD_PUSH_DEVICE_INFO:
			NSLog(@"requestWithMethod (command) : %@", @"push device info");
			break;
			
		case DF_URL_CMD_CONTENT_DOWNLOAD:
			NSLog(@"requestWithMethod (command) : %@", @"download contents");
			break;
			
		case DF_URL_CMD_LOGININFO:
			NSLog(@"requestWithMethod (command) : %@", @"logininfo");
			break;
			
		default:
			NSLog(@"requestWithMethod (command) : %@", @"unknown command");
			break;
	}
	
	NSLog(@"requestWithMethod (method)  : %@", method);
	NSLog(@"requestWithMethod (path)    : %@", path);
	NSLog(@"requestWithMethod (xml)    : %@", xml);
	NSLog(@"----------------------------------------------\n");
	
	// set header.
	[self __headerRequest:request method:method contentType:@"application/x-www-form-urlencoded"];
	
	// set body
	if (xml != nil)
	{
		// create root element
		APElement *		rootElement = [self __elementWithDictionary:xml];
		APDocument *	xmlDoc		= [[APDocument alloc] initWithRootElement:rootElement];
		NSString *		xmlString	= [xmlDoc xml];
		NSData *		xmlData		= [xmlString dataUsingEncoding:NSUTF8StringEncoding];
		
		NSLog(@"%@", xmlString);
		
		NSString *		base64String	= [Base64 encode:xmlData];
		
		NSMutableDictionary *	parameters = [[NSMutableDictionary alloc] initWithCapacity:0];
		[parameters setObject:base64String forKey:@"param"];
		
		NSMutableData *body = [self __bodyRequest:parameters];
		[request setHTTPBody:body];
		
		[xmlDoc release];
	}
	
	[m_ReceiveData release];
	m_ReceiveData	= [[NSMutableData alloc] initWithCapacity:0];
	m_Response		= nil;
	
	// create connection
	m_Connect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (m_Connect == nil)
	{
		NSLog(@"requestWithMethod : url connection failed for string %@", path);
		app.networkActivityIndicatorVisible = NO;
		
		m_IsDownLoading = NO;
		m_Command		= DF_URL_CMD_NONE;
		
		return NO;
	}
	
	[m_Connect scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	
	return YES;
}

- (BOOL) isDownloading
{
	return m_IsDownLoading;
}

- (NSInteger) getCommand
{
    return m_Command;
}

- (void) cancelConnection
{
	[m_Connect cancel];
	
	UIApplication *		app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	m_IsDownLoading = NO;
	m_Command		= DF_URL_CMD_NONE;
}

- (BOOL) loginRestWithUserId:(NSString *)userid domain:(NSString *)domain passwd:(NSString *)pwd env:(NSString *)env svc:(NSString *)svc
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	NSMutableDictionary *	parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[parameter setObject:userid forKey:@"id"];
	[parameter setObject:domain forKey:@"domain"];
	[parameter setObject:pwd forKey:@"pwd"];
	[parameter setObject:env forKey:@"env"];
	[parameter setObject:svc forKey:@"svc"];
	
	m_Command = DF_URL_CMD_LOGIN_REST;	
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_MAIN_URL, @"rest/appLogin.html"];
	
	return [self requestWithMethod:@"POST" 
							  path: path 
						 parameter:parameter];
}

- (BOOL) loginRestWithUserId:(NSString *)userid domain:(NSString *)domain passwd:(NSString *)pwd env:(NSString *)env svc:(NSString *)svc delegate:(id)delegate;
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self loginRestWithUserId:userid domain:domain passwd:pwd env:env svc:svc];
}

- (BOOL) requestCookieWithCt:(NSString *)ct AtKey:(NSString *)atkey
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	NSMutableDictionary *	parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[parameter setObject:ct forKey:@"ct"];
	[parameter setObject:atkey forKey:@"atkey"];
	
	NSString *input		= [NSString stringWithFormat:@"%@%@%@", atkey, DF_PLAY_BOOK_API_CSKEY, DF_PLAY_BOOK_API_SECRET];
	NSString *signature	= [JMDevKit digest:input];
	[parameter setObject:signature forKey:@"signature"];
	
	m_Command = DF_URL_CMD_REQUEST_COOKIE;
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_USER_URL, @"service/auth/cookie"];
	
	return [self requestWithMethod:@"POST" 
							  path:path 
						 parameter:parameter];
}

- (BOOL) requestCookieWithCt:(NSString *)ct AtKey:(NSString *)atkey delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self requestCookieWithCt:ct AtKey:atkey];
}

- (BOOL) requestTokenWithCt:(NSString *)ct mc:(NSString *)mc cs:(NSString *)cs
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	NSMutableDictionary *	parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[parameter setObject:ct forKey:@"ct"];
	[parameter setObject:DF_PLAY_BOOK_API_CSKEY forKey:@"cskey"];
	[parameter setObject:mc forKey:@"mc"];
	[parameter setObject:cs forKey:@"cs"];
	
	NSString *	input		= [NSString stringWithFormat:@"%@%@%@%@", mc, cs, DF_PLAY_BOOK_API_CSKEY, DF_PLAY_BOOK_API_SECRET];
	NSString *	signature	= [JMDevKit digest:input];
	[parameter setObject:signature forKey:@"signature"];
	
	m_Command = DF_URL_CMD_REQUEST_TOKEN;
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_USER_URL, @"service/auth/token"];
	
	return [self requestWithMethod:@"POST" 
							  path:path 
						 parameter:parameter];
}

- (BOOL) requestTokenWithCt:(NSString *)ct mc:(NSString *)mc cs:(NSString *)cs delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self requestTokenWithCt:ct mc:mc cs:cs];
}


- (BOOL) logout
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	NSMutableDictionary *	parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[parameter setObject:@"" forKey:@"surl"];
	
	m_Command = DF_URL_CMD_LOGOUT;
	
	NSString * path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_MAIN_URL, @"logout.html"];
	
	return [self requestWithMethod:@"POST" 
							  path:path 
						 parameter:parameter];
}

- (BOOL) logoutWithDelegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self logout];
}


- (BOOL) checkAppNewVersionWithScreenType:(NSString *)screenType test:(NSString *)test_yn
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	NSMutableDictionary *	parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[parameter setObject:screenType forKey:@"screen_type"];
	[parameter setObject:test_yn forKey:@"test_yn"];
	
	m_Command = DF_URL_CMD_CHECK_APP_NEW_VERSION;
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"appNewVersion.do"];
	
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) checkAppNewVersionWithScreenType:(NSString *)screenType test:(NSString *)test_yn delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self checkAppNewVersionWithScreenType:screenType test:test_yn];
}

- (BOOL) introInfoWithVersion:(NSString *)version test:(NSString *)test_yn
{
    if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	NSMutableDictionary *	parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[parameter setObject:@"IPHONE" forKey:@"model_name"];
	[parameter setObject:test_yn forKey:@"test_yn"];
	[parameter setObject:@"5.0" forKey:@"os_ver"];
	[parameter setObject:@"ios" forKey:@"screen_code"];         //change when universal version coding
	[parameter setObject:@"svc01" forKey:@"service_code"];      //svc01:palyybook, svc02:playytv, svc03:playykids
	[parameter setObject:version forKey:@"app_ver"];
	
	m_Command = DF_URL_CMD_INTRO_INFO;
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIntroInfo.do"];
	
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) introInfoWithVersion:(NSString *)version test:(NSString *)test_yn delegate:(id)delegate
{
    if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self introInfoWithVersion:version test:test_yn];

}


- (BOOL) newBookInfoWithJson:(NSDictionary *)json_info
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Command = DF_URL_CMD_NEW_BOOK_INFO;
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"newInfo.do"];
	
	return [self requestWithMethod:@"POST" path:path json:json_info];
}

- (BOOL) newBookInfoWithJson:(NSDictionary *)json_info delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self newBookInfoWithJson:json_info];
}


- (BOOL) goodsInfoWithMasterNo:(NSString *)master_no fileNo:(NSString *)file_no contentType:(NSString *)content_type PlatformType:(NSString *)platform_type
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	NSMutableDictionary *	parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[parameter setObject:master_no forKey:@"master_no"];
	[parameter setObject:file_no forKey:@"file_no"];
	[parameter setObject:content_type forKey:@"content_type"];
	[parameter setObject:platform_type forKey:@"platform_type"];
	
	m_Command = DF_URL_CMD_GOODS_INFO;
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"goodsInfo.do"];
	
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) goodsInfoWithMasterNo:(NSString *)master_no fileNo:(NSString *)file_no contentType:(NSString *)content_type PlatformType:(NSString *)platform_type delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self goodsInfoWithMasterNo:master_no fileNo:file_no contentType:content_type PlatformType:platform_type];
}


- (BOOL) goodsCntWithMasterNo:(NSString *)master_no contentType:(NSString *)content_type platformType:(NSString *)platform_type
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	NSMutableDictionary *	parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[parameter setObject:master_no forKey:@"master_no"];
	[parameter setObject:content_type forKey:@"content_type"];
	[parameter setObject:platform_type forKey:@"platform_type"];
	
	m_Command = DF_URL_CMD_GOODS_CNT;
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"goodsCnt.do"];
	
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) goodsCntWithMasterNo:(NSString *)master_no contentType:(NSString *)content_type platformType:(NSString *)platform_type delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self goodsCntWithMasterNo:master_no contentType:content_type platformType:platform_type];
}


- (BOOL) continueViewInsWithMasterNo:(NSString *)master_no userNo:(NSString *)user_no replayNo:(NSString *)replay_no fileNo:(NSString *)file_no
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	NSMutableDictionary *	parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[parameter setObject:master_no forKey:@"master_no"];
	[parameter setObject:user_no forKey:@"user_no"];
	[parameter setObject:replay_no forKey:@"replay_no"];
	[parameter setObject:file_no forKey:@"file_no"];
	
	m_Command = DF_URL_CMD_CONTINUE_VIEW_INS;
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"continueViewIns.do"];
	
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) continueViewInsWithMasterNo:(NSString *)master_no userNo:(NSString *)user_no replayNo:(NSString *)replay_no fileNo:(NSString *)file_no delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self continueViewInsWithMasterNo:master_no userNo:user_no replayNo:replay_no fileNo:file_no];
}


- (BOOL) continueViewWithMasterNo:(NSString *)master_no userNo:(NSString *)user_no fileNo:(NSString *)file_no
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	NSMutableDictionary *	parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[parameter setObject:master_no forKey:@"master_no"];
	[parameter setObject:user_no forKey:@"user_no"];
	[parameter setObject:file_no forKey:@"file_no"];
	
	m_Command = DF_URL_CMD_CONTINUE_VIEW;
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"continueView.do"];
	
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) continueViewWithMasterNo:(NSString *)master_no userNo:(NSString *)user_no fileNo:(NSString *)file_no delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self continueViewWithMasterNo:master_no userNo:user_no fileNo:file_no];
}


- (BOOL) checkBuyWithDomain:(NSString *)domain userNo:(NSString *)user_no fileNo:(NSString *)file_no
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	NSMutableDictionary *	parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[parameter setObject:domain forKey:@"domain"];
	[parameter setObject:user_no forKey:@"user_no"];
	[parameter setObject:@"kth" forKey:@"domain"];
	[parameter setObject:file_no forKey:@"file_no"];
	
	m_Command = DF_URL_CMD_CHECK_BUY;
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"exbuyCheckEncode.do"];
	//	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"exbuyCheck.do"];
	
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) checkBuyWithDomain:(NSString *)domain userNo:(NSString *)user_no fileNo:(NSString *)file_no delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self checkBuyWithDomain:domain userNo:user_no fileNo:file_no];
}


- (BOOL) completedDownloadWithMasterNo:(NSString *)master_no userNo:(NSString *)user_no fileNo:(NSString *)file_no
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	NSMutableDictionary *	parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[parameter setObject:master_no forKey:@"master_no"];
	[parameter setObject:user_no forKey:@"user_no"];
	[parameter setObject:file_no forKey:@"file_no"];
	
	m_Command = DF_URL_CMD_COMPLETED_DOWNLOAD;
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"downComplete.do"];
	
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) completedDownloadWithMasterNo:(NSString *)master_no userNo:(NSString *)user_no fileNo:(NSString *)file_no delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self completedDownloadWithMasterNo:master_no userNo:user_no fileNo:file_no];
}


- (BOOL) pushDeviceInfoWithUserNo:(NSString *)user_no deviceToken:(NSString *)device_token screenType:(NSString *)screen_type delYN:(NSString *)del_yn
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	NSMutableDictionary *	parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[parameter setObject:user_no forKey:@"user_no"];
	[parameter setObject:device_token forKey:@"device_token"];
	[parameter setObject:screen_type forKey:@"screen_type"];
	[parameter setObject:del_yn forKey:@"del_yn"];
	
	m_Command = DF_URL_CMD_PUSH_DEVICE_INFO;
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"pushDeviceInfo.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) pushDeviceInfoWithUserNo:(NSString *)user_no deviceToken:(NSString *)device_token screenType:(NSString *)screen_type delYN:(NSString *)del_yn delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self pushDeviceInfoWithUserNo:user_no deviceToken:device_token screenType:screen_type delYN:del_yn];
}

- (BOOL) downloadContentsWithContentId:(NSString *)content_id 
								userID:(NSString *)userid 
							userNumber:(NSString *)userNumber 
							  filePath:(NSString *)filePath 
							  fileType:(NSString *)fileType 
							 deviceKey:(NSString *)deviceKey 
						   contentType:(NSString *)content_type 
							  delegate:(id)delegate
{
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self downloadContentsWithContentId:content_id 
										userID:userid 
									userNumber:userNumber 
									  filePath:filePath 
									  fileType:fileType 
									 deviceKey:deviceKey 
								   contentType:content_type];	
}

- (BOOL) downloadContentsWithContentId:(NSString *)content_id 
								userID:(NSString *)userid 
							userNumber:(NSString *)userNumber 
							  filePath:(NSString *)filePath 
							  fileType:(NSString *)fileType 
							 deviceKey:(NSString *)deviceKey 
						   contentType:(NSString *)content_type
{
	
	if (m_IsDownLoading == YES)
	{
		return NO;
	}
	
	// root element (packaging request)
	NSMutableDictionary *	xml = [[NSMutableDictionary alloc] initWithCapacity:0];
	[xml setObject:@"PACKAGING_REQUEST" forKey:PBR_XML_ELEMENT_NAME];
	
	// packaging request attributes
	NSMutableArray *	packaging_request_attributes	= [[NSMutableArray alloc] initWithCapacity:0];
	
	NSDictionary *		packaging_request_attribute		= [NSDictionary dictionaryWithObjectsAndKeys:@"TYPE", PBR_XML_ATTRIBUTE_NAME, 
														   @"MOBILE", PBR_XML_ATTRIBUTE_VALUE, nil];
	[packaging_request_attributes addObject:packaging_request_attribute];
	[xml setObject:packaging_request_attributes forKey:PBR_XML_ELEMENT_ATTRIBUTES];
	
	// packaging child elements
	NSMutableArray *		packaging_childs	= [[NSMutableArray alloc] initWithCapacity:0];
	
	// parameters
	NSMutableDictionary *	parameters			= [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameters setObject:@"PARAMETERS" forKey:PBR_XML_ELEMENT_NAME];
	
	// parameters child elements
	NSMutableArray *		parameters_childs	= [[NSMutableArray alloc] initWithCapacity:0];
	NSDictionary *			domainElement		= [NSDictionary dictionaryWithObjectsAndKeys:@"DOMAIN", PBR_XML_ELEMENT_NAME, @"kth", PBR_XML_ELEMENT_VALUE, nil];
	NSDictionary *			contentIdElement	= [NSDictionary dictionaryWithObjectsAndKeys:@"CONTENT_ID", PBR_XML_ELEMENT_NAME, content_id, PBR_XML_ELEMENT_VALUE, nil];
	NSDictionary *			userIdElement		= [NSDictionary dictionaryWithObjectsAndKeys:@"USER_ID", PBR_XML_ELEMENT_NAME, userid, PBR_XML_ELEMENT_VALUE, nil];
	NSDictionary *			userNumberElement	= [NSDictionary dictionaryWithObjectsAndKeys:@"USER_NUMBER", PBR_XML_ELEMENT_NAME, userNumber, PBR_XML_ELEMENT_VALUE, nil];
	NSDictionary *			filePathElement		= [NSDictionary dictionaryWithObjectsAndKeys:@"FILE_PATH", PBR_XML_ELEMENT_NAME, filePath, PBR_XML_ELEMENT_VALUE, nil];
	NSDictionary *			fileTypeElement		= [NSDictionary dictionaryWithObjectsAndKeys:@"FILE_TYPE", PBR_XML_ELEMENT_NAME, fileType, PBR_XML_ELEMENT_VALUE, nil];
	NSDictionary *			deviceKeyElement	= [NSDictionary dictionaryWithObjectsAndKeys:@"DEVICE_KEY", PBR_XML_ELEMENT_NAME, deviceKey, PBR_XML_ELEMENT_VALUE, nil];
	NSDictionary *			contentTypeElement	= [NSDictionary dictionaryWithObjectsAndKeys:@"CONTENT_TYPE", PBR_XML_ELEMENT_NAME, content_type, PBR_XML_ELEMENT_VALUE, nil];
	
	[parameters_childs addObject:domainElement];
	[parameters_childs addObject:contentIdElement];
	[parameters_childs addObject:userIdElement];
	[parameters_childs addObject:userNumberElement];
	[parameters_childs addObject:filePathElement];
	[parameters_childs addObject:fileTypeElement];
	[parameters_childs addObject:deviceKeyElement];
	[parameters_childs addObject:contentTypeElement];
	
	[parameters setObject:parameters_childs forKey:PBR_XML_ELEMENT_CHILDS];
	[packaging_childs addObject:parameters];
	
	[xml setObject:packaging_childs forKey:PBR_XML_ELEMENT_CHILDS];
	
	
	m_Command = DF_URL_CMD_CONTENT_DOWNLOAD;
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_CHARGE_COMIC, @"KTHPackager.do"];
	return [self requestWithMethod:@"POST" path:path xml:xml];
}


- (BOOL) recommendContentListWithMenuType:(NSString *)menu_type
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_RECOMMEND_CONTENT_LIST;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:menu_type forKey:@"menu_type"];
	[parameter setObject:@"recommendContentList" forKey:@"cmd"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) recommendContentListWithMenuType:(NSString *)menu_type delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self recommendContentListWithMenuType:menu_type];
}

/*
 M menu_type 00:무료, 01:정액제 
 O main_group CO:만화, NO:소설
 O page_count - 현재 페이지 번호
 O list_count - 리스트 개수. default: 10
 O order_type 00:최신순, 01:인기술, default:00
 O view_type 00:리스트보기, 01:썸네일 보기
 */
- (BOOL) contentListWithMenuType:(NSString *)menu_type mainGroup:(NSString *)main_group pageCount:(NSString *)page_count listCount:(NSString *)list_count orderType:(NSString *)order_type viewType:(NSString *)view_type
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_CONTENT_LIST;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"contentList" forKey:@"cmd"];
	[parameter setObject:menu_type forKey:@"menu_type"];
	[parameter setObject:main_group forKey:@"main_group"];
	[parameter setObject:page_count forKey:@"page_count"];
	[parameter setObject:list_count forKey:@"list_count"];
	[parameter setObject:order_type forKey:@"order_type"];
	[parameter setObject:view_type forKey:@"view_type"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) contentListWithMenuType:(NSString *)menu_type mainGroup:(NSString *)main_group pageCount:(NSString *)page_count listCount:(NSString *)list_count orderType:(NSString *)order_type viewType:(NSString *)view_type delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self contentListWithMenuType:menu_type mainGroup:main_group pageCount:page_count listCount:list_count orderType:order_type viewType:view_type];
}

- (BOOL) contentListWithMenuType:(NSString *)menu_type mainGroup:(NSString *)main_group pageCount:(NSString *)page_count listCount:(NSString *)list_count orderType:(NSString *)order_type viewType:(NSString *)view_type userNo:(NSString *)user_no
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_CONTENT_LIST;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"contentList" forKey:@"cmd"];
	[parameter setObject:menu_type forKey:@"menu_type"];
	[parameter setObject:main_group forKey:@"main_group"];
	[parameter setObject:page_count forKey:@"page_count"];
	[parameter setObject:list_count forKey:@"list_count"];
	[parameter setObject:order_type forKey:@"order_type"];
	[parameter setObject:view_type forKey:@"view_type"];
	[parameter setObject:user_no forKey:@"user_no"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) contentListWithMenuType:(NSString *)menu_type mainGroup:(NSString *)main_group pageCount:(NSString *)page_count listCount:(NSString *)list_count orderType:(NSString *)order_type viewType:(NSString *)view_type userNo:(NSString *)user_no delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self contentListWithMenuType:menu_type mainGroup:main_group pageCount:page_count listCount:list_count orderType:order_type viewType:view_type userNo:user_no];
}

- (BOOL) contentListCartoonWithMenuType:(NSString *)menu_type pageCount:(NSString *)page_count listCount:(NSString *)list_count orderType:(NSString *)order_type viewType:(NSString *)view_type
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_CONTENT_LIST_CARTOON;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"contentList" forKey:@"cmd"];
	[parameter setObject:menu_type forKey:@"menu_type"];
	[parameter setObject:BI_MAIN_GROUP_TYPE_CARTOON forKey:@"main_group"];
	[parameter setObject:page_count forKey:@"page_count"];
	[parameter setObject:list_count forKey:@"list_count"];
	[parameter setObject:order_type forKey:@"order_type"];
	[parameter setObject:view_type forKey:@"view_type"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) contentListCartoonWithMenuType:(NSString *)menu_type pageCount:(NSString *)page_count listCount:(NSString *)list_count orderType:(NSString *)order_type viewType:(NSString *)view_type delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self contentListCartoonWithMenuType:menu_type pageCount:page_count listCount:list_count orderType:order_type viewType:view_type];
}

- (BOOL) contentListEpubWithMenuType:(NSString *)menu_type pageCount:(NSString *)page_count listCount:(NSString *)list_count orderType:(NSString *)order_type viewType:(NSString *)view_type
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_CONTENT_LIST_EPUB;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"contentList" forKey:@"cmd"];
	[parameter setObject:menu_type forKey:@"menu_type"];
	[parameter setObject:BI_MAIN_GROUP_TYPE_NOVEL forKey:@"main_group"];
	[parameter setObject:page_count forKey:@"page_count"];
	[parameter setObject:list_count forKey:@"list_count"];
	[parameter setObject:order_type forKey:@"order_type"];
	[parameter setObject:view_type forKey:@"view_type"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) contentListEpubWithMenuType:(NSString *)menu_type pageCount:(NSString *)page_count listCount:(NSString *)list_count orderType:(NSString *)order_type viewType:(NSString *)view_type delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self contentListCartoonWithMenuType:menu_type pageCount:page_count listCount:list_count orderType:order_type viewType:view_type];
}


- (BOOL) searchListWithKeyword:(NSString *)keyword pageCount:(NSString *)page_count listCount:(NSString *)list_count mainGroup:(NSString *)main_group orderType:(NSString *)order_type
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_SEARCH_LIST;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"searchList" forKey:@"cmd"];
	[parameter setObject:keyword forKey:@"keyword"];
	[parameter setObject:page_count forKey:@"page_count"];
	[parameter setObject:list_count forKey:@"list_count"];
	[parameter setObject:main_group forKey:@"main_group"];
	[parameter setObject:order_type forKey:@"order_type"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) searchListWithKeyword:(NSString *)keyword pageCount:(NSString *)page_count listCount:(NSString *)list_count mainGroup:(NSString *)main_group orderType:(NSString *)order_type delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self searchListWithKeyword:keyword pageCount:page_count listCount:list_count mainGroup:main_group orderType:order_type];
}

- (BOOL) contentInfoWithMasterNo:(NSString *)master_no
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_CONTENT_INFO;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"contentInfo" forKey:@"cmd"];
	[parameter setObject:master_no forKey:@"master_no"];
	//have to erase this line
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) contentInfoWithMasterNo:(NSString *)master_no delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self contentInfoWithMasterNo:master_no];
}

- (BOOL) contentInfoWithMasterNo:(NSString *)master_no userNo:(NSString *)user_no
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_CONTENT_INFO;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"contentInfo" forKey:@"cmd"];
	[parameter setObject:master_no forKey:@"master_no"];
	[parameter setObject:user_no forKey:@"user_no"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) contentInfoWithMasterNo:(NSString *)master_no userNo:(NSString *)user_no delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self contentInfoWithMasterNo:master_no userNo:user_no];
}

- (BOOL) contentInfoWithBillCode:(NSString *)bill_code userNo:(NSString *)user_no
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_CONTENT_INFO;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"contentInfo" forKey:@"cmd"];
	[parameter setObject:bill_code forKey:@"bill_code"];
	[parameter setObject:user_no forKey:@"user_no"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) contentInfoWithBillCode:(NSString *)bill_code userNo:(NSString *)user_no delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self contentInfoWithBillCode:bill_code userNo:user_no];
}


//#define DF_URL_CMD_GOOD_BAD_ZZIM			20
- (BOOL) goodBadZzimWithMasterNo:(NSString *)master_no userNo:(NSString *)user_no eventType:(NSString *)event_type
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_GOOD_BAD_ZZIM;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"goodBadZzim" forKey:@"cmd"];
	[parameter setObject:master_no forKey:@"master_no"];
	[parameter setObject:user_no forKey:@"user_no"];
	[parameter setObject:event_type forKey:@"event_type"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) goodBadZzimWithMasterNo:(NSString *)master_no userNo:(NSString *)user_no eventType:(NSString *)event_type delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self goodBadZzimWithMasterNo:master_no userNo:user_no eventType:event_type];
}

//#define DF_URL_CMD_BUY_LIST					21
- (BOOL) buyListWithUserNo:(NSString *)user_no pageCount:(NSString *)page_count listCount:(NSString *)list_count myType:(NSString *)my_type mainGroup:(NSString *)main_group
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_BUY_LIST;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"buyList" forKey:@"cmd"];
	[parameter setObject:user_no forKey:@"user_no"];
	[parameter setObject:page_count forKey:@"page_count"];
	[parameter setObject:list_count forKey:@"list_count"];
	[parameter setObject:my_type forKey:@"my_type"];
	[parameter setObject:main_group	forKey:@"main_group"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) buyListWithUserNo:(NSString *)user_no pageCount:(NSString *)page_count listCount:(NSString *)list_count myType:(NSString *)my_type mainGroup:(NSString *)main_group delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self buyListWithUserNo:user_no pageCount:page_count listCount:list_count myType:my_type mainGroup:main_group];
}

- (BOOL) buyListWithUserNo:(NSString *)user_no pageCount:(NSString *)page_count listCount:(NSString *)list_count myType:(NSString *)my_type
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_BUY_LIST;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"buyList" forKey:@"cmd"];
	[parameter setObject:user_no forKey:@"user_no"];
	[parameter setObject:page_count forKey:@"page_count"];
	[parameter setObject:list_count forKey:@"list_count"];
	[parameter setObject:my_type forKey:@"my_type"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) buyListWithUserNo:(NSString *)user_no pageCount:(NSString *)page_count listCount:(NSString *)list_count myType:(NSString *)my_type delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self buyListWithUserNo:user_no pageCount:page_count listCount:list_count myType:my_type];
}

//#define DF_URL_CMD_BUY_DETAIL				22
- (BOOL) buyDetailWithUserNo:(NSString *)user_no myType:(NSString *)my_type billCode:(NSString *)bill_code
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_BUY_DETAIL;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"buyDetail" forKey:@"cmd"];
	[parameter setObject:user_no forKey:@"user_no"];
	[parameter setObject:my_type forKey:@"my_type"];
	[parameter setObject:bill_code forKey:@"bill_code"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) buyDetailWithUserNo:(NSString *)user_no myType:(NSString *)my_type billCode:(NSString *)bill_code delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self buyDetailWithUserNo:user_no myType:my_type billCode:bill_code];
}

- (BOOL) myViewZzimListWithUserNo:(NSString *)user_no pageCount:(NSString *)page_count listCount:(NSString *)list_count myType:(NSString *)my_type mainGroup:(NSString *)main_group;
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_MY_VIEW_ZZIM_LIST;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"myViewZzimList" forKey:@"cmd"];
	[parameter setObject:user_no forKey:@"user_no"];
	[parameter setObject:page_count forKey:@"page_count"];
	[parameter setObject:list_count forKey:@"list_count"];
	[parameter setObject:my_type forKey:@"my_type"];
	[parameter setObject:main_group	forKey:@"main_group"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) myViewZzimListWithUserNo:(NSString *)user_no pageCount:(NSString *)page_count listCount:(NSString *)list_count myType:(NSString *)my_type mainGroup:(NSString *)main_group delegate:(id)delegate;
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self myViewZzimListWithUserNo:user_no pageCount:page_count listCount:list_count myType:my_type mainGroup:main_group];
}

//#define DF_URL_CMD_MY_VIEW_ZZIM_LIST		23
- (BOOL) myViewZzimListWithUserNo:(NSString *)user_no pageCount:(NSString *)page_count listCount:(NSString *)list_count myType:(NSString *)my_type
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_MY_VIEW_ZZIM_LIST;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"myViewZzimList" forKey:@"cmd"];
	[parameter setObject:user_no forKey:@"user_no"];
	[parameter setObject:page_count forKey:@"page_count"];
	[parameter setObject:list_count forKey:@"list_count"];
	[parameter setObject:my_type forKey:@"my_type"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) myViewZzimListWithUserNo:(NSString *)user_no pageCount:(NSString *)page_count listCount:(NSString *)list_count myType:(NSString *)my_type delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self myViewZzimListWithUserNo:user_no pageCount:page_count listCount:list_count myType:my_type];
}

//#define DF_URL_CMD_MY_VIEW_ZZIM_DELETE		24
- (BOOL) myViewZzimDeleteWithNoList:(NSString *)no_list myType:(NSString *)my_type userNo:(NSString *)user_no
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_MY_VIEW_ZZIM_DELETE;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"myViewZzimDelete" forKey:@"cmd"];
	[parameter setObject:no_list forKey:@"no_list"];
	[parameter setObject:my_type forKey:@"my_type"];
	[parameter setObject:user_no forKey:@"user_no"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) myViewZzimDeleteWithNoList:(NSString *)no_list myType:(NSString *)my_type userNo:(NSString *)user_no delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self myViewZzimDeleteWithNoList:no_list myType:my_type userNo:user_no];
}

//#define	DF_URL_CMD_PLAY_VIEW_LOG			25
- (BOOL) playViewLogWithMasterNo:(NSString *)master_no bookNo:(NSString *)book_no contentType:(NSString *)content_type userNo:(NSString *)user_no
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_PLAY_VIEW_LOG;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:@"playViewLog" forKey:@"cmd"];
	[parameter setObject:master_no forKey:@"master_no"];
	[parameter setObject:book_no forKey:@"book_no"];
	[parameter setObject:content_type forKey:@"content_type"];
	[parameter setObject:user_no forKey:@"user_no"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getIphoneApi.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) playViewLogWithMasterNo:(NSString *)master_no bookNo:(NSString *)book_no contentType:(NSString *)content_type userNo:(NSString *)user_no delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self playViewLogWithMasterNo:master_no bookNo:book_no contentType:content_type userNo:user_no];
}

- (BOOL) loginInfoWithUserId:(NSString *)userId
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_LOGININFO;
	
	NSString *idDomain;
	NSRange range = [userId rangeOfString:@"@"];
	if (range.location == NSNotFound){
		idDomain = [NSString stringWithFormat:@"%@@paran.com", userId];
	}
	else {
		idDomain = userId;
	}
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	[parameter setObject:idDomain forKey:@"iddomain"];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"loginInfo.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];
}

- (BOOL) loginInfoWithUserId:(NSString *)userId delegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self loginInfoWithUserId:userId];
}

//#define DF_URL_CMD_SAFE_TIME				26
- (BOOL) safeTime
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Command = DF_URL_CMD_SAFE_TIME;
	
	NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	NSString *	path = [NSString stringWithFormat:@"%@%@", DF_PLAY_BOOK_API_URL, @"getSafeTime.do"];
	return [self requestWithMethod:@"POST" path:path parameter:parameter];	
}

- (BOOL) safeTimeWithDelegate:(id)delegate
{
	if (m_IsDownLoading == YES) {
		return NO;
	}
	
	m_Delegate = delegate;
	
	return [self safeTime];
}


//---------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark NSURLConnectionDelegate

#pragma mark -
#pragma mark Connection Data and responses
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse 
{
	return nil;
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	self.m_Response	= response;
	
	/*
	 if ([response expectedContentLength] < 0)
	 {
	 NSLog(@"Invalid URL");
	 NSLog(@"didReceiveResponse : %@", response);
	 [m_Connect cancel];
	 
	 m_IsDownLoading = NO;
	 m_Command		= DF_URL_CMD_NONE;
	 
	 UIApplication *		app = [UIApplication sharedApplication];
	 app.networkActivityIndicatorVisible = NO;
	 }
	 */
	[m_Delegate pbrDidReceiveResponse:response command:m_Command];
}


- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	[m_ReceiveData appendData:data];
	
	[m_Delegate pbrDidReceiveData:m_ReceiveData response:self.m_Response command:m_Command];
}

#pragma mark -
#pragma mark connection Completion
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	UIApplication *		app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	NSInteger oldCommand = m_Command;
	m_IsDownLoading	= NO;
	m_Command		= DF_URL_CMD_NONE;
	
	NSLog(@"error Desc : %@", [error localizedDescription]);	
	
	[m_Delegate pbrDidFailWithError:error command:oldCommand];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
	NSInteger			preCommand	= m_Command;
	id					userInfo	= nil;
	
	UIApplication *		app			= [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	[m_Connect unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	
#ifdef DEBUG_PROTO_LOG	
	if (m_Command != DF_URL_CMD_CONTENT_DOWNLOAD) {
		NSString *strInfo = [[NSString alloc] initWithData:m_ReceiveData encoding:NSUTF8StringEncoding];
		NSLog(@"connectionDidFinishLoading :\n%@", strInfo);
	}
#endif
	
	switch (m_Command) 
	{
		case DF_URL_CMD_LOGIN_REST:
			userInfo = [self __retLoginRest:m_ReceiveData];
			break;
			
		case DF_URL_CMD_REQUEST_COOKIE:
			userInfo = [self __retRequestCookie:m_ReceiveData];
			break;
			
		case DF_URL_CMD_REQUEST_TOKEN:
			userInfo = [self __retRequestToken:m_ReceiveData];
			break;
			
		case DF_URL_CMD_LOGOUT:
			[UserProfile setMC:@""];
			[UserProfile setCS:@""];
			[UserProfile setLoginState:NO];
			break;
			
		case DF_URL_CMD_CHECK_APP_NEW_VERSION:
			userInfo = [self __retCheckAppNewVersion:m_ReceiveData];
			break;
            
        case DF_URL_CMD_INTRO_INFO:
            userInfo = [self __retIntroInfo:m_ReceiveData];
            break;
			
		case DF_URL_CMD_NEW_BOOK_INFO:
			userInfo = [self __retNewBookInfo:m_ReceiveData];
			break;
			
		case DF_URL_CMD_GOODS_INFO:
			userInfo = [self __retGoodsInfo:m_ReceiveData];
			break;
			
		case DF_URL_CMD_GOODS_CNT:
			userInfo = [self __retGoodsCnt:m_ReceiveData];
			break;
			
		case DF_URL_CMD_CONTINUE_VIEW_INS:
			userInfo = [self __retContinueViewIns:m_ReceiveData];
			break;
			
		case DF_URL_CMD_CONTINUE_VIEW:
			userInfo = [self __retContinueView:m_ReceiveData];
			break;
			
		case DF_URL_CMD_CHECK_BUY:
			userInfo = [self __retCheckBuy:m_ReceiveData];
			break;
			
		case DF_URL_CMD_COMPLETED_DOWNLOAD:
			userInfo = [self __retCompletedDownload:m_ReceiveData];	
			break;
			
		case DF_URL_CMD_PUSH_DEVICE_INFO:
			userInfo = [self __retPushDeviceInfo:m_ReceiveData];
			break;
			
		case DF_URL_CMD_CONTENT_DOWNLOAD:
			m_IsDownLoading = NO;
			m_Command		= DF_URL_CMD_NONE;
			
			[m_Delegate pbrDidFinishLoadingWithCommand:preCommand userInfo:m_ReceiveData response:m_Response];
			
			return;
			break;

		case DF_URL_CMD_RECOMMEND_CONTENT_LIST:
			userInfo = [self __retRecommendContentList:m_ReceiveData];
			break;
			
		case DF_URL_CMD_CONTENT_LIST:
			userInfo = [self __retContentList:m_ReceiveData];
			break;

		case DF_URL_CMD_CONTENT_LIST_CARTOON:
			userInfo = [self __retContentList:m_ReceiveData];
			break;
			
		case DF_URL_CMD_CONTENT_LIST_EPUB:
			userInfo = [self __retContentList:m_ReceiveData];
			break;			
			
		case DF_URL_CMD_SEARCH_LIST:
			userInfo = [self __retSearchList:m_ReceiveData];
			break;
			
		case DF_URL_CMD_CONTENT_INFO:
			userInfo = [self __retContentInfo:m_ReceiveData];
			break;
			
		case DF_URL_CMD_GOOD_BAD_ZZIM:
			userInfo = [self __retGoodBadZzim:m_ReceiveData];
			break;
			
		case DF_URL_CMD_BUY_LIST:
			userInfo = [self __retBuyList:m_ReceiveData];
			break;
			
		case DF_URL_CMD_BUY_DETAIL:
			userInfo = [self __retBuyDetail:m_ReceiveData];
			break;
			
		case DF_URL_CMD_MY_VIEW_ZZIM_LIST:
			userInfo = [self __retMyViewZzimList:m_ReceiveData];
			break;
			
		case DF_URL_CMD_MY_VIEW_ZZIM_DELETE:
			userInfo = [self __retMyViewZzimDelete:m_ReceiveData];
			break;
			
		case DF_URL_CMD_PLAY_VIEW_LOG:
			userInfo = [self __retPlayViewLog:m_ReceiveData];
			break;
			
		case DF_URL_CMD_LOGININFO:
			userInfo = [self __retLoginInfo:m_ReceiveData];
			break;
			
		case DF_URL_CMD_SAFE_TIME:
			userInfo = [self __retSafeTime:m_ReceiveData];
			break;
			
		default:
			userInfo	= m_ReceiveData;
			preCommand	= DF_URL_CMD_NONE;
			break;
	}
	
	m_IsDownLoading = NO;
	m_Command		= DF_URL_CMD_NONE;
	
	[m_Delegate pbrDidFinishLoadingWithCommand:preCommand userInfo:userInfo response:m_Response];
}


@end
