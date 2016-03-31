//
//  LPPhotoViewer.m
//  LPPhotoViewer
//
//  Created by litt1e-p on 16/3/27.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

#import "LPPhotoViewer.h"
#import "LPPhotoView.h"

@interface LPPhotoViewer () <UIScrollViewDelegate,PhotoViewDelegate>
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

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _subViewList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    kScreenHeight             = [UIScreen mainScreen].bounds.size.height;
    kScreenWidth              = [UIScreen mainScreen].bounds.size.width;
    
    [self initScrollView];
    if (self.indicatorType == IndicatorTypeNumLabel) {
        [self addLabel];
    } else if (self.indicatorType == IndicatorTypePageControl) {
        [self addPageControl];
    }
    [self setPicCurrentIndex:self.currentIndex];
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
    self.scrollView.minimumZoomScale               = 1;
    self.scrollView.maximumZoomScale               = 2;
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
    [self loadPhotoWithIndex:_currentIndex];
    [self loadPhotoWithIndex:_currentIndex + 1];
    [self loadPhotoWithIndex:_currentIndex - 1];
}

- (void)loadPhotoWithIndex:(NSInteger)index
{
    if (index < 0 || index >= self.imgArr.count) {
        return;
    }
    id currentPhotoView = [_subViewList objectAtIndex:index];
    if (![currentPhotoView isKindOfClass:[LPPhotoView class]]) {
        CGRect frame = CGRectMake(index * _scrollView.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        id obj       = [self.imgArr objectAtIndex:index];
        if ([obj isKindOfClass:[NSString class]]) {
            LPPhotoView *photoV = [[LPPhotoView alloc] initWithFrame:frame withPhotoUrl:obj];
            photoV.delegate     = self;
            photoV.disableHorizontalDrag =  (self.imgArr.count > 1);
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewList replaceObjectAtIndex:index withObject:photoV];
        } else if ([obj isKindOfClass:[UIImage class]]) {
            LPPhotoView *photoV = [[LPPhotoView alloc] initWithFrame:frame withPhotoImage:obj];
            photoV.delegate     = self;
            photoV.disableHorizontalDrag =  (self.imgArr.count > 1);
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewList replaceObjectAtIndex:index withObject:photoV];
        }
    }
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LPPhotoView class]]) {
            LPPhotoView *photoView = obj;
            [photoView zoomReset];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int i = scrollView.contentOffset.x / kScreenWidth + 1;
    if(i >= 1){
        [self loadPhotoWithIndex:i - 1];
        if (self.indicatorType == IndicatorTypeNumLabel) {
            self.indicatorLabel.text = [NSString stringWithFormat:@"%zi/%zi", i, self.imgArr.count];
        } else if (self.indicatorType == IndicatorTypePageControl) {
            self.pageControl.currentPage = i - 1;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
