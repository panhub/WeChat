//
//  TEStreamLabel.m
//  TodayExtension
//
//  Created by Vincent on 2019/5/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "TEStreamLabel.h"
#import "UIView+MNLayout.h"
#import "Reachability.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>

@interface TEStreamLabel ()
@property (nonatomic) CGFloat wifiUpPer;
@property (nonatomic) CGFloat wifiDownPer;
@property (nonatomic) CGFloat cellularUpPer;
@property (nonatomic) CGFloat cellularDownPer;
@property (nonatomic, strong) UILabel *uploadLabel;
@property (nonatomic, strong) UILabel *downloadLabel;
@property (nonatomic, strong) UIImageView *badgeView;
@property (nonatomic, strong) Reachability *reachability;
@end

@implementation TEStreamLabel
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}

- (void)createView {
    
    /// wifi 4G
    UIImageView *badgeView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.height_mn, self.height_mn)];
    badgeView.image = [[UIImage imageNamed:@"ext_today_wifi"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    badgeView.highlightedImage = [[UIImage imageNamed:@"ext_today_signal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    badgeView.tintColor = [[UIColor darkTextColor] colorWithAlphaComponent:.65f];
    [self addSubview:badgeView];
    self.badgeView = badgeView;
    
    CGFloat w = (self.width_mn - badgeView.right_mn - 30.f)/2.f;
    
    UIImageView *upView = [[UIImageView alloc] initWithFrame:CGRectMake(badgeView.right_mn, (self.height_mn - 15.f)/2.f, 15.f, 15.f)];
    upView.image = [[UIImage imageNamed:@"ext_today_up"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    upView.tintColor = [[UIColor darkTextColor] colorWithAlphaComponent:.65f];
    [self addSubview:upView];

    UILabel *uploadLabel = [[UILabel alloc] initWithFrame:CGRectMake(upView.right_mn, (self.height_mn - 15.f)/2.f, w, 15.f)];
    uploadLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.65f];
    uploadLabel.font = [UIFont systemFontOfSize:uploadLabel.height_mn];
    uploadLabel.text = @"0.0B/s";
    [self addSubview:uploadLabel];
    self.uploadLabel = uploadLabel;
    
    UILabel *downloadLabel = [[UILabel alloc] initWithFrame:uploadLabel.frame];
    downloadLabel.left_mn = uploadLabel.right_mn;
    downloadLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.65f];
    downloadLabel.font = [UIFont systemFontOfSize:downloadLabel.height_mn];
    downloadLabel.textAlignment = NSTextAlignmentRight;
    downloadLabel.text = @"0.0B/s";
    [self addSubview:downloadLabel];
    self.downloadLabel = downloadLabel;
    
    UIImageView *downView = [[UIImageView alloc] initWithFrame:upView.frame];
    downView.left_mn = downloadLabel.right_mn;
    downView.image = [[UIImage imageNamed:@"ext_today_down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    downView.tintColor = [[UIColor darkTextColor] colorWithAlphaComponent:.65f];
    [self addSubview:downView];
}

- (void)updateData {
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
                /// 更新数据
                if (self.reachability.currentReachabilityStatus == ReachableViaWiFi) {
                    CGFloat wifi_up = wifiUpPer - _wifiUpPer;
                    CGFloat wifi_down = wifiDownPer - _wifiDownPer;
                    _uploadLabel.text = [self getStreamSizeString:wifi_up];
                    _downloadLabel.text = [self getStreamSizeString:wifi_down];
                    if (_badgeView.highlighted) _badgeView.highlighted = NO;
                } else if (self.reachability.currentReachabilityStatus == ReachableViaWWAN) {
                    CGFloat cellular_up = cellularUpPer - _cellularUpPer;
                    CGFloat cellular_down = cellularDownPer - _cellularDownPer;
                    _uploadLabel.text = [self getStreamSizeString:cellular_up];
                    _downloadLabel.text = [self getStreamSizeString:cellular_down];
                    if (!_badgeView.highlighted) _badgeView.highlighted = YES;
                } else {
                    _uploadLabel.text = @"0.0B/s";
                    _downloadLabel.text = @"0.0B/s";
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

- (NSString *)getStreamSizeString:(CGFloat)size {
    if (size>1024.f*1024.f*1024.f)
    {
        return [NSString stringWithFormat:@"%.1fG/s",size/1024.f/1024.f/1024.f];
    }
    else if (size < 1024.f*1024.f*1024.f && size >= 1024.f*1024.f)
    {
        return [NSString stringWithFormat:@"%.1fM/s",size/1024.f/1024.f];
    }
    else if (size >= 1024.f && size < 1024.f*1024.f)
    {
        return [NSString stringWithFormat:@"%.1fK/s",size/1024.f];
    }
    else
    {
        return [NSString stringWithFormat:@"%.1fB/s",size];
    }
}

#pragma mark - Getter
- (Reachability *)reachability {
    if (!_reachability) {
        Reachability *reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
        _reachability = reachability;
    }
    return _reachability;
}

@end
