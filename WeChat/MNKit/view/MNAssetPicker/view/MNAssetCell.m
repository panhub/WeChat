//
//  MNAssetCell.m
//  MNKit
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetCell.h"
#import "MNAsset.h"
#import "MNAssetHelper.h"
#import "MNAssetSelectControl.h"
#import "MNAssetProgressView.h"
#import "MNAssetPickConfiguration.h"

#define MNAssetCellMargin   5.f

@interface MNAssetCell ()
@property (nonatomic, strong) UIView *holdView;
@property (nonatomic, strong) UILabel *fileSizeLabel;
@property (nonatomic, strong) UIButton *badgeButton;
@property (nonatomic, strong) UIImageView *cloudView;
@property (nonatomic, strong) MNAssetSelectControl *selectControl;
@property (nonatomic, strong) MNAssetProgressView *progressView;
@property (nonatomic, weak) id<MNAssetCellDelegate> delegate;
@property (nonatomic, weak) MNAssetPickConfiguration *configuration;
@end

@implementation MNAssetCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.imageView.frame = self.contentView.bounds;
        self.imageView.userInteractionEnabled = NO;
        self.imageView.clipsToBounds = YES;
        self.imageView.backgroundColor = UIColorWithSingleRGB(220.f);
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        UIImageView *cloudView = [UIImageView imageViewWithFrame:CGRectMake(MNAssetCellMargin, MNAssetCellMargin, 15.f, 15.f) image:[MNBundle imageForResource:@"icon_cloud"]];
        cloudView.userInteractionEnabled = NO;
        cloudView.highlightedImage = [MNBundle imageForResource:@"icon_cloud_error"];
        [self.contentView addSubview:cloudView];
        self.cloudView = cloudView;
        
        MNAssetSelectControl *selectControl = [[MNAssetSelectControl alloc] initWithFrame:CGRectMake(0.f, MNAssetCellMargin, 23.f, 23.f)];
        selectControl.right_mn = self.contentView.width_mn - MNAssetCellMargin;
        selectControl.touchInset = UIEdgeInsetsMake(-MNAssetCellMargin, -10.f, -10.f, -MNAssetCellMargin);
        [selectControl addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectControl];
        self.selectControl = selectControl;
        
        UIButton *badgeButton = [UIButton buttonWithFrame:cloudView.frame image:[MNBundle imageForResource:@"icon_live_photo"] title:nil titleColor:nil titleFont:nil];
        badgeButton.userInteractionEnabled = NO;
        [badgeButton setBackgroundImage:[MNBundle imageForResource:@"icon_gif"] forState:UIControlStateSelected];
        [badgeButton setBackgroundImage:[MNBundle imageForResource:@"icon_video"] forState:UIControlStateDisabled];
        badgeButton.bottom_mn = self.contentView.height_mn - MNAssetCellMargin;
        [self.contentView addSubview:badgeButton];
        self.badgeButton = badgeButton;
        
        UILabel *fileSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 12.f)];
        fileSizeLabel.right_mn = selectControl.right_mn;
        fileSizeLabel.centerY_mn = badgeButton.centerY_mn;
        fileSizeLabel.font = [UIFont systemFontOfSize:12.f];
        fileSizeLabel.textColor = UIColorWithSingleRGB(251.f);
        fileSizeLabel.textAlignment = NSTextAlignmentRight;
        fileSizeLabel.userInteractionEnabled = NO;
        [self.contentView addSubview:fileSizeLabel];
        self.fileSizeLabel = fileSizeLabel;
        
        self.detailLabel.frame = CGRectMake(0.f, 0.f, selectControl.right_mn - badgeButton.right_mn - MNAssetCellMargin, 12.f);
        self.detailLabel.right_mn = selectControl.right_mn;
        self.detailLabel.centerY_mn = badgeButton.centerY_mn;
        self.detailLabel.textColor = UIColorWithSingleRGB(251.f);
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        self.detailLabel.font = [UIFont systemFontOfSize:12.f];
        self.detailLabel.userInteractionEnabled = NO;
        
        MNAssetProgressView *progressView = [[MNAssetProgressView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:progressView];
        self.progressView = progressView;
        
        UIView *holdView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        holdView.userInteractionEnabled = YES;
        holdView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8f];
        [self.contentView addSubview:holdView];
        self.holdView = holdView;
    }
    return self;
}

- (void)setAsset:(MNAsset *)model {
    
    _asset = model;
    model.containerView = self.imageView;
    
    self.detailLabel.hidden = YES;
    self.badgeButton.hidden = NO;
    self.imageView.image = model.thumbnail;
    self.holdView.hidden = model.isEnabled;
    self.cloudView.highlighted = model.status == MNAssetStatusFailed;
    self.cloudView.hidden = model.source != MNAssetSourceCloud;
    self.progressView.hidden = model.status != MNAssetStatusDownloading;
    if (!self.progressView.isHidden) [self.progressView setProgress:model.progress animated:NO];
    if (self.configuration && self.configuration.maxPickingCount > 1) {
        self.selectControl.index = model.selectIndex;
        self.selectControl.selected = model.selected;
        self.selectControl.hidden = model.isCapturingModel;
    }
    
    if (model.type == MNAssetTypeVideo) {
        self.detailLabel.text = model.durationString;
        self.detailLabel.hidden = NO;
        self.badgeButton.enabled = NO;
        self.badgeButton.selected = NO;
    } else if (model.type == MNAssetTypeLivePhoto) {
        self.badgeButton.enabled = YES;
        self.badgeButton.selected = NO;
    } else if (model.type == MNAssetTypeGif) {
        self.badgeButton.enabled = YES;
        self.badgeButton.selected = YES;
    } else {
        self.badgeButton.hidden = YES;
    }
    
    @weakify(self);
    model.thumbnailChangeHandler = nil;
    model.thumbnailChangeHandler = ^(MNAsset *m) {
        weakself.imageView.image = m.thumbnail;
    };
    
    model.sourceChangeHandler = nil;
    model.sourceChangeHandler = ^(MNAsset *m) {
        weakself.cloudView.hidden = m.source != MNAssetSourceCloud;
    };
    
    model.progressChangeHandler = nil;
    model.progressChangeHandler = ^(MNAsset *m) {
        [weakself.progressView setProgress:m.progress animated:NO];
    };
    
    model.statusChangeHandler = nil;
    model.statusChangeHandler = ^(MNAsset *m) {
        weakself.cloudView.highlighted = m.status == MNAssetStatusFailed;
        weakself.progressView.hidden = m.status != MNAssetStatusDownloading;
        if (m.status == MNAssetStatusDownloading) [weakself.progressView setProgress:m.progress animated:NO];
    };
    
    if (self.configuration && self.configuration.isAllowsDisplayFileSize) {
        [weakself updateFileSize];
        model.fileSizeChangeHandler = nil;
        model.fileSizeChangeHandler = ^(MNAsset * _Nonnull m) {
            [weakself updateFileSize];
        };
    }
    
    [[MNAssetHelper helper] requestAssetProfile:model];
}

- (void)selectButtonClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(didSelectAsset:)]) {
        [self.delegate didSelectAsset:self.asset];
    }
}

- (void)updateFileSize {
    self.fileSizeLabel.text = self.asset.isCapturingModel ? @"" : self.asset.fileSizeString;
    [self.fileSizeLabel sizeToFit];
    self.fileSizeLabel.width_mn = self.fileSizeLabel.text.length ? (self.fileSizeLabel.width_mn + MNAssetCellMargin) : 0.f;
    self.fileSizeLabel.height_mn = self.detailLabel.height_mn;
    self.fileSizeLabel.right_mn = self.selectControl.right_mn;
    self.fileSizeLabel.centerY_mn = self.detailLabel.centerY_mn;
    self.detailLabel.right_mn = self.fileSizeLabel.left_mn;
}

#pragma mark - Super
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview && !self.delegate) {
        self.delegate = (id<MNAssetCellDelegate>)(self.viewController);
        if ([self.delegate respondsToSelector:@selector(assetPickingConfiguration)]) {
            self.configuration = [self.delegate assetPickingConfiguration];
            if (self.configuration && self.configuration.maxPickingCount <= 1) self.selectControl.hidden = YES;
        }
    }
}

- (void)didEndDisplaying {
    _asset.containerView = nil;
    _asset.statusChangeHandler = nil;
    _asset.sourceChangeHandler = nil;
    _asset.fileSizeChangeHandler = nil;
    _asset.progressChangeHandler = nil;
    _asset.thumbnailChangeHandler = nil;
}

@end
