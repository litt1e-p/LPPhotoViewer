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

#import "LPPhotoView.h"
#import "YYWebImage.h"
#import "UIView+Indicator.h"

@interface LPPhotoView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *imgAttatchment;
@property (nonatomic, strong) UIPanGestureRecognizer *panGr;

@end

@implementation LPPhotoView

- (instancetype)initWithFrame:(CGRect)frame withPhotoUrl:(NSURL *)photoUrl
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedScrollViewInit];
        [self sharedImageViewInit:photoUrl];
        [self sharedGestureInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withPhotoImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedScrollViewInit];
        self.imageView = [[YYAnimatedImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageView setImage:image];
        [self.imageView setUserInteractionEnabled:YES];
        [_scrollView addSubview:self.imageView];
        [self sharedGestureInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withPhotoUrlStr:(NSString *)photoUrlStr
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedScrollViewInit];
        [self sharedImageViewInit:[NSURL URLWithString:photoUrlStr]];
        [self sharedGestureInit];
    }
    return self;
}

- (void)sharedScrollViewInit
{
    _scrollView                                = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate                       = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator   = NO;
    _scrollView.decelerationRate               = UIScrollViewDecelerationRateFast;
    _scrollView.autoresizingMask               = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_scrollView];
}

- (void)sharedImageViewInit:(NSURL *)photoUrl
{
    NSAssert([photoUrl isKindOfClass:[NSURL class]], @"type of photoUrl must be NSURL or URL");
    [[YYWebImageManager sharedManager].cache.memoryCache removeAllObjects];
    self.imageView             = [[YYAnimatedImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self loadImage:photoUrl];
    [self.imageView setUserInteractionEnabled:YES];
    [_scrollView addSubview:self.imageView];
}

- (void)loadImage:(NSURL *)photoUrl
{
    [self.imageView lp_setShowActivityIndicatorView:YES];
    [self.imageView lp_setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.imageView yy_setImageWithURL:photoUrl placeholder:nil options:YYWebImageOptionProgressiveBlur|YYWebImageOptionSetImageWithFadeAnimation progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (from == YYWebImageFromDiskCache) {
//            NSLog(@"from disk");
        }
        [self.imageView lp_removeActivityIndicator];
    }];
}

- (void)cancelImageLoad
{
    [self.imageView yy_cancelCurrentImageRequest];
    self.imageView.image = nil;
}

- (void)resumeImageLoadWithPhoto:(id)photo
{
    if (self.imageView.image) {
        return;
    }
    if ([photo isKindOfClass:[NSString class]]) {
        [self loadImage:[NSURL URLWithString:photo]];
    } else if ([photo isKindOfClass:[NSURL class]]) {
        [self loadImage:photo];
    } else if ([photo isKindOfClass:[UIImage class]]) {
        self.imageView.image = photo;
    }
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGSize imageSize  = self.imageView.frame.size;
    CGFloat xScale    = boundsSize.width / imageSize.width;
    CGFloat yScale    = boundsSize.height / imageSize.height;
    CGFloat minScale  = MIN(xScale, yScale);
    CGFloat maxScale  = 16.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
        if (maxScale < minScale) {
            maxScale = minScale * 2;
        }
    }
    self.scrollView.maximumZoomScale = maxScale;
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.zoomScale = minScale;
}

- (void)sharedGestureInit
{
    UITapGestureRecognizer *singleTap    = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap    = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _panGr                               = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragEvent:)];
    singleTap.numberOfTapsRequired       = 1;
    singleTap.numberOfTouchesRequired    = 1;
    doubleTap.numberOfTapsRequired       = 2;
    twoFingerTap.numberOfTouchesRequired = 2;
    longPress.numberOfTouchesRequired    = 1;
    
    [self.imageView addGestureRecognizer:singleTap];
    [self.imageView addGestureRecognizer:doubleTap];
    [self.imageView addGestureRecognizer:twoFingerTap];
    [self.imageView addGestureRecognizer:_panGr];
    [self.imageView addGestureRecognizer:longPress];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:_scrollView];
    [self setMaxMinZoomScalesForCurrentBounds];
}

- (void)setDisableHorizontalDrag:(BOOL)disableHorizontalDrag
{
    _disableHorizontalDrag = disableHorizontalDrag;
    if (disableHorizontalDrag) {
        _panGr.delegate = self;
    }
}

#pragma mark - Gesture Recognizer Delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:_scrollView];
    return fabs(velocity.y) > fabs(velocity.x);
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self.animator removeAllBehaviors];
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents
{
    CGSize boundsSize    = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.imageView.frame = contentsFrame;
    }];
}

#pragma mark - tap event
- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.numberOfTapsRequired == 1) {
        [self.delegate tapHiddenPhotoView];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.numberOfTapsRequired == 2) {
        if(_scrollView.zoomScale == _scrollView.minimumZoomScale){
            float newScale  = _scrollView.maximumZoomScale;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [_scrollView zoomToRect:zoomRect animated:YES];
        }else{
            float newScale  = _scrollView.minimumZoomScale;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [_scrollView zoomToRect:zoomRect animated:YES];
        }
    }
}

- (void)handleTwoFingerTap:(UITapGestureRecognizer *)gestureRecongnizer
{
    float newScale  = [_scrollView zoomScale] / 2;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecongnizer locationInView:gestureRecongnizer.view]];
    [_scrollView zoomToRect:zoomRect animated:YES];
}

- (void)handleLongPress: (UILongPressGestureRecognizer *)gestureRecongnizer
{
    if (gestureRecongnizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoWithLongPress:)] && self.imageView.image) {
        id imageItem = [self.imageView.image yy_imageDataRepresentation];
        YYImageType type = YYImageDetectType((__bridge CFDataRef)(imageItem));
        if (type != YYImageTypePNG && type != YYImageTypeJPEG && type != YYImageTypeGIF) {
            imageItem = self.imageView.image;
        }
        [self.delegate photoWithLongPress:imageItem];
    }
}

#pragma mark - dragEvent
- (void)dragEvent:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.animator removeAllBehaviors];
        
        CGPoint location = [recognizer locationInView:self.scrollView];
        CGPoint imgLocation = [recognizer locationInView:self.imageView];
        
        UIOffset centerOffset = UIOffsetMake(imgLocation.x - CGRectGetMidX(self.imageView.bounds),
                                             imgLocation.y - CGRectGetMidY(self.imageView.bounds));
        self.imgAttatchment = [[UIAttachmentBehavior alloc] initWithItem:self.imageView offsetFromCenter:centerOffset attachedToAnchor:location];
        [self.animator addBehavior:self.imgAttatchment];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint ancPoint = [recognizer locationInView:self.scrollView];
        [self.imgAttatchment setAnchorPoint:ancPoint];
        CGFloat halfH = self.scrollView.bounds.size.height * 0.5f;
        [self offsetDragNofify: 1.f - fabs(ancPoint.y - halfH) / halfH];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [recognizer locationInView:self.scrollView];
        CGRect closeTopThreshhold = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height * .25);
        CGRect closeBottomThreshhold = CGRectMake(0, self.bounds.size.height - closeTopThreshhold.size.height, self.bounds.size.width, self.bounds.size.height * .25);
        if (CGRectContainsPoint(closeTopThreshhold, location) || CGRectContainsPoint(closeBottomThreshhold, location)) {
            [self.animator removeAllBehaviors];
            self.imageView.userInteractionEnabled = NO;
            self.scrollView.userInteractionEnabled = NO;
            
            UIGravityBehavior *exitGravity = [[UIGravityBehavior alloc] initWithItems:@[self.imageView]];
            if (CGRectContainsPoint(closeTopThreshhold, location)) {
                exitGravity.gravityDirection = CGVectorMake(0.0, -1.0);
            }
            exitGravity.magnitude = 15.0f;
            [self.animator addBehavior:exitGravity];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissNotify];
                [self offsetDragNofify: 0.f];
            });
        } else {
            [self zoomReset];
            UISnapBehavior *snapBack = [[UISnapBehavior alloc] initWithItem:self.imageView snapToPoint:self.scrollView.center];
            snapBack.damping = 0.2;
            [self.animator addBehavior:snapBack];
            [self offsetDragNofify: 1.f];
        }
    }
}

- (void)zoomReset
{
    CGRect zoomRect = [self zoomRectForScale:self.scrollView.minimumZoomScale withCenter:self.scrollView.center];
    [_scrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark - zoomRectForScale
- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = _scrollView.frame.size.height / scale;
    zoomRect.size.width  = _scrollView.frame.size.width / scale;
    zoomRect.origin.x    = center.x - zoomRect.size.width / 2;
    zoomRect.origin.y    = center.y - zoomRect.size.height / 2;
    return zoomRect;
}

- (void)dismissNotify
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dragToDismiss)]) {
        [self.delegate dragToDismiss];
    }
}

- (void)offsetDragNofify:(CGFloat)offsetY
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(offsetYForDrag:)]) {
        [self.delegate offsetYForDrag:offsetY];
    }
}

@end
