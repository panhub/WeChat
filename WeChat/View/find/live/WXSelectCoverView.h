//
//  WXSelectCoverView.h
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WXSelectCoverView;

NS_ASSUME_NONNULL_BEGIN

@protocol WXCoverViewDelegate <NSObject>
@optional
/**开始加载截图*/
- (void)coverViewBeginLoadThumbnails:(WXSelectCoverView *_Nonnull)coverView;
/**已经加载截图*/
- (void)coverViewDidLoadThumbnails:(WXSelectCoverView *_Nonnull)coverView;
/**加载截图失败*/
- (void)coverViewLoadThumbnailsFailed:(WXSelectCoverView *_Nonnull)coverView;
@end

@interface WXSelectCoverView : UIView

@property (nonatomic, copy) NSString *videoPath;

@property (nonatomic, weak) id<WXCoverViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame size:(CGSize)coverSize;

/**
 加载视频截图
 */
- (void)loadThumbnails;

@end

NS_ASSUME_NONNULL_END
