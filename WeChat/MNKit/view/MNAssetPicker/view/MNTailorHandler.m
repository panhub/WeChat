//
//  MNTailorHandler.m
//  MNKit
//
//  Created by Vicent on 2020/8/10.
//

#import "MNTailorHandler.h"
#import "UIView+MNLayout.h"

typedef NS_ENUM(NSInteger, MNTailorHandlerStatus) {
    MNTailorHandlerStatusNone = 0,
    MNTailorHandlerStatusLeft,
    MNTailorHandlerStatusRight
};

const CGFloat MNTailorHandlerAnimationDuration = .2f;

@interface MNTailorHandler ()
/**滑动状态*/
@property (nonatomic) MNTailorHandlerStatus status;
/**左滑手*/
@property (nonatomic, strong) UIView *leftHandler;
/**右滑手*/
@property (nonatomic, strong) UIView *rightHandler;
/**顶部分割线*/
@property (nonatomic, strong) UIView *topSeparator;
/**底部分割线*/
@property (nonatomic, strong) UIView *bottomSeparator;
/**左滑手正常层*/
@property (nonatomic, strong) CALayer *leftHandlerNormalLayer;
/**左滑手高亮层*/
@property (nonatomic, strong) CALayer *leftHandlerHighlightedLayer;
/**右滑手正常层*/
@property (nonatomic, strong) CALayer *rightHandlerNormalLayer;
/**右滑手高亮层*/
@property (nonatomic, strong) CALayer *rightHandlerHighlightedLayer;
@end

@implementation MNTailorHandler

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.lineWidth = 3.f;
        self.pathColor = UIColor.whiteColor;
        self.normalColor = UIColor.blackColor;
        self.highlightedColor = UIColor.whiteColor;
        self.backgroundColor = UIColor.clearColor;
        self.borderInset = UIEdgeInsetsMake(3.3f, 22.f, 3.3f, 22.f);
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (!self.superview || self.subviews.count) return;
    [self reloadSubviews];
}

- (void)reloadSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat lineWidth = self.lineWidth;
    UIEdgeInsets borderInset = self.borderInset;
    
    UIView *leftHandler = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, borderInset.left, self.height_mn)];
    leftHandler.backgroundColor = self.normalColor;
    [self addSubview:leftHandler];
    self.leftHandler = leftHandler;
    
    UIBezierPath *leftHandlerPath = UIBezierPath.bezierPath;
    [leftHandlerPath moveToPoint:CGPointMake(leftHandler.width_mn/2.f, leftHandler.height_mn/4.f + lineWidth/2.f)];
    [leftHandlerPath addLineToPoint:CGPointMake(leftHandler.width_mn/2.f - lineWidth, leftHandler.height_mn/2.f)];
    [leftHandlerPath addLineToPoint:CGPointMake(leftHandler.width_mn/2.f, leftHandler.height_mn/4.f*3.f - lineWidth/2.f)];
    
    CAShapeLayer *leftHandlerNormalLayer = CAShapeLayer.layer;
    leftHandlerNormalLayer.path = leftHandlerPath.CGPath;
    leftHandlerNormalLayer.lineWidth = lineWidth;
    leftHandlerNormalLayer.strokeColor = self.pathColor.CGColor;
    leftHandlerNormalLayer.fillColor = UIColor.clearColor.CGColor;
    leftHandlerNormalLayer.lineCap = kCALineCapRound;
    leftHandlerNormalLayer.lineJoin = kCALineJoinRound;
    [leftHandler.layer addSublayer:leftHandlerNormalLayer];
    self.leftHandlerNormalLayer = leftHandlerNormalLayer;
    
    CAShapeLayer *leftHandlerHighlightedLayer = CAShapeLayer.layer;
    leftHandlerHighlightedLayer.opacity = 0.f;
    leftHandlerHighlightedLayer.path = leftHandlerPath.CGPath;
    leftHandlerHighlightedLayer.lineWidth = lineWidth;
    leftHandlerHighlightedLayer.strokeColor = self.normalColor.CGColor;
    leftHandlerHighlightedLayer.fillColor = UIColor.clearColor.CGColor;
    leftHandlerHighlightedLayer.lineCap = kCALineCapRound;
    leftHandlerHighlightedLayer.lineJoin = kCALineJoinRound;
    [leftHandler.layer addSublayer:leftHandlerHighlightedLayer];
    self.leftHandlerHighlightedLayer = leftHandlerHighlightedLayer;
    
    UIView *rightHandler = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, borderInset.right, self.height_mn)];
    rightHandler.right_mn = self.width_mn;
    rightHandler.backgroundColor = self.normalColor;
    [self addSubview:rightHandler];
    self.rightHandler = rightHandler;
    
    UIBezierPath *rightHandlerPath = UIBezierPath.bezierPath;
    [rightHandlerPath moveToPoint:CGPointMake(rightHandler.width_mn/2.f, rightHandler.height_mn/4.f + lineWidth/2.f)];
    [rightHandlerPath addLineToPoint:CGPointMake(rightHandler.width_mn/2.f + lineWidth, rightHandler.height_mn/2.f)];
    [rightHandlerPath addLineToPoint:CGPointMake(rightHandler.width_mn/2.f, rightHandler.height_mn/4.f*3.f - lineWidth/2.f)];
    
    CAShapeLayer *rightHandlerNormalLayer = CAShapeLayer.layer;
    rightHandlerNormalLayer.path = rightHandlerPath.CGPath;
    rightHandlerNormalLayer.lineWidth = lineWidth;
    rightHandlerNormalLayer.strokeColor = self.pathColor.CGColor;
    rightHandlerNormalLayer.fillColor = UIColor.clearColor.CGColor;
    rightHandlerNormalLayer.lineCap = kCALineCapRound;
    rightHandlerNormalLayer.lineJoin = kCALineJoinRound;
    [rightHandler.layer addSublayer:rightHandlerNormalLayer];
    self.rightHandlerNormalLayer = rightHandlerNormalLayer;
    
    CAShapeLayer *rightHandlerHighlightedLayer = CAShapeLayer.layer;
    rightHandlerHighlightedLayer.opacity = 0.f;
    rightHandlerHighlightedLayer.path = rightHandlerPath.CGPath;
    rightHandlerHighlightedLayer.lineWidth = lineWidth;
    rightHandlerHighlightedLayer.strokeColor = self.normalColor.CGColor;
    rightHandlerHighlightedLayer.fillColor = UIColor.clearColor.CGColor;
    rightHandlerHighlightedLayer.lineCap = kCALineCapRound;
    rightHandlerHighlightedLayer.lineJoin = kCALineJoinRound;
    [rightHandler.layer addSublayer:rightHandlerHighlightedLayer];
    self.rightHandlerHighlightedLayer = rightHandlerHighlightedLayer;
    
    UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(borderInset.left, 0.f, self.width_mn - borderInset.left - borderInset.right, borderInset.top)];
    topSeparator.userInteractionEnabled = NO;
    topSeparator.backgroundColor = self.normalColor;
    [self addSubview:topSeparator];
    self.topSeparator = topSeparator;
    
    UIView *bottomSeparator = [[UIView alloc] initWithFrame:topSeparator.frame];
    bottomSeparator.height_mn = borderInset.bottom;
    bottomSeparator.bottom_mn = self.height_mn;
    bottomSeparator.userInteractionEnabled = NO;
    bottomSeparator.backgroundColor = self.normalColor;
    [self addSubview:bottomSeparator];
    self.bottomSeparator = bottomSeparator;
    
    [self setHandlerRadius:self.handlerRadius];
}

- (void)inspectHighlightedAnimated:(BOOL)animated {
    BOOL isNormal = fabs(self.leftHandler.left_mn) <= .1f && fabs(self.width_mn - self.rightHandler.right_mn) <= .1f;
    if (isNormal) {
        self.leftHandler.left_mn = 0.f;
        self.rightHandler.right_mn = self.width_mn;
        self.topSeparator.left_mn = self.bottomSeparator.left_mn = self.leftHandler.right_mn;
        self.topSeparator.width_mn = self.bottomSeparator.width_mn = self.rightHandler.left_mn - self.leftHandler.right_mn;
    }
    if (isNormal == self.isHighlighted) [self setHighlighted:!isNormal animated:animated];
}

#pragma mark - Setter
- (void)setHighlighted:(BOOL)highlighted {
    [self setHighlighted:highlighted animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted == _highlighted) return;
    _highlighted = highlighted;
    [CATransaction begin];
    [CATransaction setDisableActions:!animated];
    [CATransaction setAnimationDuration:(animated ? MNTailorHandlerAnimationDuration : CGFLOAT_MIN)];
    self.leftHandlerNormalLayer.opacity = self.rightHandlerNormalLayer.opacity = highlighted ? 0.f : 1.f;
    self.leftHandlerHighlightedLayer.opacity = self.rightHandlerHighlightedLayer.opacity = highlighted ? 1.f : 0.f;
    [CATransaction commit];
    [UIView animateWithDuration:(animated ? MNTailorHandlerAnimationDuration : CGFLOAT_MIN) animations:^{
        self.leftHandler.backgroundColor = self.rightHandler.backgroundColor = self.topSeparator.backgroundColor = self.bottomSeparator.backgroundColor = highlighted ? self.highlightedColor : self.normalColor;
    }];
}

- (void)setHandlerRadius:(CGFloat)handlerRadius {
    _handlerRadius = handlerRadius;
    if (self.subviews.count <= 0) return;
    [self.leftHandler.layer setMaskRadius:handlerRadius byCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft];
    [self.rightHandler.layer setMaskRadius:handlerRadius byCorners:UIRectCornerTopRight|UIRectCornerBottomRight];
}

#pragma mark - Getter
- (BOOL)isDragging {
    return self.status != MNTailorHandlerStatusNone;
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:self];
    CGRect leftRect = UIEdgeInsetsInsetRect(self.leftHandler.frame, self.handlerTouchInset);
    CGRect rightRect = UIEdgeInsetsInsetRect(self.rightHandler.frame, self.handlerTouchInset);
    if (CGRectContainsPoint(leftRect, point)) {
        self.status = MNTailorHandlerStatusLeft;
        if ([self.delegate respondsToSelector:@selector(tailorLeftHandlerBeginDragging:)]) {
            [self.delegate tailorLeftHandlerBeginDragging:self];
        }
    } else if (CGRectContainsPoint(rightRect, point)) {
        self.status = MNTailorHandlerStatusRight;
        if ([self.delegate respondsToSelector:@selector(tailorRightHandlerBeginDragging:)]) {
            [self.delegate tailorRightHandlerBeginDragging:self];
        }
    } else {
        self.status = MNTailorHandlerStatusNone;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.status == MNTailorHandlerStatusNone) return;
    UITouch *touche = touches.anyObject;
    CGPoint location = [touche locationInView:self];
    CGPoint previous = [touche previousLocationInView:self];
    CGFloat transition = location.x - previous.x;
    if (self.status == MNTailorHandlerStatusLeft) {
        self.leftHandler.left_mn += transition;
        self.leftHandler.left_mn = MAX(self.leftHandler.left_mn, 0.f);
        self.leftHandler.right_mn = MIN(self.leftHandler.right_mn, self.rightHandler.left_mn - self.minHandlerInterval);
    } else if (self.status == MNTailorHandlerStatusRight) {
        self.rightHandler.left_mn += transition;
        self.rightHandler.right_mn = MIN(self.rightHandler.right_mn, self.width_mn);
        self.rightHandler.left_mn = MAX(self.rightHandler.left_mn, self.leftHandler.right_mn + self.minHandlerInterval);
    }
    self.topSeparator.left_mn = self.bottomSeparator.left_mn = self.leftHandler.right_mn;
    self.topSeparator.width_mn = self.bottomSeparator.width_mn = self.rightHandler.left_mn - self.leftHandler.right_mn;
    if (self.status == MNTailorHandlerStatusLeft) {
        if ([self.delegate respondsToSelector:@selector(tailorLeftHandlerDidDragging:)]) {
            [self.delegate tailorLeftHandlerDidDragging:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(tailorRightHandlerDidDragging:)]) {
            [self.delegate tailorRightHandlerDidDragging:self];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.status == MNTailorHandlerStatusNone) return;
    if (self.status == MNTailorHandlerStatusLeft) {
        if ([self.delegate respondsToSelector:@selector(tailorLeftHandlerEndDragging:)]) {
            [self.delegate tailorLeftHandlerEndDragging:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(tailorRightHandlerEndDragging:)]) {
            [self.delegate tailorRightHandlerEndDragging:self];
        }
    }
    self.status = MNTailorHandlerStatusNone;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.status = MNTailorHandlerStatusNone;
}

#pragma mark - Super
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return (CGRectContainsPoint(UIEdgeInsetsInsetRect(self.leftHandler.frame, self.handlerTouchInset), point) || CGRectContainsPoint(UIEdgeInsetsInsetRect(self.rightHandler.frame, self.handlerTouchInset), point));
}

@end
