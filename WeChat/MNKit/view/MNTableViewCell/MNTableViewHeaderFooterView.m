//
//  MNTableViewHeaderFooterView.m
//  MNKit
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNTableViewHeaderFooterView.h"

@interface MNTableViewHeaderFooterView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation MNTableViewHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = YES;
        self.contentView.backgroundColor = UIColorWithSingleRGB(236.f);
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectZero
                                                 text:nil
                                            textColor:[UIColor darkTextColor]
                                                 font:UIFontRegular(14.f)];
        [self.contentView addSubview:_titleLabel = titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        UILabel *detailLabel = [UILabel labelWithFrame:CGRectZero
                                                  text:nil
                                             textColor:[UIColor darkGrayColor]
                                                  font:UIFontRegular(13.f)];
        [self.contentView addSubview:_detailLabel = detailLabel];
    }
    return _detailLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectZero
                                                         image:nil];
        [self.contentView addSubview:_imageView = imageView];
    }
    return _imageView;
}

@end
