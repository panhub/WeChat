//
//  WXFavorite.h
//  WeChat
//
//  Created by Vicent on 2021/4/16.
//  Copyright © 2021 Vincent. All rights reserved.
//  定义收藏

#ifndef WXFavorites_h
#define WXFavorites_h

/// 左右宽度 区头高度
#define WXFavoriteSeparatorHeight   10.f
/// 横向间隔
#define WXFavoriteHorizontalMargin   15.f
/// 纵向间隔
#define WXFavoriteVerticalMargin   19.f
/// 标题与图片间隔
#define WXFavoriteTitleLeftInterval   10.f
/// 来源与图片间隔
#define WXFavoriteSourceTopInterval   14.f
/// 来源与时间间隔
#define WXFavoriteTimeSourceInterval   7.f
/// 图片最小宽高
#define WXFavoriteImageMinWH    45.f
/// 图片最大宽高
#define WXFavoriteImageMaxWH    90.f
/// 标签宽高
#define WXFavoriteLabelWH    12.f
/// 播放按钮宽高
#define WXFavoritePlayWH    30.f

/// 标题字体
#define WXFavoriteTitleFont       [UIFont systemFontOfSize:17.f]
/// 副标题字体
#define WXFavoriteSubTitleFont       [UIFont systemFontOfSize:14.f]
/// 来源字体
#define WXFavoriteSourceFont       [UIFont systemFontOfSize:12.f]
/// 时间字体
#define WXFavoriteTimeFont       WXFavoriteSourceFont

/// 标题颜色
#define WXFavoriteTitleColor    UIColor.darkTextColor
/// 副标题颜色
#define WXFavoriteSubTitleColor    MN_RGB(178.f)
/// 来源颜色
#define WXFavoriteSourceColor    MN_RGB(178.f)
/// 时间颜色
#define WXFavoriteTimeColor    MN_RGB(178.f)

#endif /* WXFavorites_h */
