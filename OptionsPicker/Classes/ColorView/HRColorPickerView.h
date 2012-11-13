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
//some comments were translated by Google

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <sys/time.h>
#import "HRColorUtil.h"
#import "HRColorPickerMacros.h"


#define kHRColorTileSize 45.f
#define kHRColorMapSizeHorizontalCount 7
#define kHRColorMapSizeVerticalCount 6
#define kHRColorMapTilePadding 4
#define kHRColorMapMinimumTileSize 10.
#define kHRColorMapMaximumTileSize 120.

#define kHRColorLabelDefaultLabel [UIFont boldSystemFontOfSize:12.0f]

@class HRColorPickerView;

@protocol HRColorPickerViewDelegate
- (void)colorWasChanged:(HRColorPickerView*)color_picker_view;
@end

typedef struct timeval timeval;

struct HRColorPickerStyle{
// size of view with particular colorMapTileSize and element counts
    CGSize size;

// 明度スライダーを含むヘッダ部分の高さ(デフォルトは106.0f。70.0fくらいが下限になると思います)
//    (I think about 106.0f. 70.0f will be the lower limit is the default) the height of the header portion including a brightness slider
    float headerHeight;
    
// カラーマップの中のタイルのサイズ。デフォルトは15.0f;
//    The size of the tile in the color map. Default 15.0f;
    float colorMapTileSize;

// カラーマップの中にいくつのタイルが並ぶか (not view.width)。デフォルトは20;
//    I lined up a number of tiles in the color map (not view.width). The default is 20;
    int colorMapSizeHorizontalCount;
    
// 同じく縦にいくつ並ぶか。デフォルトは20;
//    Some or vertically aligned as well. The default is 20;
    int colorMapSizeVerticalCount;
// 明度の下限    
//    Lightness の lower limit
    float brightnessLowerLimit;
//    Maximum saturation の
    float saturationUpperLimit; // 彩度の上限
};

typedef struct HRColorPickerStyle HRColorPickerStyle;

@class HRBrightnessCursor;
@class HRColorCursor;

@interface HRColorPickerView : UIControl{
    NSObject<HRColorPickerViewDelegate>* __weak delegate;
 @private
    bool _animating;
    
    // 入力関係
//    Into the power relations
    bool _isTapStart;
    bool _isTapped;
	bool _wasDragStart;
    bool _isDragStart;
	bool _isDragging;
	bool _isDragEnd;
    
	CGPoint _activeTouchPosition;
	CGPoint _touchStartPosition;
    
    // 色情報
    HRRGBColor _defaultRgbColor;
    HRHSVColor _currentHsvColor;
    
    // カラーマップ上のカーソルの位置
//  Position of the cursor on the color map
    CGPoint _colorCursorPosition;
    
    // パーツの配置
//    Placing Parts
    CGRect _currentColorFrame;
    CGRect _currentColorTextFrame;
    CGRect _brightnessPickerFrame;
    CGRect _brightnessPickerTouchFrame;
    CGRect _brightnessPickerShadowFrame;
    CGRect _colorMapFrame;
    CGRect _colorMapSideFrame;
    float _tileSize;
    float _brightnessLowerLimit;
    float _saturationUpperLimit;
    
    HRBrightnessCursor* _brightnessCursor;
    HRColorCursor* _colorCursor;
    
    // キャッシュ
    CGImageRef _brightnessPickerShadowImage;
    
    // フレームレート
    timeval _lastDrawTime;
    timeval _timeInterval15fps;
    
    bool _delegateHasSELColorWasChanged;
}

// スタイルを取得
+ (HRColorPickerStyle)defaultStyle;
+ (HRColorPickerStyle)fullColorStyle;

+ (HRColorPickerStyle)fitScreenStyle; // iPhone5以降の縦長スクリーンに対応しています。
+ (HRColorPickerStyle)fitScreenFullColorStyle;

+ (HRColorPickerStyle) styleWithSize:(CGSize)defaultSize;

// スタイルからviewのサイズを取得
+ (HRColorPickerStyle)updateStyle:(HRColorPickerStyle)style forRect:(CGRect) bounds;

// スタイルを指定してデフォルトカラーで初期化
- (id)initWithStyle:(HRColorPickerStyle)style defaultColor:(const HRRGBColor)defaultColor frame:(CGRect)frame;

// デフォルトカラーで初期化 (互換性のために残していますが、frameが反映されません)
- (id)initWithFrame:(CGRect)frame defaultColor:(const HRRGBColor)defaultColor;

// 現在選択している色をRGBで返す
- (HRRGBColor)RGBColor;

// 後方互換性のため。呼び出す必要はありません。
- (void)BeforeDealloc; 

@property (getter = BrightnessLowerLimit, setter = setBrightnessLowerLimit:) float BrightnessLowerLimit;
@property (getter = SaturationUpperLimit, setter = setSaturationUpperLimit:) float SaturationUpperLimit;
@property (nonatomic, weak) NSObject<HRColorPickerViewDelegate>* delegate;

@end
