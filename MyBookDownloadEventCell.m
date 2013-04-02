    //
//  MyBookDownloadEventCell.m
//  PlayBook
//
//  Created by Daniel on 12. 4. 25..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyBookDownloadEventCell.h"


@implementation MyBookDownloadEventCell

@synthesize m_TitleEvent;
@synthesize m_ImageExtend;


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

- (void)setExtend:(BOOL)isExtend
{
/****
 *	Not Use Sub Tree
 *
	if (isExtend == YES) {
		[m_ImageExtend setImage:RESOURCE_IMAGE(@"my_download_icon_sale_on.png")];
	}
	else {
		[m_ImageExtend setImage:RESOURCE_IMAGE(@"my_download_icon_sale_off.png")];		
	}
 */
}

- (void)dealloc {
    [m_TitleEvent release];
	
	[super dealloc];
}

@end
