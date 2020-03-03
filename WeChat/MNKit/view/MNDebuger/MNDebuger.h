//
//  MNDebuger.h
//  MNFoundation
//
//  Created by Vincent on 2019/9/18.
//  Copyright © 2019 XiaoSi. All rights reserved.
//  调试悬浮窗<单例形式>

#import <UIKit/UIKit.h>
#import "MNLoger.h"
#import "MNLogView.h"
#import "MNFPSLabel.h"
#import "MNStreamView.h"

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
 @param allowDebug 是否开启
*/
+ (void)setAllowsDebug:(BOOL)allowDebug;

@end
