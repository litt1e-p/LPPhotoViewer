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

#import "LPPVTransition.h"

@interface LPPVTransition ()

@property (nonatomic, weak) UIViewController *targetVc;

@end

@implementation LPPVTransition

static NSString * const kLPPVTransitionErr = @"__FAILED_LPPVTRANSITION__";

+ (instancetype)transitionWithTargetVc:(UIViewController *)vc transitionType:(LPPVTransitionType)type
{
    
    LPPVTransition *trans = [[self alloc] initWithTransitionType:type];
    trans.targetVc = vc;
    return trans;
}

- (instancetype)initWithTransitionType:(LPPVTransitionType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    switch (_type) {
        case LPPVTransitionTypePresent:
            [self presentAnimation:transitionContext];
            break;
            
        case LPPVTransitionTypeDismiss:
            [self dismissAnimation:transitionContext];
            break;
    }
}

- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.targetVc.view.alpha = 1.0;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.targetVc.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        BOOL wasCancel = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancel];
        if (wasCancel) {
            self.targetVc.view.alpha = 1.0;
            NSLog(kLPPVTransitionErr);
        } else {
            [self.targetVc.view removeFromSuperview];
        }
    }];
}

- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:self.targetVc.view];
    self.targetVc.view.alpha = 0.0;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.targetVc.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        BOOL wasCancel = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancel];
        if (wasCancel) {
            NSLog(kLPPVTransitionErr);
        }
    }];
}

@end
