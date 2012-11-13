/*-
 * Copyright (c) 2011 Ryota Hayashi
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR(S) ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR(S) BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $FreeBSD$
 */

#import "HRColorPickerView.h"
#import "HRCgUtil.h"
#import "HRBrightnessCursor.h"
#import "HRColorCursor.h"

@interface HRColorPickerView() {
    
}
@property (nonatomic, assign) HRColorPickerStyle style;
@property (nonatomic, assign) CGPoint offset;

- (void)createCacheImage;
- (void)update;
- (void)updateBrightnessCursor;
- (void)updateColorCursor;
- (void)clearInput;
- (void)setCurrentTouchPointInView:(UITouch *)touch;
- (void)setNeedsDisplay15FPS;
@end

@implementation HRColorPickerView
@synthesize style = _style;
@synthesize offset = _offset;
@synthesize delegate;

#pragma mark - Styles
+ (HRColorPickerStyle)defaultStyle
{
    HRColorPickerStyle style;
    style.size = CGSizeMake(220.f, 300.f);
    style.headerHeight = 70.0f;
    style.colorMapTileSize = kHRColorTileSize;
    style.colorMapSizeHorizontalCount = kHRColorMapSizeHorizontalCount;
    style.colorMapSizeVerticalCount = kHRColorMapSizeVerticalCount;
    style.brightnessLowerLimit = 0.4f;
    style.saturationUpperLimit = 0.85f;
    return style;
}

+ (HRColorPickerStyle) styleWithSize:(CGSize)defaultSize {
    HRColorPickerStyle style = [HRColorPickerView defaultStyle];
    style.size = defaultSize;
    
    style.colorMapTileSize = floorf(MIN(defaultSize.width / style.colorMapSizeHorizontalCount - 2*kHRColorMapTilePadding, (defaultSize.height - style.headerHeight - 2*kHRColorMapTilePadding)/style.colorMapSizeVerticalCount));
//    if (style.headerHeight > 1) {
//        CGFloat colorMapMargin = (defaultSize.width - (style.colorMapSizeHorizontalCount*style.colorMapTileSize))/2.f;
//        style.headerHeight = defaultSize.height - (style.colorMapSizeVerticalCount*style.colorMapTileSize) - colorMapMargin;
//        if (style.headerHeight < 0) {
//            style.headerHeight = 0;
//        }
////        if (style.headerHeight > style.colorMapTileSize *2) {
////            style.headerHeight = style.colorMapTileSize *2;
////        }
//    }
    return style;
}
+ (HRColorPickerStyle)fitScreenStyle
{
//    CGSize defaultSize = [[UIScreen mainScreen] applicationFrame].size;
//    defaultSize.height -= 44.f;
    
    HRColorPickerStyle style = [HRColorPickerView defaultStyle];
//    style.colorMapSizeVerticalCount = (defaultSize.height - style.headerHeight)/style.colorMapTileSize;
    
//    float colorMapMargin = (style.size.width - (style.colorMapSizeHorizontalCount*style.colorMapTileSize))/2.f;
//    style.headerHeight = defaultSize.height - (style.colorMapSizeVerticalCount*style.colorMapTileSize) - colorMapMargin;
    
    return style;
}

+ (HRColorPickerStyle)fullColorStyle
{
    HRColorPickerStyle style = [HRColorPickerView defaultStyle];
    style.brightnessLowerLimit = 0.0f;
    style.saturationUpperLimit = 1.0f;
    return style;
}

+ (HRColorPickerStyle)fitScreenFullColorStyle
{
    HRColorPickerStyle style = [HRColorPickerView fitScreenStyle];
    style.brightnessLowerLimit = 0.0f;
    style.saturationUpperLimit = 1.0f;
    return style;
}


+ (HRColorPickerStyle)updateStyle:(HRColorPickerStyle)style forRect:(CGRect) bounds {
    CGSize colorMapSize = CGSizeZero;

    NSInteger countX = style.colorMapSizeHorizontalCount;
    NSInteger countY = style.colorMapSizeVerticalCount;
    CGFloat colorMapTileSize = floorf(MIN((bounds.size.height - style.headerHeight)/countY, bounds.size.width / countX));
    
    while ((colorMapTileSize < kHRColorMapMinimumTileSize || colorMapTileSize > kHRColorMapMaximumTileSize) && countX > 0 && countY > 0) {
        if (colorMapTileSize > kHRColorMapMaximumTileSize) {
            if ((bounds.size.height - style.headerHeight)/countY > bounds.size.width / countX) {
                countY++;
            } else {
                countX++;
            }
        } else if (colorMapTileSize < kHRColorMapMinimumTileSize) {
            if ((bounds.size.height - style.headerHeight)/countY > bounds.size.width / countX) {
                countX --;
            } else {
                countY --;
            }
        }
        colorMapTileSize = floorf(MIN((bounds.size.height - style.headerHeight)/countY, bounds.size.width / countX));
        
    }

//    float colorMapMargin = (style.width - colorMapSize.width) / 2.0f;
    HRColorPickerStyle newStyle;
    colorMapSize = CGSizeMake(colorMapTileSize * style.colorMapSizeHorizontalCount, colorMapTileSize * style.colorMapSizeVerticalCount);
    if (colorMapSize.width > bounds.size.width) {
        colorMapSize.width = bounds.size.width;
    }
    newStyle.size = CGSizeMake(floorf(colorMapSize.width), floorf(style.headerHeight + colorMapSize.height));
    newStyle.colorMapSizeHorizontalCount = countX;
    newStyle.colorMapSizeVerticalCount = countY;
    newStyle.colorMapTileSize = colorMapTileSize;
    newStyle.headerHeight = style.headerHeight;
    newStyle.saturationUpperLimit = style.saturationUpperLimit;
    newStyle.brightnessLowerLimit = style.brightnessLowerLimit;
    return newStyle;
}

#pragma mark - Init
- (id)initWithFrame:(CGRect)frame defaultColor:(const HRRGBColor)defaultColor
{
    return [self initWithStyle:[HRColorPickerView defaultStyle] defaultColor:defaultColor frame:frame];
}

- (id)initWithStyle:(HRColorPickerStyle)style defaultColor:(const HRRGBColor)defaultColor frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.offset = CGPointZero;
        _defaultRgbColor = defaultColor;
        _animating = FALSE;
        self.style = style;
        _brightnessLowerLimit = self.style.brightnessLowerLimit;
        _saturationUpperLimit = self.style.saturationUpperLimit;

        // RGBのデフォルトカラーをHSVに変換
        HSVColorFromRGBColor(&_defaultRgbColor, &_currentHsvColor);
        _timeInterval15fps.tv_sec = 0.0;
        _timeInterval15fps.tv_usec = 1000000.0/15.0;
        
        _delegateHasSELColorWasChanged = FALSE;

        // 諸々初期化
//        [self setBackgroundColor:[UIColor colorWithWhite:0.99f alpha:1.0f]];
        self.backgroundColor = [UIColor clearColor];
        [self setMultipleTouchEnabled:FALSE];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self setNeedsLayout];
    }
    return self;
}

#pragma mark - Layout 
- (void) layoutSubviews {
    HRColorPickerStyle newStyle = [HRColorPickerView updateStyle:self.style forRect:self.bounds];
    self.style = newStyle;
    _tileSize = self.style.colorMapTileSize;
    CGSize size = newStyle.size;
    CGRect frame = self.bounds;
    if (size.height < frame.size.height || size.width < frame.size.width) {
        CGPoint offset = CGPointMake(floorf((frame.size.width - size.width)/2), floorf((frame.size.height - size.height)/2));
        if (offset.x < 0) { offset.x = 0; }
        if (offset.y < 0) { offset.x = 0; }
        self.offset = offset;
    }

    // パーツの配置
    // Placing Parts
    CGFloat offset = 0.f;
    if (self.style.headerHeight > 1) {
        
        CGFloat currentColorSize = floorf(self.style.headerHeight /4 *3);
//        if (currentColorSize < 30.) {
//            currentColorSize = 30.;
//        } else if (currentColorSize + 20.f > self.style.headerHeight) {
//            currentColorSize = self.style.headerHeight - 20.f;
//        }
        offset = floorf((self.style.headerHeight - currentColorSize)/2);
        _currentColorFrame = CGRectMake(offset, offset, currentColorSize, currentColorSize);
        
        CGFloat textFrameSize = frame.size.width / 4;
        NSString *testString = @"R:100%";
        CGSize textSize = [testString sizeWithFont:[UIFont boldSystemFontOfSize:12.0f]];
        if (textFrameSize < textSize.width * 3) {
            CGFloat y = CGRectGetMidY(_currentColorFrame) - (textSize.height * 3 + kHRColorMapTilePadding *2)/2;
            if (y < 0) {
                y = 0;
            }
            _currentColorTextFrame = CGRectMake(floorf(CGRectGetMaxX(_currentColorFrame) + offset), y, textSize.width, textSize.height * 3 + kHRColorMapTilePadding *2);
            _brightnessPickerFrame = CGRectMake(CGRectGetMaxX(_currentColorTextFrame)+kHRColorMapTilePadding, _currentColorFrame.origin.y, frame.size.width - CGRectGetMaxX(_currentColorTextFrame)-offset - kHRColorMapTilePadding, currentColorSize);
            
        } else {
            _currentColorTextFrame = CGRectMake(floorf(CGRectGetMaxX(_currentColorFrame) + kHRColorMapTilePadding), floorf(CGRectGetMidY(_currentColorFrame) - textSize.height/2), textSize.width * 3 + kHRColorMapTilePadding*2, textSize.height);
            _brightnessPickerFrame = CGRectMake(CGRectGetMaxX(_currentColorTextFrame)+kHRColorMapTilePadding, _currentColorFrame.origin.y, frame.size.width - CGRectGetMaxX(_currentColorTextFrame)-kHRColorMapTilePadding - offset, currentColorSize);
        }
        
        
        
        _brightnessPickerTouchFrame = CGRectMake(_brightnessPickerFrame.origin.x - 20.0f,
                                                 10.f,
                                                 _brightnessPickerFrame.size.width + 40.0f,
                                                 _brightnessPickerFrame.size.height);
        _brightnessPickerShadowFrame = CGRectMake(_brightnessPickerFrame.origin.x-5.0f,
                                                  _brightnessPickerFrame.origin.y-5.0f,
                                                  _brightnessPickerFrame.size.width+10.0f,
                                                  _brightnessPickerFrame.size.height+10.0f);
    } else {
        _brightnessPickerFrame = CGRectZero;
        _brightnessPickerShadowFrame = CGRectZero;
        _brightnessPickerTouchFrame = CGRectZero;
        _currentColorFrame = CGRectZero;
        _currentColorTextFrame = CGRectZero;
    }
    
    CGFloat maxY = MAX(CGRectGetMaxY(_currentColorFrame), CGRectGetMaxY(_currentColorTextFrame)) + offset;
    
    CGSize colorMapSize = CGSizeMake(frame.size.width - kHRColorMapTilePadding, frame.size.height - maxY - kHRColorMapTilePadding);

    _colorMapFrame = CGRectMake(kHRColorMapTilePadding, maxY, colorMapSize.width, colorMapSize.height);
    
    _colorMapSideFrame = CGRectMake(_colorMapFrame.origin.x - kHRColorMapTilePadding,
                                    _colorMapFrame.origin.y - kHRColorMapTilePadding,
                                    _colorMapFrame.size.width + kHRColorMapTilePadding*2,
                                    _colorMapFrame.size.height+ kHRColorMapTilePadding*2);
    
    _tileSize = self.style.colorMapTileSize;
    
    if (_brightnessCursor) {
        [_brightnessCursor removeFromSuperview];
        _brightnessCursor = nil;
    }
    
    // タイルの中心にくるようにずらす
    if (_colorCursor) {
        [_colorCursor removeFromSuperview];
        _colorCursor = nil;
    }
    
    
    _colorCursor = [[HRColorCursor alloc] initWithPoint:CGPointMake(_colorMapFrame.origin.x, _colorMapFrame.origin.y)
                                           withTileSize:self.style.colorMapTileSize+2*kHRColorMapTilePadding];
    [self addSubview:_colorCursor];
    [self updateColorCursor];

    if (self.style.headerHeight > 1) {
        _brightnessCursor = [[HRBrightnessCursor alloc] initWithPoint:CGPointMake(_brightnessPickerFrame.origin.x, _brightnessPickerFrame.origin.y + _brightnessPickerFrame.size.height/2.0f)];
        

        [self addSubview:_brightnessCursor];
        
        
        if (_brightnessPickerShadowImage) {
            CGImageRelease(_brightnessPickerShadowImage);
            _brightnessPickerShadowImage = nil;
        }
        [self createCacheImage];
        [self updateBrightnessCursor];
    }

    // 入力の初期化
    _isTapStart = FALSE;
    _isTapped = FALSE;
    _wasDragStart = FALSE;
    _isDragStart = FALSE;
    _isDragging = FALSE;
    _isDragEnd = FALSE;
    
    // フレームレートの調整
    gettimeofday(&_lastDrawTime, NULL);
    
    [self setNeedsDisplay];
}

#pragma mark - Accessors
- (void)setDelegate:(NSObject<HRColorPickerViewDelegate>*)picker_delegate{
    delegate = picker_delegate;
    _delegateHasSELColorWasChanged = FALSE;
    // 微妙に重いのでメソッドを持っているかどうかの判定をキャッシュ
    //Cache the determination of whether or not you have a method slightly heavier
    if ([delegate respondsToSelector:@selector(colorWasChanged:)]) {
        _delegateHasSELColorWasChanged = TRUE;
    }
}

- (HRRGBColor)RGBColor{
    HRRGBColor rgbColor;
    RGBColorFromHSVColor(&_currentHsvColor, &rgbColor);
    return rgbColor;
}

- (float)BrightnessLowerLimit{
    return _brightnessLowerLimit;
}

- (void)setBrightnessLowerLimit:(float)brightnessUnderLimit{
    _brightnessLowerLimit = brightnessUnderLimit;
    [self updateBrightnessCursor];
}

- (float)SaturationUpperLimit{
    return _brightnessLowerLimit;
}

- (void)setSaturationUpperLimit:(float)saturationUpperLimit{
    _saturationUpperLimit = saturationUpperLimit;
    [self updateColorCursor];
}

#pragma mark - Update selections
- (void)update{
    // タッチのイベントの度、更新されます
//    Every touch events are updated
    
    if (_isDragging || _isDragStart || _isDragEnd || _isTapped) {
        CGPoint touchPosition = _activeTouchPosition;
        if (CGRectContainsPoint(_colorMapFrame,touchPosition)) {
            
            NSInteger pixelCountX = self.style.colorMapSizeHorizontalCount;
            NSInteger pixelCountY = self.style.colorMapSizeVerticalCount;
            
            CGFloat horizontalTileSize = floorf((_colorMapFrame.size.width - kHRColorMapTilePadding) / self.style.colorMapSizeHorizontalCount);
            CGFloat verticalTileSize = floorf((_colorMapFrame.size.height - kHRColorMapTilePadding) / self.style.colorMapSizeVerticalCount);

            HRHSVColor newHsv = _currentHsvColor;
            
            CGPoint newPosition = CGPointMake(touchPosition.x - _colorMapFrame.origin.x, touchPosition.y - _colorMapFrame.origin.y);
//            (Hue) is to take the value of 0.0f ~ 0.95f 1.0f = 0.0f X so
            float pixelX = (int)((newPosition.x)/horizontalTileSize)/(float)pixelCountX; // X(色相)は1.0f=0.0fなので0.0f~0.95fの値をとるように -
//            Y (chroma) is 0.0f ~ 1.0f            
            float pixelY = (int)((newPosition.y)/verticalTileSize)/(float)(pixelCountY-1); // Y(彩度)は0.0f~1.0f
            
            HSVColorAt(&newHsv, pixelX, pixelY, _saturationUpperLimit, _currentHsvColor.v);
            
            if (!HRHSVColorEqualToColor(&newHsv,&_currentHsvColor)) {
                _currentHsvColor = newHsv;
                [self setNeedsDisplay15FPS];
            }
            [self updateColorCursor];
        }else if(CGRectContainsPoint(_brightnessPickerTouchFrame,touchPosition)){
            if (CGRectContainsPoint(_brightnessPickerFrame,touchPosition)) {
                // 明度のスライダーの内側
//                The inside of the slider of brightness
                _currentHsvColor.v = (1.0f - ((touchPosition.x - _brightnessPickerFrame.origin.x )/ _brightnessPickerFrame.size.width )) * (1.0f - _brightnessLowerLimit) + _brightnessLowerLimit;
            }else{
                // 左右をタッチした場合
//                If you touch the left and right
                if (touchPosition.x < _brightnessPickerFrame.origin.x) {
                    _currentHsvColor.v = 1.0f;
                }else if((_brightnessPickerFrame.origin.x + _brightnessPickerFrame.size.width) < touchPosition.x){
                    _currentHsvColor.v = _brightnessLowerLimit;
                }
            }
            [self updateBrightnessCursor];
            [self updateColorCursor];
            [self setNeedsDisplay15FPS];
        }
    }
    [self clearInput];
}

- (void)updateBrightnessCursor{
    // 明度スライダーの移動
    if (self.style.headerHeight > 1) {
        float brightnessCursorX = (1.0f - (_currentHsvColor.v - _brightnessLowerLimit)/(1.0f - _brightnessLowerLimit)) * _brightnessPickerFrame.size.width + _brightnessPickerFrame.origin.x;
        _brightnessCursor.transform = CGAffineTransformMakeTranslation(brightnessCursorX - _brightnessPickerFrame.origin.x, 0.0f);
    }
}

- (void)updateColorCursor{
    // カラーマップのカーソルの移動＆色の更新
    NSInteger pixelCountX = self.style.colorMapSizeHorizontalCount;
    NSInteger pixelCountY = self.style.colorMapSizeVerticalCount;
//    CGFloat tileSizeColored = self.style.colorMapTileSize - kHRColorMapTilePadding;
    
    CGFloat horizontalTileSize = floorf((_colorMapFrame.size.width - kHRColorMapTilePadding) / self.style.colorMapSizeHorizontalCount);
    CGFloat verticalTileSize = floorf((_colorMapFrame.size.height - kHRColorMapTilePadding) / self.style.colorMapSizeVerticalCount);
        
    CGPoint newPosition;
//    HSVColorAt(&pixelHsv, pixelX, pixelY, _saturationUpperLimit, _currentHsvColor.v);
//    hsv->h = x;
//    hsv->s = 1.0f - (y * saturationUpperLimit);
//    hsv->v = brightness;

    newPosition.x = floorf(_currentHsvColor.h * (float)pixelCountX) * horizontalTileSize;
    newPosition.y = floorf((1.0f - _currentHsvColor.s) * (1.0f/_saturationUpperLimit) * (float)(pixelCountY)) * verticalTileSize;
    newPosition.x += (horizontalTileSize - self.style.colorMapTileSize)/2 - kHRColorMapTilePadding;
    newPosition.y += (verticalTileSize - self.style.colorMapTileSize)/2;
    _colorCursorPosition.x = floorf(newPosition.x);
    _colorCursorPosition.y = floorf(newPosition.y);
    
    HRRGBColor currentRgbColor = [self RGBColor];
    [_colorCursor setColorRed:currentRgbColor.r andGreen:currentRgbColor.g andBlue:currentRgbColor.b];
    
    _colorCursor.transform = CGAffineTransformMakeTranslation(_colorCursorPosition.x,_colorCursorPosition.y);
     
}

#pragma mark - Drawing
- (void)setNeedsDisplay15FPS{
    // 描画を20FPSに制限します
    //I am limited to 20FPS rendering
    timeval now,diff;
    gettimeofday(&now, NULL);
    timersub(&now, &_lastDrawTime, &diff);
    if (timercmp(&diff, &_timeInterval15fps, >)) {
        _lastDrawTime = now;
        [self setNeedsDisplay];
        if (_delegateHasSELColorWasChanged) {
            [delegate colorWasChanged:self];
        }
    }else{
        return;
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    HRRGBColor currentRgbColor = [self RGBColor];
    
    /////////////////////////////////////////////////////////////////////////////
    //
    // 明度 - Brightness
    //
    /////////////////////////////////////////////////////////////////////////////
    
    CGContextSaveGState(context);
    
    HRSetRoundedRectanglePath(context, _brightnessPickerFrame, 5.0f);
    CGContextClip(context);
    
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace;
    size_t numLocations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    HRRGBColor darkColor;
    HRRGBColor lightColor;
    UIColor* darkColorFromHsv = [UIColor colorWithHue:_currentHsvColor.h saturation:_currentHsvColor.s brightness:_brightnessLowerLimit alpha:1.0f];
    UIColor* lightColorFromHsv = [UIColor colorWithHue:_currentHsvColor.h saturation:_currentHsvColor.s brightness:1.0f alpha:1.0f];
    
    RGBColorFromUIColor(darkColorFromHsv, &darkColor);
    RGBColorFromUIColor(lightColorFromHsv, &lightColor);
    
    CGFloat gradientColor[] = {
        darkColor.r,darkColor.g,darkColor.b,1.0f,
        lightColor.r,lightColor.g,lightColor.b,1.0f,
    };
    
    gradient = CGGradientCreateWithColorComponents(colorSpace, gradientColor,
                                                   locations, numLocations);
    
    CGPoint startPoint = CGPointMake(_brightnessPickerFrame.origin.x + _brightnessPickerFrame.size.width, _brightnessPickerFrame.origin.y);
    CGPoint endPoint = CGPointMake(_brightnessPickerFrame.origin.x, _brightnessPickerFrame.origin.y);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    // GradientとColorSpaceを開放する - ColorSpace and open the Gradient
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    
    // 明度の内側の影 (キャッシュした画像を表示するだけ)
    // (Only to display the image cached) shadow on the inside of the brightness
    CGContextDrawImage(context, _brightnessPickerShadowFrame, _brightnessPickerShadowImage);
    
    CGContextRestoreGState(context);
    
    
    /////////////////////////////////////////////////////////////////////////////
    //
    // カラーマップ - Color map
    //
    /////////////////////////////////////////////////////////////////////////////
    
    CGContextSaveGState(context);
    
    [[UIColor colorWithWhite:0.9f alpha:1.0f] set];
    CGContextAddRect(context, _colorMapSideFrame);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    float height;
//    int pixelCountX = _colorMapFrame.size.width/_tileSize;
//    int pixelCountY = _colorMapFrame.size.height/_tileSize;
    NSInteger pixelCountX = self.style.colorMapSizeHorizontalCount;
    NSInteger pixelCountY = self.style.colorMapSizeVerticalCount;
    CGFloat tileSizeColored = self.style.colorMapTileSize - kHRColorMapTilePadding;

    CGFloat horizontalTileSize = floorf((_colorMapFrame.size.width - kHRColorMapTilePadding) / self.style.colorMapSizeHorizontalCount);
    CGFloat verticalTileSize = floorf((_colorMapFrame.size.height - kHRColorMapTilePadding) / self.style.colorMapSizeVerticalCount);
    
    HRHSVColor pixelHsv;
    HRRGBColor pixelRgb;
    for (int j = 0; j < pixelCountY; ++j) {
        height = verticalTileSize * j + _colorMapFrame.origin.y+kHRColorMapTilePadding; //compensation for cursor view
        // Y (chroma) is 0.0f ~ 1.0f
        float pixelY = (float)j/(pixelCountY-1); // Y(彩度)は0.0f~1.0f
        for (int i = 0; i < pixelCountX; ++i) {
//            (Hue) is to take the value of 0.0f ~ 0.95f 1.0f = 0.0f X so
            float pixelX = (float)i/pixelCountX; // X(色相)は1.0f=0.0fなので0.0f~0.95fの値をとるように
            HSVColorAt(&pixelHsv, pixelX, pixelY, _saturationUpperLimit, _currentHsvColor.v);
            RGBColorFromHSVColor(&pixelHsv, &pixelRgb);
            CGContextSetRGBFillColor(context, pixelRgb.r, pixelRgb.g, pixelRgb.b, 1.0f);
            
            CGRect tileFrame = CGRectMake(horizontalTileSize*i+_colorMapFrame.origin.x, height, horizontalTileSize, verticalTileSize);
            CGRect centeredFrame = CGRectZero;
            centeredFrame.size.width = tileSizeColored;
            centeredFrame.size.height = tileSizeColored;
            centeredFrame.origin.x = floorf(tileFrame.origin.x + (tileFrame.size.width - centeredFrame.size.width)/2);
            centeredFrame.origin.y = floorf(tileFrame.origin.y + (tileFrame.size.height - centeredFrame.size.height)/2);
            
            CGContextFillRect(context, centeredFrame);
        }
    }
    
    CGContextRestoreGState(context);
    
    /////////////////////////////////////////////////////////////////////////////
    //
    // カレントのカラー - The color of the current
    //
    /////////////////////////////////////////////////////////////////////////////
    if (self.style.headerHeight > 1) {
        CGContextSaveGState(context);
        HRDrawSquareColorBatch(context, CGPointMake(CGRectGetMidX(_currentColorFrame), CGRectGetMidY(_currentColorFrame)), &currentRgbColor, _currentColorFrame.size.width/2.0f);
        CGContextRestoreGState(context);
    }
    
    /////////////////////////////////////////////////////////////////////////////
    //
    // RGBのパーセント表示 Percentage of RGB - Text labels
    //
    /////////////////////////////////////////////////////////////////////////////
    
    if (self.style.headerHeight > 1) {
        [[UIColor darkGrayColor] set];
        
        if (_currentColorTextFrame.size.width > _currentColorTextFrame.size.height) {
            //horizontal
            CGFloat yPoint = _currentColorTextFrame.origin.y;
            CGFloat width = floorf((_currentColorTextFrame.size.width - 2*kHRColorMapTilePadding) / 3);
            NSString *red = [NSString stringWithFormat:@"R:%3d%%",(int)(currentRgbColor.r*100)];
            [red drawAtPoint:CGPointMake(_currentColorTextFrame.origin.x, yPoint) withFont:kHRColorLabelDefaultLabel];
            
            NSString *green = [NSString stringWithFormat:@"G:%3d%%",(int)(currentRgbColor.g*100)];
            [green drawAtPoint:CGPointMake(_currentColorTextFrame.origin.x + width + kHRColorMapTilePadding, yPoint)withFont:kHRColorLabelDefaultLabel];
            
            NSString *blue = [NSString stringWithFormat:@"B:%3d%%",(int)(currentRgbColor.b*100)];
            [blue drawAtPoint:CGPointMake(_currentColorTextFrame.origin.x + 2*width + 2*kHRColorMapTilePadding, yPoint) withFont:kHRColorLabelDefaultLabel ];
            
        } else {
            CGFloat yPoint = _currentColorFrame.origin.y;
            CGFloat width = floorf(_currentColorFrame.size.width);
            CGFloat height = floorf((_currentColorFrame.size.height - 2*kHRColorMapTilePadding)/3);
            NSString *red = [NSString stringWithFormat:@"R:%3d%%",(int)(currentRgbColor.r*100)];
            [red drawAtPoint:CGPointMake(_currentColorTextFrame.origin.x, yPoint) forWidth:width withFont:kHRColorLabelDefaultLabel lineBreakMode:NSLineBreakByClipping];
            
            NSString *green = [NSString stringWithFormat:@"G:%3d%%",(int)(currentRgbColor.g*100)];
            [green drawAtPoint:CGPointMake(_currentColorTextFrame.origin.x, yPoint + kHRColorMapTilePadding + height) forWidth:width withFont:kHRColorLabelDefaultLabel lineBreakMode:NSLineBreakByClipping];
            
            NSString *blue = [NSString stringWithFormat:@"B:%3d%%",(int)(currentRgbColor.b*100)];
            [blue drawAtPoint:CGPointMake(_currentColorTextFrame.origin.x, yPoint + 2*height + 2*kHRColorMapTilePadding) forWidth:width withFont:kHRColorLabelDefaultLabel lineBreakMode:NSLineBreakByClipping];
        }
    }
}
- (void)createCacheImage{
    // 影のコストは高いので、事前に画像に書き出しておきます
    //Because of the high cost of the shadow, I'll write the image to advance
    
    if (_brightnessPickerShadowImage != nil) {
        return;
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(_brightnessPickerShadowFrame.size.width,
                                                      _brightnessPickerShadowFrame.size.height),
                                           FALSE,
                                           [[UIScreen mainScreen] scale]);
    CGContextRef brightness_picker_shadow_context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(brightness_picker_shadow_context, 0, _brightnessPickerShadowFrame.size.height);
    CGContextScaleCTM(brightness_picker_shadow_context, 1.0, -1.0);
    
    HRSetRoundedRectanglePath(brightness_picker_shadow_context,
                              CGRectMake(0.0f, 0.0f,
                                         _brightnessPickerShadowFrame.size.width,
                                         _brightnessPickerShadowFrame.size.height), 5.0f);
    CGContextSetLineWidth(brightness_picker_shadow_context, 10.0f);
    CGContextSetShadow(brightness_picker_shadow_context, CGSizeMake(0.0f, 0.0f), 10.0f);
    CGContextDrawPath(brightness_picker_shadow_context, kCGPathStroke);
    
    _brightnessPickerShadowImage = CGBitmapContextCreateImage(brightness_picker_shadow_context);
    UIGraphicsEndImageContext();
}


/////////////////////////////////////////////////////////////////////////////
//
// 入力
//
/////////////////////////////////////////////////////////////////////////////

- (void)clearInput{
    _isTapStart = FALSE;
    _isTapped = FALSE;
    _isDragStart = FALSE;
	_isDragEnd = FALSE;
}

#pragma mark - Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([touches count] == 1) {
        UITouch* touch = [touches anyObject];
        [self setCurrentTouchPointInView:touch];
        _wasDragStart = TRUE;
        _isTapStart = TRUE;
        _touchStartPosition.x = _activeTouchPosition.x;
        _touchStartPosition.y = _activeTouchPosition.y;
        [self update];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch* touch = [touches anyObject];
    if ([touch tapCount] == 1) {
        _isDragging = TRUE;
        if (_wasDragStart) {
            _wasDragStart = FALSE;
            _isDragStart = TRUE;
        }
        [self setCurrentTouchPointInView:[touches anyObject]];
        [self update];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch* touch = [touches anyObject];
    
    if (_isDragging) {
        _isDragEnd = TRUE;
    }else{
        if ([touch tapCount] == 1) {
            _isTapped = TRUE;
        }
    }
    _isDragging = FALSE;
    [self setCurrentTouchPointInView:touch];
    [self update];
    [NSTimer scheduledTimerWithTimeInterval:1.0/20.0 target:self selector:@selector(setNeedsDisplay15FPS) userInfo:nil repeats:FALSE];
}

- (void)setCurrentTouchPointInView:(UITouch *)touch{
    CGPoint point;
	point = [touch locationInView:self];
    _activeTouchPosition.x = point.x;
    _activeTouchPosition.y = point.y;
}

#pragma mark - Memory
- (void)BeforeDealloc{
    // 何も実行しません
//    I do not do anything
}


- (void)dealloc{
    CGImageRelease(_brightnessPickerShadowImage);
}

@end
