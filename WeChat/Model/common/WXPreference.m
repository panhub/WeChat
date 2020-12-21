//
//  WXPreference.m
//  MNChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXPreference.h"

static WXPreference *_preference;
#define kLoginPolicy    @"com.wx.login.type.key"
#define kAllowsDubug    @"com.wx.allows.dubug.key"
#define kPayword    @"com.wx.payment.password.key"
#define kLocalEvaluation    @"com.wx.allows.payment.fingerprint.payment.key"
#define kShakeBackground   @"com.wx.shake.background.image.key"
#define kShakeSound    @"com.wx.allows.shake.sound.key"
#define kPlayStyle    @"com.wx.music.play.style.key"

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
            _preference.allowsDebug = MN_IS_DEBUG ? [NSUserDefaults boolForKey:kAllowsDubug def:YES] : NO;
            _preference.allowsShakeSound = [[NSUserDefaults objectForKey:kShakeSound def:@(YES)] boolValue];
            _preference.playStyle = [[NSUserDefaults objectForKey:kPlayStyle def:@(WXPlayStyleDark)] integerValue];
        }
    });
    return _preference;
}

#pragma mark - Setter
- (void)setPayword:(NSString *)payword {
    _payword = payword.copy;
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        [userDefaults setObject:payword forKey:kPayword];
    }];
}

- (void)setAllowsLocalEvaluation:(BOOL)allowsLocalEvaluation {
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        [userDefaults setObject:@(allowsLocalEvaluation) forKey:kLocalEvaluation];
    }];
}

- (void)setAllowsDebug:(BOOL)allowsDebug {
    _allowsDebug = allowsDebug;
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        [userDefaults setBool:allowsDebug forKey:kAllowsDubug];
    }];
}

- (void)setLoginPolicy:(WXLoginPolicy)loginPolicy {
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        [userDefaults setInteger:loginPolicy forKey:kLoginPolicy];
    }];
}

- (void)setShakeBackgroundImage:(UIImage *)shakeBackgroundImage {
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        if (shakeBackgroundImage) {
            [userDefaults setImage:shakeBackgroundImage forKey:kShakeBackground];
        } else {
            [userDefaults removeObjectForKey:kShakeBackground];
        }
    }];
}

- (void)setAllowsShakeSound:(BOOL)allowsShakeSound {
    _allowsShakeSound = allowsShakeSound;
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        [userDefaults setObject:@(allowsShakeSound) forKey:kShakeSound];
    }];
}

- (void)setPlayStyle:(WXPlayStyle)playStyle {
    _playStyle = playStyle;
    [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
        [userDefaults setObject:@(playStyle) forKey:kPlayStyle];
    }];
}

#pragma mark - Getter
- (NSString *)payword {
    if (!_payword) {
        _payword = [NSUserDefaults stringForKey:kPayword def:@"000000"];
    }
    return _payword;
}

- (BOOL)isAllowsLocalEvaluation {
    return [[NSUserDefaults objectForKey:kLocalEvaluation def:@(YES)] boolValue];
}

- (WXLoginPolicy)loginPolicy {
    return [NSUserDefaults.standardUserDefaults integerForKey:kLoginPolicy];
}

- (UIImage *)shakeBackgroundImage {
    return [NSUserDefaults.standardUserDefaults imageForKey:kShakeBackground def:[UIImage imageNamed:@"wx_shake_hide_img"]];
}

@end
