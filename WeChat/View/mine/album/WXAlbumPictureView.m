//
//  WXAlbumPictureView.m
//  WeChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAlbumPictureView.h"
#import "WXMonthViewModel.h"
#import "WXMomentPicture.h"
#import "WXProfile.h"
#import "WXAlbum.h"

@implementation WXAlbumPictureView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch:)]];
    }
    return self;
}

- (void)setViewModel:(WXMonthViewModel *)viewModel {
    _viewModel = viewModel;
    if (viewModel.dataSource.count) {
        __block WXExtendViewModel *vm;
        [self.subviews setValue:@(YES) forKey:@"hidden"];
        [viewModel.dataSource enumerateObjectsUsingBlock:^(WXExtendViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WXMomentPicture *picture = [self pictureWithIndex:idx];
            picture.picture = obj.content;
            picture.frame = obj.frame;
            picture.hidden = NO;
            if (vm) {
                if (obj.frame.origin.x > vm.frame.origin.x) vm = obj;
            } else {
                vm = obj;
            }
        }];
        self.frame = CGRectMake(WXAlbumPictureLeftMargin, 0.f, CGRectGetMaxY(viewModel.dataSource.lastObject.frame), CGRectGetMaxX(vm.frame));
    } else {
        self.frame = CGRectZero;
    }
}

- (WXMomentPicture *)pictureWithIndex:(NSInteger)index {
    WXMomentPicture *picture = (WXMomentPicture *)[self viewWithTag:index + 1];
    if (!picture) {
        picture = WXMomentPicture.new;
        picture.tag = index + 1;
        picture.badgeView.image = [UIImage imageNamed:@"album_badge_play"];
        picture.badgeView.size_mn = CGSizeMake(22.f, 22.f);
        [self addSubview:picture];
    }
    return picture;
}

#pragma mark - Event
- (void)touch:(UITapGestureRecognizer *)recognizer {
    __block WXMomentPicture *picture;
    CGPoint location = [recognizer locationInView:self];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof WXMomentPicture * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isHidden) return;
        if (CGRectContainsPoint(UIEdgeInsetsInsetRect(obj.frame, UIEdgeInsetWith(-WXAlbumPictureInterval)), location)) {
            picture = obj;
            *stop = YES;
        }
    }];
    if (picture) self.touchEventHandler(picture.picture);
}

@end
