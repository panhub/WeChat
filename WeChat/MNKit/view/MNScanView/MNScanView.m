//
//  MNScanView.m
//  MNKit
//
//  Created by Vincent on 2018/7/4.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNScanView.h"

@interface MNScanView ()
/**是否在扫描*/
@property (nonatomic) BOOL scanning;
/**扫描区域宽高*/
@property (nonatomic) CGSize scanSize;
/**扫描区域x坐标(默认根据宽高居中)*/
@property (nonatomic) CGFloat scanAreaX;
/**扫描区域y坐标(默认根据宽高居中)*/
@property (nonatomic) CGFloat scanAreaY;
/**扫描线*/
@property (nonatomic, strong) UIImageView *scanningLine;
@end

@implementation MNScanView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap:)];
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)initialized {
    _scanning = NO;
    _borderWidth = .7f;
    _cornerSize = CGSizeMake(2.f, 15.f);
    _scanSize = CGSizeMake(self.frame.size.width/3.f*2.2f, self.frame.size.width/3.f*2.2f);
    _scanAreaX = MEAN(self.width_mn - _scanSize.width);
    _scanAreaY = MEAN(self.height_mn - _scanSize.height);
    _scanRect = (CGRect){_scanAreaX, _scanAreaY, _scanSize};
    _borderColor = [[UIColor whiteColor] colorWithAlphaComponent:.7f];
    _cornerColor = _borderColor;
}

- (void)setScanRect:(CGRect)scanRect {
    if (CGRectEqualToRect(_scanRect, scanRect)) return;
    _scanRect = scanRect;
    _scanAreaX = scanRect.origin.x;
    _scanAreaY = scanRect.origin.y;
    _scanSize = scanRect.size;
}

- (void)drawRect:(CGRect)rect {
    
    if (CGSizeEqualToSize(_scanRect.size, CGSizeZero)) return;
    
    //镂空
    [[UIColor clearColor] setFill];
    UIRectFill(_scanRect);
    
    //边框
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextSetLineWidth(context, _borderWidth);
    CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
    CGContextAddRect(context, CGRectMake(_scanAreaX - MEAN(_borderWidth), _scanAreaY - MEAN(_borderWidth), _scanSize.width + _borderWidth, _scanSize.height + _borderWidth));
    CGContextStrokePath(context);
    
    //边角
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextSetLineWidth(context, _cornerSize.width);
    CGContextSetStrokeColorWithColor(context, _cornerColor.CGColor);
    //左上
    CGContextMoveToPoint(context, _scanAreaX + _cornerSize.width/2.f, _scanAreaY + _cornerSize.height);
    CGContextAddLineToPoint(context, _scanAreaX + _cornerSize.width/2.f, _scanAreaY);
    CGContextMoveToPoint(context, _scanAreaX, _scanAreaY + _cornerSize.width/2.f);
    CGContextAddLineToPoint(context, _scanAreaX + _cornerSize.height, _scanAreaY + _cornerSize.width/2.f);
    //右上
    CGContextMoveToPoint(context, _scanAreaX + _scanSize.width - _cornerSize.height, _scanAreaY + _cornerSize.width/2.f);
    CGContextAddLineToPoint(context, _scanAreaX + _scanSize.width, _scanAreaY + _cornerSize.width/2.f);
    CGContextMoveToPoint(context, _scanAreaX + _scanSize.width - _cornerSize.width/2.f, _scanAreaY);
    CGContextAddLineToPoint(context, _scanAreaX + _scanSize.width - _cornerSize.width/2.f, _scanAreaY + _cornerSize.height);
    //右下
    CGContextMoveToPoint(context, _scanAreaX + _scanSize.width - _cornerSize.width/2.f, _scanAreaY + _scanSize.height - _cornerSize.height);
    CGContextAddLineToPoint(context, _scanAreaX + _scanSize.width - _cornerSize.width/2.f, _scanAreaY + _scanSize.height);
    CGContextMoveToPoint(context, _scanAreaX + _scanSize.width, _scanAreaY + _scanSize.height - _cornerSize.width/2.f);
    CGContextAddLineToPoint(context, _scanAreaX + _scanSize.width - _cornerSize.height, _scanAreaY + _scanSize.height - _cornerSize.width/2.f);
    //左下
    CGContextMoveToPoint(context, _scanAreaX + _cornerSize.width/2.f, _scanAreaY + _scanSize.height - _cornerSize.height);
    CGContextAddLineToPoint(context, _scanAreaX + _cornerSize.width/2.f, _scanAreaY + _scanSize.height);
    CGContextMoveToPoint(context, _scanAreaX, _scanAreaY + _scanSize.height - _cornerSize.width/2.f);
    CGContextAddLineToPoint(context, _scanAreaX +  _cornerSize.height, _scanAreaY + _scanSize.height - _cornerSize.width/2.f);
    CGContextStrokePath(context);
}

- (void)startScanning {
    if (_scanning) return;
    if (!_scanningLine) [self.layer addSublayer:self.scanningLine.layer];
    [_scanningLine.layer resumeAnimation];
    _scanning = YES;
}

- (void)stopScanning {
    if (!_scanning) return;
    [_scanningLine.layer pauseAnimation];
    _scanning = NO;
}

- (UIImageView *)scanningLine {
    if (!_scanningLine && _scanLineImage) {
        CGSize imageSize = _scanLineImage.size;
        if (imageSize.width <= 0 || imageSize.height <= 0) return nil;
        CGFloat ratio = imageSize.height/imageSize.width;
        CGFloat height = ratio*_scanSize.width;
        UIImageView *scanningLine = [[UIImageView alloc] initWithImage:_scanLineImage];
        if (self.tintColor) scanningLine.tintColor = self.tintColor;
        scanningLine.frame = CGRectMake(_scanAreaX, _scanAreaY, _scanSize.width, height);
        scanningLine.contentMode = UIViewContentModeScaleAspectFit;
        scanningLine.contentScaleFactor = [UIScreen mainScreen].scale;
        [self addPositionAnimationToLayer:scanningLine.layer];
        [scanningLine.layer pauseAnimation];
        _scanningLine = scanningLine;
    }
    return _scanningLine;
}

- (void)addPositionAnimationToLayer:(CALayer *)layer {
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:layer.position];
    positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(layer.position.x, _scanAreaY + _scanSize.height)];
    positionAnimation.duration = 2.f;
    positionAnimation.beginTime = CACurrentMediaTime();
    positionAnimation.repeatCount = HUGE_VALF;
    positionAnimation.autoreverses = NO;
    positionAnimation.removedOnCompletion = NO;
    positionAnimation.fillMode=kCAFillModeForwards;
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [layer addAnimation:positionAnimation forKey:@"k.position.animation.key"];
}

#pragma mark - 点击手势
- (void)handTap:(UITapGestureRecognizer *)recognizer {
    if ([_delegate respondsToSelector:@selector(scanView:didClickAtPoint:)]) {
        CGPoint point = [recognizer locationInView:self];
        [_delegate scanView:self didClickAtPoint:point];
    }
}

- (void)dealloc {
    [self stopScanning];
    [_scanningLine.layer removeAllAnimations];
    MNDeallocLog;
}

@end
