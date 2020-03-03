//
//  WXCookMethodViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/6/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookMethodViewModel.h"
#import "WXCookModel.h"

@implementation WXCookMethodViewModel
- (instancetype)initWithMethod:(WXCookMethod *)model {
    if (self = [super init]) {
        self.model = model;
        self.img = model.img;
        UIImage *image = [UIImage imageWithObject:model.img];
        if (image) {
            CGSize size = CGSizeMultiplyToWidth(image.size, SCREEN_WIDTH - 30.f);
            self.imageViewFrame = CGRectMake(15.f, 13.f, size.width, size.height);
        } else {
            self.imageViewFrame = CGRectMake(15.f, 0.f, SCREEN_WIDTH - 30.f, 0.f);
        }
        
        if (model.step.length) {
            NSMutableAttributedString *step = model.step.attributedString.mutableCopy;
            step.color = [UIColor darkTextColor];
            step.font = UIFontLight(17.f);
            step.lineSpacing = 0.f;
            CGSize size = [step sizeOfLimitWidth:CGRectGetWidth(self.imageViewFrame)];
            self.textLabelFrame = CGRectMake(CGRectGetMinX(self.imageViewFrame), CGRectGetMaxY(self.imageViewFrame) + 13.f, size.width, size.height);
            self.attributedString = step.copy;
        } else {
            self.textLabelFrame = CGRectMake(CGRectGetMinX(self.imageViewFrame), CGRectGetMaxY(self.imageViewFrame), 0.f, 0.f);
            self.attributedString = @"".attributedString;
        }
        
        self.height = CGRectGetMaxY(self.textLabelFrame) + 13.f;
    }
    return self;
}

@end
