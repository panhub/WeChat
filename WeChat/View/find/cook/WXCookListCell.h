//
//  WXCookListCell.h
//  MNChat
//
//  Created by Vincent on 2019/6/20.
//  Copyright © 2019 Vincent. All rights reserved.
//  菜谱菜单Cell

#import "MNCollectionViewCell.h"
@class WXCook;

NS_ASSUME_NONNULL_BEGIN

@interface WXCookListCell : MNCollectionViewCell

/**数据模型*/
@property (nonatomic, strong) WXCook *model;

@end

NS_ASSUME_NONNULL_END
