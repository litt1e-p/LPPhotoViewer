//
//  UIView+Indicator.m
//  LPPhotoViewerSample
//
//  Created by litt1e-p on 2017/8/29.
//  Copyright © 2017年 litt1e-p. All rights reserved.
//

#import "UIView+Indicator.h"
#import "objc/runtime.h"

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

static char TAG_ACTIVITY_INDICATOR;
static char TAG_ACTIVITY_STYLE;
static char TAG_ACTIVITY_SHOW;

@implementation UIView (Indicator)

- (UIActivityIndicatorView *)activityIndicator
{
    return (UIActivityIndicatorView *)objc_getAssociatedObject(self, &TAG_ACTIVITY_INDICATOR);
}

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator
{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_INDICATOR, activityIndicator, OBJC_ASSOCIATION_RETAIN);
}

- (void)lp_setShowActivityIndicatorView:(BOOL)show
{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_SHOW, @(show), OBJC_ASSOCIATION_RETAIN);
    [self lp_addActivityIndicator];
}

- (BOOL)lp_showActivityIndicatorView
{
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_SHOW) boolValue];
}

- (void)lp_setIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_STYLE, [NSNumber numberWithInt:style], OBJC_ASSOCIATION_RETAIN);
}

- (int)lp_getIndicatorStyle
{
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_STYLE) intValue];
}

- (void)lp_addActivityIndicator
{
    dispatch_main_async_safe(^{
        if (!self.activityIndicator) {
            self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:[self lp_getIndicatorStyle]];
            self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
            
            [self addSubview:self.activityIndicator];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0.0]];
        }
        [self.activityIndicator startAnimating];
    });
}

- (void)lp_removeActivityIndicator
{
    dispatch_main_async_safe(^{
        if (self.activityIndicator) {
            [self.activityIndicator removeFromSuperview];
            self.activityIndicator = nil;
        }
    });
}

@end
