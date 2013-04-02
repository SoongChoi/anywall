//
//  PopupMenuController.m
//  PlayBook
//
//  Created by 전명곤 on 11. 11. 10..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/CAAnimation.h>

#import "PopupMenuController.h"
#import "PopupMenuForm.h"
#import "PopupMenuCell.h"
#import "UITableViewCell+CustomDraw.h"

@implementation PopupMenuController

@synthesize m_TableView;
@synthesize m_List;
@synthesize	m_ItemFont;
@synthesize m_Delegate;

+ (id) createWithOrientation:(UIDeviceOrientation)orientation
 {
	 PopupMenuController *	popupMenuController = (PopupMenuController *)[[PopupMenuController alloc] initWithNibName:@"PopupMenuController" bundle:[NSBundle mainBundle]];
	 if (popupMenuController == nil)
	 {
		 return nil;
	 }
	 [popupMenuController setOrientation:orientation];
	 
	 popupMenuController.m_List = [[NSMutableArray alloc] initWithCapacity:0];
	 
	 return popupMenuController;
 }
 
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (void) setOrientation:(UIDeviceOrientation)orientation 
{
	m_Orientation = orientation;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

	UIDeviceOrientation orientation	= m_Orientation;
	CGRect	rect;
	
	if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
	{
		rect = CGRectMake(0.0f, 
						  31.0f + 20.0f, 
						  193.0f, 
						  320.0f - (31.0f + (36.0f * 2) +20.0f));		
	}
	else 
	{
		rect = CGRectMake(0.0f, 
						  45.0f + 20.0f, 
						  193.0f, 
						  480 - (45.0f + (45.0f * 2) +20.0f));

	}	
	[self.view setFrame:rect];
	[m_TableView setFrame:CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height)];
	
	m_TableView.backgroundView = [[[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"list_content_bg.png")] autorelease];  
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
//	[m_TableView release];
	[m_List release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [m_List count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PopupMenuCell";
    
	
    PopupMenuCell *cell = (PopupMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	/* 
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    */
	
    // Configure the cell...
	if (cell == nil)
	{
		NSArray	*CellObject = [[NSBundle mainBundle] loadNibNamed:@"PopupMenuCell" owner:nil options:nil];
		for (id currentObject in CellObject)
		{
			if ([currentObject isKindOfClass:[PopupMenuCell class]])
			{
				cell = (PopupMenuCell *)currentObject;
				break;
			}
		}
	}

	cell.backgroundView = [[[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_list_content_bg_off.png")] autorelease];  
    cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:RESOURCE_IMAGE(@"vi_list_content_bg_on.png")] autorelease];

	cell.m_Text.text = [m_List objectAtIndex:indexPath.row];
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Navigation logic may go here. Create and push another view controller.
    /*
	 * <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
	 // ...
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	
	TRACE(@"Selected Index = %d", indexPath.row);
	
	[m_Delegate pmSelectedMenuItem:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40.0f;
}



- (void) setPositionWithFrame:(CGRect)rect
{
	[self.view setFrame:rect];
}

- (void) setDelegate:(id)delegate
{
	m_Delegate = delegate;	
}

- (void) addItems:(NSArray *)items
{
	if (m_List == nil)
	{
		m_List = [[NSMutableArray alloc] initWithCapacity:0];
	}

	for (NSString *item in items)
	{
		[m_List addObject:item];
	}

}


- (void) addItem:(NSString *)itemText
{
	if (m_List == nil)
	{
		m_List = [[NSMutableArray alloc] initWithCapacity:0];
	}
	
	[m_List addObject:itemText];
}

- (void) removeAllItems
{
	[m_List removeAllObjects];
}


@end
