//
//  WXCookListCell.h
//  MNChat
//
//  Created by Vincent on 2019/6/20.
//  Copyright © 2019 Vincent. All rights reserved.
//  菜谱菜单Cell

#import "MNCollectionViewCell.h"
@class WXCookModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXCookListCell : MNCollectionViewCell

@property (nonatomic, strong) WXCookModel *model;

@end

NS_ASSUME_NONNULL_END
