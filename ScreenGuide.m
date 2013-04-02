    //
//  ScreenGuide.m
//  PlayBook
//
//  Created by Daniel on 12. 6. 15..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ScreenGuide.h"


@implementation ScreenGuide

@synthesize m_Delegate;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void) dealloc
{
	m_Delegate = nil;
	
    [super dealloc];
}

+ (id) createWithDelegate:(id)delegate
{
	ScreenGuide* screenGuide = [[ScreenGuide alloc] initWithImage:RESOURCE_IMAGE(@"viewer_guide.png")];
	if (screenGuide == nil)
	{
		return nil;
	}
	screenGuide.m_Delegate = delegate;
	
	[screenGuide setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
	[screenGuide setUserInteractionEnabled:YES];
	
	return screenGuide;
}

- (BOOL) canBecomeFirstResponder
{
	return YES;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	NSLog(@"");	
	[m_Delegate touchScreenGuid:event];
}

@end
