//
//  CartoonContent.m
//  PlayBook
//
//  Created by 전명곤 on 11. 11. 16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CartoonContent.h"
#import "JMDevKit.h"

#define CARTOON_FILE_HEADER_POS		0
#define CARTOON_HEADER_SIZE			28

#define CARTOON_IMAGE_INFO_POS		28
#define CARTOON_IMAGE_INFO_SIZE		8

@implementation CartoonContent

@synthesize m_Data;
@synthesize m_FileHeader;
@synthesize m_ImageInfos;
@synthesize m_Images;

@synthesize m_FileName;
@synthesize m_CurrentPage;

/*
 * index : 0 ~
 */
- (BOOL) __readImage:(NSUInteger)index
{
	NSUInteger	imageInfoPos	= CARTOON_IMAGE_INFO_POS + index * CARTOON_IMAGE_INFO_SIZE;
	
	if ((imageInfoPos + CARTOON_IMAGE_INFO_SIZE) > [m_Data length])
	{
		return NO;
	}
	
	unsigned char *	bytes	= (unsigned char *)[m_Data bytes];
	
	// read image infomation
	CartoonImageInfo *	imageInfo = [[CartoonImageInfo alloc] init];
	
	imageInfo.m_StartPos	= ((unsigned int)bytes[imageInfoPos] << 24) | ((unsigned int)bytes[imageInfoPos + 1] << 16) | ((unsigned int)bytes[imageInfoPos + 2] << 8) | (unsigned int)bytes[imageInfoPos + 3];
	imageInfo.m_ImageSize	= ((unsigned int)bytes[imageInfoPos + 4] << 24) | ((unsigned int)bytes[imageInfoPos + 5] << 16) | ((unsigned int)bytes[imageInfoPos + 6] << 8) | (unsigned int)bytes[imageInfoPos + 7];
	
	if ((imageInfo.m_StartPos + imageInfo.m_ImageSize) > [m_Data length])
	{
		[imageInfo release];
		
		return NO;
	}
	
	[m_ImageInfos addObject:imageInfo];
	
	// read image data
	NSData *	imageData	= [[NSData alloc] initWithBytes:&bytes[imageInfo.m_StartPos] length:imageInfo.m_ImageSize];
	UIImage *	image		= [UIImage imageWithData:imageData];
	[m_Images addObject:image];
	
    [imageInfo release];
	
	return YES;	
}

- (BOOL) __readFile:(NSString *)fileName
{
	if (fileName == nil)
	{
		return NO;
	}
	
	NSString *		path	= [JMDevKit appDocumentFilePath:fileName];
	NSFileManager *	fm		= [NSFileManager defaultManager];
	
	if ([fm fileExistsAtPath:path] == NO)
	{
		[fm release];
		
		return NO;
	}
	
	[fm release];
	
	NSData *	data = [NSData dataWithContentsOfFile:path];
	if (data == nil)
	{
		return NO;
	}
	
	if ([data length] < CARTOON_HEADER_SIZE)
	{
		return NO;
	}
	
	if (m_Data != nil)
	{
		[m_Data release];
	}
	
	m_Data = [NSMutableData dataWithData:data];
	
	m_CurrentPage = 0;
	
	unsigned char *	bytes	= (unsigned char *)[m_Data bytes];
	
	// read file header infomation
	m_FileHeader.m_Version		= ((unsigned short)bytes[0]) << 8 | (unsigned short)bytes[1];
	m_FileHeader.m_HeaderSize	= ((unsigned short)bytes[2]) << 8 | (unsigned short)bytes[3];
	
	m_FileHeader.m_FileSize		= ((unsigned int)bytes[4] << 24) | ((unsigned int)bytes[5] << 16) | ((unsigned int)bytes[6] << 8) | (unsigned int)bytes[7];
	m_FileHeader.m_ImageCount	= ((unsigned int)bytes[8] << 24) | ((unsigned int)bytes[9] << 16) | ((unsigned int)bytes[10] << 8) | (unsigned int)bytes[11];
	
	memcpy(m_FileHeader.m_Reserved1, &bytes[12], 4);
	memcpy(m_FileHeader.m_Reserved2, &bytes[16], 4);
	memcpy(m_FileHeader.m_Reserved3, &bytes[20], 4);
	memcpy(m_FileHeader.m_Reserved4, &bytes[24], 4);
	
	// read image infomation & image data
	for (NSInteger i = 0; i < m_FileHeader.m_ImageCount; i++)
	{
		if ([self __readImage:i] == NO)
		{
			break;
		}
	}
	
	return YES;
}

- (BOOL) __readData:(NSData *)data
{
	if (data == nil)
	{
		return NO;
	}
	
	if ([data length] < CARTOON_HEADER_SIZE)
	{
		return NO;
	}
	
	if (m_Data != nil)
	{
		[m_Data release];
	}
	self.m_Data = (NSMutableData*)data;
	
	//m_Data = [NSMutableData dataWithData:data];
	
	m_CurrentPage = 0;
	
	unsigned char *	bytes	= (unsigned char *)[m_Data bytes];
	
	// read file header infomation
	m_FileHeader.m_Version		= ((unsigned short)bytes[0]) << 8 | (unsigned short)bytes[1];
	m_FileHeader.m_HeaderSize	= ((unsigned short)bytes[2]) << 8 | (unsigned short)bytes[3];
	
	m_FileHeader.m_FileSize		= ((unsigned int)bytes[4] << 24) | ((unsigned int)bytes[5] << 16) | ((unsigned int)bytes[6] << 8) | (unsigned int)bytes[7];
	m_FileHeader.m_ImageCount	= ((unsigned int)bytes[8] << 24) | ((unsigned int)bytes[9] << 16) | ((unsigned int)bytes[10] << 8) | (unsigned int)bytes[11];
	
	memcpy(m_FileHeader.m_Reserved1, &bytes[12], 4);
	memcpy(m_FileHeader.m_Reserved2, &bytes[16], 4);
	memcpy(m_FileHeader.m_Reserved3, &bytes[20], 4);
	memcpy(m_FileHeader.m_Reserved4, &bytes[24], 4);
	
	// read image infomation & image data	
	for (NSInteger i = 0; i < m_FileHeader.m_ImageCount; i++)
	{
		NSUInteger	imageInfoPos	= CARTOON_IMAGE_INFO_POS + i * CARTOON_IMAGE_INFO_SIZE;
		
		if ((imageInfoPos + CARTOON_IMAGE_INFO_SIZE) > [m_Data length])
		{
			return NO;
		}
		// read image infomation
		CartoonImageInfo *	imageInfo = [[CartoonImageInfo alloc] init];
		
		imageInfo.m_StartPos	= ((unsigned int)bytes[imageInfoPos] << 24) | ((unsigned int)bytes[imageInfoPos + 1] << 16) | ((unsigned int)bytes[imageInfoPos + 2] << 8) | (unsigned int)bytes[imageInfoPos + 3];
		imageInfo.m_ImageSize	= ((unsigned int)bytes[imageInfoPos + 4] << 24) | ((unsigned int)bytes[imageInfoPos + 5] << 16) | ((unsigned int)bytes[imageInfoPos + 6] << 8) | (unsigned int)bytes[imageInfoPos + 7];
				
		[m_ImageInfos addObject:imageInfo];
	}
	m_CurrentImageInfo = 0;
	
	return YES;
}

- (id) init
{
	if ((self = [super init]) != nil)
	{
		m_FileHeader	= [[CartoonFileHeader alloc] init];
		m_ImageInfos	= [[NSMutableArray alloc] initWithCapacity:0];
		m_Images		= [[NSMutableArray alloc] initWithCapacity:0];
		
		m_CurrentPage	= 0;
		m_FileName		= @"";
		m_ContentType	= CARTOON_CONTENT_TYPE_NONE;
		m_Data			= nil;
	}
	
	return self;
}


- (id) initWithContentFile:(NSString *)fileName contentType:(NSInteger)contentType
{
	if ((self = [super init]) != nil)
	{
		m_FileHeader	= [[CartoonFileHeader alloc] init];
		m_ImageInfos	= [[NSMutableArray alloc] initWithCapacity:0];
		m_Images		= [[NSMutableArray alloc] initWithCapacity:0];
		
		m_CurrentPage	= 0;
		
		m_FileName	= fileName;
		
		m_ContentType	= contentType;
		m_Data			= nil;
		
		if ([self __readFile:m_FileName] == NO)
		{
			return nil;
		}
	}
	
	return self;
}

- (id) initWithData:(NSData *)data contentType:(NSInteger)contentType
{
	if ((self = [super init]) != nil)
	{
		m_FileHeader	= [[CartoonFileHeader alloc] init];
		m_ImageInfos	= [[NSMutableArray alloc] initWithCapacity:0];
		m_Images		= [[NSMutableArray alloc] initWithCapacity:0];
		
		m_CurrentPage	= 0;
		
		m_FileName		= @"";
		m_ContentType	= contentType;
		m_Data			= nil;
		
		if ([self __readData:data] == NO)
		{
			return nil;
		}
	}
	
	return self;
}


- (void) dealloc
{
	if (m_ContentType == CARTOON_CONTENT_TYPE_STREAM && [m_FileName length] > 0)
	{
		NSFileManager *	fm		= [NSFileManager defaultManager];
		NSString *		path	= [JMDevKit appDocumentFilePath:m_FileName];
		
		[fm removeItemAtPath:path error:nil];
		
		[fm release];
	}
	
	
	//if (m_Data != nil)
	//{
	//	[m_Data release];
	//}
	
	[m_FileHeader release];
	[m_ImageInfos release];
	[m_Images release];
	
	
	[super dealloc];
}

- (UIImage *) currentPage
{
	if (m_Images == nil)
	{
		return nil;
	}
	
	if ([m_Images count] < m_CurrentPage)
	{
		return nil;
	}
	
	return [m_Images objectAtIndex:(m_CurrentPage - 1)];
}

- (UIImage *) nextPage
{
	if (m_Images == nil)
	{
		return nil;
	}
	
	if ([m_Images count] == 0)
	{
		return nil;
	}
	
	if (m_FileHeader.m_ImageCount <= 0)
	{
		return nil;
	}
	
	if (m_CurrentPage == m_FileHeader.m_ImageCount)
	{
		return nil;
	}
	
	m_CurrentPage++;
	
	NSLog(@"current page = %d", m_CurrentPage);
	
	return [m_Images objectAtIndex:(m_CurrentPage - 1)];
}

- (UIImage *) previousPage
{
	if (m_Images == nil)
	{
		return nil;
	}
	
	if ([m_Images count] == 0)
	{
		return nil;
	}
	
	if (m_FileHeader.m_ImageCount <= 0 || m_CurrentPage == 1)
	{
		return nil;
	}
	
	if (m_CurrentPage == 0)
	{
		m_CurrentPage = 1;
		
		NSLog(@"current page = %d", m_CurrentPage);
		
		return [m_Images objectAtIndex:(m_CurrentPage - 1)];
	}
	
	m_CurrentPage--;
	
	NSLog(@"current page = %d", m_CurrentPage);
	
	return [m_Images objectAtIndex:(m_CurrentPage - 1)];
}

- (NSUInteger) getPageCount
{
	if (m_Images == nil)
	{
		return 0;
	}
	
	if ([m_Images count] == 0)
	{
		return 0;
	}
	
	return (NSUInteger)[m_Images count];
}

- (NSUInteger) getFullPageCount
{
	if (m_Images == nil)
	{
		return 0;
	}
	
	return m_FileHeader.m_ImageCount;	
}

- (NSInteger) getCurrentPageNumber
{
	return m_CurrentPage;
}

- (void) setCurrentPageNumber:(NSInteger)currentPage
{
	if (m_Images == nil)
	{
		return;
	}
	
	if ([m_Images count] == 0)
	{
		return;
	}
	
	if (currentPage > m_FileHeader.m_ImageCount)
	{
		return;
	}
	
	m_CurrentPage = currentPage;
}

- (BOOL) appendWithData:(NSData *)data header:(NSInteger)headeroffset length:(NSInteger)length
{

	if (data == nil)
	{
		data = m_Data;
	}
/*
	if (data != nil)
	{
		[m_Data appendData:data];
	}
*/	
	
	NSUInteger  dataLength = length;
	unsigned char *	bytes	= (unsigned char *)[data bytes];
	
	bytes += headeroffset;
	
	// read image infomation & image data
	for (;m_CurrentImageInfo < m_FileHeader.m_ImageCount; m_CurrentImageInfo++)
	{
		CartoonImageInfo *	imageInfo = [m_ImageInfos objectAtIndex:m_CurrentImageInfo];		
		if ((imageInfo.m_StartPos + imageInfo.m_ImageSize) > dataLength) {
			break;
		}
		// read image data
		NSData *	imageData	= [[NSData alloc] initWithBytes:&bytes[imageInfo.m_StartPos] length:imageInfo.m_ImageSize];		
		UIImage *	image		= [UIImage imageWithData:imageData];
		if (image == nil){
            [imageData release];
			return NO;
        }
		
		[m_Images addObject:image];
        [imageData release];
	}
	
	return YES;
}

@end
