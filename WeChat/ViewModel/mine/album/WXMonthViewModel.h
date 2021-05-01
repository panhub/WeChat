//
//  WXMonthViewModel.h
//  WeChat
//
//  Created by Vicent on 2021/4/16.
//  Copyright © 2021 Vincent. All rights reserved.
//  相册月视图模型

#import <Foundation/Foundation.h>
#import "WXExtendViewModel.h"
#import "WXProfile.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMonthViewModel : NSObject

/**表格高度*/
@property (nonatomic, readonly) CGFloat rowHeight;

/**月份*/
@property (nonatomic, copy) NSString *month;

/**数据源*/
@property (nonatomic, strong, readonly) NSMutableArray <WXProfile *>*pictures;

/**图片视图模型集合*/
@property (nonatomic, strong, readonly) NSMutableArray <WXExtendViewModel *>*dataSource;

/**月视图模型*/
@property (nonatomic, strong) WXExtendViewModel *monthViewModel;

/**配图点击事件*/
@property (nonatomic, copy) void (^touchEventHandler) (WXProfile *picture);

/**
 依据月份实例化视图模型
 @param timestamp 时间
 */
- (instancetype)initWithTimestamp:(NSString *)timestamp;

/**
 刷新视图约束
 */
- (void)layoutSubviews;

@end

NS_ASSUME_NONNULL_END
