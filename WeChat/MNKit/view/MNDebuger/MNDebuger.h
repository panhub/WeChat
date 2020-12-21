//
//  MNDebuger.h
//  MNKit
//
//  Created by Vincent on 2019/9/18.
//  Copyright © 2019 Vincent. All rights reserved.
//  调试悬浮窗 <建议在DEBUG状态下使用>

#import <UIKit/UIKit.h>
#import "MNLoger.h"
#import "MNLogView.h"
#import "MNFPSLabel.h"
#import "MNStreamView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNDebuger : UIView
/**
 是否处于调试模式
*/
@property (nonatomic, class, readonly) BOOL isDebuging;

/**
 开启调试模式
*/
+ (void)startDebug;
/**
 结束调试模式
*/
+ (void)endDebug;
/**
 开启/关闭调试
 @param allowsDebug 是否开启
*/
+ (void)setAllowsDebug:(BOOL)allowsDebug;

@end

NS_ASSUME_NONNULL_END
