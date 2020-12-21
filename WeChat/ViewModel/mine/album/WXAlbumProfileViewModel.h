//
//  WXAlbumProfileViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  相册配置模型

#import <Foundation/Foundation.h>
#import "WXAlbumViewModel.h"

@interface WXAlbumProfileViewModel : NSObject
/**
 数据源
 */
@property (nonatomic, strong) NSArray <WXAlbumViewModel *>*dataSource;
/**
 刷新表
 */
@property (nonatomic, copy) void (^reloadTableHandler) (void);

/**
 加载朋友圈相册
 */
- (void)loadData;

@end
