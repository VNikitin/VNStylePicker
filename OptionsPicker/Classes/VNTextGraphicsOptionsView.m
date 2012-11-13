//
//  VNTextGraphicsOptions.m
//  CMTextStylePickerDemo
//
//  Created by submarine on 11/11/12.
//
//

#import "VNTextGraphicsOptionsView.h"
#import "CMUpDownControl.h"
#import "VNLineExampleImage.h"
#import "HRColorPickerView.h"
#import "GzColors.h"
#import "CMFontSelectTableViewController.h"
#import "CMFontStyleSelectTableViewController.h"

@interface VNTextGraphicsOptionsView () {
    //save color index path
    //to prevent update cell while dragg color brightness cursor
    __strong NSIndexPath *_colorIndexPath;
}
@property (nonatomic, retain) NSArray *sectionNames;
@property (nonatomic, retain, readwrite) UIFont *font;
@property (nonatomic, assign, readwrite) CGFloat sizeStepper;
@property (nonatomic, assign, readwrite) CGFloat sizeWidth;
@property (nonatomic, retain, readwrite) UIColor *color;
@end

@implementation VNTextGraphicsOptionsView
@dynamic font;
@synthesize sizeStepper = _sizeStepper;
@synthesize sizeWidth = _sizeWidth;
@synthesize color = _color;
@synthesize style = _style;
@synthesize sectionNames = _sectionNames;
@synthesize sections = _sections;

#pragma mark - Init
- (id)initWithStyle:(VNOptionsPickerStyle)style andToolImage:(NSString*)aToolImage {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _style = style;
        _toolImage = aToolImage;
        _selectedLineWidthButton = nil;
        [self configure];
    }
    return self;
}
- (void) configure {
    NSMutableArray *secNames = [NSMutableArray array];
    NSMutableArray *sections = [NSMutableArray array];
    if ((_style & VNOptionsPickerStyleFontExample) == VNOptionsPickerStyleFontExample) {
        [secNames addObject:kSectionFontExample];
        [sections addObject:[NSNumber numberWithInteger:VNOptionsPickerStyleFontExample]];
    }

    //font
    if ((_style & VNOptionsPickerStyleFontName) == VNOptionsPickerStyleFontName && (_style & VNOptionsPickerStyleFontSize) == VNOptionsPickerStyleFontSize) {
        [secNames addObject:kSectionFontName];
        [sections addObject:[NSNumber numberWithInteger:(VNOptionsPickerStyleFontName|VNOptionsPickerStyleFontSize)]];
    } else {
        if ((_style & VNOptionsPickerStyleFontName) == VNOptionsPickerStyleFontName) {
            [secNames addObject:kSectionFontName];
            [sections addObject:[NSNumber numberWithInteger:VNOptionsPickerStyleFontName]];
        }
        if ((_style & VNOptionsPickerStyleFontSize) == VNOptionsPickerStyleFontSize) {
            [secNames addObject:kSectionFontSize];
            [sections addObject:[NSNumber numberWithInteger:VNOptionsPickerStyleFontSize]];
        }
    }
    
    if ((_style & VNOptionsPickerStyleLineWidthByExamples) == VNOptionsPickerStyleLineWidthByExamples) {
        [secNames addObject:kSectionLineWidthByExample];
        [sections addObject:[NSNumber numberWithInteger:VNOptionsPickerStyleLineWidthByExamples]];
    }
    
    if ((_style & VNOptionsPickerStyleLineSectionExpanded) == VNOptionsPickerStyleLineSectionExpanded ) {
        [secNames addObject:kSectionLineExample];
        [sections addObject:[NSNumber numberWithInteger:VNOptionsPickerStyleLineExample]];
        [secNames addObject:kSectionLineWidthStepper];
        [sections addObject:[NSNumber numberWithInteger:VNOptionsPickerStyleLineWidthStepper]];
    } else {
    
        if ((_style & VNOptionsPickerStyleLineWidthStepper) == VNOptionsPickerStyleLineWidthStepper) {
            [secNames addObject:kSectionLineWidthStepper];
            [sections addObject:[NSNumber numberWithInteger:VNOptionsPickerStyleLineWidthStepper]];
        }
        
        if ((_style & VNOptionsPickerStyleLineExample) == VNOptionsPickerStyleLineExample) {
            [secNames addObject:kSectionLineExample];
            [sections addObject:[NSNumber numberWithInteger:VNOptionsPickerStyleLineExample]];
        }
    }
    
    if ((_style & VNOptionsPickerStyleColorExample) == VNOptionsPickerStyleColorExample) {
        [secNames addObject:kSectionColor];
        [sections addObject:[NSNumber numberWithInteger:(VNOptionsPickerStyleColorExample| VNOptionsPickerStyleColor)]];
    } else if ((_style & VNOptionsPickerStyleColor) == VNOptionsPickerStyleColor) {
        [secNames addObject:kSectionColor];
        [sections addObject:[NSNumber numberWithInteger:VNOptionsPickerStyleColor]];
    }


        
    self.sectionNames = secNames;
    self.sections = sections;
    [self restoreState];
    [self updateContentSizeForPopover];
}

#pragma mark - State
#define kVNOptionsPickerStyleFontName @"kVNOptionsPickerStyleFontName"
#define kVNOptionsPickerStyleFontSize @"kVNOptionsPickerStyleFontSize"
#define kVNOptionsPickerStyleLineWidth @"kVNOptionsPickerStyleLineWidth"
#define kVNOptionsPickerStyleColorHex @"kVNOptionsPickerStyleColorHex"

- (void) restoreState {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *fontName = nil;
    CGFloat fontSize = 0.;
    CGFloat lineWidth = 0.;
    NSString *colorHex = nil;
    
    if (! (fontName = [def objectForKey:kVNOptionsPickerStyleFontName])) {
        fontName = @"HelveticaNeue";
    }
    
    if (! (fontSize = [def floatForKey:kVNOptionsPickerStyleFontSize])) {
        fontSize = 17.f;
    }
    
    if (! (lineWidth = [def floatForKey:kVNOptionsPickerStyleLineWidth])) {
        lineWidth = 3.f;
    }
    
    if (! (colorHex = [def objectForKey:kVNOptionsPickerStyleColorHex])) {
        colorHex = RoyalBlue;
    }
    
    UIFont *nFont = [UIFont fontWithName:fontName size:fontSize];
    self.font = nFont;
    self.sizeStepper = fontSize;
    self.sizeWidth = lineWidth;
    self.color = [GzColors colorFromHex:colorHex];
}
- (void) saveState {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if (self.color) {
        [def setObject:[GzColors hexFromColor:self.color] forKey:kVNOptionsPickerStyleColorHex];
    }
    if (self.font) {
        [def setObject:self.font.fontName forKey:kVNOptionsPickerStyleFontName];
        [def setFloat:self.font.pointSize forKey:kVNOptionsPickerStyleFontSize];
    }
    if (self.sizeWidth > 0) {
        [def setFloat:self.sizeWidth forKey:kVNOptionsPickerStyleLineWidth];
    }
    [def synchronize];
}

#pragma mark - Accessors
- (CGFloat) sizeWidth {
    if (_sizeWidth < 1) {
        return 2.;
    }
    return _sizeWidth;
}
- (void) setStyle:(VNOptionsPickerStyle)style {
    if (_style != style) {
        _style = style;
        [self configure];
    }
}
- (void) setContentSizeForViewInPopover:(CGSize)contentSizeForViewInPopover {
    if (!CGSizeEqualToSize(contentSizeForViewInPopover, [super contentSizeForViewInPopover])) {
        [super setContentSizeForViewInPopover:contentSizeForViewInPopover];
        [self.view setNeedsLayout];
    }
}
- (void) setFont:(UIFont *)font {
    if (font) {
        _fontName = font.fontName;
        _sizeStepper = font.pointSize;
    } else {
        _fontName = nil;
    }
    [self.tableView reloadData];
}
- (UIFont*) font {
    if (_fontName) {
        return [UIFont fontWithName:_fontName size:self.sizeStepper];
    }
    return nil;
}
#pragma mark - ViewLifeCycle
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = TRUE;
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLayoutSubviews {

}
- (void) updateContentSizeForPopover {
    [super setContentSizeForViewInPopover:CGSizeMake(300, 600)];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sectionNames count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < [self.sectionNames count]) {
        return [self.sectionNames objectAtIndex:section];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [self.sections count]) {
        VNOptionsPickerStyle style = [[self.sections objectAtIndex:indexPath.section] integerValue];
        UITableViewCell *cell = [self cellForType:style];
        if ((style & VNOptionsPickerStyleColor) == VNOptionsPickerStyleColor ) {
            _colorIndexPath = indexPath;
        }
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat size = 44.f;
    if (indexPath.section < [self.sections count]) {
        VNOptionsPickerStyle style = [[self.sections objectAtIndex:indexPath.section] integerValue];
        size = [self sizeForElement:style];
    }
    return size;
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < [self.sections count]) {
        VNOptionsPickerStyle style = [[self.sections objectAtIndex:indexPath.section] integerValue];
        switch (style) {
            case VNOptionsPickerStyleFontCellUnion:
            case VNOptionsPickerStyleFontName:
            case VNOptionsPickerStyleFontSection: {
                @autoreleasepool {
                    CMFontSelectTableViewController *fontSelectTableViewController = [[CMFontSelectTableViewController alloc] initWithStyle:UITableViewStylePlain];
                    fontSelectTableViewController.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
                    fontSelectTableViewController.delegate = self;
                    fontSelectTableViewController.selectedFont = self.font;
                    fontSelectTableViewController.selectedColor = self.color;
                    [self.navigationController pushViewController:fontSelectTableViewController animated:YES];
                }
            }
                break;
            default:
                break;
        }
    }
}
- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return FALSE;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - Cell
- (UITableViewCell*) cellForType:(VNOptionsPickerStyle)type {
    switch (type) {
        case VNOptionsPickerStyleFontExample:
            return [self cellFontExample];
            break;
        case VNOptionsPickerStyleFontCellUnion:
            return [self cellFontNameAndSize];
            break;
        case VNOptionsPickerStyleFontName:
            return [self cellFontName];
            break;
        case VNOptionsPickerStyleFontSize:
            return [self cellFontSize];
            break;
        case VNOptionsPickerStyleLineWidthByExamples:
            return [self cellLineWidthByExamples];
            break;
        case VNOptionsPickerStyleLineExample:
            return [self cellLineExample];
            break;
        case VNOptionsPickerStyleLineWidthStepper:
            return [self cellLineWidth];
            break;
        case VNOptionsPickerStyleColorExample:
            return [self cellColorPickerWithExample:TRUE];
            break;
        case VNOptionsPickerStyleColor:
            return [self cellColorPickerWithExample:FALSE];
            break;
        case VNOptionsPickerStyleColorSection:
            return [self cellColorPickerWithExample:TRUE];
            break;
        default:
            break;
    }
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
;
}
- (UITableViewCell*)cellFontExample {
    static NSString *identifier = @"fontExample";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %.0f pt", self.font.fontName, self.font.pointSize];
    cell.textLabel.textColor = self.color;
    cell.textLabel.font = self.font;
    return cell;
}
- (UITableViewCell*)cellFontNameAndSize {
    static NSString *identifier = @"FontNameAndSize";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        CGSize cellSize = CGSizeMake(cell.contentView.bounds.size.width, [self sizeForElement:VNOptionsPickerStyleFontSize]);
        CMUpDownControl *stepper = [[CMUpDownControl alloc] initWithFrame:CGRectMake(4, 4, floorf(cellSize.width / 3), cellSize.height - 8)];
        stepper.unit = @"pt";
        stepper.value = self.sizeStepper;
        [stepper addTarget:self action:@selector(stepperClicked:) forControlEvents:UIControlEventValueChanged];
        [stepper sizeToFit];
        stepper.backgroundColor = [UIColor clearColor];
        //    stepper.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:stepper];

        UILabel *newLabel = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
        [cell.contentView addSubview: newLabel];
        newLabel.text = [NSString stringWithFormat:@"%@", self.font.fontName];
        newLabel.font = self.font;
        newLabel.textColor = self.color;
        newLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        newLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        //    newLabel.textAlignment = UITextAlignmentLeft;
        newLabel.backgroundColor = [UIColor clearColor];
        
        CGRect labelFrame = newLabel.frame;
        labelFrame.origin.x = CGRectGetMaxX(stepper.frame) + 4;
        labelFrame.size.width = cellSize.width - labelFrame.origin.x - 4;
        newLabel.frame = labelFrame;
        newLabel.textAlignment = UITextAlignmentCenter;
        
    }
    
    CMUpDownControl *stepper = [[[cell.contentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView *evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[CMUpDownControl class]]) {
            return TRUE;
        }
        return FALSE;
    }]] lastObject];
    
    if (stepper) {
        stepper.unit = @"pt";
        stepper.value = self.sizeStepper;
        [stepper setNeedsDisplay];        
    }

    UILabel *newLabel = [[[cell.contentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView *evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[UILabel class]]) {
            return TRUE;
        }
        return FALSE;
    }]] lastObject];
    if (newLabel) {
        newLabel.text = [NSString stringWithFormat:@"%@", self.font.fontName];
        newLabel.font = self.font;
        newLabel.textColor = self.color;
    }
    return cell;
}
- (UITableViewCell*)cellFontName {
    static NSString *identifier = @"FontName";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Font: %@", self.font.fontName];
    cell.textLabel.font = self.font;
    cell.textLabel.textColor = self.color;

    return cell;
}
- (UITableViewCell*)cellFontSize {
    static NSString *identifier = @"FontSize";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        CGSize cellSize = CGSizeMake(cell.contentView.bounds.size.width, [self sizeForElement:VNOptionsPickerStyleFontSize]);
        CMUpDownControl *stepper = [[CMUpDownControl alloc] initWithFrame:CGRectMake(cellSize.width - floorf(cellSize.width / 3), 4, floorf(cellSize.width / 3), cellSize.height - 8)];
        stepper.unit = @"pt";
        stepper.value = self.sizeStepper;
        [stepper addTarget:self action:@selector(stepperClicked:) forControlEvents:UIControlEventValueChanged];
        [stepper sizeToFit];
        stepper.backgroundColor = [UIColor clearColor];
        //    stepper.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:stepper];
        
        cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    CMUpDownControl *stepper = [[[cell.contentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView *evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[CMUpDownControl class]]) {
            return TRUE;
        }
        return FALSE;
    }]] lastObject];
    
    if (stepper) {
        stepper.unit = @"pt";
        stepper.value = self.sizeStepper;
        [stepper setNeedsDisplay];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"Font size:"];
    cell.textLabel.font = self.font;
    cell.textLabel.textColor = self.color;
    return cell;
}
- (UITableViewCell*)cellLineWidthByExamples {
    static NSString *identifier = @"widthByExample";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        NSInteger count = [kVNOptionsPickerDefaultWidths count];
        
        cell.autoresizesSubviews = TRUE;
        if (count > 0) {
            CGSize elementSize = CGSizeMake(floorf((cell.contentView.bounds.size.width- kVNOptionsCellItemPadding * (count + 1)) / count ), [self sizeForElement:VNOptionsPickerStyleLineWidthByExamples] - 2*kVNOptionsCellItemPadding);
            
            for (NSInteger index=0; index < count; index++) {
                    UIButton *exButton = [[UIButton alloc] init];
                    CGRect buttonFrame = CGRectZero;
                    buttonFrame.origin.x = kVNOptionsCellItemPadding + (kVNOptionsCellItemPadding + elementSize.width) * index;
                    buttonFrame.origin.y = kVNOptionsCellItemPadding;
                    buttonFrame.size.width = elementSize.width;
                    buttonFrame.size.height = elementSize.height;
                    [exButton addTarget:self action:@selector(buttonLineWidthClicked:) forControlEvents:UIControlEventTouchUpInside];
                    exButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
                    exButton.tag = index;
                    exButton.frame = buttonFrame;
                    [cell.contentView addSubview:exButton];
            }
            cell.textLabel.text = @"";
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"No width examples"];
            cell.textLabel.textColor = self.color;
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSArray *buttons = [[cell.contentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIButton *evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[UIButton class]]) {
            return TRUE;
        }
        return FALSE;
    }]];
    
    NSInteger count = [buttons count];

    for (NSInteger index = 0; index <  count; index ++) {
        UIButton *exButton = [buttons objectAtIndex:index];
        if (exButton.tag >=0 && exButton.tag < [kVNOptionsPickerDefaultWidths count]) {
            CGSize elementSize = CGSizeMake(floorf((cell.contentView.bounds.size.width- kVNOptionsCellItemPadding * (count + 1)) / count ), [self sizeForElement:VNOptionsPickerStyleLineWidthByExamples] - 2*kVNOptionsCellItemPadding);
            
            UIImage *example = [VNLineExampleImage solidLineWithWidth:[[kVNOptionsPickerDefaultWidths objectAtIndex:index] floatValue] withImageSize:elementSize withColor:self.color toolImage:_toolImage];
            if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending) {
                example = [example resizableImageWithCapInsets:UIEdgeInsetsMake(0, floorf(elementSize.width/3), 0, elementSize.width - floorf(elementSize.width/3)-1)];
            } else {
                example = [example stretchableImageWithLeftCapWidth:floorf(elementSize.width/3)-1 topCapHeight:0];
            }
            if (example) {
                [exButton setImage:example forState:UIControlStateNormal];
            }
            
            
            CGFloat width = [[kVNOptionsPickerDefaultWidths objectAtIndex:exButton.tag] floatValue] / self.sizeWidth;
            if (width > 0.99 && width < 1.01 ) {
                [self selectButton:exButton];
            } else {
                [self deselectButton:exButton];
            }
        }
    }
    return cell;
}
- (UITableViewCell*)cellLineWidth {
    static NSString *identifier = @"lineWidth";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        CGSize cellSize = CGSizeMake(cell.contentView.bounds.size.width, [self sizeForElement:VNOptionsPickerStyleFontSize]);
        CMUpDownControl *stepper = [[CMUpDownControl alloc] initWithFrame:CGRectMake(cellSize.width - floorf(cellSize.width / 3), 4, floorf(cellSize.width / 3), cellSize.height - 8)];
        stepper.unit = @"px";
        stepper.value = self.sizeWidth;
        stepper.maximumAllowedValue = 10.f;
        stepper.minimumAllowedValue = 1.f;
        [stepper addTarget:self action:@selector(stepperLineWidthClicked:) forControlEvents:UIControlEventValueChanged];
        [stepper sizeToFit];
        stepper.backgroundColor = [UIColor clearColor];
        //    stepper.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:stepper];

        cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    CMUpDownControl *stepper = [[[cell.contentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView *evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[CMUpDownControl class]]) {
            return TRUE;
        }
        return FALSE;
    }]] lastObject];
    
    if (stepper) {
        stepper.unit = @"px";
        stepper.value = self.sizeWidth;
        [stepper setNeedsDisplay];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Width:"];
    cell.textLabel.font = self.font;
    cell.textLabel.textColor = self.color;
    return cell;
}
- (UITableViewCell*)cellLineExample {
    static NSString *identifier = @"lineWidthExample";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.autoresizesSubviews = TRUE;
        CGSize elementSize = CGSizeMake(floorf((cell.contentView.bounds.size.width- kVNOptionsCellItemPadding * 2)), [self sizeForElement:VNOptionsPickerStyleLineExample] - 2*kVNOptionsCellItemPadding);
        
        UIImage *example = [VNLineExampleImage solidLineWithWidth:self.sizeWidth withImageSize:elementSize withColor:self.color toolImage:_toolImage];
        if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending) {
            example = [example resizableImageWithCapInsets:UIEdgeInsetsMake(0, floorf(elementSize.width/3), 0, elementSize.width - floorf(elementSize.width/3)-1)];
        } else {
            example = [example stretchableImageWithLeftCapWidth:floorf(elementSize.width/3)-1 topCapHeight:0];
        }
        
        if (example) {
            UIButton *exButton = [[UIButton alloc] init];
            CGRect buttonFrame = CGRectZero;
            buttonFrame.origin.x = kVNOptionsCellItemPadding;
            buttonFrame.origin.y = kVNOptionsCellItemPadding;
            buttonFrame.size.width = elementSize.width;
            buttonFrame.size.height = elementSize.height;
            [exButton setImage:example forState:UIControlStateNormal];
            //                [exButton addTarget:self action:@selector(buttonLineWidthClicked:) forControlEvents:UIControlEventTouchUpInside];
            exButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
            exButton.tag = 100;
            exButton.frame = buttonFrame;
            [cell.contentView addSubview:exButton];
            cell.textLabel.text = @"";
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"No width examples"];
            cell.textLabel.textColor = self.color;
        }
    }
    
    UIButton *exButton = [[[cell.contentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView* evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[UIButton class]]) {
            return TRUE;
        }
        return FALSE;
    }]] lastObject];
    
    if (exButton) {
        CGSize elementSize = CGSizeMake(floorf((cell.contentView.bounds.size.width- kVNOptionsCellItemPadding * 2)), [self sizeForElement:VNOptionsPickerStyleLineExample] - 2*kVNOptionsCellItemPadding);

        UIImage *example = [VNLineExampleImage solidLineWithWidth:self.sizeWidth withImageSize:elementSize withColor:self.color toolImage:_toolImage];
        if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending) {
            example = [example resizableImageWithCapInsets:UIEdgeInsetsMake(0, floorf(elementSize.width/3), 0, elementSize.width - floorf(elementSize.width/3)-1)];
        } else {
            example = [example stretchableImageWithLeftCapWidth:floorf(elementSize.width/3)-1 topCapHeight:0];
        }
        [exButton setImage:example forState:UIControlStateNormal];
    }
    
    return cell;
}
- (UITableViewCell*)cellColorPickerWithExample:(BOOL)exampleFlag {
    static NSString *identifier = @"colorExample";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.autoresizesSubviews = TRUE;
        
        HRRGBColor rgbColor;
        RGBColorFromUIColor(_color, &rgbColor);
        
        CGSize size;
        HRColorPickerStyle style;
        if (!exampleFlag) {
            size = CGSizeMake(cell.bounds.size.width, kVNOptionsCellSizeColorPicker);
            style = [HRColorPickerView styleWithSize:size];
            style.headerHeight = 0.f;
        } else {
            size = CGSizeMake(cell.bounds.size.width, kVNOptionsCellSizeColorPicker + kVNOptionsCellSizeColorExample);
            style = [HRColorPickerView styleWithSize:size];
        }
        
        HRColorPickerView *colorPickerView = [[HRColorPickerView alloc] initWithStyle:style defaultColor:rgbColor frame:cell.contentView.frame];
        
        [cell.contentView addSubview:colorPickerView];
        cell.contentMode = UIViewContentModeCenter;
        
        colorPickerView.delegate = self;
        cell.textLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
#pragma mark - Actions
- (void) buttonLineWidthClicked:(id) sender {
    if (!sender || ![sender isKindOfClass:[UIButton class]]) {
        return;
    }
    [self selectButton:(UIButton*)sender];
    if ([(UIButton*)sender tag] >=0 && [(UIButton*)sender tag] < [kVNOptionsPickerDefaultWidths count] ) {
        self.sizeWidth = [[kVNOptionsPickerDefaultWidths objectAtIndex:[(UIButton*)sender tag]] floatValue];
        [self.tableView reloadData];
    }
}
- (void) stepperClicked:(id) sender {
    if ([sender isKindOfClass:[CMUpDownControl class]]) {
        self.sizeStepper = [(CMUpDownControl*)sender value];
        [self.tableView reloadData];
    }
}

- (void) stepperLineWidthClicked:(id) sender {
    if ([sender isKindOfClass:[CMUpDownControl class]]) {
        self.sizeWidth = [(CMUpDownControl*)sender value];
        _selectedLineWidthButton.layer.backgroundColor = [UIColor clearColor].CGColor;
        _selectedLineWidthButton.layer.borderColor = [UIColor clearColor].CGColor;
        _selectedLineWidthButton = nil;
        [self.tableView reloadData];
    }
}

#pragma mark - Helpers
- (CGFloat) sizeForElement:(VNOptionsPickerStyle)style {
    CGFloat size = 0.f;
    switch (style) {
        case VNOptionsPickerStyleFontExample:
            size = kVNOptionsCellSizeFontExample;
            break;
        case VNOptionsPickerStyleFontSize:
        case (VNOptionsPickerStyleFontName | VNOptionsPickerStyleFontSize):
            size = kVNOptionsCellSizeFontNameAndSize;
            break;
        case VNOptionsPickerStyleFontName:
            size = kVNOptionsCellSizeFontName;
            break;
        case VNOptionsPickerStyleColorSection:
        case VNOptionsPickerStyleColorExample:
            size = kVNOptionsCellSizeColorExample + kVNOptionsCellSizeColorPicker;
            break;
        case VNOptionsPickerStyleColor:
            size = kVNOptionsCellSizeColorPicker;
            break;
        case VNOptionsPickerStyleLineWidthByExamples:
            size = kVNOptionsCellSizeLineWidthByExample;
            break;
        case VNOptionsPickerStyleLineWidthStepper:
        case (VNOptionsPickerStyleLineExample | VNOptionsPickerStyleLineWidthStepper):
            size = kVNOptionsCellSizeLineWidthStepper;
            break;
        case VNOptionsPickerStyleLineExample:
            size = kVNOptionsCellSizeLineExample;
            break;
        default:
            size = 44.f;
            break;
    }
    return size;
}

#pragma mark - delegates
- (void) colorWasChanged:(HRColorPickerView *)color_picker_view {
    HRRGBColor rgbColor = color_picker_view.RGBColor;
    self.color = [UIColor colorWithRed:rgbColor.r green:rgbColor.g blue:rgbColor.b alpha:1.];
    NSArray *paths = [self.tableView indexPathsForVisibleRows];
    paths = [paths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
        if (![evaluatedObject isEqual:_colorIndexPath]) {
            return TRUE;
        } else {
            return FALSE;
        }
    }]];

    [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView reloadData];
}
- (void)fontSelectTableViewController:(CMFontSelectTableViewController *)fontSelectTableViewController didSelectFont:(UIFont *)selectedFont {
    [self setFont:selectedFont];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)fontStyleSelectTableViewController:(CMFontStyleSelectTableViewController *)fontStyleSelectTableViewController didSelectFont:(UIFont *)selectedFont {
    [self setFont:selectedFont];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//- (UITableViewCell*)defaultCell {
//    UITableViewCell *cell = [[UITableViewCell alloc] init];
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    
//}

#pragma mark - Helpers

- (void) selectButton:(UIButton*)aButton {
    if (_selectedLineWidthButton) {
        [self deselectButton:_selectedLineWidthButton];
        _selectedLineWidthButton = nil;
    }
    aButton.layer.backgroundColor = [self invertedColorForButton].CGColor;
    aButton.layer.borderColor = [self color].CGColor;
    aButton.layer.borderWidth = kVNOptionsCellItemPadding-1;
    aButton.layer.cornerRadius = 4.;
    _selectedLineWidthButton = aButton ;
}
- (void) deselectButton:(UIButton*)aButton {
    aButton.layer.backgroundColor = [UIColor clearColor].CGColor;
    aButton.layer.borderColor = [UIColor clearColor].CGColor;
    aButton.layer.borderWidth = 0;
    aButton.layer.shadowColor = [UIColor clearColor].CGColor;

}
- (UIColor*)invertedColorForButton {
    
    const CGFloat *componentColors = CGColorGetComponents(self.color.CGColor);
    
    UIColor *newColor = [[UIColor alloc] initWithRed:(255 - componentColors[0])
                                               green:(255 - componentColors[1])
                                                blue:(255 - componentColors[2])
                                               alpha:componentColors[3]];
    return newColor;
}
@end
