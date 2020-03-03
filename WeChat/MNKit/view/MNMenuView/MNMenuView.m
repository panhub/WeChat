//
//  MNMenuView.m
//  MNKit
//
//  Created by Vincent on 2019/4/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNMenuView.h"

@implementation MNMenuConfiguration

@end

@interface MNMenuView ()
/// 展开位置
@property (nonatomic) CGRect showRect;
/// 消失位置
@property (nonatomic) CGRect dismissRect;
/// 展示视图
@property (nonatomic, weak) UIView *displayView;
/// 可视部分
@property (nonatomic, weak) CALayer *maskLayer;
/// 配置信息
@property (nonatomic, strong) MNMenuConfiguration *configuration;
/// 按钮点击回调
@property (nonatomic, copy) MNMenuClickedHandler itemClickedHandler;
@end

@implementation MNMenuView
#pragma mark - Init
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:[[UIScreen mainScreen] bounds]]) {
        /// 动画视图
        UIView *displayView = [[UIView alloc] init];
        displayView.clipsToBounds = YES;
        [self addSubview:displayView];
        self.displayView = displayView;
    }
    return self;
}

+ (instancetype)menuWithAlignment:(MNMenuAlignment)alignment handler:(MNMenuClickedHandler)handler titles:(NSString *)title,...NS_REQUIRES_NIL_TERMINATION {
    if (!title) return nil;
    NSMutableArray <NSString *>*titles = [NSMutableArray arrayWithCapacity:0];
    [titles addObject:title];
    va_list args;
    va_start(args, title);
    while ((title = va_arg(args, NSString *))) {
        [titles addObject:title];
    }
    va_end(args);
    return [[self alloc] initWithTitles:titles.copy alignment:alignment handler:handler];
}

- (instancetype)initWithTitles:(NSArray <NSString *>*)titles alignment:(MNMenuAlignment)alignment handler:(MNMenuClickedHandler)handler {
    if (titles.count <= 0) return nil;
    UIFont *font = [UIFont systemFontOfSize:16.f];
    NSMutableArray <NSNumber *>*widths = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat w = [NSString getStringSize:obj font:font].width;
        [widths addObject:@(w)];
    }];
    CGFloat max = [[widths valueForKeyPath:@"@max.floatValue"] floatValue];
    max += (alignment == MNMenuAlignmentVertical ? 55.f : 20.f);
    CGFloat height = (alignment == MNMenuAlignmentVertical ? 45.f : 30.f);
    NSMutableArray <UIView *>*items = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = idx;
        button.frame = CGRectMake(0.f, 0.f, max, height);
        [button setTitle:obj forState:UIControlStateNormal];
        [button.titleLabel setFont:font];
        [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:.9f] forState:UIControlStateNormal];
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [button addTarget:self action:@selector(menuItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [items addObject:button];
        if (idx != titles.count - 1) {
            UIView *line = [UIView new];
            if (alignment == MNMenuAlignmentVertical) {
                line.frame = CGRectMake(10.f, button.height_mn - .5f, button.width_mn - 20.f, .5f);
            } else {
                line.frame = CGRectMake(button.width_mn - .5f, 10.f, .5f, button.height_mn - 20.f);
            }
            line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.2f];
            [button addSubview:line];
        }
    }];
    MNMenuView *menuView = [self initWithAlignment:alignment items:items.copy];
    menuView.itemClickedHandler = handler;
    return menuView;
}

+ (instancetype)menuWithAlignment:(MNMenuAlignment)alignment items:(UIView *)item,...NS_REQUIRES_NIL_TERMINATION {
    if (!item) return nil;
    NSMutableArray <UIView *>*items = [NSMutableArray arrayWithCapacity:0];
    [items addObject:item];
    va_list args;
    va_start(args, item);
    while ((item = va_arg(args, UIView *))) {
        [items addObject:item];
    }
    va_end(args);
    return [[self alloc] initWithAlignment:alignment items:items.copy];
}

- (instancetype)initWithAlignment:(MNMenuAlignment)alignment items:(NSArray <UIView *>*)items {
    if (items.count <= 0) return nil;
    /// 为了适应不同大小的size, 做两次遍历
    self = self.init;
    if (!self) return nil;
    NSMutableArray <NSNumber *>*widths = [NSMutableArray arrayWithCapacity:items.count];
    NSMutableArray <NSNumber *>*heights = [NSMutableArray arrayWithCapacity:items.count];
    [items enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [widths addObject:@(obj.width_mn)];
        [heights addObject:@(obj.height_mn)];
    }];
    UIView *contentView = [UIView new];
    if (alignment == MNMenuAlignmentVertical) {
        contentView.width_mn = [[widths valueForKeyPath:@"@max.floatValue"] floatValue];
    } else {
        contentView.height_mn = [[heights valueForKeyPath:@"@max.floatValue"] floatValue];
    }
    __block CGFloat mark = 0.f;
    [items enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (alignment == MNMenuAlignmentVertical) {
            obj.top_mn = mark;
            obj.centerX_mn = contentView.width_mn/2.f;
            mark = obj.bottom_mn;
        } else {
            obj.left_mn = mark;
            obj.centerY_mn = contentView.height_mn/2.f;
            mark = obj.right_mn;
        }
        [contentView addSubview:obj];
    }];
    if (alignment == MNMenuAlignmentVertical) {
        contentView.height_mn = mark;
    } else {
        contentView.width_mn = mark;
    }
    self.contentView = contentView;
    return self;
}

#pragma mark - 更新视图
- (void)updateIfNeeded {
    if (!_contentView || !_targetView) return;
    
    /// 先更新配置数据
    if (self.configurationHandler) {
        self.configurationHandler(self.configuration);
    }
    
    CGSize size = self.configuration.arrowSize;
    CGFloat radius = self.configuration.contentRadius;
    UIOffset offset = self.configuration.arrowOffset;
    UIEdgeInsets insets = self.configuration.contentInsets;
    
    _displayView.transform = CGAffineTransformIdentity;
    _displayView.anchorsite = CGPointMake(.5f, .5f);
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGPoint anchorPoint = _displayView.layer.anchorPoint;
    CGRect frame = [_targetView.superview convertRect:_targetView.frame toView:nil];
    
    switch (self.configuration.arrowDirection) {
        case MNMenuArrowUp:
        {
            insets.top -= size.height;
            _displayView.frame = UIEdgeInsetsInsetRect(_contentView.bounds, insets);
            _contentView.frame = UIEdgeInsetsInsetRect(_displayView.bounds, UIEdgeInsetReverse(insets));
            _displayView.top_mn = CGRectGetMaxY(frame) + offset.vertical;
            _displayView.centerX_mn = CGRectGetMidX(frame) - offset.horizontal;
            
            [bezierPath moveToPoint:CGPointMake(0.f, size.height + radius)];
            [bezierPath addArcWithCenter:CGPointMake(radius, size.height + radius) radius:radius startAngle:M_PI endAngle:(M_PI + M_PI_2) clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(MEAN(_displayView.width_mn) + offset.horizontal - MEAN(size.width) , size.height)];
            [bezierPath addLineToPoint:CGPointMake(MEAN(_displayView.width_mn) + offset.horizontal, 0.f)];
            [bezierPath addLineToPoint:CGPointMake(MEAN(_displayView.width_mn) + offset.horizontal + MEAN(size.width), size.height)];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - radius, size.height)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - radius, size.height + radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn, _displayView.height_mn - radius)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - radius, _displayView.height_mn - radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(radius, _displayView.height_mn)];
            [bezierPath addArcWithCenter:CGPointMake(radius, _displayView.height_mn - radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
            [bezierPath closePath];
            
            CGFloat x = (MEAN(_displayView.width_mn) + offset.horizontal)/_displayView.width_mn;
            anchorPoint = CGPointMake(x, 0.f);
            
        } break;
        case MNMenuArrowDown:
        {
            insets.bottom -= size.height;
            _displayView.frame = UIEdgeInsetsInsetRect(_contentView.bounds, insets);
            _contentView.frame = UIEdgeInsetsInsetRect(_displayView.bounds, UIEdgeInsetReverse(insets));
            _displayView.bottom_mn = CGRectGetMinY(frame) + offset.vertical;
            _displayView.centerX_mn = CGRectGetMidX(frame) - offset.horizontal;
            
            [bezierPath moveToPoint:CGPointMake(0.f, radius)];
            [bezierPath addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI endAngle:(M_PI + M_PI_2) clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - radius, 0.f)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn, _displayView.height_mn - size.height - radius)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - radius, _displayView.height_mn - size.height - radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(MEAN(_displayView.width_mn) + offset.horizontal + MEAN(size.width), _displayView.height_mn - size.height)];
            [bezierPath addLineToPoint:CGPointMake(MEAN(_displayView.width_mn) + offset.horizontal, _displayView.height_mn)];
            [bezierPath addLineToPoint:CGPointMake(MEAN(_displayView.width_mn) + offset.horizontal - MEAN(size.width), _displayView.height_mn - size.height)];
            [bezierPath addLineToPoint:CGPointMake(radius, _displayView.height_mn - size.height)];
            [bezierPath addArcWithCenter:CGPointMake(radius, _displayView.height_mn - size.height - radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
            [bezierPath closePath];
            
            CGFloat x = (MEAN(_displayView.width_mn) + offset.horizontal)/_displayView.width_mn;
            anchorPoint = CGPointMake(x, 1.f);
            
        } break;
        case MNMenuArrowLeft:
        {
            insets.left -= size.height;
            _displayView.frame = UIEdgeInsetsInsetRect(_contentView.bounds, insets);
            _contentView.frame = UIEdgeInsetsInsetRect(_displayView.bounds, UIEdgeInsetReverse(insets));
            _displayView.left_mn = CGRectGetMaxX(frame) + offset.horizontal;
            _displayView.centerY_mn = CGRectGetMidY(frame) - offset.vertical;
            
            [bezierPath moveToPoint:CGPointMake(size.height, radius)];
            [bezierPath addArcWithCenter:CGPointMake(size.height + radius, radius) radius:radius startAngle:M_PI endAngle:(M_PI + M_PI_2) clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - radius, 0.f)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn, _displayView.height_mn - radius)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - radius, _displayView.height_mn - radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(size.height + radius, _displayView.height_mn)];
            [bezierPath addArcWithCenter:CGPointMake(size.height + radius, _displayView.height_mn - radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(size.height, MEAN(_displayView.height_mn) + offset.vertical + MEAN(size.width))];
            [bezierPath addLineToPoint:CGPointMake(0.f, MEAN(_displayView.height_mn) + offset.vertical)];
            [bezierPath addLineToPoint:CGPointMake(size.height, MEAN(_displayView.height_mn) + offset.vertical - MEAN(size.width))];
            [bezierPath closePath];
            
            CGFloat y = (MEAN(_displayView.height_mn) + offset.vertical)/_displayView.height_mn;
            anchorPoint = CGPointMake(0.f, y);
            
        } break;
        default:
        {
            insets.right -= size.height;
            _displayView.frame = UIEdgeInsetsInsetRect(_contentView.bounds, insets);
            _contentView.frame = UIEdgeInsetsInsetRect(_displayView.bounds, UIEdgeInsetReverse(insets));
            _displayView.right_mn = CGRectGetMinX(frame) + offset.horizontal;
            _displayView.centerY_mn = CGRectGetMidY(frame) - offset.vertical;
            
            [bezierPath moveToPoint:CGPointMake(0.f, radius)];
            [bezierPath addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI endAngle:(M_PI + M_PI_2) clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - size.height - radius, 0.f)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - size.height - radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - size.height, MEAN(_displayView.height_mn) + offset.vertical - MEAN(size.width))];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn, MEAN(_displayView.height_mn) + offset.vertical)];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - size.height, MEAN(_displayView.height_mn) + offset.vertical + MEAN(size.width))];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - size.height, _displayView.height_mn - radius)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - size.height - radius, _displayView.height_mn - radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(radius, _displayView.height_mn)];
            [bezierPath addArcWithCenter:CGPointMake(radius, _displayView.height_mn - radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
            [bezierPath closePath];
            
            CGFloat y = (MEAN(_displayView.height_mn) + offset.vertical)/_displayView.height_mn;
            anchorPoint = CGPointMake(1.f, y);
            
        } break;
    }
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = bezierPath.CGPath;
    maskLayer.fillColor = [self.configuration.fillColor CGColor];
    maskLayer.strokeColor = [self.configuration.borderColor CGColor];
    maskLayer.lineWidth = self.configuration.borderWidth;
    if (_maskLayer) [_maskLayer removeFromSuperlayer];
    [_displayView.layer insertSublayer:maskLayer atIndex:0];
    _maskLayer = maskLayer;
    
    [_displayView addSubview:_contentView];
    
    _displayView.alpha = 1.f;
    
    if (self.configuration.animationType == MNMenuAnimationZoom) {
        _displayView.anchorsite = anchorPoint;
        if (!self.superview) _displayView.transform = CGAffineTransformMakeScale(0.f, 0.f);
    } else if (self.configuration.animationType == MNMenuAnimationFade) {
        _displayView.alpha = self.superview ? 1.f : 0.f;
    } else {
        _showRect = _displayView.frame;
        _dismissRect = _displayView.frame;
        switch (self.configuration.arrowDirection) {
            case MNMenuArrowUp:
            {
                _dismissRect.size.height = 0.f;
            } break;
            case MNMenuArrowDown:
            {
                _dismissRect.origin.y = _displayView.bottom_mn;
                _dismissRect.size.height = 0.f;
            } break;
            case MNMenuArrowLeft:
            {
                _dismissRect.size.width = 0.f;
            } break;
            default:
            {
                _dismissRect.origin.x = _displayView.right_mn;
                _dismissRect.size.width = 0.f;
            } break;
        }
        if (!self.superview) _displayView.frame = _dismissRect;
    }
}

#pragma mark - 显示与隐藏
- (void)show {
    [self showWithAnimated:YES];
}

- (void)showWithAnimated:(BOOL)animated {
    if (self.superview) return;
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    if (self.showHandler) {
        self.showHandler(_displayView, animated);
    } else {
        if (self.configuration.animationType == MNMenuAnimationZoom) {
            [UIView animateWithDuration:(animated ? self.configuration.animationDuration : 0.f) delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                _displayView.transform = CGAffineTransformIdentity;
            } completion:nil];
        } else if (self.configuration.animationType == MNMenuAnimationFade) {
            [UIView animateWithDuration:(animated ? self.configuration.animationDuration : 0.f) animations:^{
                _displayView.alpha = 1.f;
            }];
        } else {
            [UIView animateWithDuration:(animated ? self.configuration.animationDuration : 0.f) delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                _displayView.frame = _showRect;
            } completion:nil];
        }
    }
}

- (void)dismiss {
    [self dismissWithAnimated:YES];
}

- (void)dismissWithAnimated:(BOOL)animated {
    [self dismissWithClickedItem:nil animated:animated];
}

- (void)dismissWithClickedItem:(UIView *)item animated:(BOOL)animated {
    if (!self.superview) return;
    if (self.dismissHandler) {
        __weak typeof(self) weakself = self;
        self.dismissHandler(_displayView, animated, ^{
            [weakself removeFromSuperview];
            if (item && weakself.itemClickedHandler) {
                weakself.itemClickedHandler(weakself, item);
            }
        });
    } else {
        if (self.configuration.animationType == MNMenuAnimationZoom) {
            [UIView animateWithDuration:(animated ? self.configuration.animationDuration : 0.f) animations:^{
                _displayView.transform = CGAffineTransformMakeScale(.1f, .1f);
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if (item && self.itemClickedHandler) {
                    self.itemClickedHandler(self, item);
                }
            }];
        } else if (self.configuration.animationType == MNMenuAnimationFade) {
            [UIView animateWithDuration:(animated ? self.configuration.animationDuration : 0.f) animations:^{
                _displayView.alpha = 0.f;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if (item && self.itemClickedHandler) {
                    self.itemClickedHandler(self, item);
                }
            }];
        } else {
            [UIView animateWithDuration:(animated ? self.configuration.animationDuration : 0.f) delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                _displayView.frame = _dismissRect;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if (item && self.itemClickedHandler) {
                    self.itemClickedHandler(self, item);
                }
            }];
        }
    }
}

#pragma mark - 按钮点击
- (void)menuItemClicked:(UIView *)item {
    [self dismissWithClickedItem:item animated:YES];
}

#pragma mark - Setter&Getter
- (void)setContentView:(UIView *)contentView {
    if (!contentView) return;
    _contentView = contentView;
    [self updateIfNeeded];
}

- (void)setTargetView:(UIView *)targetView {
    if (!targetView) return;
    _targetView = targetView;
    [self updateIfNeeded];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.configuration.fillColor = backgroundColor;
}

- (void)setTintColor:(UIColor *)tintColor {
    self.configuration.fillColor = tintColor;
}

- (MNMenuConfiguration *)configuration {
    if (!_configuration) {
        MNMenuConfiguration *configuration = [MNMenuConfiguration new];
        configuration.borderWidth = 0.f;
        configuration.contentRadius = 5.f;
        configuration.animationDuration = .25f;
        configuration.arrowOffset = UIOffsetZero;
        configuration.arrowSize = CGSizeMake(12.f, 10.f);
        configuration.borderColor = UIColor.clearColor;
        configuration.arrowDirection = MNMenuArrowUp;
        configuration.animationType = MNMenuAnimationZoom;
        configuration.contentInsets = UIEdgeInsetsMake(-5.f, -5.f, -5.f, -5.f);
        configuration.fillColor = [UIColor colorWithRed:76.f/255.f green:76.f/255.f blue:76.f/255.f alpha:1.f];
        _configuration = configuration;
    }
    return _configuration;
}

- (UIColor *)backgroundColor {
    return self.configuration.fillColor;
}

- (UIColor *)tintColor {
    return self.configuration.fillColor;
}

#pragma mark - TouchesEnded
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

@end
