//
//  MNConfiguration.h
//  MNKit
//
//  Created by Vincent on 2017/8/16.
//  Copyright © 2017年 小斯. All rights reserved.
//  配置信息(以单例模式存在, 向外提供字体, 颜色等配置信息)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNConfiguration : NSObject
/**
 键盘是否弹起, 可监听
 */
@property (nonatomic, readonly) BOOL keyboardVisible;
/**
 是否首次安装(运行)
 进程未kill, 返回值固定
 */
@property (nonatomic, readonly, getter=isFirstInstall) BOOL firstInstall;

/** 
 *唯一实例化方法
 *@return 实例
 */
+ (instancetype)configuration;

/**
 加载预定资源
 */
- (void)loadData;

/**
 加载预定资源<分线程>
 @param completion 完成回调
 */
- (void)loadDataWithCompletionHandler:(nullable void(^)(void))completion;

/**
 键盘是否弹出
 @return 键盘是否弹出
 */
BOOL UIKeyboardVisible (void);

@end

NS_ASSUME_NONNULL_END
