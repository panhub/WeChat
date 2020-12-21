//
//  WXMomentPictureView.m
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentPictureView.h"
#import "WXMomentPictureItem.h"
#import "WXMomentPicture.h"

@interface WXMomentPictureView ()<UIGestureRecognizerDelegate>

@end

@implementation WXMomentPictureView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        for (int i = 0; i < WXMomentPicturesMaxCount; i++) {
            WXMomentPictureItem *item = [[WXMomentPictureItem alloc] initWithFrame:CGRectZero];
            item.tag = i;
            item.userInteractionEnabled = YES;
            [item addGestureRecognizer:UITapGestureRecognizerCreate(self, @selector(handTap:), self)];
            [self addSubview:item];
        }
    }
    return self;
}

- (void)setPictures:(NSArray<WXMomentPicture *> *)pictures {
    _pictures = pictures.copy;
    NSUInteger count = pictures.count;
    if (count == 0) return;
    CGFloat WH = WXMomentPictureItemWidth();
    int maxCols = WXMomentPictureMaxCols(count);
    [self.subviews enumerateObjectsUsingBlock:^(__kindof WXMomentPictureItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < count) {
            if (count == 1) {
                item.frame = self.bounds;
            } else {
                CGFloat width = WH;
                CGFloat height = WH;
                CGFloat left = (idx%maxCols)*(WH + WXMomentPictureItemInnerMargin);
                CGFloat top = (idx/maxCols)*(WH + WXMomentPictureItemInnerMargin);
                item.frame = CGRectMake(left, top, width, height);
            }
            item.picture = pictures[idx];
            item.hidden = NO;
        } else {
            item.hidden = YES;
        }
    }];
}

#pragma mark - Event
- (void)handTap:(UITapGestureRecognizer *)recognizer {
    WXMomentPictureItem *item = (WXMomentPictureItem *)recognizer.view;
    if (![self.pictures containsObject:item.picture]) return;
    NSMutableArray <MNAsset *>*assets = @[].mutableCopy;
    [self.pictures enumerateObjectsUsingBlock:^(WXMomentPicture * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MNAsset *s = [MNAsset assetWithContent:obj.image];
        s.containerView = self.subviews[idx];
        [assets addObject:s];
    }];
    if (self.pictureClickedHandler) {
        self.pictureClickedHandler(assets, item.tag);
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [touch.view isKindOfClass:NSClassFromString(@"WXMomentPictureItem")];
}

@end
