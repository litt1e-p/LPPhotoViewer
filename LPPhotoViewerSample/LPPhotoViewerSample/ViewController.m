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
@property (nonatomic, strong) NSMutableArray *imageNames;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.urlArrays  = [[NSMutableArray alloc] init];
    self.imgArrays  = [[NSMutableArray alloc] init];
    self.imageNames = [[NSMutableArray alloc] init];
    [self.urlArrays addObject:@"https://d13yacurqjgara.cloudfront.net/users/3460/screenshots/1667332/pickle.png"];
    [self.urlArrays addObject:@"https://d13yacurqjgara.cloudfront.net/users/610286/screenshots/2012918/eggplant.png"];
    [self.urlArrays addObject:@"https://d13yacurqjgara.cloudfront.net/users/514774/screenshots/1985501/ill_2-01.png"];
    [self.imgArrays addObject:[UIImage imageNamed:@"carousel01"]];
    [self.imgArrays addObject:[UIImage imageNamed:@"carousel02"]];
    [self.imgArrays addObject:[UIImage imageNamed:@"carousel03"]];
    [self.imageNames addObject:@"I am image1"];
    [self.imageNames addObject:@"I am image2"];
    [self.imageNames addObject:@"I am image3"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self showPhotoBrowser:0];
}

- (void)showPhotoBrowser:(NSInteger)index
{
    LPPhotoViewer *pvc = [[LPPhotoViewer alloc]init];
    
    pvc.currentIndex = index;
    
    //UIImage type
//    pvc.imgArr = self.imgArrays;
    //image url type
    pvc.imgArr         = self.urlArrays;
    
    pvc.imageNameArray = self.imageNames;
    [self presentViewController:pvc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
