//
//  CMFontSelectTableViewController.m
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

#import "CMFontSelectTableViewController.h"

#define kSelectedLabelTag		1001
#define kFontNameLabelTag		1002

@interface CMFontSelectTableViewController()
@property (nonatomic, retain) NSIndexPath *selectedIndex;
@end
@implementation CMFontSelectTableViewController

@synthesize delegate;
@synthesize fontFamilyNames, selectedFont;
@synthesize selectedIndex = _selectedIndex;
@synthesize selectedColor = _selectedColor;

#pragma mark -
#pragma mark FontStyleSelectTableViewControllerDelegate methods

- (void)fontStyleSelectTableViewController:(CMFontStyleSelectTableViewController *)fontStyleSelectTableViewController didSelectFont:(UIFont *)font {
	self.selectedFont = font;

	[delegate fontSelectTableViewController:self didSelectFont:self.selectedFont];
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark View lifecycle
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self prepareData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Choose font:";
    self.navigationController.navigationBarHidden = FALSE;
}
- (void) startActivity {
    
}
- (void) stopActivity {
    
}
- (void) prepareData {

    if ([fontFamilyNames count] < 1) {
        [self startActivity];
        dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(aQueue, ^ {
            self.fontFamilyNames = [[UIFont familyNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopActivity];
                [self.tableView reloadData];
                [self gotoSelection];
            });
        });
        dispatch_release(aQueue);
    } else {
        [self gotoSelection];
    }
}

- (void) gotoSelection {
    if ([fontFamilyNames count] > 0) {
        [self calcSelectedIndex];
        if (_selectedIndex) {
            [self.tableView scrollToRowAtIndexPath:self.selectedIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
}
- (void) calcSelectedIndex {
    [self.fontFamilyNames enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:self.selectedFont.familyName]) {
            self.selectedIndex = [NSIndexPath indexPathForRow:idx inSection:0];
            *stop = TRUE;
        }
    }];
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
    return [self.fontFamilyNames count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *fontFamilyName = [self.fontFamilyNames objectAtIndex:indexPath.row];
//    UIFont *font = [UIFont fontWithName:fontFamilyName size:self.selectedFont.pointSize];
    return floorf(self.selectedFont.lineHeight + 26.);
//    CGFloat height = [fontFamilyName sizeWithFont:font].height;
//    return height + 20.;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FontSelectTableCell";
    
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
	NSString *fontFamilyName = [self.fontFamilyNames objectAtIndex:indexPath.row];
	
	UILabel *fontNameLabel = (UILabel *)[cell viewWithTag:kFontNameLabelTag];
	
	fontNameLabel.text = fontFamilyName;
	fontNameLabel.font = [UIFont fontWithName:fontFamilyName size:self.selectedFont.pointSize];
    if (_selectedColor) {
        fontNameLabel.textColor = self.selectedColor;
    } else {
        fontNameLabel.textColor = [UIColor darkGrayColor];
    }
	
	if ([[UIFont fontNamesForFamilyName:fontFamilyName] count] > 1) {
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	UILabel *selectedLabel = (UILabel *)[cell viewWithTag:kSelectedLabelTag];
    if (_selectedColor) {
        selectedLabel.textColor = self.selectedColor;
    } else {
        selectedLabel.textColor = [UIColor darkGrayColor];
    }

	if ([self.selectedFont.familyName isEqualToString:fontFamilyName]) {
		selectedLabel.text = @"✔";
	}

    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	CMFontStyleSelectTableViewController *fontStyleSelectTableViewController = [[CMFontStyleSelectTableViewController alloc] initWithStyle:UITableViewStylePlain];
    fontStyleSelectTableViewController.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
	fontStyleSelectTableViewController.fontFamilyName = [self.fontFamilyNames objectAtIndex:indexPath.row];
	fontStyleSelectTableViewController.selectedFont = self.selectedFont;
    fontStyleSelectTableViewController.selectedColor = self.selectedColor;
	fontStyleSelectTableViewController.delegate = self;
	[self.navigationController pushViewController:fontStyleSelectTableViewController animated:YES];
	[fontStyleSelectTableViewController release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *fontName = [self.fontFamilyNames objectAtIndex:indexPath.row];
	self.selectedFont = [UIFont fontWithName:fontName size:self.selectedFont.pointSize];
	
	[delegate fontSelectTableViewController:self didSelectFont:self.selectedFont];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    self.selectedColor = nil;
    self.selectedIndex = nil;
    if (fontFamilyNames) {
        [fontFamilyNames release];
    }
    if (selectedFont) {
        [selectedFont release];
    }
    fontFamilyNames = nil;
    selectedFont = nil;
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.delegate = nil;
    [super viewDidUnload];
}


- (void)dealloc {
    self.selectedColor = nil;
    self.selectedIndex = nil;
    if (fontFamilyNames) {
        [fontFamilyNames release];
    }
    if (selectedFont) {
        [selectedFont release];
    }
    fontFamilyNames = nil;
    selectedFont = nil;
    self.delegate = nil;
    [super dealloc];
}


@end

