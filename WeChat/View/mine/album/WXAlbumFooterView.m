//
//  WXAlbumFooterView.m
//  WeChat
//
//  Created by Vicent on 2021/4/16.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXAlbumFooterView.h"
#import "WXAlbum.h"

@implementation WXAlbumFooterView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // 每个图片的大小
        CGFloat wh = (MN_SCREEN_MIN - WXAlbumPictureLeftMargin - WXAlbumPictureRightMargin - WXAlbumPictureInterval*2.f)/3.f;
        wh = ceil(wh);
        
        UIView *left = [[UIView alloc] init];
        left.backgroundColor = VIEW_COLOR;//MN_RGB(229.f);
        left.height_mn = 3.f;
        left.left_mn = WXAlbumPictureLeftMargin - WXAlbumPictureInterval*2.f;
        left.width_mn = wh + WXAlbumPictureInterval*5.f;
        [self addSubview:left];
        
        UIView *center = left.viewCopy;
        center.width_mn = 4.f;
        center.height_mn = 4.f;
        center.left_mn = left.right_mn + 4.f;
        [self addSubview:center];
        
        UIView *right = left.viewCopy;
        right.left_mn = center.right_mn + 4.f;
        [self addSubview:right];
        
        left.centerY_mn = right.centerY_mn = center.centerY_mn;
        
        self.height_mn = center.bottom_mn + MAX(15.f, MN_TAB_SAFE_HEIGHT);
    }
    return self;
}

@end
