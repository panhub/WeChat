//
//  MNStreamView.m
//  MNKit
//
//  Created by Vincent on 2019/9/22.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNStreamView.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>

@interface MNStreamView ()<UIGestureRecognizerDelegate>
@property (nonatomic) MNStreamViewState state;
@property (nonatomic, strong) UILabel *uploadLabel;
@property (nonatomic, strong) UILabel *downloadLabel;
@property (nonatomic, strong) UIImageView *badgeView;
@end

#define kMNStreamViewMargin   3.f
#define kMNStreamViewSize CGSizeMake(80.f, 23.f)
const CGFloat MNStreamViewAnimationDuration = .25f;

@implementation MNStreamView
{
    CGFloat _wifiUpPer;
    CGFloat _wifiDownPer;
    CGFloat _cellularUpPer;
    CGFloat _cellularDownPer;
    CADisplayLink *_link;
    MNNetworkReachability *_reachability;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0.f;
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 3.f;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:.7f];
        _wifiUpPer = _cellularUpPer = -1.f;
        
        UIImageView *badgeView = [UIImageView imageViewWithFrame:CGRectMake(3.f, 0.f, self.height_mn - 3.f, self.height_mn - 3.f) image:[MNBundle imageForResource:@"icon_4G"]];
        badgeView.highlightedImage = [MNBundle imageForResource:@"icon_wifi"];
        badgeView.userInteractionEnabled = NO;
        badgeView.centerY_mn = self.height_mn/2.f;
        [self addSubview:badgeView];
        self.badgeView = badgeView;
        
        UIImageView *uploadView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, self.height_mn/2.f - 5.f, self.height_mn/2.f - 5.f) image:[MNBundle imageForResource:@"icon_up_arrow"]];
        uploadView.top_mn = (self.height_mn - uploadView.height_mn*2.f)/3.f;
        uploadView.right_mn = self.width_mn - 2.5f;
        uploadView.userInteractionEnabled = NO;
        [self addSubview:uploadView];
        
        UIImageView *downloadView = uploadView.viewCopy;
        downloadView.top_mn = uploadView.bottom_mn + uploadView.top_mn;
        downloadView.image = [MNBundle imageForResource:@"icon_down_arrow"];
        downloadView.userInteractionEnabled = NO;
        [self addSubview:downloadView];
        
        UILabel *uploadLabel = [UILabel labelWithFrame:CGRectMake(badgeView.right_mn + 2.f, 0.f, uploadView.left_mn - badgeView.right_mn - 3.f, 10.f) text:@"0.0B/s" textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:10.f]];
        uploadLabel.centerY_mn = uploadView.centerY_mn;
        uploadLabel.textAlignment = NSTextAlignmentRight;
        uploadLabel.userInteractionEnabled = NO;
        [self addSubview:uploadLabel];
        self.uploadLabel = uploadLabel;
        
        UILabel *downloadLabel = uploadLabel.viewCopy;
        downloadLabel.centerY_mn = downloadView.centerY_mn;
        downloadLabel.userInteractionEnabled = NO;
        [self addSubview:downloadLabel];
        self.downloadLabel = downloadLabel;
        
        _link = [CADisplayLink displayLinkWithTarget:[MNWeakProxy proxyWithTarget:self] selector:@selector(tick:)];
        [_link setPaused:YES];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handPan:)];
        pan.delegate = self;
        pan.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:pan];
        
        _reachability = MNNetworkReachability.reachability;
        [_reachability startMonitoring];
    }
    return self;
}

- (NSString *)getStreamSizeString:(CGFloat)size {
    if (size > 1024.f*1024.f*1024.f) {
        return [NSString stringWithFormat:@"%.1fG/s",size/1024.f/1024.f/1024.f];
    } else if (size < 1024.f*1024.f*1024.f && size >= 1024.f*1024.f) {
        return [NSString stringWithFormat:@"%.1fM/s",size/1024.f/1024.f];
    } else if (size >= 1024.f && size < 1024.f*1024.f) {
        return [NSString stringWithFormat:@"%.1fK/s",size/1024.f];
    }
    return [NSString stringWithFormat:@"%.1fB/s",size];
}

#pragma mark - Event
- (void)tick:(CADisplayLink *)link {
    struct ifaddrs *addrs;
    struct ifaddrs *cursor;
    struct if_data *networkStatisc;
    long wifiUpPer = 0;
    long wifiDownPer = 0;
    long cellularUpPer = 0;
    long cellularDownPer = 0;
    BOOL success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            NSString *name = [NSString stringWithFormat:@"%s", cursor->ifa_name];
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (struct if_data *) cursor->ifa_data;
                    wifiUpPer += networkStatisc->ifi_obytes;
                    wifiDownPer += networkStatisc->ifi_ibytes;
                }
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (struct if_data *) cursor->ifa_data;
                    cellularUpPer += networkStatisc->ifi_obytes;
                    cellularDownPer += networkStatisc->ifi_ibytes;
                }
                if (_reachability.isReachableWiFi) {
                    if (_wifiUpPer >= 0.f) {
                        CGFloat wifi_up = wifiUpPer - _wifiUpPer;
                        CGFloat wifi_down = wifiDownPer - _wifiDownPer;
                        self.uploadLabel.text = [self getStreamSizeString:wifi_up];
                        self.downloadLabel.text = [self getStreamSizeString:wifi_down];
                    }
                    if (!self.badgeView.highlighted) self.badgeView.highlighted = YES;
                } else if (_reachability.isReachableWWAN) {
                    if (_cellularUpPer >= 0.f) {
                        CGFloat cellular_up = cellularUpPer - _cellularUpPer;
                        CGFloat cellular_down = cellularDownPer - _cellularDownPer;
                        self.uploadLabel.text = [self getStreamSizeString:cellular_up];
                        self.downloadLabel.text = [self getStreamSizeString:cellular_down];
                    }
                    if (self.badgeView.highlighted) self.badgeView.highlighted = NO;
                } else {
                    self.uploadLabel.text = @"0.0B/s";
                    self.downloadLabel.text = @"0.0B/s";
                }
            }
            cursor = cursor->ifa_next;
        }
    }
    freeifaddrs(addrs);
    _wifiUpPer = wifiUpPer;
    _wifiDownPer = wifiDownPer;
    _cellularUpPer = cellularUpPer;
    _cellularDownPer = cellularDownPer;
}

- (void)show {
    if (self.alpha == 1.f) return;
    [UIView animateWithDuration:MNStreamViewAnimationDuration animations:^{
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [_link setPaused:NO];
    }];
}

- (void)dismiss {
    if (self.alpha == 0.f) return;
    [_link setPaused:YES];
    [UIView animateWithDuration:MNStreamViewAnimationDuration animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        self.uploadLabel.text = @"0.0B/s";
        self.downloadLabel.text = @"0.0B/s";
    }];
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame {
    frame.size = kMNStreamViewSize;
    [super setFrame:frame];
}

#pragma mark - Gesture Event
- (void)handPan:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.state = MNStreamViewStateDraging;
        } break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [recognizer translationInView:self];
            [recognizer setTranslation:CGPointZero inView:self];
            self.left_mn += point.x;
            self.top_mn += point.y;
            if (self.left_mn < CGRectGetMinX(self.superview.bounds) + kMNStreamViewMargin) {
                self.left_mn = CGRectGetMinX(self.superview.bounds) + kMNStreamViewMargin;
            } else if (self.right_mn > CGRectGetMaxX(self.superview.bounds) - kMNStreamViewMargin){
                self.right_mn = CGRectGetMaxX(self.superview.bounds) - kMNStreamViewMargin;
            }
            if (self.top_mn < CGRectGetMinY(self.superview.bounds) + kMNStreamViewMargin) {
                self.top_mn = CGRectGetMinY(self.superview.bounds) + kMNStreamViewMargin;
            } else if (self.bottom_mn > CGRectGetMaxY(self.superview.bounds) - kMNStreamViewMargin) {
                self.bottom_mn = CGRectGetMaxY(self.superview.bounds) - kMNStreamViewMargin;
            }
        } break;
        case UIGestureRecognizerStateEnded:
        {
            self.state = MNStreamViewStateAnimating;
            CGRect frame = self.frame;
            if (self.centerX_mn >= CGRectGetMinX(self.superview.bounds) + CGRectGetWidth(self.superview.bounds)/2.f) {
                frame = CGRectMake(CGRectGetMaxX(self.superview.bounds) - self.width_mn - kMNStreamViewMargin, self.top_mn, self.width_mn, self.height_mn);
            } else {
                frame = CGRectMake(CGRectGetMinX(self.superview.bounds) + kMNStreamViewMargin, self.top_mn, self.width_mn, self.height_mn);
            }
            [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.frame = frame;
            } completion:^(BOOL finished) {
                self.state = MNStreamViewStateNormal;
            }];
        } break;
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.state == MNStreamViewStateNormal;
}

#pragma mark - dealloc
- (void)dealloc {
    if (_link) {
        _link.paused = YES;
        [_link removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
        [_link invalidate];
    }
}

@end
