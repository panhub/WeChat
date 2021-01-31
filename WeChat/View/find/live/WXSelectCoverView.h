//
//  WXSelectCoverView.h
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WXSelectCoverView, WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@protocol WXCoverViewDelegate <NSObject>
@optional
/**选择截图*/
- (void)coverViewDidSelectThumbnail:(WXDataValueModel *_Nonnull)model;
/**开始加载截图*/
- (void)coverViewBeginLoadThumbnails:(WXSelectCoverView *_Nonnull)coverView;
/**已经加载截图*/
- (void)coverViewDidLoadThumbnails:(WXSelectCoverView *_Nonnull)coverView;
/**加载截图失败*/
- (void)coverViewLoadThumbnailsFailed:(WXSelectCoverView *_Nonnull)coverView;
@end

@interface WXSelectCoverView : UIView

/**选择模型*/
@property (nonatomic, readonly, nullable) WXDataValueModel *coverModel;

/**交互代理*/
@property (nonatomic, weak) id<WXCoverViewDelegate> delegate;

/**
 实例化封面视图
 */
- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath;

/**
 加载视频截图
 */
- (void)loadThumbnails;

@end

NS_ASSUME_NONNULL_END
