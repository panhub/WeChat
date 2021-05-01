//
//  WXSelectBackgroundCell.m
//  WeChat
//
//  Created by Vincent on 2019/7/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXSelectBackgroundCell.h"

@interface WXSelectBackgroundCell ()
@property (nonatomic, strong) UIView *selectedView;
@end

@implementation WXSelectBackgroundCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIViewSetCornerRadius(self.contentView, 3.f);
        self.imageView.frame = self.contentView.bounds;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        UIView *selectedView = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.contentView.height_mn/5.f*4.f, self.contentView.width_mn, self.contentView.height_mn/5.f)];
        selectedView.backgroundColor = THEME_COLOR;
        selectedView.hidden = YES;
        [self.contentView addSubview:selectedView];
        self.selectedView = selectedView;
        
        UIImageView *selectedMask = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, selectedView.height_mn - 5.f, selectedView.height_mn - 5.f) image:[UIImage imageNamed:@"chat_bg_select"]];
        ///selectedMask.backgroundColor = [UIColor whiteColor];
        UIViewSetCornerRadius(selectedMask, selectedMask.height_mn/2.f);
        selectedMask.center_mn = selectedView.bounds_center;
        [selectedView addSubview:selectedMask];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    self.selectedView.hidden = !selected;
}

@end
