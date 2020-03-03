//
//  WXAlbumPictureView.m
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAlbumPictureView.h"
#import "WXMomentPicture.h"
#import "WXAlbumViewModel.h"

@interface WXAlbumPictureView ()
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIImageView *>*cache;
@end

@implementation WXAlbumPictureView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.cache = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return self;
}

- (void)setPictures:(NSArray<WXMomentPicture *> *)pictures {
    _pictures = pictures.copy;
    [self.subviews setValue:@(YES) forKey:@"hidden"];
    CGFloat wh = WXAlbumItemWH();
    [UIView gridLayoutWithInitial:CGRectMake(0.f, 0.f, wh, wh) offset:UIOffsetMake(WXAlbumItemInterval, WXAlbumItemInterval) count:_pictures.count rows:3 handler:^(CGRect rect, NSUInteger idx, BOOL *stop) {
        WXMomentPicture *picture = _pictures[idx];
        UIImageView *view = [self imageViewWithIndex:idx];
        view.hidden = NO;
        view.frame = rect;
        view.image = picture.image;
    }];
}

- (UIImageView *)imageViewWithIndex:(NSUInteger)index {
    UIImageView *view = [self.cache objectForKey:@(index)];
    if (!view) {
        view = [UIImageView new];
        view.clipsToBounds = YES;
        view.userInteractionEnabled = YES;
        view.contentScaleFactor = [[UIScreen mainScreen] scale];
        view.contentMode = UIViewContentModeScaleAspectFill;
        [view addGestureRecognizer:UITapGestureRecognizerCreate(self, @selector(handTap:), nil)];
        [self addSubview:view];
        [self.cache setObject:view forKey:@(index)];
    }
    return view;
}

- (void)handTap:(UITapGestureRecognizer *)recognizer {
    NSArray <UIView *>*subviews = [self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isHidden == NO"]];
    if (subviews.count <= 0) return;
    __block MNAsset *asset;
    NSMutableArray *assets = @[].mutableCopy;
    [subviews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = (UIImageView *)obj;
        if (!imageView.image) return;
        MNAsset *s = [MNAsset assetWithContent:imageView.image];
        s.containerView = imageView;
        [assets addObject:s];
        if (obj == recognizer.view) asset = s;
    }];
    if (!asset) return;
    MNAssetBrowser *browser = [MNAssetBrowser new];
    browser.assets = assets.copy;
    browser.statusBarHidden = NO;
    browser.statusBarStyle = UIStatusBarStyleLightContent;
    browser.backgroundColor = UIColor.blackColor;
    [browser presentFromAsset:asset animated:YES];
}

@end
