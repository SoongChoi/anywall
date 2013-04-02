//
//  CartoonImageInfo.m
//  PlayBook
//
//  Created by 전명곤 on 11. 11. 16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CartoonImageInfo.h"


@implementation CartoonImageInfo

@synthesize m_StartPos;
@synthesize m_ImageSize;

- (id) init
{
	if ((self = [super init]) != nil)
	{
		m_StartPos		= 0;
		m_ImageSize		= 0;
	}
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

@end
