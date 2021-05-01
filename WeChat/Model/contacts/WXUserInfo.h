//
//  WXUserInfo.h
//  WeChat
//
//  Created by Vicent on 2021/4/29.
//  Copyright © 2021 Vincent. All rights reserved.
//  用户详情界面模型

#import <Foundation/Foundation.h>
@class WXProfile;

FOUNDATION_EXTERN const CGFloat WXUserCellPhotoWH;
FOUNDATION_EXTERN const CGFloat WXUserCellPhotoRowHeight;
FOUNDATION_EXTERN const CGFloat WXUserCellRowHeight;
FOUNDATION_EXTERN const CGFloat WXUserCellTitleMargin;
FOUNDATION_EXTERN const CGFloat WXUserCellSubtitleMargin;
FOUNDATION_EXTERN const NSInteger WXUserCellPhotoMaxCount;

NS_ASSUME_NONNULL_BEGIN

@interface WXUserInfo : NSObject
/**
 类型标题
 */
@property (nonatomic) CGFloat rowHeight;
/**
 表格线约束
 */
@property (nonatomic) UIEdgeInsets separatorInset;
/**
 图片
 */
@property (nonatomic, copy) UIImage *image;
/**
 朋友圈展示
 */
@property (nonatomic, copy) NSArray <WXProfile *>*photos;
/**
 表格类型
 */
@property (nonatomic, copy) NSString *cell;
/**
 类型标题
 */
@property (nonatomic, copy) NSString *title;
/**
 类型标题
 */
@property (nonatomic, copy) NSString *subtitle;

@end

NS_ASSUME_NONNULL_END
