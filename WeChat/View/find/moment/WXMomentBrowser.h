//
//  WXMomentBrowser.h
//  WeChat
//
//  Created by Vincent on 2019/9/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈浏览

#import "MNAssetBrowser.h"
@class WXMomentViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXMomentBrowser : MNAssetBrowser

- (instancetype)initWithViewModel:(WXMomentViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
