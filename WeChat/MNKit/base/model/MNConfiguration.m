//
//  MNConfiguration.m
//  MNKit
//
//  Created by Vincent on 2017/8/16.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "MNConfiguration.h"

static MNConfiguration *_configuration;
NSString * const MNConfigFirstRunKey = @"com.mn.configuration.first.run.key";
NSString * const MNConfigFirstInstallKey = @"com.mn.first.configuration.install.key";

@implementation MNConfiguration

+ (instancetype)configuration {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_configuration) {
            _configuration = [[MNConfiguration alloc] init];
        }
    });
    return _configuration;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _configuration = [super allocWithZone:zone];
    });
    return _configuration;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _configuration = [super init];
        if (_configuration) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:MNConfigFirstRunKey]) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:MNConfigFirstInstallKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:MNConfigFirstRunKey];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:MNConfigFirstInstallKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardDidShowNotification:)
                                                         name:UIKeyboardDidShowNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardDidHideNotification:)
                                                         name:UIKeyboardDidHideNotification
                                                       object:nil];
        }
    });
    return _configuration;
}

#pragma mark - 加载资源
- (void)loadData {
    [MNEmojiManager defaultManager];
}

- (void)loadDataWithCompletionHandler:(void(^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self loadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    });
}

#pragma mark - FirstInstall
- (BOOL)isFirstInstall {
    return [[NSUserDefaults standardUserDefaults] boolForKey:MNConfigFirstInstallKey];
}

#pragma mark - KeyboardNotification
- (void)keyboardDidShowNotification:(NSNotification *)not {
    [self willChangeValueForKey:@"keyboardVisible"];
    self->_keyboardVisible = YES;
    [self didChangeValueForKey:@"keyboardVisible"];
}

- (void)keyboardDidHideNotification:(NSNotification *)not {
    [self willChangeValueForKey:@"keyboardVisible"];
    self->_keyboardVisible = NO;
    [self didChangeValueForKey:@"keyboardVisible"];
}

#pragma mark - 键盘状态
inline BOOL UIKeyboardVisible (void) {
    return [[MNConfiguration configuration] keyboardVisible];
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
