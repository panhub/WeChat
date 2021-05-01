//
//  WXSpeechView.h
//  WeChat
//
//  Created by Vicent on 2021/3/21.
//  Copyright © 2021 Vincent. All rights reserved.
//  聊天-语音识别

#import <UIKit/UIKit.h>
#if __has_include(<Speech/Speech.h>)

NS_ASSUME_NONNULL_BEGIN

@interface WXSpeechView : UIView<MNAlertProtocol>

/**发送按钮事件*/
@property (nonatomic, copy, nullable) void (^speechHandler)(NSString *);

/**
 实例化语音识别视图
 @param speechHandler 发送事件回调
 @return 语音识别视图
 */
- (instancetype)initWithSpeechHandler:(void(^_Nullable)(NSString *_Nullable))speechHandler;

@end

NS_ASSUME_NONNULL_END
#endif
