//
//  LPPhotoViewer.m
//  LPPhotoViewer
//
//  Created by litt1e-p on 16/3/27.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

#import "LPPhotoViewer.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "LPPhotoView.h"

@interface LPPhotoViewer () <UIScrollViewDelegate,PhotoViewDelegate>
{
    CGFloat lastScale;
    MBProgressHUD *HUD;
    NSMutableArray *_subViewList;
    CGFloat screen_width;
    CGFloat screen_height;
}
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
    lastScale                 = 1.0;
    self.view.backgroundColor = [UIColor blackColor];
    screen_height             = [UIScreen mainScreen].bounds.size.height;
    screen_width              = [UIScreen mainScreen].bounds.size.width;
    
    [self initScrollView];
    [self addLabel];
    [self addImgDescLabel];
    [self setPicCurrentIndex:self.currentIndex];
}

- (void)initScrollView
{
    self.scrollView                                = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
    self.scrollView.pagingEnabled                  = YES;
    self.scrollView.userInteractionEnabled         = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize                    = CGSizeMake(self.imgArr.count * screen_width, screen_height);
    self.scrollView.delegate                       = self;
    self.scrollView.contentOffset                  = CGPointMake(0, 0);
    self.scrollView.minimumZoomScale               = 1;
    self.scrollView.maximumZoomScale               = 2;
    [self.view addSubview:self.scrollView];
    
    for (int i = 0; i < self.imgArr.count; i++) {
        [_subViewList addObject:[NSNull class]];
    }
    
    for (int i = 0; i < self.imageNameArray.count; i++) {
        [_subViewList addObject:[NSNull class]];
    }
}

- (void)addLabel
{
    self.indicatorLabel                 = [[UILabel alloc] initWithFrame:CGRectMake(screen_width / 2 - 20, 44, 60, 30)];
    self.indicatorLabel.backgroundColor = [UIColor clearColor];
    self.indicatorLabel.textColor       = [UIColor whiteColor];
    self.indicatorLabel.text            = [NSString stringWithFormat:@"%ld/%lu",self.currentIndex + 1,(unsigned long)self.imgArr.count];
    [self.view addSubview:self.indicatorLabel];
}

- (void)addImgDescLabel
{
    self.descLabel                 = [[UILabel alloc] initWithFrame:CGRectMake(screen_width / 2 - 40, screen_height / 2 + 240, 200, 60)];
    self.descLabel.backgroundColor = [UIColor clearColor];
    self.descLabel.textColor       = [UIColor whiteColor];
    self.descLabel.text            = self.imageNameArray.count > 0 ? self.imageNameArray[self.currentIndex] : @"";
    [self.view addSubview:self.descLabel];
}

- (void)setPicCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex                 = currentIndex;
    self.scrollView.contentOffset = CGPointMake(screen_width * currentIndex, 0);
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
        CGRect frame = CGRectMake(index*_scrollView.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        id obj       = [self.imgArr objectAtIndex:index];
        if ([obj isKindOfClass:[NSString class]]) {
            LPPhotoView *photoV = [[LPPhotoView alloc] initWithFrame:frame withPhotoUrl:obj];
            photoV.delegate     = self;
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewList replaceObjectAtIndex:index withObject:photoV];
        } else if ([obj isKindOfClass:[UIImage class]]) {
            LPPhotoView *photoV = [[LPPhotoView alloc] initWithFrame:frame withPhotoImage:obj];
            photoV.delegate     = self;
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewList replaceObjectAtIndex:index withObject:photoV];
        }
    }
}

#pragma mark - PhotoViewDelegate
- (void)tapHiddenPhotoView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int i = scrollView.contentOffset.x/screen_width + 1;
    if(i >= 1){
        [self loadPhotoWithIndex:i - 1];
        self.indicatorLabel.text = [NSString stringWithFormat:@"%d/%lu", i, (unsigned long)self.imgArr.count];
        self.descLabel.text = self.imageNameArray[i - 1];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
