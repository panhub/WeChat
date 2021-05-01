//
//  MNVideoTailorController.m
//  MNKit
//
//  Created by Vicent on 2020/7/29.
//

#import "MNVideoTailorController.h"
#import "MNVideoTailorView.h"
#import "MNVideoResizeButton.h"
#import "MNTailorTimeView.h"
#import "NSBundle+MNHelper.h"
#import "MNFileHandle.h"
#import "MNFileManager.h"
#import "MNAssetExporter+MNExportMetadata.h"

#define MNVideoTailorMargin 15.f
#define MNVideoTailorInterval 20.f
#define MNVideoTailorButtonTag  100

@interface MNVideoTailorController ()<MNVideoTailorViewDelegate, MNPlayerDelegate>
@property (nonatomic, strong) MNPlayer *player;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIControl *playControl;
@property (nonatomic, strong) MNPlayView *playView;
@property (nonatomic, strong) MNCropView *cropView;
@property (nonatomic, strong) UIImageView *badgeView;
@property (nonatomic, strong) MNTailorTimeView *timeView;
@property (nonatomic, strong) UIButton *resolutionButton;
@property (nonatomic, strong) MNVideoTailorView *tailorView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation MNVideoTailorController
- (instancetype)initWithVideoPath:(NSString *)videoPath {
    if (self = [super init]) {
        self.videoPath = videoPath.copy;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = UIColor.blackColor;
    
    UIButton *closeButton = [UIButton buttonWithFrame:CGRectZero image:[MNBundle imageForResource:@"player_close"] title:nil titleColor:nil titleFont:nil];
    closeButton.size_mn = CGSizeMake(30.f, 30.f);
    closeButton.left_mn = MNVideoTailorMargin;
    closeButton.bottom_mn = self.contentView.height_mn - MAX(MNVideoTailorMargin, MN_TAB_SAFE_HEIGHT + 7.f);
    closeButton.touchInset = UIEdgeInsetWith(-7.f);
    [closeButton setBackgroundImage:[closeButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:closeButton];
    
    UIButton *doneButton = [UIButton buttonWithFrame:CGRectZero image:[MNBundle imageForResource:@"player_done"] title:nil titleColor:nil titleFont:nil];
    doneButton.size_mn = closeButton.size_mn;
    doneButton.right_mn = self.contentView.width_mn - closeButton.left_mn;
    doneButton.centerY_mn = closeButton.centerY_mn;
    doneButton.touchInset = closeButton.touchInset;
    doneButton.enabled = NO;
    [doneButton setBackgroundImage:[doneButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(doneButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:doneButton];
    self.doneButton = doneButton;
    
    UILabel *timeLabel = [UILabel labelWithFrame:CGRectZero text:[NSString stringWithFormat:@"00:00/%@", [NSDate timeStringWithInterval:@(self.duration)]] alignment:NSTextAlignmentCenter textColor:MNVideoTailorWhiteColor font:[UIFont systemFontOfSize:12.f]];
    timeLabel.width_mn = doneButton.left_mn - closeButton.right_mn - closeButton.left_mn*2.f;
    timeLabel.height_mn = timeLabel.font.pointSize;
    timeLabel.centerX_mn = self.contentView.width_mn/2.f;
    timeLabel.centerY_mn = closeButton.centerY_mn;
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    UIControl *playControl = [[UIControl alloc] initWithFrame:CGRectMake(closeButton.left_mn, 0.f, 48.f, 48.f)];
    playControl.bottom_mn = closeButton.top_mn - MNVideoTailorInterval;
    playControl.userInteractionEnabled = NO;
    playControl.backgroundColor = MNVideoTailorBlackColor;
    [playControl.layer setMaskRadius:4.f byCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft];
    [playControl addTarget:self action:@selector(playControlTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:playControl];
    self.playControl = playControl;
    
    UIImageView *badgeView = [UIImageView imageViewWithFrame:CGRectZero image:[MNBundle imageForResource:@"player_play"]];
    badgeView.highlightedImage = [MNBundle imageForResource:@"player_pause"];
    badgeView.size_mn = CGSizeMultiplyToWidth(badgeView.image.size, 25.f);
    badgeView.center_mn = playControl.bounds_center;
    badgeView.userInteractionEnabled = NO;
    [playControl addSubview:badgeView];
    self.badgeView = badgeView;
    
    MNVideoTailorView *tailorView = [[MNVideoTailorView alloc] initWithFrame:CGRectMake(playControl.right_mn + 1.3f, 0.f, doneButton.right_mn - playControl.right_mn - 1.3f, playControl.height_mn)];
    tailorView.delegate = self;
    tailorView.videoPath = self.videoPath;
    tailorView.minTailorDuration = self.minTailorDuration;
    tailorView.maxTailorDuration = self.maxTailorDuration;
    tailorView.bottom_mn = playControl.bottom_mn;
    [tailorView setMaskRadius:4.f];
    tailorView.userInteractionEnabled = NO;
    [self.contentView addSubview:tailorView];
    self.tailorView = tailorView;
    
    // 计算播放尺寸
    CGFloat top = MN_STATUS_BAR_HEIGHT + MN_NAV_BAR_HEIGHT/2.f;
    CGFloat wh = 40.f; //比例调整按钮尺寸
    CGFloat width = self.contentView.width_mn;
    CGFloat height = playControl.top_mn - MNVideoTailorInterval - top;
    CGSize naturalSize = self.naturalSize;
    if (naturalSize.width >= naturalSize.height) {
        // 横向视频比例按钮放下面
        if (self.isAllowsResizeSize) height -= (wh + MNVideoTailorInterval);
        naturalSize = CGSizeMultiplyToWidth(naturalSize, width);
        if (naturalSize.height > height) {
            naturalSize = CGSizeMultiplyToHeight(naturalSize, height);
        }
    } else {
        // 纵向视频比例按钮放左侧
        if (self.isAllowsResizeSize) width -= (wh + MNVideoTailorInterval*2.f + MNVideoTailorMargin);
        naturalSize = CGSizeMultiplyToHeight(naturalSize, height);
        if (naturalSize.width > width) {
            naturalSize = CGSizeMultiplyToWidth(naturalSize, width);
        }
    }
    MNPlayView *playView = [[MNPlayView alloc] initWithFrame:CGRectMake(0.f, 0.f, naturalSize.width, naturalSize.height)];
    playView.panGestureRecognizer.enabled = NO;
    playView.tapGestureRecognizer.enabled = NO;
    playView.autoresizingMask = UIViewAutoresizingNone;
    if (!self.isAllowsResizeSize || naturalSize.width >= naturalSize.height) {
        playView.center_mn = CGPointMake(self.contentView.width_mn/2.f, height/2.f + top);
    } else {
        playView.center_mn = CGPointMake(width/2.f + wh + MNVideoTailorInterval*2.f, height/2.f + top);
    }
    playView.touchInset = UIEdgeInsetWith(-20.f);
    playView.backgroundColor = MNVideoTailorBlackColor;
    playView.backgroundImage = self.thumbnail;
    UIViewSetBorderRadius(playView, 0.f, (MN_IS_LOW_SCALE ? 1.f : .8f), MNVideoTailorBlackColor);
    [self.contentView addSubview:playView];
    self.playView = playView;
    
    // 裁剪视图
    if (self.isAllowsResizeSize) {
        MNCropView *cropView = [[MNCropView alloc] initWithFrame:playView.bounds];
        cropView.alpha = 0.f;
        cropView.borderColor = UIColor.whiteColor;
        cropView.cornerColor = MNVideoTailorWhiteColor;
        cropView.cornerSize = CGSizeMake(3.3f, 38.f);
        cropView.touchInset = playView.touchInset;
        cropView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:.5f];
        [playView addSubview:cropView];
        self.cropView = cropView;
    }
    
    // 加载动画
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.color = MNVideoTailorWhiteColor;//MN_RGB(250.f);
    indicatorView.hidesWhenStopped = YES;
    indicatorView.center_mn = playView.bounds_center;
    [playView addSubview:indicatorView];
    self.indicatorView = indicatorView;
    
    // 比例调整按钮
    if (self.isAllowsResizeSize) {
        __block CGSize totalSize = CGSizeZero;
        NSArray <NSString *>*scales = @[@"0:0", @"1:1", @"9:16", @"3:4", @"4:3", @"16:9"];
        NSMutableArray <UIButton *>*buttons = @[].mutableCopy;
        [scales.reversedArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray <NSString *>*components = [obj componentsSeparatedByString:@":"];
            CGFloat w = components.firstObject.floatValue;
            CGFloat h = components.lastObject.floatValue;
            CGFloat scale = MAX(w, h) <= 0.f ? 0.f : w/h;
            if (scale == 0.f) obj = @"自由";
            CGSize size = CGSizeMake(w, h);
            if (scale == 0.f) {
                size = CGSizeMake(wh, wh);
            } else {
                size = (w >= h) ? CGSizeMultiplyToWidth(size, wh) : CGSizeMultiplyToHeight(size, wh);
            }
            MNVideoResizeButton *button = [MNVideoResizeButton buttonWithFrame:CGRectOriginSize(CGPointZero, size) image:nil title:obj titleColor:MNVideoTailorBlackColor titleFont:UIFontRegular(10.f)];
            button.scale = scale;
            button.normalColor = MNVideoTailorBlackColor;
            button.selectedColor = MNVideoTailorWhiteColor;
            button.tag = MNVideoTailorButtonTag + idx;
            [button addTarget:self action:@selector(resizeButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:button];
            [buttons addObject:button];
            totalSize.width += size.width;
            totalSize.height += size.height;
        }];
        
        // 高分辨率输出
        UIButton *resolutionButton = [UIButton buttonWithFrame:CGRectZero image:[MNBundle imageForResource:@"video_1080"] title:nil titleColor:nil titleFont:nil];
        resolutionButton.size_mn = CGSizeMultiplyToWidth([resolutionButton backgroundImageForState:UIControlStateNormal].size, wh);
        [resolutionButton setBackgroundImage:[MNBundle imageForResource:@"video_1080_highlighted"] forState:UIControlStateSelected];
        [resolutionButton addTarget:self action:@selector(resolutionButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [resolutionButton cancelHighlightedEffect];
        [self.contentView addSubview:resolutionButton];
        self.resolutionButton = resolutionButton;
        [buttons insertObject:resolutionButton atIndex:0];
        
        totalSize.width += resolutionButton.size_mn.width;
        totalSize.height += resolutionButton.size_mn.height;
        
        CGFloat interval = 13.f;
        __block CGFloat x = (self.contentView.width_mn - totalSize.width - (buttons.count - 1)*interval)/2.f;
        __block CGFloat y = playView.centerY_mn - (totalSize.height + (buttons.count - 1)*interval)/2.f;
        [buttons.reversedArray enumerateObjectsUsingBlock:^(UIButton *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.touchInset = UIEdgeInsetWith(-interval/2.f);
            if (naturalSize.width >= naturalSize.height) {
                // 横向视频比例按钮放下面
                obj.left_mn = x;
                obj.centerY_mn = playView.bottom_mn + (playControl.top_mn - playView.bottom_mn)/2.f;
                x = obj.right_mn + interval;
            } else {
                // 纵向视频比例按钮放左侧
                obj.top_mn = y;
                obj.centerX_mn = playView.left_mn/2.f;
                y = obj.bottom_mn + interval;
            }
        }];
    }
    
    // 时间
    MNTailorTimeView *timeView = [[MNTailorTimeView alloc] init];
    timeView.hidden = YES;
    timeView.left_mn = tailorView.left_mn;
    timeView.bottom_mn = playControl.top_mn;
    timeView.textColor = MNVideoTailorWhiteColor;
    timeView.backgroundColor = [MNVideoTailorBlackColor colorWithAlphaComponent:.83f];
    [self.contentView addSubview:timeView];
    self.timeView = timeView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.player.isPlaying) [self.player pause];
}

- (void)loadData {
    MNPlayer *player = [[MNPlayer alloc] initWithURL:[NSURL fileURLWithPath:self.videoPath]];
    player.delegate = self;
    player.layer = self.playView.layer;
    player.observeTime = CMTimeMake(1, 60);
    self.player = player;
    [self.tailorView loadThumbnails];
}

#pragma mark - Event
- (void)playControlTouchUpInside {
    if (self.tailorView.isDragging) return;
    if (self.player.isPlaying) {
        [self.player pause];
    } else {
        if (self.tailorView.isEndPlaying) {
            @weakify(self);
            [UIView animateWithDuration:MNTailorHandlerAnimationDuration animations:^{
                weakself.tailorView.pointer.alpha = 0.f;
            } completion:^(BOOL finished) {
                [weakself.tailorView movePointerToBegin];
                [weakself.player seekToProgress:weakself.tailorView.progress completion:^(BOOL finished) {
                    [UIView animateWithDuration:MNTailorHandlerAnimationDuration animations:^{
                        weakself.tailorView.pointer.alpha = 1.f;
                    } completion:^(BOOL finished) {
                        [weakself.player play];
                    }];
                }];
            }];
        } else {
            [self.player play];
        }
    }
}

- (void)resizeButtonTouchUpInside:(MNVideoResizeButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        NSArray <MNVideoResizeButton *>*buttons = [self.contentView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag >= %@ && self.tag != %@", @(MNVideoTailorButtonTag), @(sender.tag)]];
        [buttons setValue:@(NO) forKey:kPath(sender.selected)];
        self.cropView.scale = sender.scale;
    }
    self.playView.layer.borderColor = sender.isSelected ? UIColor.clearColor.CGColor : MNVideoTailorBlackColor.CGColor;
    [UIView animateWithDuration:MNTailorHandlerAnimationDuration animations:^{
        self.cropView.alpha = (CGFloat)sender.isSelected;
    }];
}

- (void)resolutionButtonTouchUpInside:(UIButton *)sender {
    sender.selected = !sender.isSelected;
}

- (void)closeButtonTouchUpInside:(UIButton *)closeButton {
    if (self.player.isPlaying) [self.player pause];
    BOOL responds = NO;
    if (self.didCancelHandler) {
        responds = YES;
        self.didCancelHandler(self);
    }
    if ([self.delegate respondsToSelector:@selector(videoTailorControllerDidCancel:)]) {
        responds = YES;
        [self.delegate videoTailorControllerDidCancel:self];
    }
    if (!responds && self.navigationController) [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonTouchUpInside:(UIButton *)closeButton {
    // 暂停播放
    if (self.player.isPlaying) [self.player pause];
    CGFloat end = self.tailorView.end;
    CGFloat begin = self.tailorView.begin;
    NSString *outputPath = self.outputPath ? : MNCacheDirectoryAppending(MNFileMP4Name);
    if ([NSFileManager.defaultManager fileExistsAtPath:outputPath]) [NSFileManager.defaultManager removeItemAtPath:outputPath error:nil];
    __weak typeof(self) weakself = self;
    [self.view showProgressDialog:@"视频导出中"];
    if (!self.isFrameResizing && (end - begin) >= .99f && !self.resolutionButton.isSelected) {
        // 画面 时长几乎与原始相同
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSError *error;
            if ([NSFileManager.defaultManager copyItemAtPath:self.videoPath toPath:outputPath error:&error]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.view closeDialogWithCompletionHandler:^{
                        [weakself endTailoring:outputPath];
                    }];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.view showInfoDialog:error.localizedDescription ? : @"视频导出失败"];
                });
            }
        });
        return;
    }
    // 裁剪视频 进度回调
    void (^progressHandler)(float) = ^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.view updateDialogProgress:MIN(.99f, progress)];
        });
    };
    // 完成回调
    void (^completionHandler)(NSInteger, NSError*) = ^(NSInteger status, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == MNAssetExportStatusCompleted) {
                [weakself.view closeDialogWithCompletionHandler:^{
                    [weakself endTailoring:outputPath];
                }];
            } else {
                [MNFileManager removeItemAtPath:outputPath error:nil];
                [weakself.view showInfoDialog:error.localizedDescription ? : @"视频导出失败"];
            }
        });
    };
    MNAssetExporter *exporter = [[MNAssetExporter alloc] initWithAssetAtPath:self.videoPath];
    exporter.outputURL = [NSURL fileURLWithPath:self.outputPath];
    exporter.outputRect = self.videoOutputRect;
    exporter.presetName = MNAssetExportPresetHighestQuality;
    exporter.renderSize = exporter.outputRect.size;
    if (self.resolutionButton && self.resolutionButton.isSelected && CGSizeMin(exporter.renderSize) < 1080.f) {
        exporter.renderSize = CGSizeMultiplyToMin(exporter.outputRect.size, 1080.f);
    }
    exporter.timeRange = [exporter.asset timeRangeFromProgress:begin toProgress:end];
    [exporter exportAsynchronouslyWithProgressHandler:progressHandler completionHandler:completionHandler];
}

- (void)endTailoring:(NSString *)videoPath {
    if (self.isDeleteVideoWhenFinish && ![videoPath isEqualToString:self.videoPath]) {
        if (![NSFileManager.defaultManager removeItemAtPath:self.videoPath error:nil]) {
            [NSFileManager.defaultManager removeItemAtPath:self.videoPath error:nil];
        }
    }
    if (self.didTailoringVideoHandler) self.didTailoringVideoHandler(self, videoPath);
    if ([self.delegate respondsToSelector:@selector(videoTailorController:didTailoringVideoAtPath:)]) {
        [self.delegate videoTailorController:self didTailoringVideoAtPath:videoPath];
    }
}

#pragma mark - 
// 视频画面输出尺寸
- (CGRect)videoOutputRect {
    CGSize naturalSize = self.naturalSize;
    if (!self.cropView || self.cropView.isHidden) return (CGRect){CGPointZero, naturalSize};
    CGRect cropRect = self.cropView.cropRect;
    CGSize cropSize = self.cropView.bounds.size;
    // 裁剪框几乎未变化
    if (MIN(cropRect.size.width/cropSize.width, cropRect.size.height/cropSize.height) >= .99f) return (CGRect){CGPointZero, naturalSize};
    CGFloat cropRatio = MIN(naturalSize.width/cropSize.width, naturalSize.height/cropSize.height);
    cropRect = CGRectMultiplyByRatio(cropRect, cropRatio);
    return cropRect;
}

// 判断是否调整了画面尺寸
- (BOOL)isFrameResizing {
    if (!self.cropView || self.cropView.isHidden) return NO;
    CGRect cropRect = self.cropView.cropRect;
    CGSize cropSize = self.cropView.bounds.size;
    // 裁剪框几乎未变化
    return MIN(cropRect.size.width/cropSize.width, cropRect.size.height/cropSize.height) < .99f;
}

#pragma mark - MNVideoTailorViewDelegate
/**开始加载截图*/
- (void)tailorViewBeginLoadThumbnails:(MNVideoTailorView *_Nonnull)tailorView {
    [self.indicatorView startAnimating];
}
/**已经加载截图*/
- (void)tailorViewDidLoadThumbnails:(MNVideoTailorView *_Nonnull)tailorView {
    [self.player play];
}
/**加载截图失败*/
- (void)tailorViewLoadThumbnailsFailed:(MNVideoTailorView *_Nonnull)tailorView {
    __weak typeof(self) weakself = self;
    [[MNAlertView alertViewWithTitle:nil message:@"无法获取视频内容" handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
        [weakself closeButtonTouchUpInside:nil];
    } ensureButtonTitle:@"确定" otherButtonTitles:nil] showInView:self.view];
}
/**左滑手开始拖拽*/
- (void)tailorViewLeftHandlerBeginDragging:(MNVideoTailorView *_Nonnull)tailorView {
    tailorView.userInfo = @(self.player.isPlaying);
    [self.player pause];
    self.timeView.duration = self.duration*tailorView.begin;
    self.timeView.centerX_mn = CGRectGetMaxX([tailorView.tailorHandler.leftHandler.superview convertRect:tailorView.tailorHandler.leftHandler.frame toView:self.contentView]);
    self.timeView.hidden = NO;
}
/**左滑手拖拽中*/
- (void)tailorViewLeftHandlerDidDragging:(MNVideoTailorView *_Nonnull)tailorView {
    NSTimeInterval begin = tailorView.begin;
    [self.player seekToProgress:begin completion:nil];
    self.timeView.duration = self.duration*begin;
    self.timeView.centerX_mn = CGRectGetMaxX([tailorView.tailorHandler.leftHandler.superview convertRect:tailorView.tailorHandler.leftHandler.frame toView:self.contentView]);
}
/**左滑手停止拖拽*/
- (void)tailorViewLeftHandlerEndDragging:(MNVideoTailorView *_Nonnull)tailorView {
    @weakify(self);
    self.timeView.hidden = YES;
    BOOL isPlaying = [tailorView.userInfo boolValue];
    // 这里获取progress是因为内部已根据情况调整指针位置
    [self.player seekToProgress:tailorView.progress completion:^(BOOL finished) {
        @strongify(self);
        if (isPlaying) [self.player play];
    }];
}
/**右滑手开始拖拽*/
- (void)tailorViewRightHandlerBeginDragging:(MNVideoTailorView *_Nonnull)tailorView {
    tailorView.userInfo = @(self.player.isPlaying);
    [self.player pause];
    self.timeView.duration = self.duration*tailorView.end;
    self.timeView.centerX_mn = CGRectGetMinX([tailorView.tailorHandler.rightHandler.superview convertRect:tailorView.tailorHandler.rightHandler.frame toView:self.contentView]);
    self.timeView.hidden = NO;
}
/**右滑手拖拽中*/
- (void)tailorViewRightHandlerDidDragging:(MNVideoTailorView *_Nonnull)tailorView {
    NSTimeInterval end = tailorView.end;
    [self.player seekToProgress:end completion:nil];
    self.timeView.duration = self.duration*end;
    self.timeView.centerX_mn = CGRectGetMinX([tailorView.tailorHandler.rightHandler.superview convertRect:tailorView.tailorHandler.rightHandler.frame toView:self.contentView]);
}
/**右滑手拖拽结束*/
- (void)tailorViewRightHandlerEndDragging:(MNVideoTailorView *_Nonnull)tailorView {
    @weakify(self);
    self.timeView.hidden = YES;
    BOOL isPlaying = [tailorView.userInfo boolValue];
    // 这里获取progress是因为内部已根据情况调整指针位置
    __weak typeof(tailorView) weakTailorView = tailorView;
    [self.player seekToProgress:tailorView.progress completion:^(BOOL finished) {
        @strongify(self);
        if (isPlaying && !weakTailorView.isEndPlaying) [self.player play];
    }];
}
/**指针开始拖拽*/
- (void)tailorViewPointerBeginDragging:(MNVideoTailorView *_Nonnull)tailorView {
    [self.player pause];
    self.timeView.duration = self.duration*tailorView.progress;
    self.timeView.centerX_mn = CGRectGetMidX([tailorView.pointer.superview convertRect:tailorView.pointer.frame toView:self.contentView]);
    self.timeView.hidden = NO;
}
/**指针拖拽中*/
- (void)tailorViewPointerDidDragging:(MNVideoTailorView *_Nonnull)tailorView {
    NSTimeInterval progress = tailorView.progress;
    [self.player seekToProgress:progress completion:nil];
    self.timeView.duration = self.duration*progress;
    self.timeView.centerX_mn = CGRectGetMidX([tailorView.pointer.superview convertRect:tailorView.pointer.frame toView:self.contentView]);
}
/**指针停止拖拽*/
- (void)tailorViewPointerEndDragging:(MNVideoTailorView *_Nonnull)tailorView {
    @weakify(self);
    self.timeView.hidden = YES;
    __weak typeof(tailorView) weakTailorView = tailorView;
    [self.player seekToProgress:tailorView.progress completion:^(BOOL finished) {
        @strongify(self);
        if (!weakTailorView.isEndPlaying) [self.player play];
    }];
}
/**截图开始拖拽*/
- (void)tailorViewBeginDragging:(MNVideoTailorView *_Nonnull)tailorView {
    tailorView.userInfo = @(self.player.isPlaying);
    [self.player pause];
    self.timeView.duration = self.duration*tailorView.begin;
    self.timeView.centerX_mn = CGRectGetMaxX([tailorView.tailorHandler.leftHandler.superview convertRect:tailorView.tailorHandler.leftHandler.frame toView:self.contentView]);
    self.timeView.hidden = NO;
}
/**截图拖拽中*/
- (void)tailorViewDidDragging:(MNVideoTailorView *_Nonnull)tailorView {
    NSTimeInterval begin = tailorView.begin;
    [self.player seekToProgress:begin completion:nil];
    self.timeView.duration = self.duration*begin;
}
/**截图停止拖拽*/
- (void)tailorViewEndDragging:(MNVideoTailorView *_Nonnull)tailorView {
    @weakify(self);
    self.timeView.hidden = YES;
    BOOL isPlaying = [tailorView.userInfo boolValue];
    [self.player seekToProgress:tailorView.progress completion:^(BOOL finished) {
        @strongify(self);
        if (isPlaying) [self.player play];
    }];
}
/**播放到指定位置*/
- (void)tailorViewDidEndPlaying:(MNVideoTailorView *_Nonnull)tailorView {
    [self.player pause];
}

#pragma mark - MNPlayerDelegate
- (void)playerDidEndDecode:(MNPlayer *)player {
    self.doneButton.enabled = YES;
    self.tailorView.userInteractionEnabled = YES;
    self.playControl.userInteractionEnabled = YES;
    [self.indicatorView stopAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.playView.layer.contents = nil;
    });
}

- (void)playerDidChangeState:(MNPlayer *)player {
    self.badgeView.highlighted = player.state == MNPlayerStatePlaying;
}

- (void)playerDidPlayTimeInterval:(MNPlayer *)player {
    if (player.state != MNPlayerStatePlaying) return;
    self.tailorView.progress = player.progress;
    NSString *text = self.timeLabel.text;
    NSArray *components = [text componentsSeparatedByString:@"/"];
    if (components.count <= 1) return;
    NSString *duration = [NSDate timeStringWithInterval:@(player.currentTimeInterval)];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", duration, components.lastObject];
}

- (void)playerDidPlayFailure:(MNPlayer *)player {
    @weakify(self);
    [self.indicatorView stopAnimating];
    [[MNAlertView alertViewWithTitle:nil message:player.error.localizedDescription handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    } ensureButtonTitle:@"确定" otherButtonTitles:nil] showInView:self.view];
}

#pragma mark - Setter
- (void)setVideoPath:(NSString *)videoPath {
    _videoPath = videoPath.copy;
    if (videoPath.length && [NSFileManager.defaultManager fileExistsAtPath:videoPath]) {
        if (self.duration <= 0.f) self.duration = [MNAssetExporter exportDurationWithMediaAtPath:videoPath];
        if (!self.thumbnail) self.thumbnail = [MNAssetExporter exportThumbnailOfVideoAtPath:videoPath];
        if (CGSizeEqualToSize(self.naturalSize, CGSizeZero)) self.naturalSize = [MNAssetExporter exportNaturalSizeOfVideoAtPath:videoPath];
    }
}

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
