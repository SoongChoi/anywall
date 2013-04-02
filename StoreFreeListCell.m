//
//  StoreFreeListCell.m
//  PlayBook
//
//  Created by Daniel on 12. 3. 6..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreFreeListCell.h"


@implementation StoreFreeListCell


@synthesize m_ImageTitle;
@synthesize m_LabelWriter;
@synthesize m_LabelTitle;
@synthesize m_LabelVolume;
@synthesize m_BtnFavorite;
@synthesize m_Delegate;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[m_ImageTitle release];
	[m_LabelWriter release];
	[m_LabelTitle release];
	[m_LabelVolume release];
	[m_BtnFavorite release];
	
	m_Delegate = nil;
	
    [super dealloc];
}


-(IBAction) clickBtnFavorite:(id)sender 
{
	NSInteger index = ((UIView*) sender).tag;
	[m_Delegate storeFreeFavoriteSelected:sender index:index];
}

@end
