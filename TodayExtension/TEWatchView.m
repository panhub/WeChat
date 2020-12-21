//
//  WXWatchView.m
//  MNChat
//
//  Created by Vincent on 2019/5/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "TEWatchView.h"
#import "TEWatchPointer.h"
#import "UIView+MNHelper.h"

@interface TEWatchView ()
@property (nonatomic, strong) TEWatchPointer *hourPointer;
@property (nonatomic, strong) TEWatchPointer *minutePointer;
@property (nonatomic, strong) TEWatchPointer *secondPointer;
@end

@implementation TEWatchView
- (void)createView {
    [super createView];
    
    /// 底层
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 10.f, 10.f)];
    centerView.center_mn = self.bounds_center;
    centerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    centerView.layer.cornerRadius = centerView.height_mn/2.f;
    centerView.clipsToBounds = YES;
    [self addSubview:centerView];
    
    centerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 5.f, 5.f)];
    centerView.center_mn = self.bounds_center;
    centerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.9f];
    centerView.layer.cornerRadius = centerView.height_mn/2.f;
    centerView.clipsToBounds = YES;
    [self addSubview:centerView];
    
    /// 时针
    CGFloat y = 22.f;
    CGFloat h = self.height_mn/2.f - y;
    
    TEWatchPointer *pointer = [[TEWatchPointer alloc] initWithFrame:CGRectMake(0.f, y, 5.f, h)];
    pointer.centerX_mn = self.width_mn/2.f;
    pointer.type = TEWatchPointerHour;
    pointer.backgroundColor = [UIColor whiteColor];
    pointer.anchorsite = CGPointMake(.5f, 1.f);
    [self addSubview:pointer];
    self.hourPointer = pointer;
    
    /// 分针
    y = 18.f;
    h = self.height_mn/2.f - y;
    
    pointer = [[TEWatchPointer alloc] initWithFrame:CGRectMake(0.f, y, 5.f, h)];
    pointer.centerX_mn = self.width_mn/2.f;
    pointer.type = TEWatchPointerMinute;
    pointer.backgroundColor = [UIColor whiteColor];
    pointer.anchorsite = CGPointMake(.5f, 1.f);
    [self addSubview:pointer];
    self.minutePointer = pointer;
    
    /// 秒针
    y = 12.f;
    h = self.height_mn/2.f - y + 10.f;
    
    pointer = [[TEWatchPointer alloc] initWithFrame:CGRectMake(0.f, y, 1.f, h)];
    pointer.centerX_mn = self.width_mn/2.f;
    pointer.clipsToBounds = YES;
    pointer.layer.cornerRadius = pointer.width_mn/2.f;
    pointer.backgroundColor = [UIColor whiteColor];
    pointer.anchorsite = CGPointMake(.5f, (h - 10.f)/h);
    [self addSubview:pointer];
    self.secondPointer = pointer;
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

@end
