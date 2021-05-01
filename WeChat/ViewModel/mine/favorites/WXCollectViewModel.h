//
//  WXCollectViewModel.h
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//  收藏夹控制器视图模型  

#import <Foundation/Foundation.h>
#import "WXFavoriteViewModel.h"
#import "WXFavorites.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXCollectViewModel : NSObject

/**数据源*/
@property (nonatomic, strong) NSMutableArray <WXFavoriteViewModel *>*dataSource;
/**
 刷新表事件
 */
@property (nonatomic, copy) void (^reloadTableHandler) (void);
/**
 刷新行事件
 */
@property (nonatomic, copy) void (^reloadRowHandler) (NSInteger row);
/**
 加载结束回调
 */
@property (nonatomic, copy) void (^didLoadFinishHandler) (BOOL hasMore);
/**
 图片点击事件
 */
@property (nonatomic, copy) void (^imageViewClickedHandler) (WXFavoriteViewModel *viewModel);
/**
 背景长按事件
 */
@property (nonatomic, copy) void (^backgroundLongPressHandler) (WXFavoriteViewModel *viewModel);


/**
 加载数据
 */
- (void)loadData;

/**
 重载数据
 */
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
