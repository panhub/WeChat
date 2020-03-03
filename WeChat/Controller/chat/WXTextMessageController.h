//
//  WXTextMessageController.h
//  MNChat
//
//  Created by Vincent on 2019/7/18.
//  Copyright © 2019 Vincent. All rights reserved.
//  文本消息浏览

#import "MNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXTextMessageController : MNBaseViewController

- (instancetype)initWithAttributedMessage:(NSAttributedString *)message;

@end

NS_ASSUME_NONNULL_END
