//
//  WXMineEmoticonCell.h
//  WeChat
//
//  Created by Vincent on 2019/7/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  我的表情Cell

#import "MNTableViewCell.h"
@class WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXMineEmoticonCell : MNTableViewCell

@property (nonatomic, strong) MNEmojiPacket *packet;

@end

NS_ASSUME_NONNULL_END
