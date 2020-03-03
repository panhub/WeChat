//
//  WXLocationMessageViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXLocationMessageViewModel.h"
#import "WXMapLocation.h"

@implementation WXLocationMessageViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    WXMapLocation *location = self.message.fileModel.content;
    CGFloat margin = WXLocationMsgTextBottomMaxMargin;
    self.imageViewModel.extend = location;
    if (location) {
        /// 标题
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:location.name];
        string.font = WXLocationMsgTitleTextFont;
        string.color = WXLocationMsgTitleTextColor;
        self.textLabelModel.content = string.copy;
        CGSize size = [string sizeOfLimitWidth:(WXMsgContentMaxWidth() - WXLocationMsgTextLeftMargin - WXLocationMsgTextRightMargin)];
        if (self.message.isMine) {
            self.textLabelModel.frame = CGRectMake(WXLocationMsgTextLeftMargin, WXLocationMsgTextTopMargin, size.width, size.height);
        } else {
            self.textLabelModel.frame = CGRectMake(WXLocationMsgTextRightMargin, WXLocationMsgTextTopMargin, size.width, size.height);
        }
        
        /// 描述
        if (location.address.length) {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:location.address];
            string.font = WXLocationMsgDetailTextFont;
            string.color = WXLocationMsgDetailTextColor;
            self.detailLabelModel.content = string.copy;
            CGSize size = [string sizeOfLimitWidth:(WXMsgContentMaxWidth() - WXLocationMsgTextLeftMargin - WXLocationMsgTextRightMargin)];
            CGFloat interval = self.textLabelModel.frame.size.height > 0.f ? WXLocationMsgTextInterval : 0.f;
            self.detailLabelModel.frame = CGRectMake(self.textLabelModel.frame.origin.x, CGRectGetMaxY(self.textLabelModel.frame) + interval, size.width, size.height);
            margin = WXLocationMsgTextBottomMinMargin;
        } else {
            self.detailLabelModel.frame = self.textLabelModel.frame;
            self.detailLabelModel.content = [[NSAttributedString alloc] initWithString:@""];
        }
    } else {
        self.textLabelModel.frame = CGRectZero;
        self.textLabelModel.content = [[NSAttributedString alloc] initWithString:@""];
        self.detailLabelModel.frame = CGRectZero;
        self.detailLabelModel.content = [[NSAttributedString alloc] initWithString:@""];
    }
    
    UIImage *image = location.snapshot;
    CGFloat interval = self.detailLabelModel.frame.size.height > 0.f ? margin : 0.f;
    self.locationViewModel.content = image;
    if (image) {
        self.locationViewModel.frame = (CGRect){0.f, CGRectGetMaxY(self.detailLabelModel.frame) + interval, CGSizeMultiplyToWidth(image.size, WXMsgContentMaxWidth())};
    } else {
        self.locationViewModel.frame = CGRectMake(0.f, CGRectGetMaxY(self.detailLabelModel.frame) + interval, WXMsgContentMaxWidth(), 0.f);
    }
    
    if (self.message.isMine) {
        self.imageViewModel.frame = CGRectMake(CGRectGetMinX(self.headButtonModel.frame) - WXMsgContentMaxWidth() - WXMsgAvatarContentMinMargin, CGRectGetMinY(self.headButtonModel.frame), WXMsgContentMaxWidth(), CGRectGetMaxY(self.locationViewModel.frame));
    } else {
        self.imageViewModel.frame = CGRectMake(CGRectGetMaxX(self.headButtonModel.frame) + WXMsgAvatarContentMinMargin, CGRectGetMinY(self.headButtonModel.frame), WXMsgContentMaxWidth(), CGRectGetMaxY(self.locationViewModel.frame));
    }
}

#pragma mark - Getter
- (WXExtendViewModel *)locationViewModel {
    if (!_locationViewModel) {
        _locationViewModel = [WXExtendViewModel new];
    }
    return _locationViewModel;
}

@end
