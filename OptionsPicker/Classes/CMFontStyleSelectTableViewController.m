//
//  CMFontStyleSelectTableViewController.m
//  CMTextStylePicker
//
//  Created by Chris Miles on 20/10/10.
//  Copyright (c) Chris Miles 2010.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CMFontStyleSelectTableViewController.h"

#define kSelectedLabelTag		1001
#define kFontNameLabelTag		1002

@interface CMFontStyleSelectTableViewController()
@property (nonatomic, retain) NSIndexPath *selectedIndex;
@end

@implementation CMFontStyleSelectTableViewController

@synthesize delegate;
@synthesize fontFamilyName;
@synthesize fontNames, selectedFont;
@synthesize selectedIndex = _selectedIndex;
@synthesize selectedColor = _selectedColor;

#pragma mark -
#pragma mark View lifecycle
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView scrollToRowAtIndexPath:self.selectedIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void) calcSelectedIndex {
    [self.fontNames enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:self.selectedFont.familyName]) {
            self.selectedIndex = [NSIndexPath indexPathForRow:idx inSection:0];
            *stop = TRUE;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = FALSE;

	assert(self.fontFamilyName != nil);
	
	self.fontNames = [[UIFont fontNamesForFamilyName:self.fontFamilyName]
					  sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self calcSelectedIndex];
    self.title = [NSString stringWithFormat:@"%@ styles", self.fontFamilyName];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.fontNames count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FontStyleSelectTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		CGRect frame = cell.contentView.bounds;
        frame.origin.x += 10;
        frame.origin.y += 5;
        frame.size.width = 25.;
        frame.size.height -= 10;
		UILabel *selectedLabel = [[UILabel alloc] initWithFrame:frame];
		selectedLabel.tag = kSelectedLabelTag;
		selectedLabel.font = [UIFont systemFontOfSize:self.selectedFont.pointSize];
        selectedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        selectedLabel.contentMode = UIViewContentModeCenter;
		[cell.contentView addSubview:selectedLabel];
		[selectedLabel release];
        
        frame = cell.contentView.bounds;
        frame.origin.x += 35;
        frame.origin.y += 5;
        frame.size.width -= 70;
        frame.size.height -= 10;
        
		UILabel *fontNameLabel = [[UILabel alloc] initWithFrame:frame];
		fontNameLabel.tag = kFontNameLabelTag;
        fontNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:fontNameLabel];
        fontNameLabel.contentMode = UIViewContentModeCenter;
		[fontNameLabel release];
    }
    
    // Configure the cell...
	NSString *fontName = [self.fontNames objectAtIndex:indexPath.row];
	
	UILabel *fontNameLabel = (UILabel *)[cell viewWithTag:kFontNameLabelTag];
	fontNameLabel.text = fontName;
	fontNameLabel.font = [UIFont fontWithName:fontName size:self.selectedFont.pointSize];
    if (_selectedColor) {
        fontNameLabel.textColor = self.selectedColor;
    } else {
        fontNameLabel.textColor = [UIColor darkGrayColor];
    }

    
	UILabel *selectedLabel = (UILabel *)[cell viewWithTag:kSelectedLabelTag];
    if (_selectedColor) {
        selectedLabel.textColor = self.selectedColor;
    } else {
        selectedLabel.textColor = [UIColor darkGrayColor];
    }
	if ([self.selectedFont.fontName isEqualToString:fontName]) {
		selectedLabel.text = @"✔";
	}
	else {
		selectedLabel.text = @"";
	}
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *fontName = [self.fontNames objectAtIndex:indexPath.row];
	self.selectedFont = [UIFont fontWithName:fontName size:self.selectedFont.pointSize];
	
	[delegate fontStyleSelectTableViewController:self didSelectFont:self.selectedFont];
	[tableView reloadData];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    self.selectedIndex = nil;
	[fontFamilyName release];
	[fontNames release];
	[selectedFont release];
	
    [super dealloc];
}


@end

