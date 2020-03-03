//
//  MNAssetSelectCell.m
//  MNFoundation
//
//  Created by Vincent on 2019/9/11.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNAssetSelectCell.h"

@implementation MNAssetSelectCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView.userInteractionEnabled = NO;
        self.imageView.frame = self.contentView.bounds;
        self.imageView.layer.borderWidth = 0.f;
        self.imageView.layer.borderColor = UIColorWithRGB(7.f, 192.f, 96.f).CGColor;
    }
    return self;
}

- (void)setAsset:(MNAsset *)asset {
    self.imageView.image = asset.thumbnail;
}

- (void)setSelect:(BOOL)select {
    _select = select;
    self.imageView.layer.borderWidth = select ? 1.f : 0.f;
}

@end
