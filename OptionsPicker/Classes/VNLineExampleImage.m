//
//  VNLineExampleImage.m
//  CMTextStylePickerDemo
//
//  Created by submarine on 11/12/12.
//
//

#import "VNLineExampleImage.h"
@interface VNLineExampleImage ()
+ (CGRect) rectForToolImage:(UIImage*)anImage withRect:(CGRect)baseRect;
void HRSetRoundedRectanglePath(CGContextRef context,const CGRect rect,CGFloat radius);
@end

@implementation VNLineExampleImage
+ (UIImage*)solidLineWithWidth:(CGFloat)width withImageSize:(CGSize)aSize withColor:(UIColor*)aColor {
    return [[self class] solidLineWithWidth:width withImageSize:aSize withColor:aColor toolImage:nil];
}
+ (UIImage*)solidLineWithWidth:(CGFloat)width withImageSize:(CGSize)aSize withColor:(UIColor*)aColor toolImage:(UIImage *)aToolImage {
    if (CGSizeEqualToSize(aSize, CGSizeZero) || !aColor) {
        return nil;
    }
    
    
    UIGraphicsBeginImageContextWithOptions(aSize, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // flip the coordinates system
    CGContextTranslateCTM(context, 0.f, aSize.height);
    CGContextScaleCTM(context, 1.f, -1.f);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetAllowsAntialiasing(context, TRUE);
    CGContextSetShouldAntialias(context, TRUE);

    
    CGContextSaveGState(context);
    
    // setup shadow
    CGSize shadowOffset = CGSizeMake(0.0f, 1.0f);
    CGFloat shadowBlur = 3.0;
    CGColorRef cgShadowColor = [[UIColor blackColor] CGColor];
    
    // set shadow
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlur, cgShadowColor);

    //draw image and line
    CGRect toolFrame = CGRectZero;

    CGContextSetStrokeColorWithColor(context, aColor.CGColor);
    CGContextSetFillColorWithColor(context, aColor.CGColor);
    
    if (aToolImage) {

            toolFrame = CGRectMake(floorf(aSize.width *(1-kToolImageSize)), kLineCenterY, floorf(aSize.width *kToolImageSize), aSize.height -kLineCenterY - 1);
            toolFrame = [[self class] rectForToolImage:aToolImage withRect:toolFrame];
            
#if DEBUG_LEVEL >= 4
            CGContextSaveGState(context);
            //draw rect bounds
            CGRect clipRect = toolFrame;
            clipRect = CGRectInset(clipRect, 0.5, 0.5);
            //    clipRect = CGRectInset(clipRect, 1, 1);
            CGContextSetLineWidth(context, 1);
            CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
            CGContextStrokeRect(context, clipRect);
            CGContextRestoreGState(context);
#endif

    }
    CGMutablePathRef path = CGPathCreateMutable();
    
    
    if (aToolImage) {
        CGContextDrawImage(context, toolFrame, aToolImage.CGImage);
        CGPathMoveToPoint(path, NULL, 2, toolFrame.origin.y-2);
        CGPathAddLineToPoint(path, NULL, toolFrame.origin.x, toolFrame.origin.y-2);
        CGPathCloseSubpath(path);
    } else {
        CGPathMoveToPoint(path, NULL, 3., floorf((aSize.height - width)/2));
        CGPathAddLineToPoint(path, NULL, aSize.width - 6., floorf((aSize.height - width)/2));
        CGPathCloseSubpath(path);
    }

    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, width);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextRestoreGState(context);
    
    // Create an image mask from what we've drawn so far
    CGImageRef alphaMask = CGBitmapContextCreateImage(context);

    // Draw a white background (clear the window)
    CGRect rect = CGRectMake(0, 0, aSize.width, aSize.height);
    
    // Draw the image, clipped by the mask
    CGContextSaveGState(context);
    CGContextClipToMask(context, rect, alphaMask);
    
    [aColor setFill];
    CGContextFillRect(context, rect);
    CGContextRestoreGState(context);
    CGImageRelease(alphaMask);
    
#if DEBUG_LEVEL >= 4
    //draw rect bounds
    CGRect clipRect = CGContextGetClipBoundingBox(context);
    clipRect = CGRectInset(clipRect, 0.5, 0.5);
    //    clipRect = CGRectInset(clipRect, 1, 1);
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextStrokeRect(context, clipRect);
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextStrokeRect(context, rect);
    
#endif
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    CGPathRelease(path);
    
    return img;
}

+ (CGRect) rectForToolImage:(UIImage*)anImage withRect:(CGRect)baseRect {
    if (!anImage) {
        return CGRectZero;
    }
    CGSize aSize = anImage.size;
    CGFloat widthScale = baseRect.size.width / aSize.width;
    CGFloat heightScale = baseRect.size.height / aSize.height;
    CGFloat scale = MIN(widthScale, heightScale);
    aSize.width = floorf(aSize.width * scale);
    aSize.height = floorf(aSize.height * scale);
    CGRect result;
    //be carefull - align to right
    result.origin.x = floorf(CGRectGetMaxX(baseRect) - aSize.width);
    //for centered image - use below
//    result.origin.x = floorf(CGRectGetMidX(baseRect) - aSize.width / 2);
    result.origin.y = floorf(CGRectGetMidY(baseRect) - aSize.height / 2);
    result.size = aSize;
    return result;
}



+ (UIImage*)solidSquareColor:(UIColor*)aColor forSize:(CGSize)aSize withRadius:(CGFloat)aRadius {
    return [[self class] solidSquareColor:aColor forSize:aSize withRadius:aRadius withFont:[UIFont systemFontOfSize:12.]  withRGBInfo:FALSE];
}
+ (UIImage*)solidSquareColor:(UIColor*)aColor forSize:(CGSize)aSize withRadius:(CGFloat)aRadius withFont:(UIFont*)aFont withRGBInfo:(BOOL)rgbInfoFlag {
    if (CGSizeEqualToSize(aSize, CGSizeZero) || !aColor || !aFont) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(aSize, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetAllowsAntialiasing(context, TRUE);
    CGContextSetShouldAntialias(context, TRUE);
    
    CGSize imageSize = aSize;

    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    
    BOOL rgb = [aColor getRed:&red green:&green blue:&blue alpha:&alpha];

    if (rgbInfoFlag && rgb) {
        imageSize.width = floorf(aSize.width/3);
    }

    CGRect rectEllipse = CGRectMake(aRadius*2, aRadius*2, imageSize.width - aRadius*4, imageSize.height - aRadius*4);
    CGRect rectBackEllipse = CGRectMake(aRadius, aRadius, imageSize.width - aRadius*2, imageSize.height - aRadius*2);
    CGRect rectShadowEllipse = CGRectMake(0, 0, imageSize.width, imageSize.height);

    CGContextSaveGState(context);
    HRSetRoundedRectanglePath(context, rectBackEllipse,aRadius);
    CGContextClip(context);
    HRSetRoundedRectanglePath(context, rectShadowEllipse,aRadius);
    CGContextSetLineWidth(context, 5.5f);
    [[UIColor whiteColor] set];
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 4.0f, [UIColor colorWithWhite:0.0f alpha:0.2f].CGColor);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, aColor.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.5f), 0.5f, [UIColor colorWithWhite:0.0f alpha:0.2f].CGColor);
    HRSetRoundedRectanglePath(context, rectEllipse,5.0f);
    CGContextDrawPath(context, kCGPathFill);
    CGContextRestoreGState(context);

    if (rgbInfoFlag && rgb) {
        [aColor set];
        CGRect _currentColorFrame = CGRectMake(imageSize.width + 5, 0, aSize.width - imageSize.width - 5, aSize.height);
        float textCenter = CGRectGetMidY(_currentColorFrame);
        NSString *redString = [NSString stringWithFormat:@"R:%3d%%",(int)(red*100)];
        [redString drawAtPoint:CGPointMake(_currentColorFrame.origin.x, textCenter - [redString sizeWithFont:aFont].height / 2) withFont:aFont];
        NSString *greenString = [NSString stringWithFormat:@"G:%3d%%",(int)(green*100)];
        [greenString drawAtPoint:CGPointMake(_currentColorFrame.origin.x + [redString sizeWithFont:aFont].width+5.0f, textCenter - [greenString sizeWithFont:aFont].height / 2) withFont:aFont];
        NSString *blueString = [NSString stringWithFormat:@"B:%3d%%",(int)(blue*100)];
        [blueString drawAtPoint:CGPointMake(_currentColorFrame.origin.x+ + [redString sizeWithFont:aFont].width + [greenString sizeWithFont:aFont].width +10.0f, textCenter - [blueString sizeWithFont:aFont].height / 2) withFont:aFont];
    }
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

//void HRSetRoundedRectanglePath(CGContextRef context,const CGRect rect,CGFloat radius){
//    CGFloat lx = CGRectGetMinX(rect);
//    CGFloat cx = CGRectGetMidX(rect);
//    CGFloat rx = CGRectGetMaxX(rect);
//    CGFloat by = CGRectGetMinY(rect);
//    CGFloat cy = CGRectGetMidY(rect);
//    CGFloat ty = CGRectGetMaxY(rect);
//	
//    CGContextMoveToPoint(context, lx, cy);
//    CGContextAddArcToPoint(context, lx, by, cx, by, radius);
//    CGContextAddArcToPoint(context, rx, by, rx, cy, radius);
//    CGContextAddArcToPoint(context, rx, ty, cx, ty, radius);
//    CGContextAddArcToPoint(context, lx, ty, lx, cy, radius);
//    CGContextClosePath(context);
//}

@end
