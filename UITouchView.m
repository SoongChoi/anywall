//
//  UITouchView.m
//  PlayBook
//
//  Created by 전명곤 on 11. 12. 12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UITouchView.h"


@implementation UITouchView


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

- (void) setDelegate:(id)delegate
{
	m_Delegate = delegate;
}


#pragma mark -
#pragma mark [UIResponder] Touches,,,

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	[m_Delegate UITouchViewtouchesEnded];
}


@end
