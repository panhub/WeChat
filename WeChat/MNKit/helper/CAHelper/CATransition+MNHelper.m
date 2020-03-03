//
//  CATransition+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2020/2/8.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "CATransition+MNHelper.h"

/* 方块 */
CATransitionType const kCATransitionCube = @"cube";
/* 三角 */
CATransitionType const kCATransitionSuckEffect = @"suckEffect";
/* 水波抖动 */
CATransitionType const kCATransitionRippleEffect = @"rippleEffect";
/* 上翻页 */
CATransitionType const kCATransitionPageCurl = @"pageCurl";
/* 下翻页 */
CATransitionType const kCATransitionPageUnCurl = @"pageUnCurl";
/* 上下翻转 */
CATransitionType const kCATransitionOglFlip = @"oglFlip";
/* 镜头快门开 */
CATransitionType const kCATransitionCameraIrisHollowOpen = @"cameraIrisHollowOpen";
/* 镜头快门关 */
CATransitionType const kCATransitionCameraIrisHollowClose = @"cameraIrisHollowClose";
/// 以下API效果请慎用
/* 新版面在屏幕下方中间位置被释放出来覆盖旧版面 */
CATransitionType const kCATransitionSpewEffect = @"spewEffect";
/* 旧版面在屏幕左下方或右下方被吸走, 显示出下面的新版面 */
CATransitionType const kCATransitionGenieEffect = @"genieEffect";
/* 新版面在屏幕左下方或右下方被释放出来覆盖旧版面 */
CATransitionType const kCATransitionUnGenieEffect = @"unGenieEffect";
/* 版面以水平方向像龙卷风式转出来 */
CATransitionType const kCATransitionTwist = @"twist";
/* 版面垂直附有弹性的转出来 */
CATransitionType const kCATransitionTubey = @"tubey";
/* 旧版面360度旋转并淡出, 显示出新版面 */
CATransitionType const kCATransitionSwirl = @"swirl";
/* 旧版面淡出并显示新版面 */
CATransitionType const kCATransitionCharminUltra = @"charminUltra";
/* 新版面由小放大走到前面, 旧版面放大由前面消失 */
CATransitionType const kCATransitionZoomyIn = @"zoomyIn";
/* 新版面屏幕外面缩放出现, 旧版面缩小消失 */
CATransitionType const kCATransitionZoomyOut = @"zoomyOut";
/* 像按”home” 按钮的效果 */
CATransitionType const kCATransitionOglApplicationSuspend = @"oglApplicationSuspend";

@implementation CATransition (MNHelper)

+ (CATransition *)transitionWithType:(CATransitionType)type subtype:(CATransitionSubtype)subtype duration:(CFTimeInterval)duration
{
    CATransition *transition = [CATransition new];
    transition.type = type;
    if (subtype) transition.subtype = subtype;
    transition.duration = duration;
    return transition;
}

@end
