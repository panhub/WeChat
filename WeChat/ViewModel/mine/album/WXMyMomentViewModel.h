//
//  WXMyMomentViewModel.h
//  WeChat
//
//  Created by Vicent on 2021/4/18.
//  Copyright © 2021 Vincent. All rights reserved.
//  我的朋友圈视图模型

#import <Foundation/Foundation.h>
#import "WXExtendViewModel.h"
@class WXMoment;

NS_ASSUME_NONNULL_BEGIN

@interface WXMyMomentViewModel : NSObject

/**年*/
@property (nonatomic, copy) NSString *year;

/**月*/
@property (nonatomic, copy) NSString *month;

/**日*/
@property (nonatomic, copy) NSString *day;

/**朋友圈*/
@property (nonatomic, strong) WXMoment *moment;

/**高度*/
@property (nonatomic, readonly) CGFloat rowHeight;

/**是否处于第一位置*/
@property (nonatomic, getter=isFirst) BOOL first;

/**是否处于最后位置*/
@property (nonatomic, getter=isLast) BOOL last;

/**日期视图模型*/
@property (nonatomic, strong) WXExtendViewModel *dateViewModel;

/**位置视图模型*/
@property (nonatomic, strong) WXExtendViewModel *locationViewModel;

/**图片视图模型*/
@property (nonatomic, strong) WXExtendViewModel *pictureViewModel;

/**内容背景视图模型*/
@property (nonatomic, strong) WXExtendViewModel *backgroundViewModel;

/**内容视图模型*/
@property (nonatomic, strong) WXExtendViewModel *contentViewModel;

/**图片数量视图模型*/
@property (nonatomic, strong) WXExtendViewModel *numberViewModel;

/**网页视图模型*/
@property (nonatomic, strong) WXExtendViewModel *webViewModel;

/**点击事件*/
@property (nonatomic, copy) void (^touchEventHandler) (WXMoment *moment);

/**
 依据朋友圈实例化视图模型
 @param moment 朋友圈实例
 */
- (instancetype)initWithMoment:(WXMoment *)moment;

/**约束视图信息*/
- (void)layoutSubviews;

@end

NS_ASSUME_NONNULL_END
