    //
//  MyBookDownloadCell.m
//  PlayBook
//
//  Created by Daniel on 12. 4. 25..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "MyBookStreamCell.h"


#define _BUTTON_TEXT_MARIN_TOP		14
#define _BUTTON_TEXT_MARIN_LEFT		5
#define _BUTTON_TEXT_MARIN_BOTTOM	14
#define _BUTTON_TEXT_MARIN_RIGHT    10


#define _PAGE_LABEL_WIDTH_DEFAULT	34.0f
#define _PAGE_LABEL_WIDTH_EXTENDS	54.0f

@implementation MyBookStreamCell

@synthesize m_ImageTitle;
@synthesize m_ImageBound;
@synthesize m_Writer;
@synthesize m_Title;
@synthesize m_StatusLablel;
@synthesize m_PageLablel;
@synthesize m_ImageNextInd;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		// Initialize...
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

- (void)setPageWithStatus:(PlayBookContentType)contentType pages:(NSString*)pages status:(NSString*)status
{	
	[m_StatusLablel setText:[NSString stringWithFormat:@"만료일 %@", status]];	 

	CGRect pageRect = m_PageLablel.frame;	
	pageRect.size.width = _PAGE_LABEL_WIDTH_DEFAULT;		
	[m_PageLablel setFrame:pageRect];
	
	[m_ImageNextInd setHidden:NO];	
	
	if (contentType == ContentTypeCartoon) {
		[m_PageLablel setText:[NSString stringWithFormat:@"P%@", pages]];
	}
	else {
		[m_PageLablel setText:@""];
	}

	[m_Writer setTextColor:[UIColor colorWithRed:122.0f/255.0f green:94.0f/255.0f blue:82.0f/255.0f alpha:1.0]];	
	[m_Title setTextColor:[UIColor colorWithRed:51.0f/255.0f green:50.0f/255.0f blue:51.0f/255.0f alpha:1.0]];

	[self setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	NSLog(@"pages=[%@]", pages);	
}

- (void)setContentExpire:(NSString*)status
{
	[m_StatusLablel setText:[NSString stringWithFormat:@"만료일 %@", status]];	 
	
	CGRect pageRect = m_PageLablel.frame;	
	if (_PAGE_LABEL_WIDTH_EXTENDS > pageRect.size.width) {
		pageRect.size.width = _PAGE_LABEL_WIDTH_EXTENDS;
		
		[m_PageLablel setFrame:pageRect];
	}	
	[m_ImageNextInd setHidden:YES];
	[m_PageLablel setText:@"기간만료"];

	
	[m_Writer setTextColor:[UIColor colorWithRed:145.0f/255.0f green:145.0f/255.0f blue:145.0f/255.0f alpha:1.0]];	
	[m_Title setTextColor:[UIColor colorWithRed:145.0f/255.0f green:145.0f/255.0f blue:145.0f/255.0f alpha:1.0]];

	[self setSelectionStyle:UITableViewCellSelectionStyleNone];
	
}

- (void)dealloc {
	[m_ImageTitle release];
	[m_ImageBound release];
	[m_Writer release];
	[m_Title release];
	[m_StatusLablel release];
	[m_PageLablel release];
	[m_ImageNextInd release];
	
    [super dealloc];
}

@end
