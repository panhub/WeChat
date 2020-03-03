//
//  MNAuthenticator.m
//  MNKit
//
//  Created by Vincent on 2018/10/17.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNAuthenticator.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>
#import <EventKit/EventKit.h>
#if __has_include(<Contacts/Contacts.h>)
#import <Contacts/Contacts.h>
#endif
#if __has_include(<CoreTelephony/CTCellularData.h>)
#import <CoreTelephony/CTCellularData.h>
#endif

#define MNAuthorizationHandler(allowed) \
if (handler) { \
    handler(allowed); \
}

#define MNAuthorizationAvailableIOS9 \
BOOL IOS9_AVAILABLE = NO; \
if (@available(iOS 9.0, *)) { \
    IOS9_AVAILABLE = UIDevice.currentDevice.systemVersion.floatValue >= 9.f; \
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@interface MNAuthenticator ()<CLLocationManagerDelegate, MNNetworkReachabilityDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) MNAuthorizationStatusHandler locationAuthorizationHandler;
@property (nonatomic, strong) MNNetworkReachability *networkReachability;
@property (nonatomic, copy) MNAuthorizationStatusHandler networkAuthorizationHandler;
@end

static MNAuthenticator *_authenticator;

@implementation MNAuthenticator
+ (instancetype)authenticator {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _authenticator = [[MNAuthenticator alloc] init];
    });
    return _authenticator;
}

#pragma mark 获取相册权限
+ (void)requestAlbumAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        MNAuthorizationHandler(NO);
        return;
    }
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        __block BOOL isMainThread = [[NSThread currentThread] isMainThread];
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (isMainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MNAuthorizationHandler(status == PHAuthorizationStatusAuthorized);
                });
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    MNAuthorizationHandler(status == PHAuthorizationStatusAuthorized);
                });
            }
        }];
    } else {
        MNAuthorizationHandler(status == PHAuthorizationStatusAuthorized);
    }
}

#pragma mark - 获取相机权限
+ (void)requestCameraAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
    if (TARGET_IPHONE_SIMULATOR || ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        MNAuthorizationHandler(NO);
        return;
    }
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        __block BOOL isMainThread = [[NSThread currentThread] isMainThread];
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (isMainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MNAuthorizationHandler(granted);
                });
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    MNAuthorizationHandler(granted);
                });
            }
        }];
    } else {
        MNAuthorizationHandler(status == AVAuthorizationStatusAuthorized);
    }
}

 #pragma mark - 获取麦克风权限 一
+ (void)requestMicrophoneAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusNotDetermined) {
        __block BOOL isMainThread = [[NSThread currentThread] isMainThread];
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if (isMainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MNAuthorizationHandler(granted);
                });
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    MNAuthorizationHandler(granted);
                });
            }
        }];
    } else {
        MNAuthorizationHandler(status == AVAuthorizationStatusAuthorized);
    }
}

#pragma mark - 获取麦克风权限 二
+ (void)requestMicrophonePermissionWithHandler:(MNAuthorizationStatusHandler)handler {
    AVAudioSessionRecordPermission permisson = [[AVAudioSession sharedInstance] recordPermission];
    if (permisson == AVAudioSessionRecordPermissionUndetermined) {
        __block BOOL isMainThread = [[NSThread currentThread] isMainThread];
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (isMainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MNAuthorizationHandler(granted);
                });
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    MNAuthorizationHandler(granted);
                });
            }
        }];
    } else {
        MNAuthorizationHandler(permisson == AVAudioSessionRecordPermissionDenied);
    }
}

#pragma mark - 获取通讯录权限
+ (void)requestAddressBookAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
    MNAuthorizationAvailableIOS9
    if (IOS9_AVAILABLE) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusNotDetermined) {
            __block BOOL isMainThread = [[NSThread currentThread] isMainThread];
            [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (isMainThread) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MNAuthorizationHandler(granted);
                    });
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        MNAuthorizationHandler(granted);
                    });
                }
            }];
        } else {
            MNAuthorizationHandler(status == CNAuthorizationStatusAuthorized);
        }
    } else {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusNotDetermined) {
            __block BOOL isMainThread = [[NSThread currentThread] isMainThread];
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                if (isMainThread) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MNAuthorizationHandler(granted);
                    });
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        MNAuthorizationHandler(granted);
                    });
                }
            });
        } else {
            MNAuthorizationHandler(status == kABAuthorizationStatusAuthorized);
        }
    }
}

#pragma mark - 获取日历和提醒权限
+ (void)requestEntityAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if (status == EKAuthorizationStatusNotDetermined) {
        __block BOOL isMainThread = [[NSThread currentThread] isMainThread];
        [[EKEventStore new] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            if (isMainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MNAuthorizationHandler(granted);
                });
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    MNAuthorizationHandler(granted);
                });
            }
        }];
    } else {
        MNAuthorizationHandler(status == EKAuthorizationStatusAuthorized);
    }
}

#pragma mark - 获取提醒权限
+ (void)requestRemindAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    if (status == EKAuthorizationStatusNotDetermined) {
        __block BOOL isMainThread = [[NSThread currentThread] isMainThread];
        [[EKEventStore new] requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
            if (isMainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MNAuthorizationHandler(granted);
                });
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    MNAuthorizationHandler(granted);
                });
            }
        }];
    } else {
        MNAuthorizationHandler(status == EKAuthorizationStatusAuthorized);
    }
}

#pragma mark - 获取网络权限
+ (void)requestNetworkAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
    MNNetworkReachability *reachability = [MNNetworkReachability reachability];
    reachability.delegate = MNAuthenticator.authenticator;
    MNAuthenticator.authenticator.networkReachability = reachability;
    MNAuthenticator.authenticator.networkAuthorizationHandler = handler;
    [reachability startMonitoring];
}

#pragma mark - 获取定位权限
+ (void)requestLocationAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
    if ([CLLocationManager locationServicesEnabled] && CLLocationManager.authorizationStatus != kCLAuthorizationStatusNotDetermined) {
        CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
        if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
            MNAuthorizationHandler(NO);
        } else {
            if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
                MNAuthorizationHandler(YES);
            } else {
                MNAuthorizationHandler(status == kCLAuthorizationStatusAuthorizedAlways);
            }
        }
    } else {
        /// 开启定位, 不用太精细, 只为调出定位权限
        CLLocationManager *locationManager = [CLLocationManager new];
        locationManager.delegate = MNAuthenticator.authenticator;
        MNAuthenticator.authenticator.locationManager = locationManager;
        MNAuthenticator.authenticator.locationAuthorizationHandler = handler;
        NSDictionary<NSString *, id>* bundleInfo = [[NSBundle mainBundle] infoDictionary];
        if ([bundleInfo objectForKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"] || [bundleInfo objectForKey:@"NSLocationAlwaysUsageDescription"]) {
            [locationManager requestAlwaysAuthorization];
        } else {
            [locationManager requestWhenInUseAuthorization];
        }
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined) return;
    if (self.locationAuthorizationHandler) {
        self.locationAuthorizationHandler((status != kCLAuthorizationStatusDenied && status != kCLAuthorizationStatusRestricted));
    }
    manager.delegate = nil;
    self.locationManager = nil;
    self.locationAuthorizationHandler = nil;
}

#pragma mark - MNNetworkReachabilityDelegate
- (void)networkReachabilityStatusDidChange:(MNNetworkReachability *)reachability {
    if (self.networkAuthorizationHandler) {
        MNAuthorizationStatusHandler handler = [self.networkAuthorizationHandler copy];
        MNAuthorizationHandler(reachability.isReachable);
    }
    reachability.delegate = nil;
    self.networkReachability = nil;
    self.networkAuthorizationHandler = nil;
}

@end
#pragma clang diagnostic pop
