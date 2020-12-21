//
//  MNCollectionReusableView.m
//  MNKit
//
//  Created by Vincent on 2019/5/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNCollectionReusableView.h"

@interface MNCollectionReusableView()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation MNCollectionReusableView

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentScaleFactor = [[UIScreen mainScreen] scale];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        imageView.clipsToBounds = YES;
        [self addSubview:_imageView = imageView];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textColor = [UIColor darkTextColor];
        titleLabel.font = [UIFont systemFontOfSize:15.f];
        [self addSubview:_titleLabel = titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        detailLabel.textColor = [UIColor darkGrayColor];
        detailLabel.font = [UIFont systemFontOfSize:14.f];
        [self addSubview:_detailLabel = detailLabel];
    }
    return _detailLabel;
}

@end
