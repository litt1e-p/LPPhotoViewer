//
//  LPPhotoViewer.h
//  LPPhotoViewer
//
//  Created by litt1e-p on 16/3/27.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPPhotoViewer : UIViewController

@property(nonatomic,strong) NSMutableArray  *imageNameArray;

/**
 *  array of UIImage or image urls
 */
@property(nonatomic, strong) NSMutableArray *imgArr;

@property(nonatomic, strong) UIScrollView *scrollView;

@property(nonatomic, strong) UILabel *indicatorLabel;

@property(nonatomic, strong) UILabel *descLabel;

@property(nonatomic, assign) NSInteger currentIndex;

@end
