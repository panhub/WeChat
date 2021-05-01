//
//  WXMyMomentYearModel.h
//  WeChat
//
//  Created by Vicent on 2021/4/18.
//  Copyright © 2021 Vincent. All rights reserved.
//  我的朋友圈年视图模型

#import <Foundation/Foundation.h>
#import "WXMyMomentViewModel.h"
#import "WXExtendViewModel.h"
@class WXMoment, WXProfile;

NS_ASSUME_NONNULL_BEGIN

@interface WXMyMomentYearModel : NSObject

/**年份*/
@property (nonatomic, copy) NSString *year;

/**区头高度*/
@property (nonatomic) CGFloat headerHeight;

/**年视图模型*/
@property (nonatomic, strong) WXExtendViewModel *yearViewModel;

/**点击事件*/
@property (nonatomic, copy) void (^touchEventHandler) (WXMoment *moment);

/**数据源*/
@property (nonatomic, strong, readonly) NSMutableArray <WXMyMomentViewModel *>*dataSource;

/**
 依据年份实例化视图模型
 @param year 年份
 */
- (instancetype)initWithYear:(NSString *)year;

/**
 添加朋友圈
 @param moment 朋友圈数据模型
 */
- (void)addMoment:(WXMoment *)moment;

/**
 加入新朋友圈=
 @param moment 朋友圈数据模型
 */
- (void)insertMoment:(WXMoment *)moment;

/**
 删除图片
 @param picture 图片数据模型
 @return 结果回调
 */
- (BOOL)del:(WXProfile *)picture;

@end

NS_ASSUME_NONNULL_END
