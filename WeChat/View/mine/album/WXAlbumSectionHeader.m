//
//  WXAlbumSectionHeader.m
//  WeChat
//
//  Created by Vicent on 2021/4/16.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXAlbumSectionHeader.h"
#import "WXYearViewModel.h"
#import "WXAlbum.h"

@implementation WXAlbumSectionHeader
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.titleLabel.numberOfLines = 1;
        self.contentView.backgroundColor = UIColor.whiteColor;
    }
    return self;
}

- (void)setViewModel:(WXYearViewModel *)viewModel {
    _viewModel = viewModel;
    if (viewModel) {
        self.titleLabel.frame = viewModel.yearViewModel.frame;
        self.titleLabel.attributedText = viewModel.yearViewModel.content;
    }
}

@end
