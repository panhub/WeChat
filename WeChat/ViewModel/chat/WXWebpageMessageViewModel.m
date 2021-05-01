//
//  WXWebpageMessageViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/5/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXWebpageMessageViewModel.h"
#import "WXWebpage.h"

@implementation WXWebpageMessageViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    /// 网页模型
    WXWebpage *webpage = self.message.fileModel.content;
    self.imageViewModel.extend = webpage;
    /// 标题
    if (webpage.title.length) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:webpage.title];
        string.font = WXWebpageMsgTitleTextFont;
        string.color = WXWebpageMsgTitleTextColor;
        self.textLabelModel.content = string.copy;
        CGSize size = [string sizeOfLimitWidth:(WXMsgContentMaxWidth - WXWebpageMsgContentLeftMargin - WXWebpageMsgContentRightMargin)];
        // 限制两行
        size.height = MIN(WXWebpageMsgTitleTextFont.pointSize*2.f + 7.f, size.height);
        if (self.message.isMine) {
            self.textLabelModel.frame = CGRectMake(WXWebpageMsgContentLeftMargin, WXWebpageMsgContentTopBottomMargin, size.width, size.height);
        } else {
            self.textLabelModel.frame = CGRectMake(WXWebpageMsgContentRightMargin, WXWebpageMsgContentTopBottomMargin, size.width, size.height);
        }
    } else {
        self.textLabelModel.content = [[NSAttributedString alloc] initWithString:@""];
        if (self.message.isMine) {
            self.textLabelModel.frame = CGRectMake(WXWebpageMsgContentLeftMargin, WXWebpageMsgContentTopBottomMargin, 0.f, 0.f);
        } else {
            self.textLabelModel.frame = CGRectMake(WXWebpageMsgContentRightMargin, WXWebpageMsgContentTopBottomMargin, 0.f, 0.f);
        }
    }
    
    /// 链接
    if (webpage.url.length) {
        NSMutableAttributedString *string = webpage.url.attributedString.mutableCopy;
        string.font = WXWebpageMsgDetailTextFont;
        string.color = WXWebpageMsgDetailTextColor;
        self.detailLabelModel.content = string.copy;
        CGSize size = [string sizeOfLimitWidth:(WXMsgContentMaxWidth - WXWebpageMsgContentLeftMargin - WXWebpageMsgContentRightMargin - WXWebpageMsgImageViewWH - WXWebpageMsgDetailImageMargin)];
        size.height = MIN(size.height, MIN(WXWebpageMsgImageViewWH*2.f, WXWebpageMsgDetailTextFont.lineHeight*3.f));
        self.detailLabelModel.frame = CGRectMake(self.textLabelModel.frame.origin.x, CGRectGetMaxY(self.textLabelModel.frame) + WXWebpageMsgTextInterval, size.width, size.height);
    } else {
        self.detailLabelModel.content = [[NSAttributedString alloc] initWithString:@""];
        self.detailLabelModel.frame = CGRectMake(self.textLabelModel.frame.origin.x, CGRectGetMaxY(self.textLabelModel.frame) + WXWebpageMsgTextInterval, 0.f, 0.f);
    }
    
    /// 缩略图
    UIImage *image = webpage.image ? : [UIImage imageNamed:@"favorite_link"];
    self.thumbnailViewModel.content = image;
    if (self.message.isMine) {
        self.thumbnailViewModel.frame = CGRectMake(WXMsgContentMaxWidth - WXWebpageMsgContentRightMargin - WXWebpageMsgImageViewWH, CGRectGetMinY(self.detailLabelModel.frame), WXWebpageMsgImageViewWH, WXWebpageMsgImageViewWH);
    } else {
        self.thumbnailViewModel.frame = CGRectMake(WXMsgContentMaxWidth - WXWebpageMsgContentLeftMargin - WXWebpageMsgImageViewWH, CGRectGetMinY(self.detailLabelModel.frame), WXWebpageMsgImageViewWH, WXWebpageMsgImageViewWH);
    }
    
    CGFloat max = MAX(CGRectGetMaxY(self.detailLabelModel.frame), CGRectGetMaxY(self.thumbnailViewModel.frame));
    
    if (self.message.isMine) {
        self.imageViewModel.frame = CGRectMake(CGRectGetMinX(self.headButtonModel.frame) - WXMsgContentMaxWidth - WXMsgAvatarContentMinMargin, CGRectGetMinY(self.headButtonModel.frame), WXMsgContentMaxWidth, max + WXWebpageMsgContentTopBottomMargin);
    } else {
        self.imageViewModel.frame = CGRectMake(CGRectGetMaxX(self.headButtonModel.frame) + WXMsgAvatarContentMinMargin, CGRectGetMinY(self.headButtonModel.frame), WXMsgContentMaxWidth, max + WXWebpageMsgContentTopBottomMargin);
    }
}

#pragma mark - Getter
- (WXExtendViewModel *)thumbnailViewModel {
    if (!_thumbnailViewModel) {
        _thumbnailViewModel = [WXExtendViewModel new];
    }
    return _thumbnailViewModel;
}

@end
