//
//  LPPhotoView.m
//  LPPhotoViewer
//
//  Created by litt1e-p on 16/3/27.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

#import "LPPhotoView.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface LPPhotoView ()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    MBProgressHUD *hud;
}

@end

@implementation LPPhotoView

- (instancetype)initWithFrame:(CGRect)frame withPhotoUrl:(NSString *)photoUrl
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView                                = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate                       = self;
        _scrollView.minimumZoomScale               = 1;
        _scrollView.maximumZoomScale               = 3;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator   = NO;
        [self addSubview:_scrollView];
        self.imageView             = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        BOOL isCached              = [manager cachedImageExistsForURL:[NSURL URLWithString:photoUrl]];
        if (!isCached) {
            hud      = [MBProgressHUD showHUDAddedTo:self animated:YES];
            hud.mode = MBProgressHUDModeDeterminate;
        }
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){
            hud.progress = ((float)receivedSize)/expectedSize;
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (!isCached) {
                [hud hide:YES];
            }
        }];
        
        [self.imageView setUserInteractionEnabled:YES];
        [_scrollView addSubview:self.imageView];
        
        UITapGestureRecognizer *singleTap    = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        UITapGestureRecognizer *doubleTap    = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
        singleTap.numberOfTapsRequired       = 1;
        singleTap.numberOfTouchesRequired    = 1;
        doubleTap.numberOfTapsRequired       = 2;
        twoFingerTap.numberOfTouchesRequired = 2;
        
        [self.imageView addGestureRecognizer:singleTap];
        [self.imageView addGestureRecognizer:doubleTap];
        [self.imageView addGestureRecognizer:twoFingerTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [_scrollView setZoomScale:1];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withPhotoImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView                                = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate                       = self;
        _scrollView.minimumZoomScale               = 1;
        _scrollView.maximumZoomScale               = 3;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator   = NO;
        [self addSubview:_scrollView];
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageView setImage:image];
        [self.imageView setUserInteractionEnabled:YES];
        [_scrollView addSubview:self.imageView];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
        
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        doubleTap.numberOfTapsRequired = 2;
        twoFingerTap.numberOfTouchesRequired = 2;
        
        [self.imageView addGestureRecognizer:singleTap];
        [self.imageView addGestureRecognizer:doubleTap];
        [self.imageView addGestureRecognizer:twoFingerTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [_scrollView setZoomScale:1];
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [scrollView setZoomScale:scale + 0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
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
        if(_scrollView.zoomScale == 1){
            float newScale  = [_scrollView zoomScale] * 2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [_scrollView zoomToRect:zoomRect animated:YES];
        }else{
            float newScale  = [_scrollView zoomScale] / 2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [_scrollView zoomToRect:zoomRect animated:YES];
        }
    }
}

- (void)handleTwoFingerTap:(UITapGestureRecognizer *)gestureRecongnizer
{
    float newScale  = [_scrollView zoomScale]/2;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecongnizer locationInView:gestureRecongnizer.view]];
    [_scrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark - zoomRectForScale
- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = [_scrollView frame].size.height/scale;
    zoomRect.size.width  = [_scrollView frame].size.width/scale;
    zoomRect.origin.x    = center.x - zoomRect.size.width/2;
    zoomRect.origin.y    = center.y - zoomRect.size.height/2;
    return zoomRect;
}

@end
