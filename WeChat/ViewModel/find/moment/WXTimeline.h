//
//  WXTimeline.h
//  WeChat
//
//  Created by Vicent on 2021/4/16.
//  Copyright © 2021 Vincent. All rights reserved.
//  朋友圈定义

#ifndef WXTimeline_h
#define WXTimeline_h

#import "WXProfile.h"

/// 朋友圈内容距顶部间距
#define WXMomentAvatarTopMargin    16.f
/// 朋友圈内容左右间距
#define WXMomentContentLeftOrRightMargin     20.f
/// 朋友圈内容顶部间距
#define WXMomentContentTopMargin     8.f
/// 朋友圈头像大小
#define WXMomentAvatarWH    44.f
/// 朋友圈内部 位置 与配图/分享 间距
#define WXMomentLocationTopMargin     7.f
/// 朋友圈正文文字距头像左间距
#define WXMomentContentLeftMargin  12.f
/// 全文/收起 按钮 与 配图/分享 间隔
#define WXMomentInnerViewMargin  10.f
/// 朋友圈网页分享高度
#define WXMomentWebpageHeight   50.f
/// 配图大小 (屏幕尺寸 > 320)
#define WXMomentPictureWH1  86.f
/// 配图大小 (屏幕尺寸 <= 320)
#define WXMomentPictureWH2  70.f
/// 配图之间间隔
#define WXMomentPictureInterval  6.f
/// 配图最大张数
#define WXMomentPicturesMaxCount    9
/// 配图列数
#define WXMomentPictureMaxCols(count) ((count==4) ? 2 : 3)
/// 向上箭头W 45
#define WXMomentArrowViewWidth    45.f
/// 向上箭头H 6
#define WXMomentArrowViewHeight   6.f
/// 更多按钮宽
#define WXMomentMoreButtonWidth     32.f
/// 更多按钮高
#define WXMomentMoreButtonHeight    20.f
/// 朋友圈更多视图宽
#define WXMomentMoreViewWidth   185.f
/// 朋友圈更多视图高
#define WXMomentMoreViewHeight  40.f
/// 更多视图动画时长
#define WXMomentMoreViewAnimatedDuration   .3f
/// 向上箭头W
#define WXMomentArrowViewWidth  45.f
/// 向上箭头H
#define WXMomentArrowViewHeight     6.f
/// 向上箭头顶部间隔
#define WXMomentArrowViewTopMargin  7.f
/// 隐私视图大小
#define WXMomentPrivacyViewWH   17.f
/// 评论内容距评论视图上下间距
#define WXMomentCommentTopOrBottomMargin    3.f
/// 评论内容距评论视图左右间距
#define WXMomentCommentLeftOrRightMargin    8.f
/// 点赞内容距评论视图上下间距
#define WXMomentLikeTopOrBottomMargin    3.5f
/// 点赞内容距评论视图左右间距
#define WXMomentLikeLeftOrRightMargin    WXMomentCommentLeftOrRightMargin
/// 朋友圈分割线高度
#define WXMomentSeparatorHeight    .5f
/// 朋友圈更多视图动画时间
#define WXMommentMoreViewAnimationDuration   .33f

/// 朋友圈昵称字体
#define WXMomentNicknameFont    [UIFont systemFontOfSizes:17.f weights:.3f]
/// 朋友圈正文字体
#define WXMomentContentTextFont     [UIFont systemFontOfSize:17.f]
/// 朋友圈 全文/收起 按钮标题字体
#define WXMomentExpandButtonTitleFont     [UIFont systemFontOfSize:18.f]
/// 朋友圈 地址 时间 来源 字体
#define WXMomentContentInnerFont    [UIFont systemFontOfSize:14.f]
/// 朋友圈 点赞 字体
#define WXMomentLikedTextFont  [UIFont systemFontOfSizes:14.f weights:MNFontWeightMedium]
/// 朋友圈评论内容字体
#define WXMomentCommentTextFont  [UIFont systemFontOfSizes:14.f weights:MNFontWeightRegular]
/// 朋友圈评论昵称字体
#define WXMomentCommentNicknameFont  [UIFont systemFontOfSizes:14.f weights:MNFontWeightMedium]

/// 全局黑色字体
#define WXMomentGlobalTextColor   UIColorWithAlpha([UIColor darkTextColor], .9f)
/// 朋友圈昵称字体颜色
#define WXMomentNicknameTextColor  UIColorWithHex(@"#5B6A92")
/// 朋友圈正文字体颜色
#define WXMomentContentTextColor    WXMomentGlobalTextColor
/// 朋友圈评论内容字体颜色
#define WXMomentCommentTextColor   WXMomentGlobalTextColor
/// 朋友圈内容 链接 电话 字体颜色
#define WXMomentLinkTextColor       UIColorWithHex(@"#4380D1")
/// 朋友圈 位置 字体颜色
#define WXMomentLocationTextColor   WXMomentNicknameTextColor
/// 朋友圈 来源 字体颜色
#define WXMomentSourceTextColor    WXMomentNicknameTextColor
/// 朋友圈 删除 字体颜色
#define WXMomentDeleteTextColor    WXMomentNicknameTextColor
/// 朋友圈 时间 字体颜色
#define WXMomentCreatedTimeTextColor    UIColorWithHex(@"#b2b1b2")
/// 朋友圈 点赞昵称 字体颜色
#define WXMomentLikedTextColor    WXMomentNicknameTextColor
/// 朋友圈 评论or点赞view的背景色
#define WXMomentCommentViewBackgroundColor UIColorWithSingleRGB(245.f)
/// 朋友圈 评论or点赞view的选中的背景色
#define WXMomentCommentViewSelectedBackgroundColor UIColorWithHex(@"#CED2DE")

#endif /* WXTimeline_h */

/// 微信朋友圈正文/评论宽度
#define WXMomentContentWidth   __WXMomentContentWidth()
static inline CGFloat __WXMomentContentWidth(void) {
    return (MN_SCREEN_MIN - WXMomentContentLeftOrRightMargin*2 - WXMomentAvatarWH - WXMomentContentLeftMargin);
}
/// 微信朋友圈九宫格配图宽/高
#define WXMomentPictureWH   __WXMomentPictureWH()
static inline CGFloat __WXMomentPictureWH(void) {
    return (MN_SCREEN_MIN <= 320.f ? WXMomentPictureWH2 : WXMomentPictureWH1);
}
/// 微信朋友圈单张配图最大宽度<方形or等比例>
#define WXMomentPictureMaxWidth   __WXMomentPictureMaxWidth()
static inline CGFloat __WXMomentPictureMaxWidth(void) {
    return (__WXMomentPictureWH() + WXMomentPictureInterval)*2.f;
}

/// 微信朋友圈单张配图最大高度<方形or等比例>
#define WXMomentPictureMaxHeight  __WXMomentPictureMaxHeight()
static inline CGFloat __WXMomentPictureMaxHeight(void) {
    return floor((__WXMomentPictureWH() + WXMomentPictureInterval)*1.75f);
}

/// 微信朋友圈单张配图尺寸
#define WXMomentPictureSize(picture)  __WXMomentPictureSize(picture)
static CGSize __WXMomentPictureSize(WXProfile *picture) {
    CGSize size = CGSizeZero;
    if (!picture.image) return size;
    CGSize imageSize = picture.image.size;
    if (imageSize.width == imageSize.height) {
        size.width = WXMomentPictureWH;
        size.height = size.width;
    } else if (imageSize.width > imageSize.height) {
        size.width = (imageSize.width - imageSize.height) > 10.f ? WXMomentPictureMaxWidth : WXMomentPictureWH;
        size.height = floor(CGSizeMultiplyToWidth(imageSize, size.width).height);
    } else {
        size.height = (imageSize.height - imageSize.width) > 10.f ? WXMomentPictureMaxHeight : WXMomentPictureWH;
        size.width = floor(CGSizeMultiplyToHeight(imageSize, size.height).width);
    }
    return size;
}

/// 微信朋友圈配图尺寸
#define WXMomentPictureViewSize(pictures)  __WXMomentPictureViewSize(pictures)
static CGSize __WXMomentPictureViewSize(NSArray <WXProfile *>*pictures) {
    NSUInteger count = pictures ? pictures.count : 0;
    if (count <= 0) return CGSizeZero;
    if (count == 1) return __WXMomentPictureSize(pictures.firstObject);
    // 九宫格样式
    float wh = WXMomentPictureWH;
    // 理想列数
    int maxCols = WXMomentPictureMaxCols(count);
    // 总列数
    int totalCols = (int)(MIN(count, maxCols));
    // 总行数
    int totalRows = (int)(ceil(count*1.f/maxCols));
    // 计算尺寸
    CGFloat width = totalCols*wh + (totalCols - 1)*WXMomentPictureInterval;
    CGFloat height = totalRows*wh + (totalRows - 1)*WXMomentPictureInterval;
    return CGSizeMake(width, height);
}
