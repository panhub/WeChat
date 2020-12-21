//
//  MNRecordView.m
//  MNKit
//
//  Created by Vincent on 2018/7/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNRecordView.h"
#import "UIColor+MNHelper.h"

@interface MNRecordView ()
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *recordBG;
@property (nonatomic, strong) UIImageView *volumeBG;
@property (nonatomic, strong) UIImageView *cancelView;
@property (nonatomic, strong) UIImageView *volumeView;
@end

@implementation MNRecordView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self createView];
    }
    return self;
}

- (void)createView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((self.width_mn - 170.f)/2.f, (self.height_mn - 170.f)/2.f, 170.f, 170.f)];
    contentView.layer.cornerRadius = 11.f;
    contentView.clipsToBounds = YES;
    [contentView addSubview:UIBlurEffectCreate(contentView.bounds, UIBlurEffectStyleDark)];
    [self addSubview:contentView];
    
    UIImage *record = [MNBundle imageForResource:@"voice_recording_bkg"];
    UIImage *volume = [MNBundle imageForResource:@"voice_recording_volume_bkg"];
    CGSize record_size = CGSizeMultiplyToHeight(record.size, 100.f);
    CGSize volume_size = CGSizeMultiplyToHeight(volume.size, 100.f);
    CGFloat x = (contentView.width_mn - record_size.width - volume_size.width - 10.f)/2.f;
    CGFloat y = (contentView.height_mn - record_size.height - 25.f)/2.f;
    
    UIImageView *recordBG = [UIImageView imageViewWithFrame:CGRectMake(x, y, record_size.width, record_size.height) image:record];
    [contentView addSubview:recordBG];
    self.recordBG = recordBG;
    
    UIImageView *volumeBG = [UIImageView imageViewWithFrame:CGRectMake(recordBG.right_mn + 10.f, recordBG.top_mn, volume_size.width, volume_size.height) image:volume];
    volumeBG.alpha = .3f;
    [contentView addSubview:volumeBG];
    self.volumeBG = volumeBG;
    
    UIImageView *volumeView = [UIImageView imageViewWithFrame:volumeBG.frame image:[MNBundle imageForResource:@"voice_recording_volume_1"]];
    [contentView addSubview:volumeView];
    self.volumeView = volumeView;
    
    UIImageView *cancelView = [UIImageView imageViewWithFrame:CGRectMake((contentView.width_mn - 100.f)/2.f, recordBG.top_mn, 100.f, 100.f) image:[MNBundle imageForResource:@"voice_recording_cancel"]];
    cancelView.hidden = YES;
    [contentView addSubview:cancelView];
    self.cancelView = cancelView;
    
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectMake(10.f, recordBG.bottom_mn, contentView.width_mn - 20.f, 25.f) text:@"手指上滑, 取消发送" alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor whiteColor], .8f) font:[UIFont systemFontOfSize:16.f]];
    hintLabel.layer.cornerRadius = 3.f;
    hintLabel.clipsToBounds = YES;
    [contentView addSubview:hintLabel];
    self.hintLabel = hintLabel;
    
    UILabel *timeLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, contentView.width_mn, hintLabel.top_mn) text:@"5" alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor whiteColor], .85f) font:[UIFont systemFontOfSize:contentView.width_mn/2.f]];
    [contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
}

- (void)show {
    /// 这里进行两遍赋值是因为二次录音时, 解决UI不能及时更新的bug
    self.timeLabel.hidden = YES;
    self.state = MNRecordViewStateCancel;
    self.state = MNRecordViewStateNormal;
    [[UIWindow mainWindow] addSubview:self];
}

- (void)dismiss {
    [self removeFromSuperview];
}

#pragma mark - Setter
- (void)setState:(MNRecordViewState)state {
    if (state == _state) return;
    _state = state;
    if (state == MNRecordViewStateNormal) {
        if (self.timeLabel.hidden) {
            self.cancelView.hidden = YES;
            self.recordBG.hidden = self.volumeBG.hidden = self.volumeView.hidden = NO;
        }
        self.hintLabel.text = @"手指上滑, 取消发送";
        self.hintLabel.backgroundColor = [UIColor clearColor];
    } else if (state == MNRecordViewStateCancel) {
        if (self.timeLabel.hidden) {
            self.cancelView.hidden = NO;
            self.recordBG.hidden = self.volumeBG.hidden = self.volumeView.hidden = YES;
        }
        self.hintLabel.text = @"松开手指, 取消发送";
        self.hintLabel.backgroundColor = MN_R_G_B(145.f, 50.f, 40.f);
    } else if (state == MNRecordViewStateTimeout) {
        self.timeLabel.hidden = NO;
        self.recordBG.hidden = self.volumeBG.hidden = self.volumeView.hidden = self.cancelView.hidden = YES;
    }
}

- (void)setDuration:(int)duration power:(float)power {
    int level = round((power + 160.f)/160.f*7.f);
    self.volumeView.image = [MNBundle imageForResource:[NSString stringWithFormat:@"voice_recording_volume_%d", level]];
    int count = 60 - duration;
    if (count > 10) return;
    if (count <= 0) {
        self.state = MNRecordViewStateStop;
        if ([self.delegate respondsToSelector:@selector(voiceRecordTimeoutNeedStop:)]) {
            [self.delegate voiceRecordTimeoutNeedStop:duration];
        }
    } else {
        self.timeLabel.text = NSStringFromNumber(@(count));
        self.state = MNRecordViewStateTimeout;
    }
}

@end
