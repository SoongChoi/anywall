//
//  PopupMenuCell.m
//  PlayBook
//
//  Created by 전명곤 on 11. 11. 10..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PopupMenuCell.h"


@implementation PopupMenuCell

@synthesize m_Text;

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

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:animated];
/*
	if (highlighted == YES)
	{
		[m_Text setTextColor:[UIColor redColor]];
	}
	else 
	{
		[m_Text setTextColor:[UIColor whiteColor]];
	}*/
}

- (void)dealloc {
    [super dealloc];
}


@end
