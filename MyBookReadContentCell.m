    //
//  MyBookDownloadCell.m
//  PlayBook
//
//  Created by Daniel on 12. 4. 25..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyBookReadContentCell.h"

#define __MARGIN_EDIT_MODE_IMAGE_X	26

#define _BUTTON_TEXT_MARIN_TOP		14
#define _BUTTON_TEXT_MARIN_LEFT		5
#define _BUTTON_TEXT_MARIN_BOTTOM	14
#define _BUTTON_TEXT_MARIN_RIGHT    10


@implementation MyBookReadContentCell

@synthesize m_ImageSelect;
@synthesize m_ImageTitle;
@synthesize m_ImageBound;
@synthesize m_Writer;
@synthesize m_Title;
@synthesize m_StatusLabel;

@synthesize m_BtnContentDetail;
@synthesize m_BtnContentViewer;

@synthesize m_LabPages;
@synthesize m_LabVolume;

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

- (void)setImageTitleBounds:(PlayBookContentType)contentType isEidtMode:(BOOL)isEditMode
{
	
	if (contentType == ContentTypeEpub) {
		CGFloat iamgePosX = 21.0f;
		CGFloat boundPoxX = 20.0f;
		if (isEditMode == YES) {
			iamgePosX += __MARGIN_EDIT_MODE_IMAGE_X;
			boundPoxX += __MARGIN_EDIT_MODE_IMAGE_X;
		}
		
		CGRect imageRect = CGRectMake(iamgePosX, 8.0f, 38.0f, 57.0f);	
		CGRect boundRect = CGRectMake(boundPoxX, 8.0f, 40.0f, 59.0f);			
		
		[m_ImageTitle setFrame:imageRect];
		[m_ImageBound setFrame:boundRect];
		[m_ImageBound setImage:RESOURCE_IMAGE(@"list_thumb_box_epub.png")];
	}
	else {
		CGFloat iamgePosX = 12.0f;
		CGFloat boundPoxX = 11.0f;
		if (isEditMode == YES) {
			iamgePosX += __MARGIN_EDIT_MODE_IMAGE_X;
			boundPoxX += __MARGIN_EDIT_MODE_IMAGE_X;
		}
		
		CGRect imageRect = CGRectMake(iamgePosX, 8.0f, 57.0f, 57.0f);	
		CGRect boundRect = CGRectMake(boundPoxX, 8.0f, 59.0f, 59.0f);
		
		[m_ImageTitle setFrame:imageRect];
		[m_ImageBound setFrame:boundRect];
		[m_ImageBound setImage:RESOURCE_IMAGE(@"list_thumb_box_comic.png")];
	}
}

- (void)setBtnPages:(NSInteger)itemIndex pages:(NSString*)pages 
{
	NSLog(@"pages=[%@]", pages);
	
	[m_BtnContentDetail setTag:itemIndex];
	[m_BtnContentViewer setTag:itemIndex];
	
	[m_BtnContentDetail setImage:RESOURCE_IMAGE(@"mybook_readcontent_btn_left_off.png") forState:UIControlStateHighlighted];
	[m_BtnContentDetail setImage:RESOURCE_IMAGE(@"mybook_readcontent_btn_left_on.png") forState:UIControlStateHighlighted];
	
	[m_BtnContentViewer setImage:RESOURCE_IMAGE(@"mybook_readcontent_btn_right_off.png") forState:UIControlStateHighlighted];
	[m_BtnContentViewer setImage:RESOURCE_IMAGE(@"mybook_readcontent_btn_right_on.png") forState:UIControlStateHighlighted];
	
	[m_LabPages setText:pages];	
}

- (void)dealloc {

	[m_ImageSelect release];
	[m_ImageTitle release];
	[m_ImageBound release];
	[m_Writer release];
	[m_Title release]; 
	[m_StatusLabel release];
	
	[m_BtnContentDetail release];
	[m_BtnContentViewer release];	
	
	[m_LabPages release];
	[m_LabVolume release];

	m_Delegate = nil;
	
    [super dealloc];
}

- (void) clickBtnContentDetail:(id)sender
{
	NSInteger index = ((UIButton*) sender).tag;

	[m_Delegate requestMyBookReadContent:sender readType:ContentReadDetail itemIndex:index];	
}

- (void) clickBtnContentViewer:(id)sender
{
	NSInteger index = ((UIButton*) sender).tag;
	
	[m_Delegate requestMyBookReadContent:sender readType:ContentReadViewer itemIndex:index];
}

@end
