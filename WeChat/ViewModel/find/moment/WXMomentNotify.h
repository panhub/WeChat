//
//  WXMomentNotify.h
//  WeChat
//
//  Created by Vicent on 2021/4/27.
//  Copyright © 2021 Vincent. All rights reserved.
//

#ifndef WXMomentNotify_h
#define WXMomentNotify_h

// 头像大小
#define WXNotifyAvatarWH    47.f
// 配图大小
#define WXNotifyPictureWH    61.f
// 配图内部间隔
#define WXNotifyPictureInterval    1.f
// 点赞图片大小
#define WXNotifyLikeWH    18.f
// 左间隔
#define WXNotifyLeftMargin    10.f
// 右间隔
#define WXNotifyRightMargin    10.f
// 上间隔
#define WXNotifyTopMargin    10.f
// 底部间隔
#define WXNotifyBottomMargin    7.f
// 头像昵称间隔
#define WXNotifyAvatarNickInterval    10.f

// 昵称字体
#define WXNotifyNickFont    [UIFont systemFontOfSizes:14.f weights:MNFontWeightMedium]
// 朋友圈内容字体
#define WXNotifyContentFont    [UIFont systemFontOfSizes:17.f weights:MNFontWeightRegular]
// 评论内容字体
#define WXNotifyCommentFont    [UIFont systemFontOfSizes:14.f weights:MNFontWeightRegular]
// 日期字体
#define WXNotifyDateFont    [UIFont systemFontOfSizes:13.f weights:MNFontWeightRegular]

// 昵称字体颜色
#define WXNotifyNickFontColor    UIColorWithHex(@"#5B6A92")
// 评论内容字体颜色
#define WXNotifyContentFontColor    [UIColor.darkTextColor colorWithAlphaComponent:.88f]
// 评论内容字体颜色
#define WXNotifyCommentFontColor    [UIColor.darkTextColor colorWithAlphaComponent:.88f]
// 日期字体颜色
#define WXNotifyDateFontColor    [UIColor.darkGrayColor colorWithAlphaComponent:.88f]

#endif /* WXMomentNotify_h */
