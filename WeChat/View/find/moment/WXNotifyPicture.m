//
//  WXNotifyPicture.m
//  WeChat
//
//  Created by Vicent on 2021/4/27.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXNotifyPicture.h"
#import "WXProfile.h"
#import "WXExtendViewModel.h"
#import "WXMomentNotify.h"

@interface WXNotifyPicture ()
@property (nonatomic, strong) UIImageView *badgeView;
@end

@implementation WXNotifyPicture
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.clipsToBounds = YES;
        
        for (NSInteger idx = 0; idx < 4; idx++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.tag = idx + 1;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [self addSubview:imageView];
        }
        
        UIImageView *badgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"album_badge_play"]];
        badgeView.tag = 100;
        badgeView.width_mn = 22.f;
        [badgeView sizeFitToWidth];
        badgeView.clipsToBounds = YES;
        badgeView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:badgeView];
        self.badgeView = badgeView;
    }
    return self;
}

- (void)setViewModel:(WXExtendViewModel *)viewModel {
    self.frame = viewModel.frame;
    NSArray <WXProfile *>*pictures = viewModel.content;
    if (pictures.count <= 0) return;
    CGFloat wh = (WXNotifyPictureWH - WXNotifyPictureInterval)/2.f;
    [self.subviews setValue:@(YES) forKey:@"hidden"];
    if (pictures.count == 1) {
        UIImageView *imageView = [self viewWithTag:1];
        imageView.hidden = NO;
        imageView.frame = self.bounds;
        imageView.image = pictures.firstObject.image;
        self.badgeView.hidden = pictures.firstObject.type != WXProfileTypeVideo;
    } else if (pictures.count == 2) {
        [UIView gridLayoutWithInitial:CGRectMake(0.f, 0.f, self.width_mn, wh) offset:UIOffsetMake(WXNotifyPictureInterval, WXNotifyPictureInterval) count:2 rows:1 handler:^(CGRect rect, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImageView *imageView = [self viewWithTag:idx + 1];
            imageView.hidden = NO;
            imageView.frame = rect;
            imageView.image = pictures[idx].image;
        }];
    } else if (pictures.count == 3) {
        [UIView gridLayoutWithInitial:CGRectMake(0.f, 0.f, wh, wh) offset:UIOffsetMake(WXNotifyPictureInterval, WXNotifyPictureInterval) count:3 rows:2 handler:^(CGRect rect, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImageView *imageView = [self viewWithTag:idx + 1];
            imageView.hidden = NO;
            imageView.frame = rect;
            if (idx == 0) {
                imageView.width_mn = self.width_mn;
            } else if (idx == 1) {
                imageView.left_mn = 0.f;
                imageView.bottom_mn = self.height_mn;
            } else if (idx == 2) {
                imageView.right_mn = self.width_mn;
            }
            imageView.image = pictures[idx].image;
        }];
    } else if (pictures.count >= 4) {
        [UIView gridLayoutWithInitial:CGRectMake(0.f, 0.f, wh, wh) offset:UIOffsetMake(WXNotifyPictureInterval, WXNotifyPictureInterval) count:4 rows:2 handler:^(CGRect rect, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImageView *imageView = [self viewWithTag:idx + 1];
            imageView.hidden = NO;
            imageView.frame = rect;
            imageView.image = pictures[idx].image;
        }];
    }
}

- (void)layoutSubviews {
    self.badgeView.center_mn = self.bounds_center;
}

@end
