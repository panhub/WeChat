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
#if __has_include(<iAd/iAd.h>)
#import <iAd/iAd.h>
#endif
#if __has_include(<AdSupport/AdSupport.h>)
#import <AdSupport/AdSupport.h>
#endif
#if __has_include(<AppTrackingTransparency/AppTrackingTransparency.h>)
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#endif

#define IS_MAIN_QUEUE \
BOOL isMainThread = [[NSThread currentThread] isMainThread]

#define dispatch_authorization_queue (isMainThread ? dispatch_get_main_queue() : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))

#define MNAuthorizationHandler(allowed) \
if (handler) { \
    handler(allowed); \
} \

@interface MNAuthenticator ()

@end

@implementation MNAuthenticator
#pragma mark 获取相册权限
+ (void)requestAlbumAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        MNAuthorizationHandler(NO);
        return;
    }
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        IS_MAIN_QUEUE;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus s) {
            dispatch_async(dispatch_authorization_queue, ^{
#ifdef __IPHONE_14_0
                if (@available(iOS 14.0, *)) {
                    MNAuthorizationHandler(s == PHAuthorizationStatusAuthorized || s == PHAuthorizationStatusLimited);
                } else {
                    MNAuthorizationHandler(s == PHAuthorizationStatusAuthorized);
                }
#else
                MNAuthorizationHandler(s == PHAuthorizationStatusAuthorized);
#endif
            });
        }];
    } else {
#ifdef __IPHONE_14_0
        if (@available(iOS 14.0, *)) {
            MNAuthorizationHandler(status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited);
        } else {
            MNAuthorizationHandler(status == PHAuthorizationStatusAuthorized);
        }
#else
        MNAuthorizationHandler(status == PHAuthorizationStatusAuthorized);
#endif
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
        IS_MAIN_QUEUE;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_authorization_queue, ^{
                MNAuthorizationHandler(granted);
            });
        }];
    } else {
        MNAuthorizationHandler(status == AVAuthorizationStatusAuthorized);
    }
}

 #pragma mark - 获取麦克风权限 一
+ (void)requestMicrophoneAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusNotDetermined) {
        IS_MAIN_QUEUE;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_authorization_queue, ^{
                MNAuthorizationHandler(granted);
            });
        }];
    } else {
        MNAuthorizationHandler(status == AVAuthorizationStatusAuthorized);
    }
}

#pragma mark - 获取麦克风权限 二
+ (void)requestMicrophonePermissionWithHandler:(MNAuthorizationStatusHandler)handler {
    AVAudioSessionRecordPermission permisson = [[AVAudioSession sharedInstance] recordPermission];
    if (permisson == AVAudioSessionRecordPermissionUndetermined) {
        IS_MAIN_QUEUE;
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_authorization_queue, ^{
                MNAuthorizationHandler(granted);
            });
        }];
    } else {
        MNAuthorizationHandler(permisson == AVAudioSessionRecordPermissionGranted);
    }
}

#pragma mark - 获取通讯录权限
+ (void)requestAddressBookAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
#ifdef __IPHONE_9_0
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        IS_MAIN_QUEUE;
        [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_authorization_queue, ^{
                MNAuthorizationHandler(granted);
            });
        }];
    } else {
        MNAuthorizationHandler(status == CNAuthorizationStatusAuthorized);
    }
#else
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusNotDetermined) {
        IS_MAIN_QUEUE;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_authorization_queue, ^{
                MNAuthorizationHandler(granted);
            });
        });
    } else {
        MNAuthorizationHandler(status == kABAuthorizationStatusAuthorized);
    }
#endif
}

#pragma mark - 获取日历和提醒权限
+ (void)requestEntityAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if (status == EKAuthorizationStatusNotDetermined) {
        IS_MAIN_QUEUE;
        [[EKEventStore new] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_authorization_queue, ^{
                MNAuthorizationHandler(granted);
            });
        }];
    } else {
        MNAuthorizationHandler(status == EKAuthorizationStatusAuthorized);
    }
}

#pragma mark - 获取提醒权限
+ (void)requestRemindAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    if (status == EKAuthorizationStatusNotDetermined) {
        IS_MAIN_QUEUE;
        [[EKEventStore new] requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_authorization_queue, ^{
                MNAuthorizationHandler(granted);
            });
        }];
    } else {
        MNAuthorizationHandler(status == EKAuthorizationStatusAuthorized);
    }
}

+ (void)requestTrackingAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler {
#ifdef __IPHONE_14_0
    if (@available(iOS 14.0, *)) {
        ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
        if (status == ATTrackingManagerAuthorizationStatusNotDetermined) {
            IS_MAIN_QUEUE;
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus s) {
                dispatch_async(dispatch_authorization_queue, ^{
                    MNAuthorizationHandler(s == ATTrackingManagerAuthorizationStatusAuthorized);
                });
            }];
        } else {
            MNAuthorizationHandler(status == ATTrackingManagerAuthorizationStatusAuthorized);
        }
    } else {
        MNAuthorizationHandler(ASIdentifierManager.sharedManager.advertisingTrackingEnabled);
    }
#else
    MNAuthorizationHandler(ASIdentifierManager.sharedManager.advertisingTrackingEnabled);
#endif
}

@end
