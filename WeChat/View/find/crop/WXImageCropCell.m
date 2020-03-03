//
//  WXImageCropCell.m
//  MNChat
//
//  Created by Vincent on 2019/12/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXImageCropCell.h"

@implementation WXImageCropCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView.frame = self.contentView.bounds;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

@end
