//
//  CATransition+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2020/2/8.
//  Copyright © 2020 Vincent. All rights reserved.
//  系统转场<谨慎使用>

#import <QuartzCore/QuartzCore.h>

/* 转场类型 */
/* 方块 */
CA_EXTERN CATransitionType const kCATransitionCube;
/* 三角 */
CA_EXTERN CATransitionType const kCATransitionSuckEffect;
/* 水波抖动 */
CA_EXTERN CATransitionType const kCATransitionRippleEffect;
/* 上翻页 */
CA_EXTERN CATransitionType const kCATransitionPageCurl;
/* 下翻页 */
CA_EXTERN CATransitionType const kCATransitionPageUnCurl;
/* 上下翻转 */
CA_EXTERN CATransitionType const kCATransitionOglFlip;
/* 镜头快门开 */
CA_EXTERN CATransitionType const kCATransitionCameraIrisHollowOpen;
/* 镜头快门关 */
CA_EXTERN CATransitionType const kCATransitionCameraIrisHollowClose;
/// 以下API效果请慎用
/* 新版面在屏幕下方中间位置被释放出来覆盖旧版面 */
CA_EXTERN CATransitionType const kCATransitionSpewEffect;
/* 旧版面在屏幕左下方或右下方被吸走, 显示出下面的新版面 */
CA_EXTERN CATransitionType const kCATransitionGenieEffect;
/* 新版面在屏幕左下方或右下方被释放出来覆盖旧版面 */
CA_EXTERN CATransitionType const kCATransitionUnGenieEffect;
/* 版面以水平方向像龙卷风式转出来 */
CA_EXTERN CATransitionType const kCATransitionTwist;
/* 版面垂直附有弹性的转出来 */
CA_EXTERN CATransitionType const kCATransitionTubey;
/* 旧版面360度旋转并淡出, 显示出新版面 */
CA_EXTERN CATransitionType const kCATransitionSwirl;
/* 旧版面淡出并显示新版面 */
CA_EXTERN CATransitionType const kCATransitionCharminUltra;
/* 新版面由小放大走到前面, 旧版面放大由前面消失 */
CA_EXTERN CATransitionType const kCATransitionZoomyIn;
/* 新版面屏幕外面缩放出现, 旧版面缩小消失 */
CA_EXTERN CATransitionType const kCATransitionZoomyOut;
/* 像按”home” 按钮的效果 */
CA_EXTERN CATransitionType const kCATransitionOglApplicationSuspend;

@interface CATransition (MNHelper)

/**
 转场动画
 @param type 转场类型
 @param subtype 转场方向
 @param duration 时长
 @return 转场动画 实例
*/
+ (CATransition *)transitionWithType:(CATransitionType)type subtype:(CATransitionSubtype)subtype duration:(CFTimeInterval)duration;

@end
