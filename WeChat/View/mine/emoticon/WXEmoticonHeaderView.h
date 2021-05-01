//
//  WXEmoticonHeaderView.h
//  WeChat
//
//  Created by Vincent on 2019/7/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  表情详情表头

#import <UIKit/UIKit.h>
@class MNEmojiPacket;

@interface WXEmoticonHeaderView : UIView

@property (nonatomic, strong) MNEmojiPacket *packet;

@end
