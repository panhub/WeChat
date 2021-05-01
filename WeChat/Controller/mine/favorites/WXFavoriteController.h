//
//  WXFavoriteController.h
//  WeChat
//
//  Created by Vincent on 2019/4/29.
//  Copyright © 2019 Vincent. All rights reserved.
//  收藏

#import "MNSearchViewController.h"
#import "WXFavorite.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXFavoriteController : MNSearchViewController

/**收藏选择回调*/
@property (nonatomic, copy, nullable) void (^selectedHandler) (WXFavorite *);

@end
NS_ASSUME_NONNULL_END
