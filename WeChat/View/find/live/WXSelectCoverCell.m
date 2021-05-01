//
//  WXSelectCoverCell.m
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXSelectCoverCell.h"
#import "WXDataValueModel.h"

@interface WXSelectCoverCell ()
@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIImageView *selectImageView;
@end

@implementation WXSelectCoverCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = self.collectionView.backgroundColor = UIColor.clearColor;
        self.imageView.frame = self.contentView.bounds;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        UIView *selectView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        selectView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:.65f];
        selectView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        UIViewSetBorderRadius(selectView, 0.f, 1.5f, THEME_COLOR);
        [self.contentView addSubview:selectView];
        self.selectView = selectView;
        
        UIImageView *selectImageView = [UIImageView imageViewWithFrame:CGRectZero image:[MNBundle imageForResource:@"player_done"]];
        [selectView addSubview:selectImageView];
        self.selectImageView = selectImageView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat wh = floor(MIN(15.f, MIN(self.selectView.size_mn.width/2.f, self.selectView.size_mn.height/2.f)));
    self.selectImageView.size_mn = CGSizeMake(wh, wh);
    self.selectImageView.center_mn = self.selectView.bounds_center;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.imageView.image = model.image;
    self.selectView.hidden = !model.isSelected;
}

@end
