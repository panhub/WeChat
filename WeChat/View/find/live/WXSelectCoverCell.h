//
//  WXSelectCoverCell.h
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "MNCollectionViewCell.h"
@class WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXSelectCoverCell : MNCollectionViewCell

/**数据模型*/
@property (nonatomic, strong) WXDataValueModel *model;

@end

NS_ASSUME_NONNULL_END
