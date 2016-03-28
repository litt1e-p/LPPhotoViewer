//
//  ViewController.m
//  LPPhotoViewerSample
//
//  Created by litt1e-p on 16/3/26.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

#import "ViewController.h"
#import "LPPhotoViewer.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *urlArrays;
@property (nonatomic, strong) NSMutableArray *imgArrays;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.urlArrays  = [[NSMutableArray alloc] init];
    self.imgArrays  = [[NSMutableArray alloc] init];
    [self.urlArrays addObject:@"https://drscdn.500px.org/photo/42393810/q=80_m=2000/fed5ccbf106c289f62e5762df92f1438"];
    [self.urlArrays addObject:@"https://drscdn.500px.org/photo/146441995/q=80_m=2000/0a6e687c0750ea05abf709bbd8c3d7f8"];
    [self.urlArrays addObject:@"https://drscdn.500px.org/photo/146512755/q=80_m=2000_k=1/62c584ed280fb11bbdb7d1c5451b6676"];
    [self.urlArrays addObject:@"https://drscdn.500px.org/photo/146409463/q=80_m=2000/9658bd373b7f84799dda05253d404a5d"];
    
    [self.imgArrays addObject:[UIImage imageNamed:@"carousel01"]];
    [self.imgArrays addObject:[UIImage imageNamed:@"carousel02"]];
    [self.imgArrays addObject:[UIImage imageNamed:@"carousel03"]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self showPhotoBrowser:0];
}

- (void)showPhotoBrowser:(NSInteger)index
{
    LPPhotoViewer *pvc = [[LPPhotoViewer alloc] init];
    
    pvc.currentIndex = index;
    
    //UIImage type
//    pvc.imgArr = self.imgArrays;
    //image url type
    pvc.imgArr         = self.urlArrays;
//    pvc.indicatorType = IndicatorTypePageControl;
    pvc.indicatorType = IndicatorTypeNumLabel;
//    pvc.indicatorType = IndicatorTypeNone;
    [self presentViewController:pvc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
