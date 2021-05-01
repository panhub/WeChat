//
//  WXMyMomentCell.h
//  WeChat
//
//  Created by Vicent on 2021/4/18.
//  Copyright © 2021 Vincent. All rights reserved.
//  我的朋友圈Cell

#import "MNTableViewCell.h"
@class WXMyMomentViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXMyMomentCell : MNTableViewCell

/**视图模型*/
@property (nonatomic, strong) WXMyMomentViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
