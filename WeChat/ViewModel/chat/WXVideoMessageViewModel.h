//
//  WXVideoMessageViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/6/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  视频消息

#import "WXMessageViewModel.h"

typedef NS_ENUM(NSInteger, WXVideoMessageState) {
    WXVideoMessageStateNormal = 0,
    WXVideoMessageStateUpdating
};

@interface WXVideoMessageViewModel : WXMessageViewModel
/**
 进度视图大小
 */
@property (nonatomic, strong) WXExtendViewModel *playViewModel;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) WXVideoMessageState state;

@property (nonatomic, copy) void(^updateProgressHandler) (CGFloat progress);

- (void)beginUpdateProgress;

- (void)pauseUpdateProgress;

@end
