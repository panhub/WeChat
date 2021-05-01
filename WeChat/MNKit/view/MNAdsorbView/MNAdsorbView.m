//
//  MNAdsorbView.m
//  MNKit
//
//  Created by Vincent on 2018/12/10.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNAdsorbView.h"

@interface MNAdsorbView ()
{
    CGFloat MNAdsorbViewLastOffsetY;
}
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) UIImageView *imageView;
@end

#define MNAdsorbViewObservePath     @"contentOffset"

@implementation MNAdsorbView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}

- (void)createView {
    UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self insertSubview:contentView atIndex:0];
    self.contentView = contentView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:contentView.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.contentScaleFactor = [[UIScreen mainScreen] scale];
    [contentView insertSubview:imageView atIndex:0];
    self.imageView = imageView;
}

#pragma mark - Super
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)newSuperview;
        if (![self observedScrollView:scrollView] && self.imageView) {
            self.imageView.autoresizingMask = UIViewAutoresizingNone;
            scrollView.alwaysBounceVertical = YES;
            [scrollView addObserver:self
                         forKeyPath:MNAdsorbViewObservePath
                            options:NSKeyValueObservingOptionNew
                            context:nil];
        }
    }
    [super willMoveToSuperview:newSuperview];
}

- (void)removeFromSuperview {
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)(self.superview);
        if ([self observedScrollView:scrollView]) {
            [scrollView removeObserver:self forKeyPath:MNAdsorbViewObservePath];
        }
    }
    [super removeFromSuperview];
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    self.imageView.contentMode = contentMode;
}

#pragma mark - observe
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (![keyPath isEqualToString:MNAdsorbViewObservePath]) return;
    UIScrollView *scrollView = (UIScrollView *)object;
    if (!scrollView) return;
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > 0.f) return;
    CGFloat changeH = MNAdsorbViewLastOffsetY - offsetY;
    MNAdsorbViewLastOffsetY = offsetY;
    CGRect frame = self.imageView.frame;
    frame.origin.y = offsetY;
    frame.size.height += changeH;
    self.imageView.frame = frame;
}

#pragma mark - 判断是否已经监听
- (BOOL)observedScrollView:(UIScrollView *)scrollView {
    id info = scrollView.observationInfo;
    NSArray *observances = [info valueForKey:@"_observances"];
    for (id objc in observances) {
        id observer = [objc valueForKeyPath:@"_observer"];
        if (![observer isEqual:self]) continue;
        id property = [objc valueForKeyPath:@"_property"];
        NSString *keyPath = [property valueForKeyPath:@"_keyPath"];
        if ([keyPath isEqualToString:MNAdsorbViewObservePath]) return YES;
    }
    return NO;
}

@end
