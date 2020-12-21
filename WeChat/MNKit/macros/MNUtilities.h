//
//  MNUtilities.h
//  MNKit
//
//  Created by 冯盼 on 2019/10/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 CGFloat 相反数
 @param number 数字
 @return 相反数
 */
CG_INLINE CGFloat fopposite (CGFloat number) {
    return -1.f*number;
}

/**
 NSInteger 相反数
 @param number 数字
 @return 相反数
 */
CG_INLINE CGFloat opposite (NSInteger number) {
    return -1.f*number;
}

/**
 UIEdgeInsets快速创建
 @param inset 指定插入值
 @return UIEdgeInsets
 */
UIKIT_STATIC_INLINE UIEdgeInsets UIEdgeInsetWith (CGFloat inset) {
    return UIEdgeInsetsMake(inset, inset, inset, inset);
}

/**
 UIEdgeInsets取反
 @param inset 指定Inset
 @return 取反后的Inset
 */
UIKIT_STATIC_INLINE UIEdgeInsets UIEdgeInsetReverse (UIEdgeInsets inset) {
    return UIEdgeInsetsMake(-inset.top, -inset.left, -inset.bottom, -inset.right);
}

/**
 UIEdgeInsets倍数
 @param inset 指定Inset
 @param multiplier 倍数
 @return 倍数后的Inset
 */
UIKIT_STATIC_INLINE UIEdgeInsets UIEdgeInsetMultiplyByRatio (UIEdgeInsets inset, CGFloat multiplier) {
    return UIEdgeInsetsMake(inset.top*multiplier, inset.left*multiplier, inset.bottom*multiplier, inset.right*multiplier);
}

/**
 二分之一
 @param value 指定值
 @return value/2.f
 */
CG_INLINE CGFloat MEAN (CGFloat value) {
    return ((value)/2.f);
}

/**
 三分之一
 @param value 指定值
 @return value/3.f
 */
CG_INLINE CGFloat MEAN_3 (CGFloat value) {
    return ((value)/3.f);
}

/**
 三分之二
 @param value 指定值
 @return value/3.f*2.f
 */
CG_INLINE CGFloat MEAN_3_2 (CGFloat value) {
    return ((value)/3.f*2.f);
}

/**
 随机整数
 @param value 范围值
 @return 范围随机值
 */
UIKIT_STATIC_INLINE NSInteger RandomValue (NSInteger value) {
    return (arc4random()%(value));
}

/**
 角度转弧度
 @param degrees 角度
 @return 弧度
 */
CG_INLINE CGFloat DegreeToRadian (CGFloat degrees) {
    return (M_PI*(degrees)/180.f);
}

/**
 弧度转角度
 @param radians 弧度
 @return 角度
 */
CG_INLINE CGFloat RadianToDegree (CGFloat radians) {
    return ((radians*180.f)/M_PI);
}

/**
 取尺寸最大值
 @param size 尺寸
 @return 最大值
 */
CG_INLINE CGFloat CGSizeMax (CGSize size) {
    return MAX(size.width, size.height);
}

/**
 取尺寸最小值
 @param size 尺寸
 @return 最小值
 */
CG_INLINE CGFloat CGSizeMin (CGSize size) {
    return MIN(size.width, size.height);
}

/**
 判断尺寸是否为空
 @param size 尺寸
 @return 是否为空
 */
CG_INLINE BOOL CGSizeIsEmpty (CGSize size) {
    return (isnan(size.width) || size.width <= 0.f || isnan(size.height) || size.height <= 0.f);
}

/**
判断尺寸是否存在 NaN
@param size 尺寸
@return 是否存在 NaN
*/
CG_INLINE BOOL CGSizeIsNaN(CGSize size) {
    return (isnan(size.width) || isnan(size.height));
}

/**
判断尺寸是否存在 infinite
@param size 尺寸
@return 是否存在 infinite
*/
CG_INLINE BOOL CGSizeIsInf(CGSize size) {
    return (isinf(size.width) || isinf(size.height));
}

/**
判断尺寸是否合法
@param size 尺寸
@return 是否合法
*/
CG_INLINE BOOL CGSizeIsValidated(CGSize size) {
    return !CGSizeIsEmpty(size) && !CGSizeIsInf(size) && !CGSizeIsNaN(size);
}

/**
 按比例获取尺寸
 @param size 指定尺寸
 @param multiplier 比例
 @return 比例尺寸
 */
CG_INLINE CGSize CGSizeMultiplyByRatio (CGSize size, CGFloat multiplier) {
    return CGSizeMake(size.width*multiplier, size.height*multiplier);
}

/**
 缩放到指定宽度的比例尺寸
 @param size 指定尺寸
 @param width 指定宽度
 @return 比例尺寸
 */
CG_INLINE CGSize CGSizeMultiplyToWidth (CGSize size, CGFloat width) {
    if (width <= 0.f || CGSizeIsEmpty(size)) return CGSizeZero;
    return CGSizeMake(width, size.height/(size.width/width));
}

/**
 缩放到指定高度的比例尺寸
 @param size 指定尺寸
 @param height 指定高度
 @return 比例尺寸
 */
CG_INLINE CGSize CGSizeMultiplyToHeight (CGSize size, CGFloat height) {
    if (height <= 0.f || CGSizeIsEmpty(size)) return CGSizeZero;
    return CGSizeMake(size.width/(size.height/height), height);
}

/**
最小值缩放到指定大小
@param size 指定尺寸
@param min 最小值
@return 比例尺寸
*/
CG_INLINE CGSize CGSizeMultiplyToMin (CGSize size, CGFloat min) {
    return size.width <= size.height ? CGSizeMultiplyToWidth(size, min) : CGSizeMultiplyToHeight(size, min);
}

/**
最大值缩放到指定大小
@param size 指定尺寸
@param max 最大值
@return 比例尺寸
*/
CG_INLINE CGSize CGSizeMultiplyToMax (CGSize size, CGFloat max) {
    return size.width >= size.height ? CGSizeMultiplyToWidth(size, max) : CGSizeMultiplyToHeight(size, max);
}

/**
 CGSize - CGRect
 @param size 尺寸
 @return {CGPointZero, size}
 */
CG_INLINE CGRect CGRectFillToSize (CGSize size) {
    return (CGRect){CGPointZero, size};
}

/**
 在指定位置中适应大小
 @param rect 位置
 @param size 适应大小
 @return 最终位置
 */
CG_INLINE CGRect CGRectFitToSize (CGRect rect, CGSize size) {
    CGFloat x = (rect.size.width - size.width)/2.f;
    x = MAX(0.f, x);
    CGFloat y = (rect.size.height - size.height)/2.f;
    y = MAX(0.f, y);
    return (CGRect){x, y, size};
}

/**
 获取块内位置
 @param rect 外围
 @param insets 块约束
 @return 位置
 */
CG_INLINE CGRect CGRectFitInset(CGRect rect, UIEdgeInsets insets) {
    rect.origin.x += insets.left;
    rect.size.width -= insets.left + insets.right;
    rect.origin.y += insets.top;
    rect.size.height -= insets.top + insets.bottom;
    rect.size.width = MAX(rect.size.width, 0.f);
    rect.size.height = MAX(rect.size.height, 0.f);
    return rect;
}

/**
 根据中心点与边长构造CGRect
 @param center 中心点
 @param side 边长
 @return CGRect结构体
 */
CG_INLINE CGRect CGRectCenterSide(CGPoint center, CGFloat side) {
    CGRect rect = CGRectZero;
    rect.origin.x = center.x - fabs(side)/2.f;
    rect.origin.y = center.y - fabs(side)/2.f;
    rect.size.width = fabs(side);
    rect.size.height = fabs(side);
    return rect;
}

/**
 根据中心点与大小构造CGRect
 @param center 中心点
 @param size 大小
 @return CGRect结构体
 */
CG_INLINE CGRect CGRectCenterSize(CGPoint center, CGSize size) {
    CGRect rect = CGRectZero;
    rect.origin.x = center.x - size.width/2.f;
    rect.origin.y = center.y - size.height/2.f;
    rect.size = size;
    return rect;
}

/**
 依据原点大小构造CGRect
 @param origin 原点
 @param size 大小
 @return CGRect结构体
 */
CG_INLINE CGRect CGRectOriginSize(CGPoint origin, CGSize size) {
    CGRect rect = CGRectZero;
    rect.origin = origin;
    rect.size = size;
    return rect;
}

/**
 将结构体放大指定倍数
 @param rect 结构体
 @param multiplier 指定倍数
 @return CGRect结构体
 */
CG_INLINE CGRect CGRectMultiplyByRatio(CGRect rect, CGFloat multiplier) {
    return CGRectMake(rect.origin.x*multiplier, rect.origin.y*multiplier, rect.size.width*multiplier, rect.size.height*multiplier);
}

/**
 当前语言
 @return 当前语言
 */
UIKIT_STATIC_INLINE NSString * NSLocaleLanguage (void) {
    return [[NSLocale preferredLanguages] firstObject];
}

#ifdef __cplusplus
extern "C" {
#endif
/**
 CALayerContentsGravity ==> UIViewContentMode
 @param gravity <CALayerContentsGravity>
*/
UIViewContentMode UIViewContentModeFromGravity(CALayerContentsGravity gravity);

/**
 UIViewContentMode ==> CALayerContentsGravity
 @param contentMode <UIViewContentMode>
 */
CALayerContentsGravity CALayerContentsGravityFromMode(UIViewContentMode contentMode);

/**
 键盘位置改变通知解析
 @param notification 通知
 @param completion 返回解析信息
 */
void UIKeyboardWillChangeFrameConvert (NSNotification *notification, void(^completion)(CGRect from, CGRect to, CGFloat duration, UIViewAnimationOptions options));

/**
 转化可与 __IPHONE_OS_VERSION_MAX_ALLOWED 比较版本号
 @param verson 版本号
 @return 转化后的版本
 */
NSUInteger __IPHONE (CGFloat verson);

/**
比较系统框架最大版本是否>=某版本
@param verson 版本号
@return 与系统框架最大版本比较结果
*/
BOOL __IPHONE_MAX_ALLOWED (CGFloat verson);

#ifdef __cplusplus
}
#endif
