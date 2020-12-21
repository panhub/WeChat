//
//  WXAlbumViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAlbumViewModel.h"

CGFloat const WXAlbumItemInterval = 10.f;
//CGFloat const WXAlbumViewTopMargin = 15.f;
CGFloat const WXAlbumViewLeftMargin = 80.f;
CGFloat const WXAlbumViewRightMargin = 30.f;

CGFloat WXAlbumViewWidth (void) {
    return MN_SCREEN_WIDTH - WXAlbumViewLeftMargin - WXAlbumViewRightMargin;
}

CGFloat WXAlbumItemWH (void) {
    return (WXAlbumViewWidth() - WXAlbumItemInterval*2.f)/3.f;
}

@implementation WXAlbumViewModel
- (instancetype)initWithPictures:(NSArray <WXMomentPicture *>*)pictures {
    if (self = [super init]) {
        self.pictures = pictures.copy;
        CGFloat wh = WXAlbumItemWH();
        __block CGFloat height = 0.f;
        [UIView gridLayoutWithInitial:CGRectMake(0.f, 0.f, wh, wh) offset:UIOffsetMake(WXAlbumItemInterval, WXAlbumItemInterval) count:pictures.count rows:3 handler:^(CGRect rect, NSUInteger idx, BOOL *stop) {
            height = CGRectGetMaxY(rect);
        }];
        self.frame = CGRectMake(WXAlbumViewLeftMargin, 0.f, WXAlbumViewWidth(), height);
        self.height = self.frame.size.height + WXAlbumItemInterval;
    }
    return self;
}
@end
