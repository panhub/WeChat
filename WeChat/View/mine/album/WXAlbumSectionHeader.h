//
//  WXAlbumSectionHeader.h
//  WeChat
//
//  Created by Vicent on 2021/4/16.
//  Copyright © 2021 Vincent. All rights reserved.
//  相册区头视图

#import "MNTableViewHeaderFooterView.h"
@class WXYearViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXAlbumSectionHeader : MNTableViewHeaderFooterView

/**视图模型*/
@property (nonatomic, strong) WXYearViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
