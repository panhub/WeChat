//
//  WXEmoticonPreviewController.h
//  MNChat
//
//  Created by Vincent on 2019/7/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  表情详情

#import "MNListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXEmoticonPreviewController : MNListViewController

- (instancetype)initWithPacket:(MNEmojiPacket *)packet;

@end

NS_ASSUME_NONNULL_END
