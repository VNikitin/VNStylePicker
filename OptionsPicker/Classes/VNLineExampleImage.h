//
//  VNLineExampleImage.h
//  CMTextStylePickerDemo
//
//  Created by submarine on 11/12/12.
//
//

#import <UIKit/UIKit.h>
#ifndef DEBUG_LEVEL
#define DEBUG_LEVEL 2
#endif

#define kLineCenterY 10.f
#define kToolImageSize 0.5f //percent of width

@interface VNLineExampleImage : UIImage

+ (UIImage*)solidLineWithWidth:(CGFloat)width withImageSize:(CGSize)aSize withColor:(UIColor*)aColor;
+ (UIImage*)solidLineWithWidth:(CGFloat)width withImageSize:(CGSize)aSize withColor:(UIColor*)aColor toolImage:(NSString *)aToolImage;
+ (UIImage*)solidSquareColor:(UIColor*)aColor forSize:(CGSize)aSize withRadius:(CGFloat)aRadius;
+ (UIImage*)solidSquareColor:(UIColor*)aColor forSize:(CGSize)aSize withRadius:(CGFloat)aRadius withFont:(UIFont*)aFont withRGBInfo:(BOOL)rgbInfoFlag;
@end
