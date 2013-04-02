//
//  BookVolumeGridView.m
//  PlayBook
//
//  Created by Daniel on 12. 4. 9..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BookVolumeGridView.h"

#define _VIEW_MARGIN_TOP	    15
#define _VIEW_MARGIN_LEFT	    15

#define _ITEM_GRID_WIDTH		58
#define _ITEM_GRID_HEIGHT		60
#define _ITEM_MARGIN			1


@implementation BookVolumeGridView

@synthesize m_BoolVolueArray;
@synthesize m_Delegate;


+ (id) createWithDelegate:(NSMutableArray*)volumeArray delegate:(id)delegate
{
	BookVolumeGridView* volumeGridView = [[BookVolumeGridView alloc] initWithDelegate:volumeArray delegate:(id)delegate];
	if (volumeGridView == nil) {
		return nil;
	}
	int line = 0, loopCount = 0;
    
    for (NSDictionary* itemDic in volumeArray) {
        line = loopCount / _COLUMN_COUNT;
        
        //int itemIndex = (line == 0) ? loopCount : (loopCount%_COLUMN_COUNT);
        //NSString* title = [NSString stringWithFormat:@"%@권", [itemDic objectForKey:@"book_no"]];
        
        BOOL isEnable = [[itemDic objectForKey:@"exbuy_yn"] isEqualToString:@"Y"];
        //BOOL isRead   = [[itemDic objectForKey:@"user_no"] length] == 0 ? NO : YES;
        BOOL isFree   = [[itemDic objectForKey:@"free_yn"] isEqualToString:@"Y"];
        BOOL isSample = ([[itemDic objectForKey:@"sample_count"] integerValue] == 0) ? NO : YES;
        
        if (isSample == YES) { isEnable = YES; }
        
        if (isEnable == YES || isFree == YES || isSample == YES){
            loopCount += 1;
        }
    }
    
    int lines = (loopCount / _COLUMN_COUNT) + (loopCount % _COLUMN_COUNT == 0 ? 0 : 1);
	//int lines = ([volumeArray count] / _COLUMN_COUNT) + ([volumeArray count] % _COLUMN_COUNT == 0 ? 0 : 1);
	
	[volumeGridView setFrame:CGRectMake(_VIEW_MARGIN_LEFT, _VIEW_MARGIN_TOP, (_COLUMN_COUNT * _ITEM_GRID_WIDTH) + _ITEM_MARGIN, (lines * _ITEM_GRID_HEIGHT) + _ITEM_MARGIN)];
	[volumeGridView setBackgroundColor:[UIColor colorWithRed:212.0/255.0 green:212.0/255.0 blue:212.0/255.0 alpha:1.0]];
	
	return volumeGridView;
}


- (void) __addSubViewGridItem:(int)loop line:(int)line index:(int)index title:(NSString*)title enable:(BOOL)isEnable read:(BOOL)isRead free:(BOOL)isFree sample:(BOOL)isSample
{
	CGFloat posX =  (index * _ITEM_GRID_WIDTH) + _ITEM_MARGIN;
	CGFloat posY =  (line * _ITEM_GRID_HEIGHT) + _ITEM_MARGIN;
	if (line == 0) {
		posY =  (line * _ITEM_GRID_HEIGHT) + (line * _ITEM_MARGIN) + _ITEM_MARGIN;
	}
	
	//NSLog(@"title=[%@], line=[%d], index=[%d], x=[%d], y=[%d]", title, line, posX, posY);
	//NSLog(@"isEnable=[%d], isRead=[%d], isFree=[%d]", isEnable, isRead, isFree);
	
	UIButton* btnGridItem = [UIButton buttonWithType:UIButtonTypeCustom];
	[btnGridItem setFrame:CGRectMake(posX, posY,_ITEM_GRID_WIDTH, _ITEM_GRID_HEIGHT)];
	[btnGridItem setTitle:title forState:UIControlStateNormal];
	
	if (isEnable == YES) {
		[btnGridItem setTitleColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]  forState:UIControlStateNormal];
	}
	else {
		[btnGridItem setTitleColor:[UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0]  forState:UIControlStateNormal];
	}

	
	if (isRead == YES) {
		if (isEnable == YES) {
			[btnGridItem setBackgroundImage:RESOURCE_IMAGE(@"view_table_on.png") forState:UIControlStateNormal];
		}
		else {
			[btnGridItem setBackgroundImage:RESOURCE_IMAGE(@"view_table_on_g.png") forState:UIControlStateNormal];			
		}		
	}
	else {
		if (isEnable == YES) {
			[btnGridItem setBackgroundImage:RESOURCE_IMAGE(@"view_table_off.png") forState:UIControlStateNormal];
		}
		else {
			[btnGridItem setBackgroundImage:RESOURCE_IMAGE(@"view_table_off_g.png") forState:UIControlStateNormal];
		}
	}
	if (isFree == YES) {
		UIImageView* imageFree = [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"view_icon_free.png")];		
		[imageFree setFrame:CGRectMake(-1, -1, 39, 16)];			
		[btnGridItem addSubview:imageFree];		
	}
	else if (isSample == YES) {
		UIImageView* imageFree = [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"view_icon_sample.png")];		
		[imageFree setFrame:CGRectMake(-1, -1, 39, 16)];			
		[btnGridItem addSubview:imageFree];		
	}


	[btnGridItem addTarget:self action:@selector(clickBtnItem:) forControlEvents:UIControlEventTouchUpInside];
	[btnGridItem setTag:loop];
	
	
	[self addSubview:btnGridItem];

}

- (void) __addSubViewFillEmpty:(int) endItem line:(int) line
{
	int posX = (endItem * _ITEM_GRID_WIDTH) + _ITEM_MARGIN;
	int posY = (line * _ITEM_GRID_HEIGHT) + _ITEM_MARGIN;
	int width = _ITEM_GRID_WIDTH * (_COLUMN_COUNT - endItem) + (_ITEM_MARGIN * 2);
	int height = _ITEM_GRID_HEIGHT + _ITEM_MARGIN; 
	
	if (line == 0) {
		posY -= 2;
		height += 2;
	}
	
	UIView* emptyView = [[UIView alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
	[emptyView setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]];
	
	[self addSubview:emptyView];
}

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define X_SHIFT  5

- (id) initWithDelegate:(NSMutableArray*)volumeArray delegate:(id)delegate
{
	if ((self = [super init]) != nil) {
		
		NSLog(@"initWithDelegate... volumeArray count=[%d]", [volumeArray count]);
		
		m_BoolVolueArray = volumeArray;
		m_Delegate = delegate;
		
		int line = 0, loopCount = 0;
		
		for (NSDictionary* itemDic in m_BoolVolueArray) {
			line = loopCount / _COLUMN_COUNT;
			
			int itemIndex = (line == 0) ? loopCount : (loopCount%_COLUMN_COUNT);
			NSString* title = [NSString stringWithFormat:@"%@권", [itemDic objectForKey:@"book_no"]];
			
			BOOL isEnable = [[itemDic objectForKey:@"exbuy_yn"] isEqualToString:@"Y"];
			BOOL isRead   = [[itemDic objectForKey:@"user_no"] length] == 0 ? NO : YES;
			BOOL isFree   = [[itemDic objectForKey:@"free_yn"] isEqualToString:@"Y"];
			BOOL isSample = ([[itemDic objectForKey:@"sample_count"] integerValue] == 0) ? NO : YES;
			
			if (isSample == YES) { isEnable = YES; }
			
            if (isEnable == YES || isFree == YES || isSample == YES){
                [self __addSubViewGridItem:loopCount line:line index:itemIndex title:title enable:isEnable read:isRead free:isFree sample:isSample];
                loopCount += 1;
            }
		}
		
        //int endItem = [volumeArray count] % _COLUMN_COUNT;
        int endItem = loopCount % _COLUMN_COUNT;
        if (endItem > 0 || loopCount == 0) {
			NSLog(@"initWithDelegate... endItem=[%d]", endItem);
			
			[self __addSubViewFillEmpty:endItem line:line];
		}
        
        if (loopCount == 0)
        {
            NSString *str = @"열람 가능한 작품이 없습니다.";
            UIFont *fnt = [UIFont systemFontOfSize:18];
            CGSize lblSize = [str sizeWithFont:fnt];
            
            {
//                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(44, 53, 250, 30)];
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake((320/2)-(lblSize.width/2)-10, 53, lblSize.width, 30)];
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:18];
                label.textColor = RGB(253,253,253);
                label.text = @"열람 가능한 작품이 없습니다.";
                [self addSubview:label];
                [label release];
            }
            {
                //UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(42, 51, 250, 30)];
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake((320/2)-(lblSize.width/2)-2-10, 53 - 2, lblSize.width, 30)];
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:18];
                label.textColor = RGB(170,170,170);
                label.text = @"열람 가능한 작품이 없습니다.";
                [self addSubview:label];
                [label release];
            }
        }
	}
	return self;
}



- (id) initWithFrame:(CGRect)frame 
{
	if (self = [super initWithFrame:frame]) {
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
	[m_BoolVolueArray release];
}

- (IBAction) clickBtnItem:(id)sender
{
	int itemTag = ((UIButton*)sender).tag;
	NSLog(@"tag=[%d]", itemTag);
	
	[m_Delegate selectVolumeItem:sender itemIndex:itemTag];
}

@end
