//
//  SEMainView.h
//  ShareExtension
//
//  Created by Vincent on 2020/1/24.
//  Copyright © 2020 Vincent. All rights reserved.
//  分享主视图

#import <UIKit/UIKit.h>
#import "SEButton.h"
@class SEMainView;

UIKIT_EXTERN NSString * const SEShareFavoriteUrlKey;
UIKIT_EXTERN NSString * const SEShareFavoriteTitleKey;
UIKIT_EXTERN NSString * const SEShareFavoriteTimeKey;
UIKIT_EXTERN NSString * const SEShareFavoriteImageKey;

@protocol SEMainViewDelegate <NSObject>
@optional;
- (void)mainViewButtonTouchUpInside:(SEButton *)button;
@end

@interface SEMainView : UIView
/**网页链接*/
@property (nonatomic, copy) NSString *url;
/**网页标题*/
@property (nonatomic, copy) NSString *title;
/**网页图片*/
@property (nonatomic, strong) UIImage *image;
/**事件代理*/
@property (nonatomic, weak) id<SEMainViewDelegate> delegate;

/**获取数据*/
- (NSDictionary *)jsonValue;

@end
