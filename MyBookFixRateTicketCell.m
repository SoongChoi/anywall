    //
//  MyBookFixRateUsingCell.m
//  PlayBook
//
//  Created by Daniel on 12. 5. 27..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyBookFixRateTicketCell.h"


@implementation MyBookFixRateTicketCell

@synthesize m_TicketTitle;
@synthesize m_ExpireDate;


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
	
	[m_TicketTitle release];
	[m_ExpireDate release];
	
    [super dealloc];
}

@end
