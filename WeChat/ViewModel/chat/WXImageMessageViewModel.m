//
//  WXImageMessageViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXImageMessageViewModel.h"

@implementation WXImageMessageViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    UIImage *image = self.message.fileModel.content;
    CGFloat x = 0.f;
    CGSize imageSize = image.size;
    if (CGSizeIsEmpty(imageSize)) {
        imageSize = CGSizeZero;
    } else {
        if (imageSize.width >= imageSize.height && imageSize.width > WXImageMsgMaxWidth) {
            imageSize = CGSizeMultiplyToWidth(imageSize, WXImageMsgMaxWidth);
        } else if (imageSize.height > imageSize.width && imageSize.height > WXImageMsgMaxHeight) {
            imageSize = CGSizeMultiplyToHeight(imageSize, WXImageMsgMaxHeight);
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
