//
//  WXMyMomentSectionHeader.m
//  WeChat
//
//  Created by Vicent on 2021/4/18.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXMyMomentSectionHeader.h"
#import "WXMyMomentYearModel.h"
#import "WXMyMoment.h"

@implementation WXMyMomentSectionHeader
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.titleLabel.numberOfLines = 1;
        self.contentView.backgroundColor = UIColor.whiteColor;
    }
    return self;
}

- (void)setViewModel:(WXMyMomentYearModel *)viewModel {
    _viewModel = viewModel;
    if (viewModel) {
        self.titleLabel.frame = viewModel.yearViewModel.frame;
        self.titleLabel.attributedText = viewModel.yearViewModel.content;
    }
}

@end
