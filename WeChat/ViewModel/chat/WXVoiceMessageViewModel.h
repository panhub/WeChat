//
//  WXVoiceMessageViewModel.h
//  WeChat
//
//  Created by Vincent on 2019/6/11.
//  Copyright © 2019 Vincent. All rights reserved.
//  语音消息视图模型

#import "WXMessageViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXVoiceMessageViewModel : WXMessageViewModel
/**
 是否在播放语音
 */
@property (nonatomic, getter=isPlaying) BOOL playing;
/**
 语音播放动画图片
 */
@property (nonatomic, strong) NSArray <UIImage *>*images;
/**
 语音图片
 */
@property (nonatomic, strong) WXExtendViewModel *voiceViewModel;

@end

NS_ASSUME_NONNULL_END
