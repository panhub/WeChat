//
//  MNCollectionViewCell.m
//  MNKit
//
//  Created by Vincent on 2017/7/21.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "MNCollectionViewCell.h"

@interface MNCollectionViewCell()
@property(nonatomic,strong,readwrite) UILabel *titleLabel;
@property(nonatomic,strong,readwrite) UILabel *detailLabel;
@property(nonatomic,strong,readwrite) UIImageView *imageView;
@end
@implementation MNCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.frame = self.bounds;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.contentView.clipsToBounds = YES;
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentScaleFactor = [[UIScreen mainScreen] scale];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textColor = [UIColor darkTextColor];
        titleLabel.font = [UIFont systemFontOfSize:15.f];
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        detailLabel.textColor = [UIColor darkGrayColor];
        detailLabel.font = [UIFont systemFontOfSize:14.f];
        [self.contentView addSubview:detailLabel];
        _detailLabel = detailLabel;
    }
    return _detailLabel;
}

- (void)didBeginDisplaying {}

- (void)didEndDisplaying {}

@end
