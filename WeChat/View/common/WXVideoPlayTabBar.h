//
//  WXVideoPlayTabBar.h
//  MNKit
//
//  Created by Vincent on 2018/3/22.
//  Copyright © 2018年 小斯. All rights reserved.
//  视频播放底部控制条

#import <UIKit/UIKit.h>
@class WXVideoPlayTabBar;

@protocol WXVideoPlayTabBarDelegate<MNSliderDelegate>
@optional 
- (void)playTabBarWillChangePlayState:(WXVideoPlayTabBar *)tabbar;
@end

@interface WXVideoPlayTabBar : UIView

@property (nonatomic, weak) id<WXVideoPlayTabBarDelegate> delegate;

@property (nonatomic) CGFloat progress;

@property (nonatomic) NSTimeInterval timeInterval;

@property (nonatomic) NSTimeInterval duration;

@property (nonatomic, getter=isPlay) BOOL play;

@end
