//
//  WXPreference.m
//  MNChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXPreference.h"

static WXPreference *_preference;
#define WXLoginTypeKey    @"com.wx.login.type.key"
#define WXAllowsDubugKey    @"com.wx.allows.dubug.key"
#define WXPaymentPasswordKey    @"com.wx.payment.password.key"
#define WXAllowsFingerprintPaymentKey    @"com.wx.allows.payment.fingerprint.payment.key"
#define WXShakeBackgroundImageKey   @"com.wx.shake.background.image.key"
#define WXAllowsShakeSoundKey    @"com.wx.allows.shake.sound.key"
#define WXMusicPlayStyleKey    @"com.wx.music.play.style.key"

@interface WXPreference ()

@end

@implementation WXPreference
@synthesize payword = _payword;

+ (instancetype)preference {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_preference) {
            _preference = [[WXPreference alloc] init];
        }
    });
    return _preference;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _preference = [super allocWithZone:zone];
    });
    return _preference;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _preference = [super init];
        if (_preference) {
            _preference.allowsDebug = IS_DEBUG ? [NSUserDefaults boolForKey:WXAllowsDubugKey def:YES] : NO;
            _preference.allowsShakeSound = [[NSUserDefaults objectForKey:WXAllowsShakeSoundKey def:@(YES)] boolValue];
            _preference.playStyle = [[NSUserDefaults objectForKey:WXMusicPlayStyleKey def:@(WXMusicPlayStyleDark)] integerValue];
        }
    });
    return _preference;
}

#pragma mark - Setter
- (void)setPayword:(NSString *)payword {
    _payword = payword.copy;
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        [userDefaults setObject:payword forKey:WXPaymentPasswordKey];
    }];
}

- (void)setAllowsFingerprint:(BOOL)allowsFingerprint {
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        [userDefaults setObject:@(allowsFingerprint) forKey:WXAllowsFingerprintPaymentKey];
    }];
}

- (void)setAllowsDebug:(BOOL)allowsDebug {
    _allowsDebug = allowsDebug;
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        [userDefaults setBool:allowsDebug forKey:WXAllowsDubugKey];
    }];
}

- (void)setLoginType:(WXLoginType)loginType {
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        [userDefaults setInteger:loginType forKey:WXLoginTypeKey];
    }];
}

- (void)setShakeBackgroundImage:(UIImage *)shakeBackgroundImage {
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        if (shakeBackgroundImage) {
            [userDefaults setImage:shakeBackgroundImage forKey:WXShakeBackgroundImageKey];
        } else {
            [userDefaults removeObjectForKey:WXShakeBackgroundImageKey];
        }
    }];
}

- (void)setAllowsShakeSound:(BOOL)allowsShakeSound {
    _allowsShakeSound = allowsShakeSound;
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        [userDefaults setObject:@(allowsShakeSound) forKey:WXAllowsShakeSoundKey];
    }];
}

- (void)setPlayStyle:(WXMusicPlayStyle)playStyle {
    _playStyle = playStyle;
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        [userDefaults setObject:@(playStyle) forKey:WXMusicPlayStyleKey];
    }];
}

#pragma mark - Getter
- (NSString *)payword {
    if (!_payword) {
        _payword = [NSUserDefaults stringForKey:WXPaymentPasswordKey def:@"000000"];
    }
    return _payword;
}

- (BOOL)isAllowsFingerprint {
    return [[NSUserDefaults objectForKey:WXAllowsFingerprintPaymentKey def:@(YES)] boolValue];
}

- (WXLoginType)loginType {
    return [NSUserDefaults.standardUserDefaults integerForKey:WXLoginTypeKey];
}

- (UIImage *)shakeBackgroundImage {
    return [NSUserDefaults.standardUserDefaults imageForKey:WXShakeBackgroundImageKey def:[UIImage imageNamed:@"wx_shake_hide_img"]];
}

@end
