//
//  WXVideoFavoriteViewModel.h
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXFavoriteViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXVideoFavoriteViewModel : WXFavoriteViewModel

/**
 播放视图模型
 */
@property (nonatomic, strong, readonly) WXExtendViewModel *playViewModel;

@end

NS_ASSUME_NONNULL_END
