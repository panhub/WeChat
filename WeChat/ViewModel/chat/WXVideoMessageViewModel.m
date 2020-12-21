//
//  WXVideoMessageViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/6/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXVideoMessageViewModel.h"
#import "WXFileModel.h"

@implementation WXVideoMessageViewModel
- (instancetype)init {
    if (self = [super init]) {
        _progress = 0.f;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    WXFileModel *fileModel = self.message.fileModel;
    UIImage *image = fileModel.content;
    CGFloat x = 0.f;
    CGSize size = image.size;
    if (CGSizeIsEmpty(size)) {
        size = CGSizeZero;
    } else {
        if (size.width >= size.height && size.width > WXVideoMsgMaxWidth) {
            size = CGSizeMultiplyToWidth(size, WXVideoMsgMaxWidth);
        } else if (size.height > size.width && size.height > WXVideoMsgMaxHeight) {
            size = CGSizeMultiplyToHeight(size, WXVideoMsgMaxHeight);
        }
        if (self.message.isMine) {
            x = CGRectGetMinX(self.headButtonModel.frame) - size.width - WXMsgAvatarContentMaxMargin;
        } else {
            x = CGRectGetMaxX(self.headButtonModel.frame) + WXMsgAvatarContentMaxMargin;
        }
    }
    self.imageViewModel.frame = (CGRect){x, CGRectGetMinY(self.headButtonModel.frame), size};
    self.imageViewModel.content = image;
    self.imageViewModel.extend = fileModel;
    
    self.playViewModel.frame = CGRectMake((CGRectGetWidth(self.imageViewModel.frame) - WXVideoMsgPlayViewWH)/2.f, (CGRectGetHeight(self.imageViewModel.frame) - WXVideoMsgPlayViewWH)/2.f, WXVideoMsgPlayViewWH, WXVideoMsgPlayViewWH);
}

- (void)beginUpdateProgress {
    [self updateProgress];
}

- (void)pauseUpdateProgress {
    self.updateProgressHandler = nil;
}

- (void)finishUpdateProgress {
    self.progress = 1.f;
    self.state = WXVideoMessageStateNormal;
    self.updateProgressHandler = nil;
}

- (void)updateProgress {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        /// 开始更新进度
        if (self.progress >= 1.f) {
            [self finishUpdateProgress];
        } else {
            self.progress += .1f;
            if (self.updateProgressHandler) {
                self.updateProgressHandler(self.progress);
            }
            [self updateProgress];
        }
    });
}

#pragma mark - Getter
- (WXExtendViewModel *)playViewModel {
    if (!_playViewModel) {
        _playViewModel = [WXExtendViewModel new];
    }
    return _playViewModel;
}

#pragma mark - dealloc
- (void)dealloc {
    self.updateProgressHandler = nil;
}

@end
