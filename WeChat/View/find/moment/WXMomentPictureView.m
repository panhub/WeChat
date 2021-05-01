//
//  WXMomentPictureView.m
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentPictureView.h"
#import "WXMomentPicture.h"
#import "WXProfile.h"
#import "WXTimeline.h"

@implementation WXMomentPictureView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        for (int i = 0; i < WXMomentPicturesMaxCount; i++) {
            WXMomentPicture *item = [[WXMomentPicture alloc] init];
            item.tag = i;
            [self addSubview:item];
        }
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch:)]];
    }
    return self;
}

- (void)setPictures:(NSArray<WXProfile *> *)pictures {
    _pictures = pictures.copy;
    NSUInteger count = pictures.count;
    if (count == 0) return;
    CGFloat wh = WXMomentPictureWH;
    int columns = WXMomentPictureMaxCols(count);
    __weak typeof(self) weakself = self;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof WXMomentPicture * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < count) {
            if (count == 1) {
                item.frame = weakself.bounds;
            } else {
                int row = floor(idx/columns);
                int column = idx%columns;
                CGFloat x = column*(wh + WXMomentPictureInterval);
                CGFloat y = row*(wh + WXMomentPictureInterval);
                item.frame = CGRectMake(x, y, wh, wh);
            }
            item.picture = pictures[idx];
            item.hidden = NO;
        } else {
            item.hidden = YES;
        }
    }];
}

#pragma mark - Event
- (void)touch:(UITapGestureRecognizer *)recognizer {
    __block WXMomentPicture *picture;
    CGPoint location = [recognizer locationInView:self];
    NSMutableArray <MNAsset *>*assets = @[].mutableCopy;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof WXMomentPicture * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isHidden) return;
        if (CGRectContainsPoint(UIEdgeInsetsInsetRect(obj.frame, UIEdgeInsetWith(-WXMomentPictureInterval)), location)) picture = obj;
        MNAsset *asset = [[MNAsset alloc] init];
        asset.content = obj.picture.content;
        asset.type = (MNAssetType)obj.picture.type;
        asset.thumbnail = obj.picture.image;
        asset.containerView = obj;
        [assets addObject:asset];
    }];
    if (picture && self.touchEventHandler) {
        self.touchEventHandler(assets, picture.tag);
    }
}

@end
