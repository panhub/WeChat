//
//  UIApplication+MNNetworkActivity.h
//  MNKit
//
//  Created by Vicent on 2020/8/5.
//  网络指示图管理

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (MNNetworkActivity)

/**打开网络指示器*/
+ (void)startNetworkActivityIndicating;

/**关闭网络指示器*/
+ (void)closeNetworkActivityIndicating;

@end

NS_ASSUME_NONNULL_END
