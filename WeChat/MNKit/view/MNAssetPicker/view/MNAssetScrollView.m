//
//  MNAssetScrollView.m
//  MNKit
//
//  Created by Vincent on 2019/9/10.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNAssetScrollView.h"

@interface MNAssetScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *contentView;

@end

@implementation MNAssetScrollView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.bouncesZoom = YES;
        self.maximumZoomScale = 3;
        self.alwaysBounceVertical = NO;
        self.userInteractionEnabled = YES;
        self.alwaysBounceHorizontal = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.backgroundColor = UIColor.clearColor;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        if (@available(iOS 11.0, *)) {
            if ([self respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
                /**这种情况下adjustContentInset值不受SafeAreaInset(安全区域)值的影响 adjustedContentInset = contentInset*/
                self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
#endif
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        contentView.backgroundColor = UIColor.clearColor;
        [self addSubview:contentView];
        self.contentView = contentView;
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
    (scrollView.bounds.size.width - scrollView.contentSize.width)/2.f : 0.f;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height)/2.f : 0.f;
    
    self.contentView.center = CGPointMake(scrollView.contentSize.width/2.f + offsetX,
                                                scrollView.contentSize.height/2.f + offsetY);
}

@end
