    //
//  MyBookGallaryIconCell.m
//  PlayBook
//
//  Created by Daniel on 12. 4. 17..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyBookGallaryIconLineCell.h"


@implementation MyBookGallaryIconLineCell

@synthesize m_ItemLayout_1;
@synthesize m_ItemLayout_2;
@synthesize m_ItemLayout_3;

@synthesize m_BtnItem_1;
@synthesize m_Title_1;
@synthesize m_Volume_1;
@synthesize m_ExpireDate_1;
@synthesize m_BtnChecked_1;
@synthesize m_Progress_1;

@synthesize m_BtnItem_2;
@synthesize m_Title_2;
@synthesize m_Volume_2;
@synthesize m_ExpireDate_2;
@synthesize m_BtnChecked_2;
@synthesize m_Progress_2;

@synthesize m_BtnItem_3;
@synthesize m_Title_3;
@synthesize m_Volume_3;
@synthesize m_ExpireDate_3;
@synthesize m_BtnChecked_3;
@synthesize m_Progress_3;

@synthesize m_Delegate;

#define GRID_COLUMN_COUNT			3


#define CARTOON_BUTTON_X			0
#define CARTOON_BUTTON_Y			8
#define CARTOON_BUTTON_WIDTH		95
#define CARTOON_BUTTON_HEIGHT		112

#define CARTOON_IMAGE_MARIN_TOP		1
#define CARTOON_IMAGE_MARIN_BOTTOM  22
#define CARTOON_IMAGE_MARIN_LEFT	1
#define CARTOON_IMAGE_MARIN_RIGHT	5


#define EPUB_BUTTON_X				6	
#define EPUB_BUTTON_Y				0
#define EPUB_BUTTON_WIDTH			85	
#define EPUB_BUTTON_HEIGHT			120


#define EPUB_IMAGE_MARIN_TOP		1
#define EPUB_IMAGE_MARIN_BOTTOM		0
#define EPUB_IMAGE_MARIN_LEFT		1
#define EPUB_IMAGE_MARIN_RIGHT		5


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
    [m_BtnItem_1 release];
	[m_Title_1 release];
	[m_Volume_1 release];
	[m_Progress_1 release];
	
	[m_BtnItem_2 release];
	[m_Title_2 release];
	[m_Volume_2 release];
	[m_Progress_2 release];
	
	[m_BtnItem_3 release];
	[m_Title_3 release];
	[m_Volume_3 release];
	[m_Progress_3 release];
	
	[m_ItemLayout_1 release];
	[m_ItemLayout_2 release];
	[m_ItemLayout_3 release];
	
	m_Delegate = nil;
	
	[super dealloc];
}


- (void) addBookGallaryItem:(GallaryItemPosition)position title:(NSString*)title titleImage:(UIImage*)titleImage volume:(NSString*)volume itemIndex:(NSInteger)index
{
	CGRect btnRect = CGRectMake(CARTOON_BUTTON_X, CARTOON_BUTTON_Y, CARTOON_BUTTON_WIDTH, CARTOON_BUTTON_HEIGHT);
	
	switch(position) {
		case GallaryItemFirst:			
			[m_ItemLayout_1 setHidden:NO];
			[m_ItemLayout_1 setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];
//			[m_BtnChecked_1 setHidden:YES];
			[m_BtnChecked_1 setTag:index];
			
			[m_BtnItem_1 setFrame:btnRect];
			[m_BtnItem_1 setBackgroundImage:RESOURCE_IMAGE(@"my_keep_bg_comic.png") forState:UIControlStateNormal];			
			[m_BtnItem_1 setImageEdgeInsets:UIEdgeInsetsMake(CARTOON_IMAGE_MARIN_TOP, CARTOON_IMAGE_MARIN_LEFT, CARTOON_IMAGE_MARIN_BOTTOM, CARTOON_IMAGE_MARIN_RIGHT)];			
			[m_BtnItem_1 setImage:titleImage forState:UIControlStateNormal];
			[m_BtnItem_1 setTag:index];
			
			[m_Title_1 setText:title];
			[m_Title_1 setHidden:NO];	
			
			if([volume length] == 0) {
				[m_Volume_1 setHidden:YES];
			}
			else {
				[m_Volume_1 setHidden:NO];
				[m_Volume_1 setText:volume];
			}
			[m_Progress_1 setHidden:YES];			
			break;
			
		case GallaryItemSecond:
			[m_ItemLayout_2 setHidden:NO];
			[m_ItemLayout_2 setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];
//			[m_BtnChecked_2 setHidden:YES];
			[m_BtnChecked_2 setTag:index];
			
			[m_BtnItem_2 setFrame:btnRect];
			[m_BtnItem_2 setBackgroundImage:RESOURCE_IMAGE(@"my_keep_bg_comic.png") forState:UIControlStateNormal];						
			[m_BtnItem_2 setImageEdgeInsets:UIEdgeInsetsMake(CARTOON_IMAGE_MARIN_TOP, CARTOON_IMAGE_MARIN_LEFT, CARTOON_IMAGE_MARIN_BOTTOM, CARTOON_IMAGE_MARIN_RIGHT)];			
			[m_BtnItem_2 setImage:titleImage forState:UIControlStateNormal];
			[m_BtnItem_2 setTag:index];
			
			[m_Title_2 setText:title];
			[m_Title_2 setHidden:NO];
			
			if([volume length] == 0) {
				[m_Volume_2 setHidden:YES];
			}
			else {
				[m_Volume_2 setHidden:NO];
				[m_Volume_2 setText:volume];
			}
			[m_Progress_2 setHidden:YES];			
			break;			
			
		case CallaryItemThird:
			[m_ItemLayout_3 setHidden:NO];
			[m_ItemLayout_3 setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];			
//			[m_BtnChecked_3 setHidden:YES];
			[m_BtnChecked_3 setTag:index];			
			
			[m_BtnItem_3 setFrame:btnRect];
			[m_BtnItem_3 setBackgroundImage:RESOURCE_IMAGE(@"my_keep_bg_comic.png") forState:UIControlStateNormal];			
			[m_BtnItem_3 setImageEdgeInsets:UIEdgeInsetsMake(CARTOON_IMAGE_MARIN_TOP, CARTOON_IMAGE_MARIN_LEFT, CARTOON_IMAGE_MARIN_BOTTOM, CARTOON_IMAGE_MARIN_RIGHT)];			
			[m_BtnItem_3 setImage:titleImage forState:UIControlStateNormal];			
			[m_BtnItem_3 setTag:index];
			
			[m_Title_3 setText:title];
			[m_Title_3 setHidden:NO];
			
			if([volume length] == 0) {
				[m_Volume_3 setHidden:YES];
			}
			else {
				[m_Volume_3 setHidden:NO];
				[m_Volume_3 setText:volume];
			}
			[m_Progress_3 setHidden:YES];			
			break;			
	}

}

- (void) addBookGallaryItem:(GallaryItemPosition)position titleImage:(UIImage*)titleImage volume:(NSString*)volume itemIndex:(NSInteger)index
{
	CGRect btnRect = CGRectMake(EPUB_BUTTON_X, EPUB_BUTTON_Y, EPUB_BUTTON_WIDTH, EPUB_BUTTON_HEIGHT);

	switch(position) {
		case GallaryItemFirst:			
			[m_ItemLayout_1 setHidden:NO];
			[m_ItemLayout_1 setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];
//			[m_BtnChecked_1 setHidden:YES];
			[m_BtnChecked_1 setTag:index];
			
			[m_BtnItem_1 setFrame:btnRect];
			[m_BtnItem_1 setBackgroundImage:RESOURCE_IMAGE(@"my_keep_bg_novel.png") forState:UIControlStateNormal];			
			[m_BtnItem_1 setImageEdgeInsets:UIEdgeInsetsMake(EPUB_IMAGE_MARIN_TOP, EPUB_IMAGE_MARIN_LEFT, EPUB_IMAGE_MARIN_BOTTOM, EPUB_IMAGE_MARIN_RIGHT)];			
			[m_BtnItem_1 setImage:titleImage forState:UIControlStateNormal];			
			[m_BtnItem_1 setTag:index];
			
			[m_Title_1 setHidden:YES];	
			
			if([volume length] == 0) {
				[m_Volume_1 setHidden:YES];
			}
			else {
				[m_Volume_1 setHidden:NO];
				[m_Volume_1 setText:volume];
			}
			[m_Progress_1 setHidden:YES];			
			break;
			
		case GallaryItemSecond:
			[m_ItemLayout_2 setHidden:NO];
			[m_ItemLayout_2 setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];			
//			[m_BtnChecked_2 setHidden:YES];
			[m_BtnChecked_2 setTag:index];
			
			[m_BtnItem_2 setFrame:btnRect];
			[m_BtnItem_2 setBackgroundImage:RESOURCE_IMAGE(@"my_keep_bg_novel.png") forState:UIControlStateNormal];			
			[m_BtnItem_2 setImageEdgeInsets:UIEdgeInsetsMake(EPUB_IMAGE_MARIN_TOP, EPUB_IMAGE_MARIN_LEFT, EPUB_IMAGE_MARIN_BOTTOM, EPUB_IMAGE_MARIN_RIGHT)];			
			[m_BtnItem_2 setImage:titleImage forState:UIControlStateNormal];				
			[m_BtnItem_2 setTag:index];
			
			[m_Title_2 setHidden:YES];
			
			if([volume length] == 0) {
				[m_Volume_2 setHidden:YES];
			}
			else {
				[m_Volume_2 setHidden:NO];
				[m_Volume_2 setText:volume];
			}
			[m_Progress_2 setHidden:YES];			
			break;			
			
		case CallaryItemThird:
			[m_ItemLayout_3 setHidden:NO];
			[m_ItemLayout_3 setBackgroundColor:[UIColor colorWithPatternImage:RESOURCE_IMAGE(@"main_background.png")]];			
//			[m_BtnChecked_3 setHidden:YES];
			[m_BtnChecked_3 setTag:index];
			
			[m_BtnItem_3 setFrame:btnRect];
			[m_BtnItem_3 setBackgroundImage:RESOURCE_IMAGE(@"my_keep_bg_novel.png") forState:UIControlStateNormal];			
			[m_BtnItem_3 setImageEdgeInsets:UIEdgeInsetsMake(EPUB_IMAGE_MARIN_TOP, EPUB_IMAGE_MARIN_LEFT, EPUB_IMAGE_MARIN_BOTTOM, EPUB_IMAGE_MARIN_RIGHT)];			
			[m_BtnItem_3 setImage:titleImage forState:UIControlStateNormal];				
			[m_BtnItem_3 setTag:index];
			
			[m_Title_3 setHidden:YES];
			
			if([volume length] == 0) {
				[m_Volume_3 setHidden:YES];
			}
			else {
				[m_Volume_3 setHidden:NO];
				[m_Volume_3 setText:volume];
			}
			[m_Progress_3 setHidden:YES];
			
			break;			
	}
}

- (void) clearBookGallaryItem:(GallaryItemPosition)position
{
	switch(position) {
		case GallaryItemFirst:			
			[m_ItemLayout_1 setHidden:YES];
			[m_Volume_1 setHidden:YES];
			[m_ExpireDate_1 setHidden:YES];
			[m_Progress_1 setHidden:YES];
			break;
		case GallaryItemSecond:
			[m_ItemLayout_2 setHidden:YES];
			[m_Volume_2 setHidden:YES];
			[m_ExpireDate_2 setHidden:YES];			
			[m_Progress_2 setHidden:YES];
			
			break;			
		case CallaryItemThird:
			[m_ItemLayout_3 setHidden:YES];
			[m_Volume_3 setHidden:YES];
			[m_ExpireDate_3 setHidden:YES];			
			[m_Progress_3 setHidden:YES];			
			break;			
	}
}

- (void) setProgressHidden:(GallaryItemPosition)position isHidden:(BOOL)isHidden
{
	switch(position) {
		case GallaryItemFirst:			
			[m_Volume_1 setHidden:(isHidden == YES ? NO : YES)];
			[m_Progress_1 setHidden:isHidden];
			break;
		case GallaryItemSecond:
			[m_Volume_2 setHidden:(isHidden == YES ? NO : YES)];			
			[m_Progress_2 setHidden:isHidden];
			break;			
		case CallaryItemThird:
			[m_Volume_3 setHidden:(isHidden == YES ? NO : YES)];			
			[m_Progress_3 setHidden:isHidden];
			break;			
	}
}

- (void) setProgressPercent:(GallaryItemPosition)position percent:(CGFloat)percent
{
	switch(position) {
		case GallaryItemFirst:			
			[m_Progress_1 setProgress:percent];
			[m_Progress_1 setNeedsDisplay];
			break;
		case GallaryItemSecond:
			[m_Progress_2 setProgress:percent];
			[m_Progress_2 setNeedsDisplay];
			break;			
		case CallaryItemThird:
			[m_Progress_3 setProgress:percent];
			[m_Progress_3 setNeedsDisplay];
			break;			
	}
}

- (void) setCheckGallaryItem:(NSInteger)itemIndex checked:(BOOL)checked
{
	NSInteger position = (itemIndex == 0) ? 0 : (itemIndex % GRID_COLUMN_COUNT);
	
	NSLog(@"position=[%d], check=[%@]", position, (checked == YES) ? @"YES" : @"NO");
	
	switch (position) 
	{
		case GallaryItemFirst:
			if (checked == YES) {
				[m_BtnChecked_1 setFrame:m_BtnItem_1.frame];
				[m_BtnChecked_1 setHidden:NO];				
			}
			else {
				[m_BtnChecked_1 setHidden:YES];
			}
			break;
		case GallaryItemSecond:
			if (checked == YES) {
				[m_BtnChecked_2 setFrame:m_BtnItem_2.frame];				
				[m_BtnChecked_2 setHidden:NO];
			}
			else {
				[m_BtnChecked_2 setHidden:YES];				
			}
			break;
		case CallaryItemThird:
			if (checked == YES) {
				[m_BtnChecked_3 setFrame:m_BtnItem_3.frame];				
				[m_BtnChecked_3 setHidden:NO];
			}
			else {
				[m_BtnChecked_3 setHidden:YES];				
			}
			break;
	}
	
}

- (void) setExpireDate:(GallaryItemPosition)position drmType:(NSString*)drmType expireDate:(NSString*)expireDate counter:(NSString*)counter
{
	UIColor*  fontColor = [UIColor colorWithRed:(136.0f/255.0f) green:(136.0f/255.0f) blue:(136.0f/255.0f) alpha:1.0f];
	NSString* expireString = @"기한없음";
	
	if ([BI_DRM_TYPE_UNLIMITE isEqualToString:drmType] == YES) {
		expireString = @"기한없음";
	}
	else if([BI_DRM_TYPE_PERIOD isEqualToString:drmType] == YES){
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyyMMdd"];
		
		NSDate* lastDate = [dateFormatter dateFromString:getStringValue(expireDate)];
		[dateFormatter release];
		
		NSInteger leftDay = (int)[lastDate timeIntervalSinceNow] / (60*60*24);

		if (leftDay < 0) {
			expireString = @"기한만료";
		}
		else if (leftDay > 0 && leftDay <= 3) {
			expireString = [NSString stringWithFormat:@"%d일 남음", leftDay];
			fontColor = [UIColor redColor];
		}
		else {
			expireString = [NSString stringWithFormat:@"%d일 남음", leftDay];
		}
	}
	else if([BI_DRM_TYPE_COUNTER isEqualToString:drmType] == YES) {
		if ([counter isEqualToString:@"-1"] == YES) {
			expireString = @"무제한";
		}
		else {
			expireString = [NSString stringWithFormat:@"%@회", counter];
		}		
	}

	switch (position) 
	{
		case GallaryItemFirst:
			[m_ExpireDate_1 setTextColor:fontColor];
			[m_ExpireDate_1 setText:expireString];
			break;
		case GallaryItemSecond:
			[m_ExpireDate_2 setTextColor:fontColor];
			[m_ExpireDate_2 setText:expireString];			
			break;
		case CallaryItemThird:
			[m_ExpireDate_3 setTextColor:fontColor];
			[m_ExpireDate_3 setText:expireString];
			break;
	}

}

- (void) clickGallaryItemCell:(id) sender
{
	UIButton* btnItem = (UIButton*) sender;
	
	[m_Delegate selectedGallaryItem:sender lineCell:self itemIndex:btnItem.tag];
}

@end
