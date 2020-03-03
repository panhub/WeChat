//
//  WXEmotionMessageViewModel.m
//  MNChat
//
//  Created by Vincent on 2020/2/17.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXEmotionMessageViewModel.h"

@implementation WXEmotionMessageViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    UIImage *image = self.message.fileModel.content;
    CGFloat x = 0.f;
    CGSize imageSize = image.size;
    if (CGSizeIsEmpty(imageSize)) {
        imageSize = CGSizeZero;
    } else {
        if (imageSize.width >= imageSize.height) {
            imageSize = CGSizeMultiplyToWidth(imageSize, 95.f);
        } else {
            imageSize = CGSizeMultiplyToHeight(imageSize, 95.f);
        }
        if (self.message.isMine) {
            x = CGRectGetMinX(self.headButtonModel.frame) - imageSize.width - WXMsgAvatarContentMaxMargin;
        } else {
            x = CGRectGetMaxX(self.headButtonModel.frame) + WXMsgAvatarContentMaxMargin;
        }
    }
    self.imageViewModel.frame = (CGRect){x, CGRectGetMinY(self.headButtonModel.frame), imageSize};
    self.imageViewModel.content = image;
    self.imageViewModel.extend = image;
}

@end
