//
//  UIDevice+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/12/12.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UIDevice+MNHelper.h"
#include <sys/sysctl.h>
#include <mach/mach.h>
#import <sys/utsname.h>

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

#pragma mark - 标识符(应用与设备共同作用)
+ (NSString *)UUIDString {
    /*
     与应用和设备两者都有关;
     A应用安装到张三这台设备上,就会产生一个identifier(比如1234);
     A应用安装到李四这台设备上,就会产生另一个identifier(比如5678);
     B应用安装到张三这台设备上,又是一个全新的identifier(比如9999),
     B应用安装到李四这台设备上,还是一个全新的identifier(比如是7777),
     但是无论A应用安装卸载多少次,产生的是都是1234!
     */
    /**
     UUID原本具有时空唯一性;
     但应用在第一次安装时, 系统获取了UUID存入钥匙串中;
     以后获取都是获取钥匙串的UUID, 所以无论卸载多少次, 都是同一UUID
     */
    /**
     UDID是设备的唯一标识符, 与iOS设备相关, 不管App卸载再重装多少次, UDID的值都不会变的;
     自从iOS5之后, 苹果就禁止了通过代码访问UDID
     在一定意义上我们可以使用这种方法来获取UUID代替UDID
     */
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

#pragma mark - 强制旋转屏幕
+ (BOOL)rotateInterfaceToOrientation:(UIInterfaceOrientation)orientation {
    if (![[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) return NO;
    SEL selector  = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    /**从第二个参数开始是因为前两个参数已经被selector和target占用*/
    [invocation setArgument:&orientation atIndex:2];
    [invocation invoke];
    return YES;
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

#pragma mark - 获取设备型号
+ (NSString *)model {
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
        else if ([model isEqualToString:@"iPhone11,8"])   device_model = @"iPhone XR";
        else if ([model isEqualToString:@"iPhone11,2"])   device_model = @"iPhone XS";
        else if ([model isEqualToString:@"iPhone11,6"])   device_model = @"iPhone XS Max";
        else if ([model isEqualToString:@"iPhone11,4"])   device_model = @"iPhone XS Max";
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

@end
