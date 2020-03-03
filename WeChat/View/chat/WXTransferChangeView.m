//
//  WXTransferChangeView.m
//  MNChat
//
//  Created by Vincent on 2019/6/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTransferChangeView.h"

@implementation WXTransferChangeView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *top_line = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
        top_line.frame = CGRectMake(20.f, 0.f, self.width_mn - 40.f, 1.f);
        [self addSubview:top_line];
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(top_line.left_mn, top_line.bottom_mn + 20.f, 50.f, 50.f) image:[UIImage imageNamed:@"wx_transfer_change"]];
        imageView.backgroundColor = UIColorWithSingleRGB(248.f);
        UIViewSetCornerRadius(imageView, imageView.height_mn/2.f);
        [self addSubview:imageView];
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(imageView.right_mn + 10.f, imageView.top_mn + 6.f, top_line.right_mn - imageView.right_mn - 10.f, 14.f) text:@"零钱通" textColor:UIColorWithAlpha([UIColor darkTextColor], .5f) font:[UIFont systemFontOfSize:14.f]];
        [self addSubview:titleLabel];
        
        UILabel *textLabel = [UILabel labelWithFrame:CGRectMake(titleLabel.left_mn, titleLabel.bottom_mn + 7.f, titleLabel.width_mn, 17.f) text:@"转入赚收益 七日年化3.04%" textColor:UIColorWithAlpha([UIColor darkTextColor], .9f) font:[UIFont systemFontOfSize:17.f]];
        [self addSubview:textLabel];
        
        UIImageView *bottom_line = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
        bottom_line.frame = CGRectMake(top_line.left_mn, imageView.bottom_mn + imageView.top_mn - top_line.height_mn, top_line.width_mn, top_line.height_mn);
        [self addSubview:bottom_line];
        
        self.height_mn = bottom_line.bottom_mn;
        
        UIImage *image = [UIImage imageNamed:@"wx_transfer_arrow"];
        CGSize size = CGSizeMultiplyToHeight(image.size, 13.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(self.width_mn - size.width - top_line.left_mn, MEAN(self.height_mn - size.height), size.width, size.height) image:image];
        [self addSubview:arrowView];
    }
    return self;
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame {
    frame.size.width = SCREEN_WIDTH;
    [super setFrame:frame];
}
@end
