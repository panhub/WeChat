//
//  WXWatchView.m
//  WeChat
//
//  Created by Vincent on 2019/5/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXWatchView.h"
#import "WXWatchPointer.h"

@interface WXWatchView ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) WXWatchPointer *hourPointer;
@property (nonatomic, strong) WXWatchPointer *minutePointer;
@property (nonatomic, strong) WXWatchPointer *secondPointer;
@end

@implementation WXWatchView
- (void)createView {
    [super createView];
    /// 品牌
    UIImageView *brandView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, self.width_mn/5.f, self.width_mn/5.f)
                                                       image:UIImageNamed(@"wx_watch_brand")];
    brandView.centerX_mn = self.width_mn/2.f;
    brandView.centerY_mn = self.height_mn/4.f*1.3f;
    [self addSubview:brandView];
    
    /// 底层
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 15.f, 15.f)];
    centerView.center_mn = self.bounds_center;
    centerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    centerView.layer.cornerRadius = centerView.height_mn/2.f;
    centerView.clipsToBounds = YES;
    [self addSubview:centerView];
    
    centerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 8.f, 8.f)];
    centerView.center_mn = self.bounds_center;
    centerView.backgroundColor = [UIColor whiteColor];
    centerView.layer.cornerRadius = centerView.height_mn/2.f;
    centerView.clipsToBounds = YES;
    [self addSubview:centerView];
    
    /// 时针
    CGFloat y = 38.f;
    CGFloat h = self.height_mn/2.f - y;
    
    WXWatchPointer *pointer = [[WXWatchPointer alloc] initWithFrame:CGRectMake(0.f, y, 8.f, h)];
    pointer.centerX_mn = MEAN(self.width_mn);
    pointer.type = MNWatchPointerHour;
    pointer.backgroundColor = [UIColor whiteColor];
    pointer.anchorsite = CGPointMake(.5f, 1.f);
    [self addSubview:pointer];
    self.hourPointer = pointer;
    
    /// 分针
    y = 26.f;
    h = self.height_mn/2.f - y;
    
    pointer = [[WXWatchPointer alloc] initWithFrame:CGRectMake(0.f, y, 7.f, h)];
    pointer.centerX_mn = MEAN(self.width_mn);
    pointer.type = MNWatchPointerMinute;
    pointer.backgroundColor = [UIColor whiteColor];
    pointer.anchorsite = CGPointMake(.5f, 1.f);
    [self addSubview:pointer];
    self.minutePointer = pointer;
    
    /// 秒针
    y = 16.f;
    h = self.height_mn/2.f - y + 13.f;
    
    pointer = [[WXWatchPointer alloc] initWithFrame:CGRectMake(0.f, y, 1.5f, h)];
    pointer.centerX_mn = MEAN(self.width_mn);
    pointer.clipsToBounds = YES;
    pointer.layer.cornerRadius = pointer.width_mn/2.f;
    pointer.backgroundColor = [UIColor whiteColor];
    pointer.anchorsite = CGPointMake(.5f, (h - 13.f)/h);
    [self addSubview:pointer];
    self.secondPointer = pointer;
}

- (void)fire {
    if (_timer) return;
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self.timer fire];
}

- (void)invalidate {
    if (!_timer) return;
    [_timer invalidate];
    _timer = nil;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1.f
                                         target:self
                                       selector:@selector(updateTime)
                                       userInfo:nil
                                        repeats:YES];
    }
    return _timer;
}

- (void)updateTime {
    NSUInteger timestamp = [[NSDate date] timeIntervalSince1970];
    timestamp += (3600*8);

    CGFloat hour = timestamp/(3600.f*12.f);
    hour = hour - floor(hour);
    CGFloat angle = M_PI*2.f*hour;
    self.hourPointer.transform = CGAffineTransformMakeRotation(angle);
    
    CGFloat minute = timestamp/3600.f;
    minute = minute - floor(minute);
    angle = M_PI*2.f*minute;
    self.minutePointer.transform = CGAffineTransformMakeRotation(angle);
    
    NSUInteger second = timestamp%60;
    angle = M_PI*2.f/60.f*second;
    self.secondPointer.transform = CGAffineTransformMakeRotation(angle);
}

- (void)dealloc {
    [self invalidate];
}

@end
