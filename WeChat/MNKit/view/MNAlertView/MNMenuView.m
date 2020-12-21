//
//  MNMenuView.m
//  MNKit
//
//  Created by Vincent on 2019/4/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNMenuView.h"
#import <objc/runtime.h>

const NSInteger MNMenuViewTag = 101010;

@implementation MNMenuConfiguration

@end

@interface MNMenuView ()
/// 展开位置
@property (nonatomic) CGRect displayRect;
/// 消失位置
@property (nonatomic) CGRect dismissRect;
/// 展示视图
@property (nonatomic, weak) UIView *displayView;
/// 可视部分
@property (nonatomic, weak) CALayer *maskLayer;
/// 标记是否展开
@property (nonatomic, getter=isExpanded) BOOL expanded;
/// 配置信息
@property (nonatomic, strong) MNMenuConfiguration *configuration;
@end

@implementation MNMenuView
#pragma mark - Init
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        /// 动画视图
        UIView *displayView = [[UIView alloc] init];
        displayView.clipsToBounds = YES;
        [self addSubview:displayView];
        self.displayView = displayView;
    }
    return self;
}

+ (instancetype)menuWithAlignment:(MNMenuAlignment)alignment createdHandler:(MNMenuCreatedHandler)createdHandler titles:(NSString *)title,...NS_REQUIRES_NIL_TERMINATION {
    if (!title) return nil;
    NSMutableArray <NSString *>*titles = [NSMutableArray arrayWithCapacity:0];
    [titles addObject:title];
    va_list args;
    va_start(args, title);
    while ((title = va_arg(args, NSString *))) {
        [titles addObject:title];
    }
    va_end(args);
    return [[self alloc] initWithTitles:titles.copy alignment:alignment createdHandler:createdHandler];
}

- (instancetype)initWithTitles:(NSArray <NSString *>*)titles alignment:(MNMenuAlignment)alignment createdHandler:(MNMenuCreatedHandler)createdHandler {
    if (titles.count <= 0) return nil;
    UIFont *font = [UIFont systemFontOfSize:15.f];
    NSMutableArray <NSNumber *>*widths = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat width = [obj sizeWithAttributes:@{NSFontAttributeName: font}].width;
        [widths addObject:@(width)];
    }];
    CGFloat width = [[widths valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat height = (alignment == MNMenuAlignmentVertical ? 48.f : 30.f);
    NSMutableArray <UIView *>*items = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = idx;
        button.frame = CGRectMake(0.f, 0.f, width, height);
        [button setTitle:obj forState:UIControlStateNormal];
        [button.titleLabel setFont:font];
        [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:.9f] forState:UIControlStateNormal];
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [items addObject:button];
        if (idx != titles.count - 1) {
            UIView *separator = UIView.new;
            if (alignment == MNMenuAlignmentVertical) {
                separator.frame = CGRectMake(0.f, button.height_mn - .5f, button.width_mn, .5f);
            } else {
                separator.frame = CGRectMake(button.width_mn - .5f, 15.f, .5f, button.height_mn - 30.f);
            }
            separator.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:.2f];
            [button addSubview:separator];
            button.separator = separator;
        }
        if (createdHandler) createdHandler(self, idx, button);
    }];
    MNMenuView *menuView = [self initWithAlignment:alignment items:items.copy];
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
        [widths addObject:@(obj.frame.size.width)];
        [heights addObject:@(obj.frame.size.height)];
    }];
    UIView *contentView = UIView.new;
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
        if ([obj isKindOfClass:UIControl.class] && ((UIControl *)obj).allTargets.count <= 0) {
            [((UIControl *)obj) addTarget:self action:@selector(menuButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
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
- (BOOL)updateIfNeeded {
    if (!_contentView || !_targetView || !self.superview) return NO;
    
    /// 先更新配置数据
    if (self.configurationHandler) {
        self.configurationHandler(self.configuration);
    }
    
    CGSize size = self.configuration.arrowSize;
    UIOffset offset = self.configuration.arrowOffset;
    CGFloat radius = self.configuration.contentRadius;
    CGFloat lineWidth = self.configuration.borderWidth;
    UIEdgeInsets insets = self.configuration.contentInsets;
    if (self.configuration.borderWidth > 0.f) {
        insets.left -= lineWidth;
        insets.right -= lineWidth;
        insets.top -= lineWidth;
        insets.bottom -= lineWidth;
    }
    
    _displayView.transform = CGAffineTransformIdentity;
    _displayView.anchorsite = CGPointMake(.5f, .5f);
    CGPoint anchorPoint = _displayView.layer.anchorPoint;
    CGRect frame = [_targetView.superview convertRect:_targetView.frame toView:self.superview];
    if (frame.size.width + frame.size.height <= 0.f) return NO;
    
    UIBezierPath *bezierPath = UIBezierPath.bezierPath;
    
    switch (self.configuration.arrowDirection) {
        case MNMenuArrowUp:
        {
            insets.top -= size.height;
            _displayView.frame = UIEdgeInsetsInsetRect(_contentView.bounds, insets);
            _contentView.frame = UIEdgeInsetsInsetRect(_displayView.bounds, UIEdgeInsetReverse(insets));
            _displayView.top_mn = CGRectGetMaxY(frame) + offset.vertical;
            _displayView.centerX_mn = CGRectGetMidX(frame) - offset.horizontal;
            
            [bezierPath moveToPoint:CGPointMake(lineWidth/2.f, size.height + lineWidth + radius)];
            [bezierPath addArcWithCenter:CGPointMake(radius + lineWidth, size.height + lineWidth + radius) radius:(radius + lineWidth/2.f) startAngle:M_PI endAngle:(M_PI + M_PI_2) clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn/2.f + offset.horizontal - size.width/2.f - lineWidth/2.f, size.height + lineWidth/2.f)];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn/2.f + offset.horizontal, lineWidth/2.f)];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn/2.f + offset.horizontal + size.width/2.f + lineWidth/2.f, size.height + lineWidth/2.f)];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - radius - lineWidth, size.height + lineWidth/2.f)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - radius - lineWidth, size.height + radius + lineWidth) radius:(radius + lineWidth/2.f) startAngle:-M_PI_2 endAngle:0 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - lineWidth/2.f, _displayView.height_mn - radius - lineWidth)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - radius - lineWidth, _displayView.height_mn - radius - lineWidth) radius:(radius + lineWidth/2.f) startAngle:0 endAngle:M_PI_2 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(radius + lineWidth, _displayView.height_mn - lineWidth/2.f)];
            [bezierPath addArcWithCenter:CGPointMake(radius + lineWidth, _displayView.height_mn - radius - lineWidth) radius:(radius + lineWidth/2.f) startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
            [bezierPath closePath];
            
            CGFloat x = (_displayView.width_mn/2.f + offset.horizontal)/_displayView.width_mn;
            anchorPoint = CGPointMake(x, 0.f);
            
        } break;
        case MNMenuArrowDown:
        {
            insets.bottom -= size.height;
            _displayView.frame = UIEdgeInsetsInsetRect(_contentView.bounds, insets);
            _contentView.frame = UIEdgeInsetsInsetRect(_displayView.bounds, UIEdgeInsetReverse(insets));
            _displayView.bottom_mn = CGRectGetMinY(frame) + offset.vertical;
            _displayView.centerX_mn = CGRectGetMidX(frame) - offset.horizontal;
            
            [bezierPath moveToPoint:CGPointMake(lineWidth/2.f, radius + lineWidth)];
            [bezierPath addArcWithCenter:CGPointMake(radius + lineWidth, radius + lineWidth) radius:(radius + lineWidth/2.f) startAngle:M_PI endAngle:(M_PI + M_PI_2) clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - radius - lineWidth, lineWidth/2.f)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - radius - lineWidth, radius + lineWidth) radius:(radius + lineWidth/2.f) startAngle:-M_PI_2 endAngle:0 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - lineWidth/2.f, _displayView.height_mn - size.height - radius - lineWidth)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - lineWidth - radius, _displayView.height_mn - size.height - radius - lineWidth) radius:(radius + lineWidth/2.f) startAngle:0 endAngle:M_PI_2 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn/2.f + offset.horizontal + size.width/2.f + lineWidth/2.f, _displayView.height_mn - size.height - lineWidth/2.f)];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn/2.f + offset.horizontal, _displayView.height_mn - lineWidth/2.f)];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn/2.f + offset.horizontal - size.width/2.f - lineWidth/2.f, _displayView.height_mn - size.height - lineWidth/2.f)];
            [bezierPath addLineToPoint:CGPointMake(radius + lineWidth, _displayView.height_mn - size.height - lineWidth/2.f)];
            [bezierPath addArcWithCenter:CGPointMake(radius + lineWidth, _displayView.height_mn - size.height - radius - lineWidth) radius:(radius + lineWidth/2.f) startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
            [bezierPath closePath];
            
            CGFloat x = (_displayView.width_mn/2.f + offset.horizontal)/_displayView.width_mn;
            anchorPoint = CGPointMake(x, 1.f);
            
        } break;
        case MNMenuArrowLeft:
        {
            insets.left -= size.height;
            _displayView.frame = UIEdgeInsetsInsetRect(_contentView.bounds, insets);
            _contentView.frame = UIEdgeInsetsInsetRect(_displayView.bounds, UIEdgeInsetReverse(insets));
            _displayView.left_mn = CGRectGetMaxX(frame) + offset.horizontal;
            _displayView.centerY_mn = CGRectGetMidY(frame) - offset.vertical;
            
            [bezierPath moveToPoint:CGPointMake(size.height + lineWidth/2.f, radius + lineWidth)];
            [bezierPath addArcWithCenter:CGPointMake(size.height + radius + lineWidth, radius + lineWidth) radius:(radius + lineWidth/2.f) startAngle:M_PI endAngle:(M_PI + M_PI_2) clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - radius - lineWidth, lineWidth/2.f)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - radius - lineWidth, radius + lineWidth) radius:(radius + lineWidth/2.f) startAngle:-M_PI_2 endAngle:0 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - lineWidth/2.f, _displayView.height_mn - radius - lineWidth)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - radius - lineWidth, _displayView.height_mn - radius - lineWidth) radius:(radius + lineWidth/2.f) startAngle:0.f endAngle:M_PI_2 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(size.height + radius + lineWidth, _displayView.height_mn - lineWidth/2.f)];
            [bezierPath addArcWithCenter:CGPointMake(size.height + radius + lineWidth, _displayView.height_mn - radius - lineWidth) radius:(radius + lineWidth/2.f) startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(size.height + lineWidth/2.f, _displayView.height_mn/2.f + offset.vertical + size.width/2.f + lineWidth/2.f)];
            [bezierPath addLineToPoint:CGPointMake(lineWidth/2.f, _displayView.height_mn/2.f + offset.vertical)];
            [bezierPath addLineToPoint:CGPointMake(size.height + lineWidth/2.f, _displayView.height_mn/2.f + offset.vertical - size.width/2.f - lineWidth/2.f)];
            [bezierPath closePath];
            
            CGFloat y = (_displayView.height_mn/2.f + offset.vertical)/_displayView.height_mn;
            anchorPoint = CGPointMake(0.f, y);
            
        } break;
        default:
        {
            insets.right -= size.height;
            _displayView.frame = UIEdgeInsetsInsetRect(_contentView.bounds, insets);
            _contentView.frame = UIEdgeInsetsInsetRect(_displayView.bounds, UIEdgeInsetReverse(insets));
            _displayView.right_mn = CGRectGetMinX(frame) + offset.horizontal;
            _displayView.centerY_mn = CGRectGetMidY(frame) - offset.vertical;
            
            [bezierPath moveToPoint:CGPointMake(lineWidth/2.f, radius + lineWidth)];
            [bezierPath addArcWithCenter:CGPointMake(radius + lineWidth, radius + lineWidth) radius:(radius + lineWidth/2.f) startAngle:M_PI endAngle:(M_PI + M_PI_2) clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - size.height - radius - lineWidth, lineWidth/2.f)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - size.height - radius - lineWidth, radius + lineWidth) radius:(radius + lineWidth/2.f) startAngle:-M_PI_2 endAngle:0 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - size.height - lineWidth/2.f, _displayView.height_mn/2.f + offset.vertical - size.width/2.f - lineWidth/2.f)];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - lineWidth/2.f, _displayView.height_mn/2.f + offset.vertical)];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - size.height - lineWidth/2.f, _displayView.height_mn/2.f + offset.vertical + size.width/2.f + lineWidth/2.f)];
            [bezierPath addLineToPoint:CGPointMake(_displayView.width_mn - size.height - lineWidth/2.f, _displayView.height_mn - radius - lineWidth)];
            [bezierPath addArcWithCenter:CGPointMake(_displayView.width_mn - size.height - radius - lineWidth, _displayView.height_mn - radius - lineWidth) radius:(radius + lineWidth/2.f) startAngle:0.f endAngle:M_PI_2 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(radius + lineWidth, _displayView.height_mn - lineWidth/2.f)];
            [bezierPath addArcWithCenter:CGPointMake(radius + lineWidth, _displayView.height_mn - radius - lineWidth) radius:(radius + lineWidth/2.f) startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
            [bezierPath closePath];
            
            CGFloat y = (_displayView.height_mn/2.f + offset.vertical)/_displayView.height_mn;
            anchorPoint = CGPointMake(1.f, y);
            
        } break;
    }
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = bezierPath.CGPath;
    maskLayer.fillColor = [self.configuration.fillColor CGColor];
    maskLayer.strokeColor = [self.configuration.borderColor CGColor];
    maskLayer.lineWidth = self.configuration.borderWidth;
    if (_maskLayer) [_maskLayer removeFromSuperlayer];
    [_displayView.layer insertSublayer:_maskLayer = maskLayer atIndex:0];
    
    _contentView.layer.cornerRadius = radius;
    _contentView.clipsToBounds = YES;
    [_displayView addSubview:_contentView];
    
    _displayView.alpha = 1.f;
    
    if (self.configuration.animationType == MNMenuAnimationZoom) {
        _displayView.anchorsite = anchorPoint;
        if (!self.isExpanded) _displayView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    } else if (self.configuration.animationType == MNMenuAnimationFade) {
        _displayView.alpha = self.isExpanded ? 1.f : 0.f;
    } else {
        _displayRect = _displayView.frame;
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
        if (!self.isExpanded) _displayView.frame = _dismissRect;
    }
    return YES;
}

#pragma mark - 显示与隐藏
- (void)show {
    [self showInView:nil animated:YES clickedHandler:nil];
}

- (void)showInView:(UIView *)superview {
    [self showInView:superview animated:YES clickedHandler:nil];
}

- (void)showWithAnimated:(BOOL)animated {
    [self showInView:nil animated:animated clickedHandler:nil];
}

- (void)showWithAnimated:(BOOL)animated clickedHandler:(MNMenuClickedHandler)clickedHandler {
    [self showInView:nil animated:animated clickedHandler:clickedHandler];
}

- (void)showInView:(UIView *)superview animated:(BOOL)animated
    clickedHandler:(MNMenuClickedHandler)clickedHandler
{
    if (self.superview) return;
    if (!superview) superview = [[[UIApplication sharedApplication] delegate] window];
    self.tag = MNMenuViewTag;
    self.frame = superview.bounds;
    [superview addSubview:self];
    if (![self updateIfNeeded]) {
        [self removeFromSuperview];
        return;
    }
    if (clickedHandler) self.clickedHandler = clickedHandler;
    if (self.showHandler) {
        self.showHandler(_displayView, animated);
    } else {
        if (self.configuration.animationType == MNMenuAnimationZoom) {
            [UIView animateWithDuration:(animated ? self.configuration.animationDuration : CGFLOAT_MIN) animations:^{
                self.displayView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.expanded = YES;
            }];
        } else if (self.configuration.animationType == MNMenuAnimationFade) {
            [UIView animateWithDuration:(animated ? self.configuration.animationDuration : CGFLOAT_MIN) animations:^{
                self.displayView.alpha = 1.f;
            } completion:^(BOOL finished) {
                self.expanded = YES;
            }];
        } else {
            [UIView animateWithDuration:(animated ? self.configuration.animationDuration : CGFLOAT_MIN) delay:0.f usingSpringWithDamping:1.f initialSpringVelocity:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.displayView.frame = self.displayRect;
            } completion:^(BOOL finished) {
                self.expanded = YES;
            }];
        }
    }
}

- (void)dismiss {
    [self dismissWithAnimated:YES];
}

- (void)dismissWithAnimated:(BOOL)animated {
    [self dismiss:nil animated:animated];
}

- (void)dismiss:(UIView *)item animated:(BOOL)animated {
    if (!self.superview) return;
    if (self.dismissHandler) {
        __weak typeof(self) weakself = self;
        self.dismissHandler(_displayView, animated, ^{
            [weakself removeFromSuperview];
            if (item && weakself.clickedHandler) {
                weakself.clickedHandler(weakself, item);
            }
        });
    } else {
        if (self.configuration.animationType == MNMenuAnimationZoom) {
            [UIView animateWithDuration:(animated ? self.configuration.animationDuration : CGFLOAT_MIN) animations:^{
                self.displayView.transform = CGAffineTransformMakeScale(.01f, .01f);
            } completion:^(BOOL finished) {
                self.expanded = NO;
                [self removeFromSuperview];
                if (item && self.clickedHandler) {
                    self.clickedHandler(self, item);
                }
            }];
        } else if (self.configuration.animationType == MNMenuAnimationFade) {
            [UIView animateWithDuration:(animated ? self.configuration.animationDuration : CGFLOAT_MIN) animations:^{
                self.displayView.alpha = 0.f;
            } completion:^(BOOL finished) {
                self.expanded = NO;
                [self removeFromSuperview];
                if (item && self.clickedHandler) {
                    self.clickedHandler(self, item);
                }
            }];
        } else {
            [UIView animateWithDuration:(animated ? self.configuration.animationDuration : CGFLOAT_MIN) delay:0.f usingSpringWithDamping:1.f initialSpringVelocity:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.displayView.frame = self.dismissRect;
            } completion:^(BOOL finished) {
                self.expanded = NO;
                [self removeFromSuperview];
                if (item && self.clickedHandler) {
                    self.clickedHandler(self, item);
                }
            }];
        }
    }
}

+ (void)close {
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    MNMenuView *menuView = [keyWindow viewWithTag:MNMenuViewTag];
    if (!menuView) return;
    menuView.showHandler = nil;
    menuView.dismissHandler = nil;
    menuView.clickedHandler = nil;
    menuView.configurationHandler = nil;
    [menuView removeFromSuperview];
}

+ (BOOL)isPresenting {
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    return [keyWindow viewWithTag:MNMenuViewTag] != nil;
}

#pragma mark - 按钮点击
- (void)menuButtonTouchUpInside:(UIView *)sender {
    [self dismiss:sender animated:YES];
}

#pragma mark - Setter&Getter
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
        configuration.contentRadius = 4.f;
        configuration.animationDuration = .27f;
        configuration.arrowOffset = UIOffsetZero;
        configuration.borderColor = UIColor.clearColor;
        configuration.arrowSize = CGSizeMake(12.f, 10.f);
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
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEstimatedPropertiesUpdated:(NSSet<UITouch *> *)touches {}
@end


@implementation UIButton (MNMenuSeparator)

- (void)setSeparator:(UIView *)separator {
    objc_setAssociatedObject(self, @"com.mn.menu.button.separator", separator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)separator {
    return objc_getAssociatedObject(self, @"com.mn.menu.button.separator");
}

@end
