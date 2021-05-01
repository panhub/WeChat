//
//  WXAllEmoticonCell.m
//  WeChat
//
//  Created by Vincent on 2019/8/4.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAllEmoticonCell.h"

@implementation WXAllEmoticonCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIViewSetBorderRadius(self.contentView, 5.f, .8f, SEPARATOR_COLOR);
        self.imageView.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, UIEdgeInsetWith(self.contentView.width_mn/6.f));
    }
    return self;
}

- (void)setPacket:(MNEmojiPacket *)packet {
    self.imageView.image = packet.image;
}

@end
