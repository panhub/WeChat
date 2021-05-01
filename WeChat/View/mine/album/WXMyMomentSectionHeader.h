//
//  WXMyMomentSectionHeader.h
//  WeChat
//
//  Created by Vicent on 2021/4/18.
//  Copyright © 2021 Vincent. All rights reserved.
//  我的朋友圈区头

#import "MNTableViewHeaderFooterView.h"
@class WXMyMomentYearModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXMyMomentSectionHeader : MNTableViewHeaderFooterView

/**视图模型*/
@property (nonatomic, strong) WXMyMomentYearModel *viewModel;

@end

NS_ASSUME_NONNULL_END
