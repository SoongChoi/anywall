    //
//  MyBookDownloadCell.m
//  PlayBook
//
//  Created by Daniel on 12. 4. 25..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyBookDownloadCell.h"


@implementation MyBookDownloadCell

@synthesize m_ImageTitle;
@synthesize m_ImageBound;
@synthesize m_Writer;
@synthesize m_Title;
@synthesize m_ExpireDays;
@synthesize m_DownloadCount;	
@synthesize m_DownloadStatus;	


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
	[m_ImageBound release];
	[m_Writer release];
	[m_Title release]; 
	[m_DownloadCount release];
	[m_DownloadStatus release];	
	
	[super dealloc];
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

- (void) setContentWithTitle:(NSString*)title writer:(NSString*)writer downloadCount:(NSInteger)count contentStatus:(ContentStatusType)type
{
	[m_Writer setText:writer];
	[m_Title setText:title];
	[self setContentDownloadCount:count];
	[self setContentStatus:type];
}


- (void) setExpireDateStatus:(BOOL)isExpire drmType:(NSString*)drmType drmValue:(NSString*)drmValue
{
	NSString* expireString = @"-";
	
	if (isExpire == NO) {
		if ([BI_DRM_TYPE_UNLIMITE isEqualToString:drmType] == YES) {
			expireString = @"기한없음";
		}
		else if([BI_DRM_TYPE_PERIOD isEqualToString:drmType] == YES){
			NSArray* expireDayValues = [drmValue componentsSeparatedByString:@"-"];
			if ([expireDayValues count] == 2) {
				NSString* expireDay = [expireDayValues objectAtIndex:1];
				
				expireString = [NSString stringWithFormat:@"다운로드후 %@일간 얼람가능", expireDay];
			}		
		}
		else if([BI_DRM_TYPE_COUNTER isEqualToString:drmType] == YES) {
			if ([drmValue isEqualToString:@"-1"] == YES) {
				expireString = @"무제한";
			}
			else {
				expireString = [NSString stringWithFormat:@"%@회간 얼람가능", drmValue];
			}
		}
		[self setSelectionStyle:UITableViewCellSelectionStyleGray];
	}
	else {
		expireString = @"만료됨";
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
       	[m_Writer setTextColor:[UIColor colorWithRed:145.0f/255.0f green:145.0f/255.0f blue:145.0f/255.0f alpha:1.0]];
        [m_Title setTextColor:[UIColor colorWithRed:145.0f/255.0f green:145.0f/255.0f blue:145.0f/255.0f alpha:1.0]];
	}
	[m_ExpireDays setText:expireString];
}

- (void) setContentStatus:(ContentStatusType)type
{
	if (type == ContentStatusDownload) {
		[m_DownloadStatus setImage:RESOURCE_IMAGE(@"my_download_btn_down.png")];
	}
	else if (type == ContentStatusSaved) {
		[m_DownloadStatus setImage:RESOURCE_IMAGE(@"my_download_btn_view.png")];
	}
	else {
		[m_DownloadStatus setImage:RESOURCE_IMAGE(@"my_download_btn_disable.png")];
	}
}

- (void) setDownloadCount:(NSInteger)count
{
	[m_DownloadCount setText:[NSString stringWithFormat:@"%d", count]];
}

- (void) setContentDownloadCount:(NSInteger)count
{
	if (count >= 5) {
		 [m_DownloadCount setText:@"5"];
		 [m_DownloadCount setTextColor:[UIColor colorWithRed:153.0/255.0f green:153.0/255.0f blue:153.0/255.0f alpha:1.0]];
		 [self setContentStatus:ContentStatusExpire];
	}
	else {
		 [m_DownloadCount setText:[NSString stringWithFormat:@"%d", count]];
		 [m_DownloadCount setTextColor:[UIColor colorWithRed:226.0/255.0f green:65.0/255.0f blue:65.0/255.0f alpha:1.0]];
	}
	
}


@end
