//
//  NoneClientView.m
//  PlayBook
//
//  Created by 전명곤 on 11. 11. 10..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoneClientView.h"


@implementation NoneClientView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}

- (void) setWithClientRect:(CGRect)clientRect delegate:(id)delegate
{
	m_Delegate		= delegate;
	m_ClientRect	= clientRect;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch		*touch = [touches anyObject];
	CGPoint		pt = [touch locationInView:self];
	
	NSLog(@"touchesBegan : x = %d, y = %d", pt.x, pt.y);
	
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch		*touch = [touches anyObject];
	CGPoint		pt = [touch locationInView:self];
	
	NSLog(@"touchesBegan : x = %d, y = %d", pt.x, pt.y);
	
	[super touchesEnded:touches withEvent:event];
	
	if (CGRectContainsPoint(m_ClientRect, pt) == NO)
	{
		[m_Delegate ncvTouchNoneClientRect];
	}
}

@end
