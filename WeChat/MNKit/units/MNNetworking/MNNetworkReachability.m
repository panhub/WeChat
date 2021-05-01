//
//  MNNetworkReachability.m
//  MNKit
//
//  Created by Vincent on 2019/11/29.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNNetworkReachability.h"
#if !TARGET_OS_WATCH
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

typedef void (^MNNetworkReachabilityStatusChangeBlock)(MNNetworkReachabilityStatus status);
NSNotificationName const MNNetworkReachabilityStatusDidChangeNotification = @"com.mn.network.reachability.status.change.notification";
NSString * MNStringFromNetworkReachabilityStatus(MNNetworkReachabilityStatus status) {
    switch (status) {
        case MNNetworkReachabilityStatusNotReachable:
            return NSLocalizedString(@"Not Reachable", nil);
        case MNNetworkReachabilityStatusWWAN:
            return NSLocalizedString(@"Reachable via WWAN", nil);
        case MNNetworkReachabilityStatusWiFi:
            return NSLocalizedString(@"Reachable via WiFi", nil);
        case MNNetworkReachabilityStatusUnknown:
        default:
            return NSLocalizedString(@"Unknown", nil);
    }
}
static MNNetworkReachabilityStatus MNNetworkReachabilityStatusFromFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    MNNetworkReachabilityStatus status = MNNetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = MNNetworkReachabilityStatusNotReachable;
    }
#if TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = MNNetworkReachabilityStatusWWAN;
    }
#endif
    else {
        status = MNNetworkReachabilityStatusWiFi;
    }
    return status;
}
static void MNPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, MNNetworkReachabilityStatusChangeBlock callback) {
    MNNetworkReachabilityStatus status = MNNetworkReachabilityStatusFromFlags(flags);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (callback) {
            callback(status);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:MNNetworkReachabilityStatusDidChangeNotification
                                                            object:@(status)];
    });
}
static void MNNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    MNPostReachabilityStatusChange(flags, (__bridge MNNetworkReachabilityStatusChangeBlock)info);
}
static const void * MNNetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}
static void MNNetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface MNNetworkReachability ()
@property (nonatomic) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic) MNNetworkReachabilityStatus status;
@property (nonatomic, copy) MNNetworkReachabilityStatusChangeBlock networkReachabilityStatusBlock;
@end

@implementation MNNetworkReachability
+ (instancetype)reachability {
    return [[self alloc] init];
}

- (instancetype)init {
    // 依据地址创建网络链接引用, 当为0.0.0.0时则可以查询本机的网络连接状态;
    // 创建零地址, 表示查询本机网络链接信息
    // 支持IPV6
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 zero_address;
    bzero(&zero_address, sizeof(zero_address));
    zero_address.sin6_len = sizeof(zero_address);
    zero_address.sin6_family = AF_INET6;
#else
    struct sockaddr_in zero_address;
    bzero(&zero_address, sizeof(zero_address));
    zero_address.sin_len = sizeof(zero_address);
    zero_address.sin_family = AF_INET;
#endif
    return [self initWithAddress:(const struct sockaddr *)&zero_address];
}

- (instancetype)initWithAddress:(const struct sockaddr *)hostAddress {
    return [self initWithReachabilityRef:SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress)];
}

- (instancetype)initWithHostname:(NSString *)hostname {
    return [self initWithReachabilityRef:SCNetworkReachabilityCreateWithName(NULL, hostname.UTF8String)];
}

- (instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)reachabilityRef {
    self = [super init];
    if (!self) return nil;
    self.reachabilityRef = reachabilityRef;
    self.status = MNNetworkReachabilityStatusUnknown;
    return self;
}

#pragma mark - Method
- (void)startMonitoring {
    [self stopMonitoring];
    if (self.reachabilityRef == NULL) return;
    __weak __typeof(self)weakSelf = self;
    MNNetworkReachabilityStatusChangeBlock callback = ^(MNNetworkReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.status = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }
        if ([strongSelf.delegate respondsToSelector:@selector(networkReachabilityStatusDidChange:)]) {
            [strongSelf.delegate networkReachabilityStatusDidChange:strongSelf];
        }
    };
    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, MNNetworkReachabilityRetainCallback, MNNetworkReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.reachabilityRef, MNNetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
            MNPostReachabilityStatusChange(flags, callback);
        }
    });
}

- (void)stopMonitoring {
    if (_reachabilityRef) return;
    SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

- (void)registerStatusChangeHandler:(void (^)(MNNetworkReachabilityStatus status))handler {
    self.networkReachabilityStatusBlock = handler;
}

#pragma mark - Getter
- (BOOL)isReachable {
    return self.isReachableWWAN || self.isReachableWiFi;
}

- (BOOL)isReachableWWAN {
    return self.status == MNNetworkReachabilityStatusWWAN;
}

- (BOOL)isReachableWiFi {
    return self.status == MNNetworkReachabilityStatusWiFi;
}

- (NSString *)reachabilityStatusString {
    return MNStringFromNetworkReachabilityStatus(self.status);
}

#pragma dealloc
- (void)dealloc {
    [self stopMonitoring];
    _networkReachabilityStatusBlock = nil;
    if (_reachabilityRef != NULL) {
        CFRelease(_reachabilityRef);
    }
}

@end
#endif
