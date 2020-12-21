//
//  WXAlbumTableHeaderView.m
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAlbumTableHeaderView.h"

@implementation WXAlbumTableHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIImage *image = UIImageNamed(@"wx_common_right_arrow");
        CGSize size = CGSizeMultiplyToHeight(image.size, 14.f);
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(self.width_mn - size.width - 30.f, 25.f, size.width, size.height)
                                                           image:image];
        [self addSubview:imageView];
        
        UIButton *button = [UIButton buttonWithFrame:CGRectMake(imageView.left_mn - 92.f, imageView.top_mn - 1.f, 90.f, 16.f)
                                               image:nil
                                               title:@"我的朋友圈"
                                          titleColor:TEXT_COLOR
                                                titleFont:[UIFont systemFontOfSize:16.f]];
        button.touchInset = UIEdgeInsetsMake(-5.f, 0.f, -5.f, 0.f);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self addSubview:button];
        
        self.height_mn = imageView.bottom_mn + imageView.top_mn;
    }
    return self;
}

- (void)buttonClicked {
    if (self.tableHeaderButtonClickedHandler) {
        self.tableHeaderButtonClickedHandler();
    }
}

@end
