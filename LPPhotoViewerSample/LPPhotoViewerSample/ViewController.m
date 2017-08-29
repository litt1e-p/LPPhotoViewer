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

@property (nonatomic, strong) NSMutableArray *urlStrArrays;
@property (nonatomic, strong) NSMutableArray *urlArrays;
@property (nonatomic, strong) NSMutableArray *imgArrays;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    UIButton *btn             = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"I am rootView" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.frame                 = CGRectMake(0, 0, 200, 50);
    btn.center                = self.view.center;
    [self.view addSubview:btn];
    
    self.urlStrArrays = [[NSMutableArray alloc] init];
    self.urlArrays  = [[NSMutableArray alloc] init];
    self.imgArrays  = [[NSMutableArray alloc] init];
    
    [self.urlArrays addObject:[NSURL URLWithString:@"http://www.ratoo.net/uploads/allimg/130330/7-130330200347.gif"]];
    [self.urlArrays addObject:[NSURL URLWithString:@"https://drscdn.500px.org/photo/146512755/q=80_m=2000_k=1/62c584ed280fb11bbdb7d1c5451b6676"]];
    [self.urlArrays addObject:[NSURL URLWithString:@"https://drscdn.500px.org/photo/85567631/q%3D85_w%3D560_s%3D1/86ec6bbfc690723af5f2e40d8c832956"]];
    [self.urlArrays addObject:[NSURL URLWithString:@"https://drscdn.500px.org/photo/146441995/q=80_m=2000/0a6e687c0750ea05abf709bbd8c3d7f8"]];
    [self.urlArrays addObject:[NSURL URLWithString:@"https://drscdn.500px.org/photo/146409463/q=80_m=2000/9658bd373b7f84799dda05253d404a5d"]];
    [self.urlArrays addObject:[NSURL URLWithString:@"https://drscdn.500px.org/photo/42393810/q=80_m=2000/fed5ccbf106c289f62e5762df92f1438"]];
    
    [self.urlStrArrays addObject:@"http://www.ratoo.net/uploads/allimg/130330/7-130330200347.gif"];
    [self.urlStrArrays addObject:@"https://drscdn.500px.org/photo/146512755/q=80_m=2000_k=1/62c584ed280fb11bbdb7d1c5451b6676"];
    [self.urlStrArrays addObject:@"https://drscdn.500px.org/photo/85567631/q%3D85_w%3D560_s%3D1/86ec6bbfc690723af5f2e40d8c832956"];
    [self.urlStrArrays addObject:@"https://drscdn.500px.org/photo/146441995/q=80_m=2000/0a6e687c0750ea05abf709bbd8c3d7f8"];
    [self.urlStrArrays addObject:@"https://drscdn.500px.org/photo/146409463/q=80_m=2000/9658bd373b7f84799dda05253d404a5d"];
    [self.urlStrArrays addObject:@"https://drscdn.500px.org/photo/42393810/q=80_m=2000/fed5ccbf106c289f62e5762df92f1438"];
    
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
        pvc.imgArr         = self.urlStrArrays;
    //    pvc.imgArr         = self.urlArrays;
//    pvc.indicatorType = IndicatorTypePageControl;
//    pvc.indicatorType = IndicatorTypeNumLabel;
//    pvc.indicatorType = IndicatorTypeNone;
//    [self presentViewController:pvc animated:YES completion:nil];
    [pvc showFromViewController:self sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
