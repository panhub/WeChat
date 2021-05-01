//
//  WXAddMomentCollectionViewCell.m
//  WeChat
//
//  Created by Vincent on 2019/5/9.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAddMomentCollectionViewCell.h"
#import "WXAddProfile.h"

@interface WXAddMomentCollectionViewCell ()
@property (nonatomic, strong) UIImageView *badgeView;
@end

@implementation WXAddMomentCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.imageView.clipsToBounds = YES;
        self.imageView.userInteractionEnabled = NO;
        self.imageView.frame = self.contentView.bounds;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        UIImageView *badgeView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 30.f, 30.f) image:[MNBundle imageForResource:@"record_play"]];
        badgeView.hidden = YES;
        badgeView.userInteractionEnabled = NO;
        badgeView.center_mn = self.bounds_center;
        [self.contentView addSubview:badgeView];
        self.badgeView = badgeView;
        
    }
    return self;
}

- (void)setModel:(WXAddProfile *)model {
    _model = model;
    model.containerView = self.imageView;
    self.imageView.image = model.image;
    self.badgeView.hidden = model.type != WXAddProfileTypeVideo;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.badgeView.center_mn = self.contentView.center_mn;
}

@end
