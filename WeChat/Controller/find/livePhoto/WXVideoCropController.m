//
//  WXVideoCropController.m
//  ZiMuKing
//
//  Created by Vincent on 2019/12/10.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXVideoCropController.h"
#import "WXLivePhotoController.h"
#import "WXVideoCropView.h"
#import "MNPlayView.h"
#import "MNAssetExporter.h"

@interface WXVideoCropController ()<MNPlayerDelegate, WXVideoCropDelegate, MNPlayViewDelegate>
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, strong) MNPlayer *player;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *cutTimeLabel;
@property (nonatomic, strong) MNPlayView *playView;
@property (nonatomic, strong) MNCropView *cropView;
@property (nonatomic, strong) UIImageView *badgeView;
@property (nonatomic, strong) WXVideoCropView *videoCropView;
@end

#define WXCropViewMargin          15.f
#define WXCropQuickButtonTag    10
#define WXCropScaleButtonTag    20

@implementation WXVideoCropController
- (instancetype)initWithContentsOfFile:(NSString *)filePath {
    if (self = [super init]) {
        self.videoPath = filePath;
        self.title = @"视频裁剪";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowColor = UIColor.whiteColor;
    self.navigationBar.backgroundColor = UIColor.whiteColor;
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, 0.f)];
    backgroundView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:backgroundView];
    
    WXVideoCropView *videoCropView = [[WXVideoCropView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, 51.f)];
    videoCropView.delegate = self;
    videoCropView.bottom_mn = self.contentView.height_mn - UITabSafeHeight() - 30.f;
    videoCropView.videoPath = self.videoPath;
    [self.contentView addSubview:videoCropView];
    self.videoCropView = videoCropView;
    
    UILabel *quickLabel = [UILabel labelWithFrame:CGRectZero
                                             text:@"快速截取视频时长:"
                                        textColor:UIColorWithSingleRGB(51.f)
                                             font:[UIFont systemFontOfSize:13.f]];
    quickLabel.left_mn = videoCropView.leftHandler.width_mn;
    quickLabel.bottom_mn = videoCropView.top_mn;
    [self.contentView addSubview:quickLabel];
    
    CGFloat duration = [MNAssetExporter exportDurationWithAssetAtPath:self.videoPath];
    if (duration > 15.f) {
        [quickLabel sizeToFit];
        quickLabel.height_mn = quickLabel.font.pointSize;
        quickLabel.bottom_mn = videoCropView.top_mn - WXCropViewMargin;
        __block CGFloat x = quickLabel.right_mn;
        NSArray <NSString *>*titles = @[@"5", @"10", @"15"];
        [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *title = [obj stringByAppendingString:@"秒"];
            UIButton *button = [UIButton buttonWithFrame:CGRectZero image:nil title:title titleColor:quickLabel.textColor titleFont:quickLabel.font];
            button.height_mn = 28.f;
            button.width_mn = [title sizeWithFont:quickLabel.font].width + WXCropViewMargin;
            button.centerY_mn = quickLabel.centerY_mn;
            button.left_mn = x;
            button.user_info = @(title.floatValue);
            button.tag = WXCropQuickButtonTag + idx;
            [button setTitleColor:THEME_COLOR forState:UIControlStateSelected];
            [button addTarget:self action:@selector(resizingDurationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:button];
            x = button.right_mn;
        }];
    }
    
    backgroundView.top_mn = quickLabel.top_mn - WXCropViewMargin;
    backgroundView.height_mn = self.contentView.height_mn - backgroundView.top_mn;
    
    UILabel *cutTimeLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, backgroundView.width_mn, 12.f) text:@"" textAlignment:NSTextAlignmentCenter textColor:quickLabel.textColor font:[UIFont systemFontOfSize:12.f]];
    cutTimeLabel.hidden = YES;
    cutTimeLabel.centerY_mn = (self.contentView.height_mn - videoCropView.bottom_mn - UITabSafeHeight())/2.f + videoCropView.bottom_mn - backgroundView.top_mn;
    cutTimeLabel.text = [NSString stringWithFormat:@"%@s", NSStringFromNumber(@(round(videoCropView.cropRange.length*duration)))];
    [backgroundView addSubview:cutTimeLabel];
    self.cutTimeLabel = cutTimeLabel;

    UILabel *timeLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, quickLabel.font.pointSize) text:@"" textAlignment:NSTextAlignmentCenter textColor:quickLabel.textColor font:quickLabel.font];
    timeLabel.bottom_mn = backgroundView.top_mn - WXCropViewMargin;
    timeLabel.text = NSStringWithFormat(@"00:00/%@",[NSDate playTimeStringWithInterval:@(duration)]);
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    // 计算播放尺寸
    BOOL isCanResizing = YES; //不可编辑时UI略有不同
    CGFloat wh = 40.f; //比例调整按钮尺寸
    CGFloat width = self.contentView.width_mn;
    CGFloat height = timeLabel.top_mn - WXCropViewMargin*2.f;
    CGSize naturalSize = [MNAssetExporter exportNaturalSizeOfVideoAtPath:self.videoPath];
    if (CGSizeIsEmpty(naturalSize)) {
        UIImage *thumbnail = [MNAssetExporter exportThumbnailOfVideoAtPath:self.videoPath];
        if (CGSizeIsEmpty(thumbnail.size)) {
            isCanResizing = NO;
            naturalSize = CGSizeMake(720.f, 1280.f);
        } else {
            naturalSize = thumbnail.size;
        }
    }
    if (naturalSize.width >= naturalSize.height) {
        // 横向视频比例按钮放下面
        if (isCanResizing) height -= (wh + WXCropViewMargin);
        naturalSize = CGSizeMultiplyToWidth(naturalSize, width);
        if (naturalSize.height > height) {
            naturalSize = CGSizeMultiplyToHeight(naturalSize, height);
        }
    } else {
        // 纵向视频比例按钮放左侧
        if (isCanResizing) width -= (wh + WXCropViewMargin*2.f);
        naturalSize = CGSizeMultiplyToHeight(naturalSize, height);
        if (naturalSize.width > width) {
            naturalSize = CGSizeMultiplyToWidth(naturalSize, width);
        }
    }
    MNPlayView *playView = [[MNPlayView alloc] initWithFrame:CGRectMake(0.f, 0.f, naturalSize.width, naturalSize.height)];
    playView.delegate = self;
    playView.scrollEnabled = NO;
    playView.touchEnabled = YES;
    if (!isCanResizing || width == self.contentView.width_mn) {
        playView.center_mn = CGPointMake(width/2.f, height/2.f + WXCropViewMargin);
    } else {
        playView.center_mn = CGPointMake(width/2.f + wh + WXCropViewMargin*2.f, height/2.f + WXCropViewMargin);
    }
    playView.autoresizingMask = UIViewAutoresizingNone;
    playView.touchInset = UIEdgeInsetWith(-20.f);
    playView.backgroundColor = isCanResizing ? UIColor.clearColor : UIColor.blackColor;
    playView.backgroundImage = [MNAssetExporter exportThumbnailOfVideoAtPath:self.videoPath];
    [self.contentView addSubview:playView];
    self.playView = playView;
    
    // 播放/暂停
    UIImageView *badgeView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 38.f, 38.f) image:UIImageNamed(@"wx_video_cut_play")];
    badgeView.alpha = 0.f;
    badgeView.highlightedImage = UIImageNamed(@"wx_video_cut_pause");
    badgeView.userInteractionEnabled = NO;
    badgeView.center_mn = playView.bounds_center;
    [playView addSubview:badgeView];
    self.badgeView = badgeView;
    
    if (isCanResizing) {
        // 裁剪视图
        MNCropView *cropView = [[MNCropView alloc] initWithFrame:playView.bounds];
        cropView.borderColor = UIColor.whiteColor;
        cropView.cornerColor = THEME_COLOR;
        cropView.touchInset = UIEdgeInsetWith(-20.f);
        cropView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:.4f];
        [playView insertSubview:cropView belowSubview:badgeView];
        self.cropView = cropView;
        // 比例调整按钮
        __block CGFloat z_w = 0.f;
        __block CGFloat z_h = 0.f;
        NSArray <NSString *>*scales = @[@"0:0", @"9:16", @"1:1", @"3:4", @"4:3", @"16:9"];
        NSMutableArray <UIButton *>*buttons = @[].mutableCopy;
        [scales.reverseObjects enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray <NSString *>*components = [obj componentsSeparatedByString:@":"];
            CGFloat w = components.firstObject.floatValue;
            CGFloat h = components.lastObject.floatValue;
            CGFloat scale = [components.lastObject isEqualToString:@"0"] ? 0.f : w/h;
            if (scale == 0.f) obj = @"自由";
            CGSize size = CGSizeMake(w, h);
            if (scale == 0.f) {
                size = CGSizeMake(wh, wh);
            } else {
                size = (w >= h) ? CGSizeMultiplyToWidth(size, wh) : CGSizeMultiplyToHeight(size, wh);
            }
            UIColor *color = scale == 0.f ? THEME_COLOR : quickLabel.textColor;
            UIButton *button = [UIButton buttonWithFrame:CGRectOriginSize(CGPointZero, size) image:nil title:obj titleColor:color titleFont:UIFontRegular(10.f)];
            button.size_mn = size;
            UIViewSetBorderRadius(button, 2.f, 1.f, color);
            button.user_info = @(scale);
            button.selected = scale == 0.f;
            button.tag = WXCropScaleButtonTag + idx;
            [button addTarget:self action:@selector(resizingScaleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:button];
            [buttons addObject:button];
            z_w += size.width;
            z_h += size.height;
        }];
        CGFloat interval = 13.f;
        __block CGFloat x = (self.contentView.width_mn - z_w - (buttons.count - 1)*interval)/2.f;
        __block CGFloat y = playView.centerY_mn - (z_h + (buttons.count - 1)*interval)/2.f;
        [buttons.reverseObjects enumerateObjectsUsingBlock:^(UIButton *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (naturalSize.width >= naturalSize.height) {
                // 横向视频比例按钮放下面
                obj.left_mn = x;
                obj.centerY_mn = playView.bottom_mn + (timeLabel.top_mn - playView.bottom_mn)/2.f;
                x = obj.right_mn + interval;
            } else {
                // 纵向视频比例按钮放左侧
                obj.top_mn = y;
                obj.left_mn = WXCropViewMargin;
                y = obj.bottom_mn + interval;
            }
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactiveTransitionEnabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_player pause];
    self.navigationController.interactiveTransitionEnabled = YES;
}

#pragma mark - Event
- (void)resizingScaleButtonClicked:(UIButton *)sender {
    if (sender.selected) return;
    for (NSInteger i = 0; i < 6; i++) {
        UIButton *button = [self.contentView viewWithTag:(WXCropScaleButtonTag + i)];
        button.selected = NO;
        button.layer.borderColor = self.timeLabel.textColor.CGColor;
        [button setTitleColor:self.timeLabel.textColor forState:UIControlStateNormal];
    }
    sender.selected = YES;
    sender.layer.borderColor = THEME_COLOR.CGColor;
    [sender setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    NSNumber *scale = sender.user_info;
    self.cropView.scale = scale.floatValue;
}

- (void)resizingDurationButtonClicked:(UIButton *)sender {
    for (NSInteger i = 0; i < 3; i++) {
        UIButton *button = [self.contentView viewWithTag:(WXCropQuickButtonTag + i)];
        [button setTitleColor:self.timeLabel.textColor forState:UIControlStateNormal];
    }
    [sender setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    NSNumber *num = sender.user_info;
    [self.videoCropView resizingCropFragmentToDuration:num.floatValue];
    self.cutTimeLabel.text = [NSString stringWithFormat:@"%@s", num];
}

#pragma mark - MNPlayerDelegate
- (void)playerDidChangeState:(MNPlayer *)player {
    if (player.state == MNPlayerStatePlaying) {
        self.badgeView.highlighted = YES;
        [self.badgeView.layer removeAllAnimations];
        [UIView animateWithDuration:.3f animations:^{
            self.badgeView.alpha = 0.f;
            self.badgeView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        }];
    } else {
        self.badgeView.alpha = 1.f;
        self.badgeView.highlighted = NO;
        self.badgeView.transform = CGAffineTransformIdentity;
        [self.badgeView.layer removeAllAnimations];
    }
}

- (void)playerDidPlayToEndTime:(MNPlayer *)player {
    @weakify(_player);
    [player seekToProgress:self.videoCropView.leftProgress completion:^(BOOL finished) {
        if (finished) {
            // 这里强行置为暂停模式, 避免进度计算时直接返回1<方式不够优雅, 但可解决问题>
            [weak_player setValue:@(MNPlayerStatePause) forKey:kPath(weak_player.state)];
            [weak_player play];
        }
    }];
}

- (void)playerDidPlayFailure:(MNPlayer *)player {
    [self.view showInfoDialog:player.error.localizedDescription];
}

- (void)playerDidPlayTimeInterval:(MNPlayer *)player {
    if (player.state != MNPlayerStatePlaying) return;
    self.videoCropView.progress = player.progress;
    NSString *text = self.timeLabel.text;
    NSArray *components = [text componentsSeparatedByString:@"/"];
    if (components.count <= 1) return;
    NSString *duration = [NSDate playTimeStringWithInterval:@(player.currentTimeInterval)];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", duration, components.lastObject];
}

#pragma mark - MNPlayViewDelegate
- (void)playViewDidClicked:(MNPlayView *)playView {
    if (self.player.isPlaying) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

#pragma mark - WXVideoCropDelegate
- (void)videoCropViewWillLoadThumbnails:(WXVideoCropView *)cropView {
    [self.view showLoadDialog:@"视频加载中"];
}

- (void)videoCropViewLoadThumbnailsFinish:(WXVideoCropView *)cropView {
    [self.view closeDialog];
    self.cutTimeLabel.hidden = NO;
    [self.player play];
}

- (void)videoCropViewLoadThumbnailsFailure:(WXVideoCropView *)cropView {
    @weakify(self);
    [MNAlertView closeAlertView];
    [[MNAlertView alertViewWithTitle:nil message:@"~获取视频信息失败~" handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    } ensureButtonTitle:@"确定" otherButtonTitles:nil] show];
}

- (BOOL)videoCropViewShouldBeginDragging:(WXVideoCropView *)cropView {
    return (self.player.state != MNPlayerStateUnknown && self.player.state != MNPlayerStateFailed);
}

- (void)videoCropViewWillBeginDragging:(WXVideoCropView *)cropView {
    [self.player pause];
}

- (void)videoCropViewLeftHandlerDidDragging:(WXVideoCropView *)cropView {
    self.cutTimeLabel.text = [NSString stringWithFormat:@"%@s", NSStringFromNumber(@(round(cropView.cropRange.length*cropView.duration)))];
    [self.player seekToProgress:cropView.leftProgress completion:nil];
}

- (void)videoCropViewRightHandlerDidDragging:(WXVideoCropView *)cropView {
    self.cutTimeLabel.text = [NSString stringWithFormat:@"%@s", NSStringFromNumber(@(round(cropView.cropRange.length*cropView.duration)))];
    [self.player seekToProgress:cropView.rightProgress completion:nil];
}

- (void)videoCropViewLeftHandlerDidEndDragging:(WXVideoCropView *)cropView {
    @weakify(self);
    [self.player seekToProgress:cropView.leftProgress completion:^(BOOL finished) {
        @strongify(self);
        [self.player play];
    }];
}

- (void)videoCropViewRightHandlerDidEndDragging:(WXVideoCropView *)cropView {
    CGFloat l_progress = cropView.leftProgress;
    CGFloat r_progress = cropView.rightProgress;
    CGFloat progress = l_progress + (r_progress - l_progress)/4.f*3.f;
    @weakify(self)
    [self.player seekToProgress:progress completion:^(BOOL finished) {
        @strongify(self);
        [self.player play];
    }];
}

- (void)videoCropViewDidEndLimiting:(WXVideoCropView *)cropView {
    @weakify(self)
    [self.player seekToProgress:cropView.leftProgress completion:^(BOOL finished) {
        @strongify(self);
        [self.player play];
    }];
}

#pragma mark - MNNavigationBarDelegate
- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightBarItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 55.f, 30.f)
                                                 image:nil
                                                 title:@"确定"
                                            titleColor:UIColor.whiteColor
                                             titleFont:UIFontSystem(15.f)];
    rightBarItem.backgroundColor = THEME_COLOR;
    UIViewSetCornerRadius(rightBarItem, 4.f);
    [rightBarItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightBarItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    if (self.player.state == MNPlayerStateFailed || MNPlayerStateUnknown) {
        [self.view showInfoDialog:@"获取视频信息失败"];
        return;
    }
    // 导出视频
    [self.player pause];
    @weakify(self);
    BOOL isFrameResizing = self.isFrameResizing;
    MNRange cutRange = self.videoCropView.cropRange;
    NSString *outputPath = MNCacheDirectoryAppending([MNFileHandle fileNameWithExtension:@"mp4"]);
    [self.view showProgressDialog:@"视频处理中"];
    // 进度回调
    MNAssetExportProgressHandler progressHandler = ^(float progress) {
        dispatch_async_main(^{
            @strongify(self);
            [self.view updateDialogProgress:progress];
        });
    };
    // 完成回调
    void (^completionHandler)(NSInteger, NSError*) = ^(NSInteger status, NSError *error) {
        dispatch_async_main(^{
            @strongify(self);
            if (status == MNAssetExportStatusCompleted) {
                @weakify(self);
                [self.view updateDialogProgress:0.f];
                [self.view updateDialogMessage:@"LivePhoto转换中"];
                [MNLivePhoto requestLivePhotoWithVideoResourceOfPath:outputPath progressHandler:^(float progress) {
                    dispatch_async_main(^{
                        @strongify(self);
                        [self.view updateDialogProgress:progress];
                    });
                } completionHandler:^(MNLivePhoto *livePhoto) {
                    [MNFileManager removeItemAtPath:outputPath error:nil];
                    dispatch_async_main(^{
                        @strongify(self);
                        if (livePhoto) {
                            [self.view closeProgressDialogWithCompletionHandler:^{
                                WXLivePhotoController *vc = [[WXLivePhotoController alloc] initWithLivePhoto:livePhoto];
                                [self.navigationController pushViewController:vc animated:YES];
                            }];
                        } else {
                            [self.view showInfoDialog:@"转换LivePhoto失败"];
                        }
                    });
                }];
            } else {
                [self.view showInfoDialog:@"视频导出失败"];
                [MNFileManager removeItemAtPath:outputPath error:nil];
            }
        });
    };
    if (isFrameResizing) {
        // 裁剪了画面, 使用自定义裁剪方案
        MNAssetExporter *exporter = [[MNAssetExporter alloc] initWithAssetAtPath:self.videoPath];
        exporter.outputPath = outputPath;
        exporter.outputRect = self.videoExportOutputRect;
        exporter.presetName = self.videoExportPresetName;
        exporter.timeRange = [exporter timeRangeFromProgress:cutRange.location toProgress:MNMaxRange(cutRange)];
        [exporter exportAsynchronouslyWithProgressHandler:progressHandler completionHandler:completionHandler];
    } else {
        // 没裁剪画面, 使用系统时长裁剪方案
        MNAssetExportSession *session = [[MNAssetExportSession alloc] initWithAssetAtPath:self.videoPath];
        session.outputPath = outputPath;
        session.outputFileType = AVFileTypeMPEG4;
        session.presetName = AVAssetExportPresetHighestQuality;
        session.timeRange = [session timeRangeFromProgress:cutRange.location toProgress:MNMaxRange(cutRange)];
        [session exportAsynchronouslyWithCompletionHandler:completionHandler];
    }
}

- (MNAssetExportPresetName)videoExportPresetName {
    CGFloat scale = 0.f;
    for (NSInteger i = 0; i < 6; i++) {
        UIButton *button = [self.contentView viewWithTag:(WXCropScaleButtonTag + i)];
        if (!button.selected) continue;
        scale = ((NSNumber *)(button.user_info)).floatValue;
    }
    MNAssetExportPresetName presetName = MNAssetExportPresetHighestQuality;
    if (scale == 16.f/9.f) {
        presetName = MNAssetExportPreset1280x720;
    } else if (scale == 9.f/16.f) {
        presetName = MNAssetExportPreset720x1280;
    } else if (scale == 4.f/3.f) {
        presetName = MNAssetExportPreset640x480;
    } else if (scale == 3.f/4.f) {
        presetName = MNAssetExportPreset480x640;
    } else if (scale == 1.f) {
        CGRect outputRect = self.videoExportOutputRect;
        CGFloat minWH = MIN(outputRect.size.width, outputRect.size.height);
        if (minWH <= 600.f) {
            presetName = MNAssetExportPreset600x600;
        } else if (minWH <= 800.f) {
            presetName = MNAssetExportPreset800x800;
        } else if (minWH <= 1024.f) {
            presetName = MNAssetExportPreset1024x1024;
        }
    }
    return presetName;
}

// 视频画面输出尺寸
- (CGRect)videoExportOutputRect {
    CGSize naturalSize = [MNAssetExporter exportNaturalSizeOfVideoAtPath:self.videoPath];
    CGSize cropSize = self.cropView.bounds.size;
    CGFloat cropRatio = MIN(naturalSize.width/cropSize.width, naturalSize.height/cropSize.height);
    CGRect cropRect = self.cropView.cropRect;
    cropRect = CGRectMultiplyByRatio(cropRect, cropRatio);
    return cropRect;
}

// 判断是否调整了尺寸
- (BOOL)isFrameResizing {
    if (!self.cropView || self.cropView.hidden) return NO;
    CGSize cropViewSize = self.cropView.bounds.size;
    CGSize cropRectSize = self.cropView.cropRect.size;
    return MIN(cropRectSize.width/cropViewSize.width, cropRectSize.height/cropViewSize.height) <= .99f;
}

#pragma mark - Lazy
- (MNPlayer *)player {
    if (!_player) {
        MNPlayer *player = [MNPlayer new];
        player.delegate = self;
        player.layer = self.playView.layer;
        player.observeTime = CMTimeMake(1, 60);
        [player addURL:[NSURL fileURLWithPath:self.videoPath]];
        _player = player;
    }
    return _player;
}

#pragma mark - dealloc
- (void)dealloc {
    if ([self.videoPath containsString:MNKitFolderName]) [MNFileManager removeItemAtPath:self.videoPath error:nil];
}

@end
