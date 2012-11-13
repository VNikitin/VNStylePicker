//
//  VNDemoVC.m
//  CMTextStylePickerDemo
//
//  Created by submarine on 11/12/12.
//
//

#import "VNDemoVC.h"
#import "VNTextGraphicsOptionsView.h"

@interface VNDemoVC ()
@property (nonatomic, retain) UIPopoverController *popover;
@end

@implementation VNDemoVC
@synthesize popover = _popover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Color" style:UIBarButtonItemStylePlain target:self action:@selector(colorClicked:)];
    self.navigationItem.rightBarButtonItem = anotherButton;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) colorClicked:(id)sender {
    if (_popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
        return;
    }
    
//  sections are optional
    VNTextGraphicsOptionsView *colors = [[VNTextGraphicsOptionsView alloc] initWithStyle:VNOptionsPickerStyleColorSection | VNOptionsPickerStyleLineWidthByExamples | VNOptionsPickerStyleFontSection andToolImage:@"VNButtonBarBrush.png"];
    
//    VNTextGraphicsOptionsView *colors = [[VNTextGraphicsOptionsView alloc] initWithStyle:VNOptionsPickerStyleColorSection andToolImage:@"VNButtonBarBrush.png"];

//    VNTextGraphicsOptionsView *colors = [[VNTextGraphicsOptionsView alloc] initWithStyle:  VNOptionsPickerStyleFontSection | VNOptionsPickerStyleLineWidthByExamples | VNOptionsPickerStyleLineSectionExpanded andToolImage:@"VNButtonBarBrush.png"];

    [colors setContentSizeForViewInPopover:CGSizeMake(350, 570)];
    UINavigationController *newNav = [[UINavigationController alloc] initWithRootViewController:colors];
    newNav.navigationBarHidden = TRUE;
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIPopoverController *pop = [[UIPopoverController alloc] initWithContentViewController:newNav];
        self.popover = pop;
        [pop presentPopoverFromBarButtonItem:(UIBarButtonItem*)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}
@end
