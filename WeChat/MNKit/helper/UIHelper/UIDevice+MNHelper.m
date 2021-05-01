//
//  UIDevice+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/12/12.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UIDevice+MNHelper.h"
#import "MNFileHandle.h"
#import "MNKeychain.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <sys/sysctl.h>
#include <mach/mach.h>
#import <sys/utsname.h>
#include <sys/param.h>
#include <sys/mount.h>


// 用于生成设备唯一标识, 生成后不要更改此标识
#define kDeviceIdentifier   @"com.mn.kit.device.identifier"

@implementation UIDevice (MNHelper)
#pragma mark - DeviceModel
NSString* UIDeviceModel (void) {
    return [[UIDevice currentDevice] model];
}

#pragma mark - DeviceName
NSString* UIDeviceName (void) {
    return [[UIDevice currentDevice] name];
}

#pragma mark - 是否为iPhone
BOOL UIInterfacePhoneModel (void) {
    static BOOL isPhone;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isPhone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    });
    return isPhone;
}

#pragma mark - 是否为iPad
BOOL UIInterfacePadModel (void) {
    static BOOL isPad;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    });
    return isPad;
}

#pragma mark - 是否是模拟器
BOOL UIDeviceSimulator (void) {
    static BOOL isSimulator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isSimulator = TARGET_IPHONE_SIMULATOR;
    });
    return isSimulator;
}

#pragma mark - iOS系统版本号
NSString * IOS_VERSION (void) {
    static NSString *systemversion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        systemversion = UIDevice.currentDevice.systemVersion;
    });
    return systemversion;
}

inline CGFloat IOS_VERSION_NUMBER (void) {
    return [IOS_VERSION() floatValue];
}

#pragma mark - 判断当前系统版本是否是某个版本
inline BOOL IOS_VERSION_EQUAL (CGFloat version) {
    return IOS_VERSION_NUMBER() == version;
}

#pragma mark - 当前系统版本 >= 某个版本
inline BOOL IOS_VERSION_LATER (CGFloat version) {
    return IOS_VERSION_NUMBER() >= version;
}

#pragma mark - 当前系统版本 <= 某个版本
inline BOOL IOS_VERSION_UNDER (CGFloat version) {
    return IOS_VERSION_NUMBER() <= version;
}

#pragma mark - 唯一标识符
+ (NSString *)identifier {
    static NSString *device_identifier;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        device_identifier = [NSUserDefaults.standardUserDefaults stringForKey:kDeviceIdentifier];
        if (device_identifier.length <= 0) {
            device_identifier = [MNKeychain stringForKey:kDeviceIdentifier];
            if (device_identifier.length > 0) {
                [NSUserDefaults.standardUserDefaults setObject:device_identifier forKey:kDeviceIdentifier];
                [NSUserDefaults.standardUserDefaults synchronize];
            } else {
                device_identifier = MNFileHandle.fileName;
                [MNKeychain setString:device_identifier forKey:kDeviceIdentifier];
                [NSUserDefaults.standardUserDefaults setObject:device_identifier forKey:kDeviceIdentifier];
                [NSUserDefaults.standardUserDefaults synchronize];
            }
        }
    });
    return device_identifier;
}

#pragma mark - 判断是否为越狱设备
+ (BOOL)isBreakDevice {
    static BOOL is_break_device = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        is_break_device = getenv("DYLD_INSERT_LIBRARIES") != NULL;
        if (is_break_device) return;
        NSArray *break_paths = @[@"/Applications/Cydia.app",@"/Library/MobileSubstrate/MobileSubstrate.dylib",@"/bin/bash",@"/usr/sbin/sshd",@"/etc/apt"];
        for (int i = 0; i < break_paths.count; i++) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:break_paths[i]]) {
                is_break_device = YES;
                break;
            }
        }
        if (is_break_device) return;
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
            is_break_device = YES;
        }
        if (is_break_device) return;
        if ([[NSFileManager defaultManager] fileExistsAtPath:@"User/Applications/"]) {
            is_break_device = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"User/Applications/" error:nil] count] > 0;
        }
    });
    return is_break_device;
}

#pragma mark - 设备地址
+ (NSString *)address {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

#pragma mark - 获取设备型号
+ (NSString *)model {
    //https://www.theiphonewiki.com/wiki/Models
    static NSString *device_model;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
        if ([model isEqualToString:@"iPhone3,1"])           device_model = @"iPhone 4";
        else if ([model isEqualToString:@"iPhone3,2"])    device_model = @"iPhone 4";
        else if ([model isEqualToString:@"iPhone3,3"])    device_model = @"iPhone 4";
        else if ([model isEqualToString:@"iPhone4,1"])    device_model = @"iPhone 4S";
        else if ([model isEqualToString:@"iPhone5,1"])    device_model = @"iPhone 5";
        else if ([model isEqualToString:@"iPhone5,2"])    device_model = @"iPhone 5 (GSM+CDMA)";
        else if ([model isEqualToString:@"iPhone5,3"])    device_model = @"iPhone 5c (GSM)";
        else if ([model isEqualToString:@"iPhone5,4"])    device_model = @"iPhone 5c (GSM+CDMA)";
        else if ([model isEqualToString:@"iPhone6,1"])    device_model = @"iPhone 5s (GSM)";
        else if ([model isEqualToString:@"iPhone6,2"])    device_model = @"iPhone 5s (GSM+CDMA)";
        else if ([model isEqualToString:@"iPhone7,1"])    device_model = @"iPhone 6 Plus";
        else if ([model isEqualToString:@"iPhone7,2"])    device_model = @"iPhone 6";
        else if ([model isEqualToString:@"iPhone8,1"])    device_model = @"iPhone 6s";
        else if ([model isEqualToString:@"iPhone8,2"])    device_model = @"iPhone 6s Plus";
        else if ([model isEqualToString:@"iPhone8,4"])    device_model = @"iPhone SE";
        else if ([model isEqualToString:@"iPhone9,1"])    device_model = @"iPhone 7";
        else if ([model isEqualToString:@"iPhone9,2"])    device_model = @"iPhone 7 Plus";
        else if ([model isEqualToString:@"iPhone9,3"])    device_model = @"iPhone 7";
        else if ([model isEqualToString:@"iPhone9,4"])    device_model = @"iPhone 7 Plus";
        else if ([model isEqualToString:@"iPhone10,1"])   device_model = @"iPhone 8";
        else if ([model isEqualToString:@"iPhone10,4"])   device_model = @"iPhone 8";
        else if ([model isEqualToString:@"iPhone10,2"])   device_model = @"iPhone 8 Plus";
        else if ([model isEqualToString:@"iPhone10,5"])   device_model = @"iPhone 8 Plus";
        else if ([model isEqualToString:@"iPhone10,3"])   device_model = @"iPhone X";
        else if ([model isEqualToString:@"iPhone10,6"])   device_model = @"iPhone X";
        else if ([model isEqualToString:@"iPhone11,2"])   device_model = @"iPhone XS";
        else if ([model isEqualToString:@"iPhone11,4"])   device_model = @"iPhone XS Max";
        else if ([model isEqualToString:@"iPhone11,6"])   device_model = @"iPhone XS Max";
        else if ([model isEqualToString:@"iPhone11,8"])   device_model = @"iPhone XR";
        else if ([model isEqualToString:@"iPhone12,1"])   device_model = @"iPhone 11";
        else if ([model isEqualToString:@"iPhone12,3"])   device_model = @"iPhone 11 Pro";
        else if ([model isEqualToString:@"iPhone12,5"])   device_model = @"iPhone 11 Pro Max";
        else if ([model isEqualToString:@"iPhone12,8"])   device_model = @"iPhone SE (2nd generation)";
        else if ([model isEqualToString:@"iPhone13,1"])   device_model = @"iPhone 12 Mini";
        else if ([model isEqualToString:@"iPhone13,2"])   device_model = @"iPhone 12";
        else if ([model isEqualToString:@"iPhone13,3"])   device_model = @"iPhone 12 Pro";
        else if ([model isEqualToString:@"iPhone13,4"])   device_model = @"iPhone 12 Pro Max";
        else if ([model isEqualToString:@"iPod1,1"])      device_model = @"iPod Touch 1G";
        else if ([model isEqualToString:@"iPod2,1"])      device_model = @"iPod Touch 2G";
        else if ([model isEqualToString:@"iPod3,1"])      device_model = @"iPod Touch 3G";
        else if ([model isEqualToString:@"iPod4,1"])      device_model = @"iPod Touch 4G";
        else if ([model isEqualToString:@"iPod5,1"])      device_model = @"iPod Touch (5 Gen)";
        else if ([model isEqualToString:@"iPad1,1"])      device_model = @"iPad";
        else if ([model isEqualToString:@"iPad1,2"])      device_model = @"iPad 3G";
        else if ([model isEqualToString:@"iPad2,1"])      device_model = @"iPad 2 (WiFi)";
        else if ([model isEqualToString:@"iPad2,2"])      device_model = @"iPad 2";
        else if ([model isEqualToString:@"iPad2,3"])      device_model = @"iPad 2 (CDMA)";
        else if ([model isEqualToString:@"iPad2,4"])      device_model = @"iPad 2";
        else if ([model isEqualToString:@"iPad2,5"])      device_model = @"iPad Mini (WiFi)";
        else if ([model isEqualToString:@"iPad2,6"])      device_model = @"iPad Mini";
        else if ([model isEqualToString:@"iPad2,7"])      device_model = @"iPad Mini (GSM+CDMA)";
        else if ([model isEqualToString:@"iPad3,1"])      device_model = @"iPad 3 (WiFi)";
        else if ([model isEqualToString:@"iPad3,2"])      device_model = @"iPad 3 (GSM+CDMA)";
        else if ([model isEqualToString:@"iPad3,3"])      device_model = @"iPad 3";
        else if ([model isEqualToString:@"iPad3,4"])      device_model = @"iPad 4 (WiFi)";
        else if ([model isEqualToString:@"iPad3,5"])      device_model = @"iPad 4";
        else if ([model isEqualToString:@"iPad3,6"])      device_model = @"iPad 4 (GSM+CDMA)";
        else if ([model isEqualToString:@"iPad4,1"])      device_model = @"iPad Air (WiFi)";
        else if ([model isEqualToString:@"iPad4,2"])      device_model = @"iPad Air (Cellular)";
        else if ([model isEqualToString:@"iPad4,4"])      device_model = @"iPad Mini 2 (WiFi)";
        else if ([model isEqualToString:@"iPad4,5"])      device_model = @"iPad Mini 2 (Cellular)";
        else if ([model isEqualToString:@"iPad4,6"])      device_model = @"iPad Mini 2";
        else if ([model isEqualToString:@"iPad4,7"])      device_model = @"iPad Mini 3";
        else if ([model isEqualToString:@"iPad4,8"])      device_model = @"iPad Mini 3";
        else if ([model isEqualToString:@"iPad4,9"])      device_model = @"iPad Mini 3";
        else if ([model isEqualToString:@"iPad5,1"])      device_model = @"iPad Mini 4 (WiFi)";
        else if ([model isEqualToString:@"iPad5,2"])      device_model = @"iPad Mini 4 (LTE)";
        else if ([model isEqualToString:@"iPad5,3"])      device_model = @"iPad Air 2";
        else if ([model isEqualToString:@"iPad5,4"])      device_model = @"iPad Air 2";
        else if ([model isEqualToString:@"iPad6,3"])      device_model = @"iPad Pro 9.7";
        else if ([model isEqualToString:@"iPad6,4"])      device_model = @"iPad Pro 9.7";
        else if ([model isEqualToString:@"iPad6,7"])      device_model = @"iPad Pro 12.9";
        else if ([model isEqualToString:@"iPad6,8"])      device_model = @"iPad Pro 12.9";
        else if ([model isEqualToString:@"iPad6,11"])      device_model = @"iPad 5 (WiFi)";
        else if ([model isEqualToString:@"iPad6,12"])      device_model = @"iPad 5 (Cellular)";
        else if ([model isEqualToString:@"iPad7,1"])      device_model = @"iPad Pro 12.9 2nd gen (WiFi)";
        else if ([model isEqualToString:@"iPad7,2"])      device_model = @"iPad Pro 12.9 2nd gen (Cellular)";
        else if ([model isEqualToString:@"iPad7,3"])      device_model = @"iPad Pro 10.5 inch (WiFi)";
        else if ([model isEqualToString:@"iPad7,4"])      device_model = @"iPad Pro 10.5 inch (Cellular)";
        else if ([model isEqualToString:@"AppleTV2,1"])      device_model = @"Apple TV 2";
        else if ([model isEqualToString:@"AppleTV3,1"])      device_model = @"Apple TV 3";
        else if ([model isEqualToString:@"AppleTV3,2"])      device_model = @"Apple TV 3";
        else if ([model isEqualToString:@"AppleTV5,3"])      device_model = @"Apple TV 4";
        else if ([model isEqualToString:@"i386"])         device_model = @"Simulator";
        else if ([model isEqualToString:@"x86_64"])       device_model = @"Simulator";
        else device_model = @"iPhone 11 Series Later";
    });
    return device_model;
}

#pragma mark - 强制旋转屏幕
+ (BOOL)rotateInterfaceToOrientation:(UIInterfaceOrientation)orientation {
    if (![[UIDevice currentDevice] respondsToSelector:NSSelectorFromString(@"setOrientation:")]) return NO;
    SEL selector  = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    /**从第二个参数开始是因为前两个参数已经被selector和target占用*/
    [invocation setArgument:&orientation atIndex:2];
    [invocation invoke];
    return YES;
}

@end
