//
//  WXVideoPlayTopBar.h
//  MNKit
//
//  Created by Vincent on 2018/3/22.
//  Copyright © 2018年 小斯. All rights reserved.
//  视频播放顶部控制条

#import <UIKit/UIKit.h>
@class WXVideoPlayTopBar;

@protocol WXVideoPlayTopBarDelegate<NSObject>
@optional
- (void)playTopBarBackButtonClicked:(WXVideoPlayTopBar *)topbar;
@end

@interface WXVideoPlayTopBar : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, weak) id<WXVideoPlayTopBarDelegate> delegate;

@end
