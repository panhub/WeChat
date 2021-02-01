//
//  WXCookRecipeViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/6/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  

#import <Foundation/Foundation.h>
#import "WXCook.h"
#import "WXCookMethodViewModel.h"

@interface WXCookRecipeViewModel : NSObject
/**
 将要刷新数据
 */
@property (nonatomic, copy) void (^prepareLoadDataHandler) (void);
/**
 已经刷新数据
 */
@property (nonatomic, copy) void (^didLoadDataHandler) (void);
/**
 刷新表事件
 */
@property (nonatomic, copy) void (^reloadTableHandler) (void);
/**
 数据模型
 */
@property (nonatomic, strong) WXCookRecipe *model;
/**
 数据源
 */
@property (nonatomic, strong) NSMutableArray <WXCookMethodViewModel *>*dataSource;
/**
 加载聊天数据
 */
- (void)loadData;

/**
 实例化入口
 @param model 数据模型
 @return 视图模型
 */
- (instancetype)initWithRecipeModel:(WXCookRecipe *)model;

/**
 获取分享图片
 @return 图片数组
 */
- (NSArray <UIImage *>*)shareImages;

@end

