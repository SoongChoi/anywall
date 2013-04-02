//
//  CartoonFileHeader.m
//  PlayBook
//
//  Created by 전명곤 on 11. 11. 16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CartoonFileHeader.h"


@implementation CartoonFileHeader

@synthesize m_Version;
@synthesize m_HeaderSize;

@synthesize m_FileSize;

@synthesize m_ImageCount;

@synthesize m_Reserved1;
@synthesize m_Reserved2;
@synthesize m_Reserved3;
@synthesize m_Reserved4;

- (id) init
{
	if ((self = [super init]) != nil)
	{
		m_Version		= 0;
		m_HeaderSize	= 0;
		
		m_FileSize		= 0;
		
		m_ImageCount	= 0;
		
		m_Reserved1 = (unsigned char *)calloc(4, sizeof(unsigned char));	
		m_Reserved2 = (unsigned char *)calloc(4, sizeof(unsigned char));	
		m_Reserved3 = (unsigned char *)calloc(4, sizeof(unsigned char));	
		m_Reserved4 = (unsigned char *)calloc(4, sizeof(unsigned char));	
	}
	
	return self;
}

- (void) dealloc
{
	free(m_Reserved1);
	free(m_Reserved2);
	free(m_Reserved3);
	free(m_Reserved4);
	
	[super dealloc];
}

@end
