//
//  WXNewMomentDeleteView.m
//  WeChat
//
//  Created by Vicent on 2021/3/12.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXNewMomentDeleteView.h"

@interface WXNewMomentDeleteView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *highlightedLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation WXNewMomentDeleteView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor.redColor colorWithAlphaComponent:.7f];
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectZero image:[[UIImage imageNamed:@"wx_moment_delete"] imageWithColor:UIColor.whiteColor]];
        imageView.height_mn = 25.f;
        [imageView sizeFitToHeight];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.highlightedImage = [[UIImage imageNamed:@"wx_moment_deleteHL"] imageWithColor:UIColor.whiteColor];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectZero text:@"拖动到此处删除" alignment:NSTextAlignmentCenter textColor:UIColor.whiteColor font:[UIFont systemFontOfSize:15.f]];
        titleLabel.numberOfLines = 1;
        [titleLabel sizeToFit];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *highlightedLabel = [UILabel labelWithFrame:CGRectZero text:@"松开即可删除" alignment:NSTextAlignmentCenter textColor:UIColor.whiteColor font:titleLabel.font];
        highlightedLabel.numberOfLines = 1;
        [highlightedLabel sizeToFit];
        highlightedLabel.hidden = YES;
        [self addSubview:highlightedLabel];
        self.highlightedLabel = highlightedLabel;
        
        imageView.top_mn = 25.f;
        imageView.centerX_mn = self.width_mn/2.f;
        
        titleLabel.top_mn = imageView.bottom_mn + 6.f;
        titleLabel.centerX_mn = self.width_mn/2.f;
        
        highlightedLabel.center_mn = titleLabel.center_mn;
        
        self.height_mn = titleLabel.bottom_mn + imageView.top_mn;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted == _highlighted) return;
    _highlighted = highlighted;
    self.imageView.highlighted = highlighted;
    self.titleLabel.hidden = highlighted;
    self.highlightedLabel.hidden = !highlighted;
}

@end
