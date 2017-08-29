//
//  UIView+Indicator.h
//  LPPhotoViewerSample
//
//  Created by litt1e-p on 2017/8/29.
//  Copyright © 2017年 litt1e-p. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Indicator)

/**
 *  Show activity UIActivityIndicatorView
 */
- (void)lp_setShowActivityIndicatorView:(BOOL)show;

/**
 *  set desired UIActivityIndicatorViewStyle
 *
 *  @param style The style of the UIActivityIndicatorView
 */
- (void)lp_setIndicatorStyle:(UIActivityIndicatorViewStyle)style;

- (BOOL)lp_showActivityIndicatorView;
- (void)lp_addActivityIndicator;
- (void)lp_removeActivityIndicator;

@end
