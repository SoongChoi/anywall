//
//  StoreFreeListCell.m
//  PlayBook
//
//  Created by Daniel on 12. 3. 6..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "MyBookZzimContentCell.h"


@implementation MyBookZzimContentCell


@synthesize m_ImageTitle;
@synthesize m_ImageBound;
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

- (void)setImageTitleBounds:(PlayBookContentType)contentType
{
	if (contentType == ContentTypeEpub) {
		CGRect imageRect = CGRectMake(21.0f, 8.0f, 38.0f, 57.0f);	
		CGRect boundRect = CGRectMake(20.0f, 8.0f, 40.0f, 59.0f);			
		
		[m_ImageTitle setFrame:imageRect];
		[m_ImageBound setFrame:boundRect];
		[m_ImageBound setImage:RESOURCE_IMAGE(@"list_thumb_box_epub.png")];		
	}
	else {
		CGRect imageRect = CGRectMake(12.0f, 8.0f, 57.0f, 57.0f);	
		CGRect boundRect = CGRectMake(11.0f, 8.0f, 59.0f, 59.0f);

		[m_ImageTitle setFrame:imageRect];
		[m_ImageBound setFrame:boundRect];
		[m_ImageBound setImage:RESOURCE_IMAGE(@"list_thumb_box_comic.png")];
	}
}

- (void)dealloc {

	[m_ImageTitle release];
	[m_ImageBound release]; 
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
	[m_Delegate zzimFavoriteSelected:sender index:index];
}

@end
