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

#import "LPPhotoViewer.h"
#import "LPPhotoView.h"
#import "LPPVTransition.h"
#import "YYWebImage.h"

@interface LPPhotoViewer () <UIScrollViewDelegate, PhotoViewDelegate, UIViewControllerTransitioningDelegate>
{
    NSMutableArray *_subViewList;
    CGFloat kScreenWidth;
    CGFloat kScreenHeight;
}

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UILabel *indicatorLabel;
@property(nonatomic, strong) UIPageControl *pageControl;

@end

@implementation LPPhotoViewer

- (instancetype)init
{
    if (self = [super init]) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _subViewList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setPicCurrentIndex:self.currentIndex];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self clearImageCache];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self clearImageCache];
    [self reducePhotoSubViewsIfNeed];
}

-(void)clearImageCache
{
    [[YYWebImageManager sharedManager].cache.memoryCache removeAllObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:0.f alpha:1.f];
    kScreenHeight             = [UIScreen mainScreen].bounds.size.height;
    kScreenWidth              = [UIScreen mainScreen].bounds.size.width;
    
    [self initScrollView];
    if (self.indicatorType == IndicatorTypeNumLabel) {
        [self addLabel];
    } else if (self.indicatorType == IndicatorTypePageControl) {
        [self addPageControl];
    }
    [YYWebImageManager sharedManager].cache.memoryCache.costLimit = 80 * 1024 * 1024;
    [YYWebImageManager sharedManager].cache.diskCache.costLimit = 500 * 1024 * 1024;
}

- (void)initScrollView
{
    self.scrollView                                = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.scrollView.pagingEnabled                  = YES;
    self.scrollView.userInteractionEnabled         = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize                    = CGSizeMake(self.imgArr.count * kScreenWidth, kScreenHeight);
    self.scrollView.delegate                       = self;
    self.scrollView.contentOffset                  = CGPointMake(0, 0);
    [self.view addSubview:self.scrollView];
    
    for (int i = 0; i < self.imgArr.count; i++) {
        [_subViewList addObject:[NSNull class]];
    }
}

- (void)addLabel
{
    UILabel *indicatorLabel        = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 30, kScreenWidth, 30)];
    indicatorLabel.backgroundColor = [UIColor clearColor];
    indicatorLabel.textColor       = [UIColor whiteColor];
    indicatorLabel.textAlignment   = NSTextAlignmentCenter;
    indicatorLabel.text            = [NSString stringWithFormat:@"%zi/%zi", self.currentIndex + 1, self.imgArr.count];
    [self.view addSubview:indicatorLabel];
    self.indicatorLabel            = indicatorLabel;
}

- (void)addPageControl
{
    if (self.imgArr.count <= 0) {
        return;
    }
    UIPageControl *pc = [[UIPageControl alloc] init];
    pc.numberOfPages  = self.imgArr.count;
    CGSize size       = [pc sizeForNumberOfPages:self.imgArr.count];
    pc.frame          = CGRectMake(kScreenWidth / 2 - size.width / 2, kScreenHeight - size.height, size.width, size.height);
    [self.view addSubview:pc];
    self.pageControl  = pc;
}

- (void)setPicCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex                 = currentIndex;
    self.scrollView.contentOffset = CGPointMake(kScreenWidth * currentIndex, 0);
    [self updateIndicatorAt:currentIndex];
    [self loadPhotoWithIndex:_currentIndex];
    [self loadPhotoWithIndex:_currentIndex + 1];
    [self loadPhotoWithIndex:_currentIndex - 1];
}

- (void)loadPhotoWithIndex:(NSInteger)index
{
    if (index < 0 || index >= self.imgArr.count) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoViewWillShow:)]) {
        [self.delegate photoViewWillShow:index];
    }
    id currentPhotoView = [_subViewList objectAtIndex:index];
    if (![currentPhotoView isKindOfClass:[LPPhotoView class]]) {
        CGRect frame = CGRectMake(index * _scrollView.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        id obj       = [self.imgArr objectAtIndex:index];
        if ([obj isKindOfClass:[NSString class]]) {
            LPPhotoView *photoV = [[LPPhotoView alloc] initWithFrame:frame withPhotoUrlStr:obj];
            photoV.delegate     = self;
            photoV.disableHorizontalDrag =  (self.imgArr.count > 1);
            photoV.tag = index;
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewList replaceObjectAtIndex:index withObject:photoV];
        } else if ([obj isKindOfClass:[UIImage class]]) {
            LPPhotoView *photoV = [[LPPhotoView alloc] initWithFrame:frame withPhotoImage:obj];
            photoV.delegate     = self;
            photoV.disableHorizontalDrag =  (self.imgArr.count > 1);
            photoV.tag = index;
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewList replaceObjectAtIndex:index withObject:photoV];
        } else if ([obj isKindOfClass:[NSURL class]]) {
            LPPhotoView *photoV = [[LPPhotoView alloc] initWithFrame:frame withPhotoUrl:obj];
            photoV.delegate     = self;
            photoV.disableHorizontalDrag =  (self.imgArr.count > 1);
            photoV.tag = index;
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewList replaceObjectAtIndex:index withObject:photoV];
        } else {
            NSAssert(YES, @"unsupport type of photoViewer");
        }
    } else {
        [currentPhotoView resumeImageLoadWithPhoto:[self.imgArr objectAtIndex:index]];
    }
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LPPhotoView class]]) {
            LPPhotoView *photoView = obj;
            [photoView zoomReset];
        }
    }];
//    [self reducePhotoSubViewsIfNeed];
}

- (void)reducePhotoSubViewsIfNeed
{
    NSMutableArray *targetTags = [NSMutableArray array];
    NSUInteger index = self.scrollView.contentOffset.x / kScreenWidth + 1;
    [_subViewList enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LPPhotoView class]]) {
            LPPhotoView *view = (LPPhotoView *)obj;
            NSUInteger position = (index - idx);
            if (position > 10) {
                [targetTags addObject:@(view.tag)];
            }
        }
    }];
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LPPhotoView class]]) {
            LPPhotoView *view = (LPPhotoView *)obj;
            [targetTags enumerateObjectsUsingBlock:^(id  _Nonnull tag, NSUInteger idx, BOOL * _Nonnull stop) {
                NSInteger t = [tag integerValue];
                if (view.tag == t) {
                    [view cancelImageLoad];
                }
            }];
        }
    }];
}

#pragma mark - PhotoViewDelegate
- (void)tapHiddenPhotoView
{
    [self dragToDismiss];
}

- (void)dragToDismiss
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoViewWillClose:)]) {
        int i = self.scrollView.contentOffset.x / kScreenWidth + 1;
        [self.delegate photoViewWillClose:i - 1];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)offsetYForDrag:(CGFloat)offsetY
{
    self.view.backgroundColor = [UIColor colorWithWhite:0.f alpha:offsetY];
}

- (void)photoWithLongPress:(UIImage *)image
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoViewDidLongPress:)]) {
        [self.delegate photoViewDidLongPress:image];
    }
}

#pragma mark - transition delegate 📌
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [LPPVTransition transitionWithTargetVc:self transitionType:LPPVTransitionTypePresent];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [LPPVTransition transitionWithTargetVc:self transitionType:LPPVTransitionTypeDismiss];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int i = scrollView.contentOffset.x / kScreenWidth + 1;
    if(i >= 1){
        [self loadPhotoWithIndex:i - 1];
        [self updateIndicatorAt:i - 1];
    }
}

- (void)updateIndicatorAt:(NSInteger)index
{
    if (self.indicatorType == IndicatorTypeNumLabel) {
        self.indicatorLabel.text = [NSString stringWithFormat:@"%zi/%zi", index + 1, self.imgArr.count];
    } else if (self.indicatorType == IndicatorTypePageControl) {
        self.pageControl.currentPage = index;
    }
}

#pragma mark - showFromViewController 📌
- (void)showFromViewController:(UIViewController *)vc sender:(id)sender
{
    [vc presentViewController:self animated:YES completion:nil];
}

@end
