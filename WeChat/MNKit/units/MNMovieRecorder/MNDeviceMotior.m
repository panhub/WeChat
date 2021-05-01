//
//  MNDeviceMotior.m
//  MNKit
//
//  Created by Vicent on 2021/3/10.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "MNDeviceMotior.h"
#import <CoreMotion/CMMotionManager.h>

NSString * const MNDeviceOrientationChangeKey = @"com.mn.device.orientation.change.key";
NSNotificationName const MNDeviceOrientationDidChangeNotification = @"com.mn.device.orientation.did.change.notification";

@interface MNDeviceMotior ()
@property (nonatomic, strong) CMMotionManager *manager;
@property (nonatomic, getter=isNeedsNotification) BOOL needsPostNotification;
@end

@implementation MNDeviceMotior
- (instancetype)init {
    if (self = [super init]) {
        self.updateInterval = 1.f;
        self.orientation = UIDeviceOrientationUnknown;
        self.manager = [[CMMotionManager alloc] init];
    }
    return self;
}

- (void)startMotior {
    if (!self.manager.isAccelerometerAvailable || self.manager.isAccelerometerActive) return;
    __weak typeof(self) weakself = self;
    self.manager.accelerometerUpdateInterval = self.updateInterval;
    [self.manager startAccelerometerUpdatesToQueue:NSOperationQueue.new withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        if (error) return;
        __strong typeof(self) self = weakself;
        CGFloat x = accelerometerData.acceleration.x;
        CGFloat y = accelerometerData.acceleration.y;
        //CGFloat z = accelerometerData.acceleration.z;
        UIDeviceOrientation orientation = self.orientation;
        if (fabs(x) <= fabs(y)) {
            if (y >= 0) {
                orientation = UIDeviceOrientationPortraitUpsideDown;
            } else {
                orientation = UIDeviceOrientationPortrait;
            }
        } else {
            if (x >= 0) {
                orientation = UIDeviceOrientationLandscapeRight;
            } else {
                orientation = UIDeviceOrientationLandscapeLeft;
            }
        }
        if (orientation != self.orientation) {
            self.orientation = orientation;
            if (self.isNeedsNotification) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSNotificationCenter.defaultCenter postNotificationName:MNDeviceOrientationDidChangeNotification object:self userInfo:@{MNDeviceOrientationChangeKey:@(orientation)}];
                });
            }
        }
    }];
}

- (void)stopMotior {
    if (!self.manager.isAccelerometerAvailable || !self.manager.isAccelerometerActive) return;
    [self.manager stopAccelerometerUpdates];
}

- (void)beginGeneratingDeviceOrientationNotifications {
    @synchronized (self) {
        if (self.isNeedsNotification) return;
        self.needsPostNotification = YES;
    }
    [self startMotior];
}

- (void)endGeneratingDeviceOrientationNotifications {
    @synchronized (self) {
        if (!self.isNeedsNotification) return;
        self.needsPostNotification = NO;
    }
}

@end
