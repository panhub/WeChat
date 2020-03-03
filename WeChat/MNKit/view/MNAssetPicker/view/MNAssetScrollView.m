//
//  MNAssetScrollView.m
//  MNFoundation
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
        self.backgroundColor = [UIColor clearColor];
        self.bouncesZoom = YES;
        self.maximumZoomScale = 3;
        self.alwaysBounceVertical = NO;
        self.userInteractionEnabled = YES;
        self.alwaysBounceHorizontal = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        [self adjustContentInset];
        
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:contentView];
        self.contentView = contentView;
    }
    return self;
}

#pragma mark - Setter
- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    self.alwaysBounceVertical = self.contentView.height_mn >= self.height_mn;
}

#pragma mark - Event
- (void)reset {
    [self setZoomScale:1.f animated:NO];
    [self scrollRectToVisible:self.bounds animated:NO];
    self.contentSize = self.bounds.size;
    self.contentView.frame = self.bounds;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width)*.5f : 0.f;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height)*.5f : 0.f;
    
    self.contentView.center = CGPointMake(scrollView.contentSize.width*.5f + offsetX,
                                                scrollView.contentSize.height*.5f + offsetY);
}

@end
