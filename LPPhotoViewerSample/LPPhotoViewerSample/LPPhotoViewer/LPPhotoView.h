// The MIT License (MIT)
//
// Copyright (c) 2017-2020 litt1e-p ( https://github.com/litt1e-p )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <UIKit/UIKit.h>

@protocol PhotoViewDelegate <NSObject>

- (void)tapHiddenPhotoView;
- (void)dragToDismiss;
@optional
- (void)offsetYForDrag:(CGFloat)offsetY;
- (void)photoWithLongPress:(id)image;

@end

@interface LPPhotoView : UIView

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, assign) id<PhotoViewDelegate> delegate;
@property (nonatomic, getter=shouldDisableHorizontalDrag) BOOL disableHorizontalDrag;

- (instancetype)initWithFrame:(CGRect)frame withPhotoUrlStr:(NSString *)photoUrlStr;
- (instancetype)initWithFrame:(CGRect)frame withPhotoImage:(UIImage *)image;
- (instancetype)initWithFrame:(CGRect)frame withPhotoUrl:(NSURL *)photoUrl;
- (void)zoomReset;
- (void)cancelImageLoad;
- (void)resumeImageLoadWithPhoto:(id)photo;

@end
