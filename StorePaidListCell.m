//
//  StorePaidListCell.m
//  PlayBook
//
//  Created by Daniel on 12. 3. 6..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StorePaidListCell.h"


@implementation StorePaidListCell


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
    [super dealloc];
}


-(IBAction) clickBtnFavorite:(id)sender 
{
	NSInteger index = ((UIView*) sender).tag;
	[m_Delegate storePaidFavoriteSelected:sender index:index];
}

@end
