//
//  WXAlbumHeaderView.m
//  WeChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAlbumHeaderView.h"

@implementation WXAlbumHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIControl *control = UIControl.new;
        control.backgroundColor = UIColor.clearColor;
        [control addTarget:self action:@selector(buttonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control];
        
        UILabel *textLabel = [UILabel labelWithFrame:CGRectZero text:@"我的朋友圈" textColor:TEXT_COLOR font:[UIFont systemFontOfSize:14.f]];
        [textLabel sizeToFit];
        textLabel.numberOfLines = 1;
        textLabel.userInteractionEnabled = NO;
        [control addSubview:textLabel];
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageNamed:@"album_right_arrow"]];
        imageView.height_mn = textLabel.font.pointSize - 2.f;
        [imageView sizeFitToHeight];
        textLabel.userInteractionEnabled = NO;
        [control addSubview:imageView];
        
        textLabel.left_mn = 5.f;
        textLabel.top_mn = 5.f;
        
        control.height_mn = textLabel.bottom_mn + textLabel.top_mn;
        
        imageView.centerY_mn = textLabel.centerY_mn;
        imageView.left_mn = textLabel.right_mn + 2.f;
        
        control.width_mn = imageView.right_mn + textLabel.left_mn;
        control.top_mn = 30.f;
        control.right_mn = self.width_mn - 15.f;
        
        self.height_mn = floor(control.bottom_mn) + 40.f;
    }
    return self;
}

- (void)buttonTouchUpInside {
    if (self.touchEventHandler) {
        self.touchEventHandler();
    }
}

@end
