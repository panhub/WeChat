//
//  MNAlbumSelectControl.m
//  MNKit
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAlbumSelectControl.h"

@interface MNAlbumSelectControl ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowView;
@end

@implementation MNAlbumSelectControl
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, 0.f, self.height_mn) text:@"未知相册" textColor:[UIColor darkTextColor] font:[UIFont systemFontOfSize:17.f]];
        [titleLabel sizeToFit];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.userInteractionEnabled = NO;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 15.f, 15.f) image:[[MNBundle imageForResource:@"icon_arrow_down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        arrowView.left_mn = titleLabel.width_mn + 3.f;
        arrowView.centerY_mn = self.height_mn/2.f;
        arrowView.tintColor = titleLabel.textColor;
        arrowView.userInteractionEnabled = NO;
        [self addSubview:arrowView];
        self.arrowView = arrowView;
        
        self.width_mn = arrowView.right_mn;
    }
    return self;
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame {
    frame.size.height = 20.f;
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [UIView animateWithDuration:.3f animations:^{
        self.arrowView.transform = selected ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
    }];
}

- (void)setTitle:(NSString *)title {
    if ([title isEqualToString:self.titleLabel.text]) return;
    CGFloat x = self.centerX_mn;
    CGFloat interval = self.arrowView.left_mn - self.titleLabel.width_mn;
    CGAffineTransform transform = self.arrowView.transform;
    self.arrowView.transform = CGAffineTransformIdentity;
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    if (self.arrowView.hidden) {
        self.width_mn = self.titleLabel.width_mn;
    } else {
        self.arrowView.left_mn = self.titleLabel.width_mn + interval;
        self.width_mn = self.arrowView.right_mn;
    }
    self.arrowView.transform = transform;
    self.centerX_mn = x;
}

- (void)setSelectEnabled:(BOOL)selectEnabled {
    if (selectEnabled != self.arrowView.hidden) return;
    if (selectEnabled) {
        CGFloat x = self.centerX_mn;
        CGAffineTransform transform = self.arrowView.transform;
        self.arrowView.transform = CGAffineTransformIdentity;
        self.arrowView.left_mn = self.titleLabel.width_mn + 3.f;
        self.width_mn = self.arrowView.right_mn;
        self.arrowView.hidden = NO;
        self.arrowView.transform = transform;
        self.centerX_mn = x;
    } else {
        CGFloat x = self.centerX_mn;
        self.arrowView.hidden = YES;
        self.width_mn = self.titleLabel.width_mn;
        self.centerX_mn = x;
    }
}

@end
