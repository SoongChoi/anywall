//
//  StorePaidContentCell.m
//  PlayBook
//
//  Created by Daniel on 12. 4. 1..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StorePaidContentCell.h"

@implementation StorePaidContentCell


@synthesize m_BtnItem_1;
@synthesize m_BtnItem_2;
@synthesize m_BtnItem_3;
@synthesize m_BtnItem_4;
@synthesize m_BtnItem_5;
@synthesize m_BtnItem_6;
@synthesize m_BtnItem_7;
@synthesize m_BtnItem_8;
@synthesize m_BtnItem_9;

@synthesize m_IconItem_1;
@synthesize m_IconItem_2;
@synthesize m_IconItem_3;
@synthesize m_IconItem_4;
@synthesize m_IconItem_5;
@synthesize m_IconItem_6;
@synthesize m_IconItem_7;
@synthesize m_IconItem_8;
@synthesize m_IconItem_9;

@synthesize m_ImageItem_1;
@synthesize m_ImageItem_2;
@synthesize m_ImageItem_3;
@synthesize m_ImageItem_4;
@synthesize m_ImageItem_5;
@synthesize m_ImageItem_6;
@synthesize m_ImageItem_7;
@synthesize m_ImageItem_8;
@synthesize m_ImageItem_9;

@synthesize m_Title_1;
@synthesize m_Title_3;
@synthesize m_Title_5;
@synthesize m_Title_6;
@synthesize m_Title_7;
@synthesize m_Title_8;


@synthesize	m_Delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		m_BtnItem_1.tag = 0;
		m_BtnItem_2.tag = 1;
		m_BtnItem_3.tag = 2;
		m_BtnItem_4.tag = 3;
		m_BtnItem_5.tag = 4;
		m_BtnItem_6.tag = 5;
		m_BtnItem_7.tag = 6;		
		m_BtnItem_8.tag = 7;		
		m_BtnItem_9.tag = 8;		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
	
	[m_IconItem_1 release];
	[m_IconItem_2 release];
	[m_IconItem_3 release];
	[m_IconItem_4 release];
	[m_IconItem_5 release];
	[m_IconItem_6 release];
	[m_IconItem_7 release];
	[m_IconItem_8 release];
	[m_IconItem_9 release];
	
	[m_ImageItem_1 release];
	[m_ImageItem_2 release];
	[m_ImageItem_3 release];
	[m_ImageItem_4 release];
	[m_ImageItem_5 release];
	[m_ImageItem_6 release];
	[m_ImageItem_7 release];
	[m_ImageItem_8 release];
	[m_ImageItem_9 release];
	
	[m_Title_1 release];
	[m_Title_3 release];
	[m_Title_5 release];	
	[m_Title_6 release];
	[m_Title_7 release];	
	[m_Title_8 release];
	
	[m_BtnItem_1 release];
	[m_BtnItem_2 release];
	[m_BtnItem_3 release];
	[m_BtnItem_4 release];
	[m_BtnItem_5 release];
	[m_BtnItem_6 release];	
	[m_BtnItem_7 release];
	[m_BtnItem_8 release];
	[m_BtnItem_9 release];
	
	
	
}


-(IBAction) clickBtnItem:(id)sender
{
	UIButton* btnItem = (UIButton*) sender;
	
	if (m_Delegate != nil) {
		[m_Delegate selectedStorePaidContentItem:sender index:btnItem.tag];
	}
}

@end
