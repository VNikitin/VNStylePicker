//
//  VNTextGraphicsOptions.h
//  CMTextStylePickerDemo
//
//  Created by submarine on 11/11/12.
//
//

#import <UIKit/UIKit.h>
#import "HRColorPickerView.h"
#import "CMUpDownControl.h"
#import "CMFontSelectTableViewController.h"
#import "CMFontStyleSelectTableViewController.h"

#define kVNOptionsPickerDefaultWidths @[@2, @4, @6, @8]

static NSString *kSectionFontExample = @"Current Font";
static NSString *kSectionFontName = @"Font name";
static NSString *kSectionFontSize = @"Font Size";
static NSString *kSectionLineExample = @"Current Line";
static NSString *kSectionLineWidthStepper = @"Line Width";
static NSString *kSectionLineWidthByExample = @"Choose line width";
static NSString *kSectionColorExample = @"Current color";
static NSString *kSectionColor = @"Colors";

#define kVNOptionsCellSizeFontExample             44.
#define kVNOptionsCellSizeFontNameAndSize         80.
#define kVNOptionsCellSizeFontName                44.
#define kVNOptionsCellSizeLineExample             60.
#define kVNOptionsCellSizeLineWidthStepper        80.
#define kVNOptionsCellSizeLineWidthByExample      70.
#define kVNOptionsCellSizeColorExample            70.
#define kVNOptionsCellSizeColorPicker             320.
#define kVNOptionsCellItemPadding                 4.

@protocol VNTextGraphicsOptionsDelegate <NSObject>

@end


typedef NS_OPTIONS(NSUInteger, VNOptionsPickerStyle) {
    VNOptionsPickerStyleFontExample         = 1UL << 0,
    VNOptionsPickerStyleFontName            = 1UL << 1,
    VNOptionsPickerStyleFontSize            = 1UL << 2,
    VNOptionsPickerStyleLineExample         = 1UL << 3,
    VNOptionsPickerStyleLineWidthStepper    = 1UL << 4,
    VNOptionsPickerStyleLineWidthByExamples = 1UL << 5,
    VNOptionsPickerStyleColor               = 1UL << 6,
    VNOptionsPickerStyleColorExample        = 1UL << 7,
    VNOptionsPickerStyleFontCellUnion  = VNOptionsPickerStyleFontName | VNOptionsPickerStyleFontSize,
    VNOptionsPickerStyleFontSection = VNOptionsPickerStyleFontExample | VNOptionsPickerStyleFontCellUnion,
    VNOptionsPickerStyleLineSectionSmall = VNOptionsPickerStyleLineWidthByExamples,
    VNOptionsPickerStyleLineSectionExpanded = VNOptionsPickerStyleLineExample | VNOptionsPickerStyleLineWidthStepper,
    VNOptionsPickerStyleColorSection = VNOptionsPickerStyleColor | VNOptionsPickerStyleColorExample,
    VNOptionsPickerStyleAll             = VNOptionsPickerStyleFontSection | VNOptionsPickerStyleLineSectionSmall | VNOptionsPickerStyleColorSection
};

//typedef struct {
//    BOOL isFontExample:1;
//    BOOL isFontName:1;
//    BOOL isFontSize:1;
//    BOOL isLineExample:1;
//    BOOL isLineWidth:1;
//    BOOL isLineWidthByExamples:1;
//    BOOL isColor:1;
//    BOOL isColorExample:1;
//} VNSections;


@interface VNTextGraphicsOptionsView : UITableViewController <HRColorPickerViewDelegate, CMFontSelectTableViewControllerDelegate, CMFontStyleSelectTableViewControllerDelegate> {
    
    @private
    VNOptionsPickerStyle _style;
//    UIFont *_font;
    NSString *_fontName;
    CGFloat _sizeStepper;
    CGFloat _sizeWidth;
    UIColor *_color;
    NSArray *_sections;
    __strong NSString *_toolImage;
    __strong UIButton *_selectedLineWidthButton;
}
@property (nonatomic, assign, readwrite) VNOptionsPickerStyle style;

- (id)initWithStyle:(VNOptionsPickerStyle)style andToolImage:(NSString*)aToolImage;
//@property (nonatomic, retain) NSString* unitsName; // default @"pt" if style  match VNOptionsPickerStyleFontName
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain, readonly) UIFont *font;
@property (nonatomic, assign, readonly) CGFloat sizeStepper;
@property (nonatomic, assign, readonly) CGFloat sizeWidth;
@property (nonatomic, retain, readonly) UIColor *color;
- (void) setFont:(UIFont *)font;
@end


