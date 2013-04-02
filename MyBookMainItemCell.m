//
//  MyBookMainItemCell.m
//  PlayBook
//
//  Created by Daniel on 12. 5. 23..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyBookMainItemCell.h"


@implementation MyBookMainItemCell

@synthesize m_IconIndImage;
@synthesize m_TitleLable;


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

- (void)setTitleWithIcon:(UIImage*)iconImage itemTitle:(NSString*)itemTitle
{
	[m_IconIndImage setImage:iconImage];
	[m_TitleLable setText:itemTitle];
}

- (void)dealloc {
	[m_IconIndImage release];
	[m_TitleLable release];
	
    [super dealloc];
}


@end
