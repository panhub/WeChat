//
//  WXYearViewModel.h
//  WeChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  相册年视图模型

#import <Foundation/Foundation.h>
#import "WXExtendViewModel.h"
#import "WXMonthViewModel.h"
#import "WXMoment.h"

@interface WXYearViewModel : NSObject

/**年份*/
@property (nonatomic, copy) NSString *year;

/**区头高度*/
@property (nonatomic) CGFloat headerHeight;

/**年视图模型*/
@property (nonatomic, strong) WXExtendViewModel *yearViewModel;

/**数据源*/
@property (nonatomic, strong, readonly) NSMutableArray <WXMonthViewModel *>*dataSource;

/**配图点击事件*/
@property (nonatomic, copy) void (^touchEventHandler) (WXProfile *picture);

/**
 依据年份实例化视图模型
 @param year 年份
 */
- (instancetype)initWithYear:(NSString *)year;

/**
 添加朋友圈图片
 @param moment 朋友圈数据模型
 */
- (void)addMoment:(WXMoment *)moment;

/**
 添加朋友圈图片
 @param moment 朋友圈数据模型
 */
- (void)insertMoment:(WXMoment *)moment;

/**
 删除图片
 @param picture 图片数据模型
 @return 结果返回
 */
- (BOOL)del:(WXProfile *)picture;

@end

