//
//  WXMsg.h
//  WeChat
//
//  Created by Vicent on 2021/4/16.
//  Copyright © 2021 Vincent. All rights reserved.
//  消息定义

#ifndef WXMsg_h
#define WXMsg_h

/// 聊天背景图片保存key
#define WXChatBackgroundKey     @"com.wx.chat.background.key"

/// 聊天消息时间间隔 显示时间
#define WXMsgTimeInterval  75000

/// 微信消息头像大小
#define WXMsgAvatarWH     40.5f
/// 微信消息可视部分底部间隔
#define WXMsgContentBottomMargin   7.5f
/// 微信消息头像左右间距
#define WXMsgAvatarLeftOrRightMargin   15.f
/// 微信消息与头像间距<大>
#define WXMsgAvatarContentMaxMargin      13.f
/// 微信消息与头像间距<小>
#define WXMsgAvatarContentMinMargin      7.f
/// 微信文字消息内容左间距
#define WXTextMsgContentLeftMargin      17.f
/// 微信文字消息内容右间距
#define WXTextMsgContentRightMargin     11.f
/// 微信文字消息内容上下间距
#define WXTextMsgContentTopBottomMargin      10.f
/// 微信图片消息最大宽度
#define WXImageMsgMaxWidth      130.f
/// 微信图片消息最大高度
#define WXImageMsgMaxHeight      220.f
/// 微信位置消息文字左间距
#define WXLocationMsgTextLeftMargin      10.f
/// 微信位置消息文字右间距
#define WXLocationMsgTextRightMargin      15.f
/// 微信位置消息文字上间距
#define WXLocationMsgTextTopMargin      10.f
/// 微信位置消息文字下间距 <描述为空时>
#define WXLocationMsgTextBottomMaxMargin      WXLocationMsgTextTopMargin
/// 微信位置消息文字下间距 <描述不为空时>
#define WXLocationMsgTextBottomMinMargin      5.f
/// 微信位置消息文字间隔
#define WXLocationMsgTextInterval      3.f
/// 微信名片消息头像大小
#define WXCardMsgAvatarWH     43.f
/// 微信名片消息文字左间距
#define WXCardMsgLeftMargin      11.f
/// 微信名片消息文字右间距
#define WXCardMsgRightMargin      16.f
/// 微信名片消息分割线高度
#define WXCardMsgSeparatorHeight    (MN_IS_LOW_SCALE ? .5f : .3f)
/// 微信名片消息头像与文字间距
#define WXCardMsgAvatarTextMargin    WXCardMsgLeftMargin
/// 微信名片消息头像顶部间距
#define WXCardMsgTopMargin      WXCardMsgLeftMargin
/// 微信名片消息"个人名片"文字与分割线间隔
#define WXCardMsgTypeSeparatorMargin    7.f
/// 微信网页收藏消息内容上下间距
#define WXWebpageMsgContentTopBottomMargin      10.f
/// 微信网页收藏消息内容左间距
#define WXWebpageMsgContentLeftMargin      11.f
/// 微信网页收藏消息内容右间距
#define WXWebpageMsgContentRightMargin      17.f
/// 微信网页收藏消息图片大小
#define WXWebpageMsgImageViewWH      35.f
/// 微信网页收藏消息标题文字图片间距
#define WXWebpageMsgTextInterval     2.5f
/// 微信网页收藏消息描述文字图片间距
#define WXWebpageMsgDetailImageMargin     7.f
/// 微信红包消息内容左间距
#define WXRedpacketMsgContentLeftMargin      10.f
/// 微信红包消息内容右间距
#define WXRedpacketMsgContentRightMargin      15.f
/// 微信红包消息上图片与文字间隔
#define WXRedpacketMsgIconTextMargin      8.f
/// 微信红包消息上红包图片宽
#define WXRedpacketMsgIconWidth      37.f
/// 微信红包背景上部分比例<有颜色部分>
#define WXRedpacketBackgroundRatio      (191.f/252.f)
/// 微信转账消息内容左间距
#define WXTransferMsgContentLeftMargin      10.f
/// 微信转账消息内容右间距
#define WXTransferMsgContentRightMargin      15.f
/// 微信转账消息上图片与文字间隔
#define WXTransferMsgIconTextMargin      8.f
/// 微信转账消息上红包图片宽
#define WXTransferMsgIconWidth      37.f
/// 微信转账背景上部分比例<有颜色部分>
#define WXTransferBackgroundRatio      (191.f/252.f)
/// 微信语音消息图标大小
#define WXVoiceMsgIconWH      25.f
/// 微信语音消息图标上下间距
#define WXVoiceMsgIconTopOrBottomMargin      10.f
/// 微信语音消息图标左右间距
#define WXVoiceMsgIconLeftOrRightMargin      10.f
/// 微信语音消息图标与文字间距
#define WXVoiceMsgIconTextMargin      5.f
/// 微信视频消息播放视图大小
#define WXVideoMsgPlayViewWH      40.f
/// 微信视频消息最大宽度
#define WXVideoMsgMaxWidth      165.f
/// 微信视频消息最大高度
#define WXVideoMsgMaxHeight      165.f
/// 微信通话消息内容左间距
#define WXCallMsgContentLeftMargin      17.f
/// 微信通话消息内容右间距
#define WXCallMsgContentRightMargin     11.f
/// 微信通话消息角标与文字间距
#define WXCallMsgTextBadgeMargin     7.f
/// 微信消息 时间 字体颜色
#define WXMsgCreatedTimeTextColor    [[UIColor darkTextColor] colorWithAlphaComponent:.5f]
/// 微信添加成功消息文字颜色
#define WXInitialMsgTextColor    UIColorWithAlpha([UIColor darkTextColor], .5f)
/// 微信文字消息文字颜色
#define WXTextMsgTextColor    UIColorWithAlpha([UIColor darkTextColor], .9f)
/// 微信位置消息标题文字颜色
#define WXLocationMsgTitleTextColor    UIColorWithAlpha([UIColor darkTextColor], .85f)
/// 微信位置消息描述文字颜色
#define WXLocationMsgDetailTextColor    UIColorWithAlpha([UIColor darkGrayColor], .7f)
/// 微信名片消息备注字体颜色
#define WXCardMsgNotenameTextColor     UIColorWithAlpha([UIColor darkTextColor], .9f)
/// 微信名片消息昵称字体颜色
#define WXCardMsgNicknameTextColor    UIColorWithAlpha([UIColor darkGrayColor], .5f)
/// 微信名片消息类型字体颜色
#define WXCardMsgTypeTextColor    UIColorWithAlpha([UIColor darkGrayColor], .5f)
/// 微信网页收藏消息标题文字颜色
#define WXWebpageMsgTitleTextColor    UIColorWithAlpha([UIColor darkTextColor], .85f)
/// 微信网页收藏消息描述文字颜色
#define WXWebpageMsgDetailTextColor    UIColorWithAlpha([UIColor darkGrayColor], .7f)
/// 微信红包消息标题文字颜色
#define WXRedpacketMsgTitleTextColor    UIColorWithAlpha([UIColor whiteColor], .95f)
/// 微信红包消息领取状态文字颜色
#define WXRedpacketMsgStateTextColor    UIColorWithAlpha([UIColor whiteColor], .95f)
/// 微信红包文字颜色
#define WXRedpacketMsgDetailTextColor    UIColorWithAlpha([UIColor darkGrayColor], .7f)
/// 微信红包领取描述文字颜色
#define WXRedpacketMsgDescTextColor    UIColorWithAlpha([UIColor darkGrayColor], .5f)
/// 微信红包领取描述高亮颜色
#define WXRedpacketMsgDescTextHighlightColor    MN_R_G_B(250.f, 157.f, 59.f)
/// 微信转账消息标题文字颜色
#define WXTransferMsgTitleTextColor    UIColorWithAlpha([UIColor whiteColor], .95f)
/// 微信转账消息领取状态文字颜色
#define WXTransferMsgStateTextColor    UIColorWithAlpha([UIColor whiteColor], .95f)
/// 微信转账文字颜色
#define WXTransferMsgDetailTextColor    UIColorWithAlpha([UIColor darkGrayColor], .7f)
/// 微信转账领取描述文字颜色
#define WXTransferMsgDescTextColor    UIColorWithAlpha([UIColor darkGrayColor], .5f)
/// 微信转账领取描述高亮颜色
#define WXTransferMsgDescTextHighlightColor    MN_R_G_B(250.f, 157.f, 59.f)
/// 微信语音消息时长文字颜色
#define WXVoiceMsgDurationTextColor      UIColorWithAlpha([UIColor darkTextColor], .9f)
/// 微信通话消息文字颜色
#define WXCallMsgTextColor    UIColorWithAlpha([UIColor darkTextColor], .9f)

/// 微信消息时间字体
#define WXMsgCreatedTimeTextFont  [UIFont systemFontOfSize:13.f]
/// 微信添加成功消息字体
#define WXInitialMsgTextFont    [UIFont systemFontOfSize:13.f]
/// 微信文字消息字体
#define WXTextMsgTextFont    [UIFont systemFontOfSize:17.f]
/// 微信位置消息标题字体
#define WXLocationMsgTitleTextFont    [UIFont systemFontOfSize:16.f]
/// 微信位置消息描述字体
#define WXLocationMsgDetailTextFont    [UIFont systemFontOfSize:12.f]
/// 微信名片消息备注字体
#define WXCardMsgNotenameTextFont    [UIFont systemFontOfSize:17.f]
/// 微信名片消息昵称字体
#define WXCardMsgNicknameTextFont    [UIFont systemFontOfSize:13.f]
/// 微信名片消息类型字体
#define WXCardMsgTypeTextFont    [UIFont systemFontOfSize:12.f]
/// 微信网页收藏消息标题字体
#define WXWebpageMsgTitleTextFont    [UIFont systemFontOfSize:16.f]
/// 微信网页收藏消息描述字体
#define WXWebpageMsgDetailTextFont    [UIFont systemFontOfSize:12.f]
/// 微信红包消息标题字体<未领取>
#define WXRedpacketMsgTitleTextFont1    [UIFont systemFontOfSize:17.f]
/// 微信红包消息标题字体<已领取>
#define WXRedpacketMsgTitleTextFont2    [UIFont systemFontOfSize:15.f]
/// 微信红包消息领取状态字体
#define WXRedpacketMsgStateTextFont    [UIFont systemFontOfSize:12.f]
/// 微信红包文字字体
#define WXRedpacketMsgDetailTextFont    [UIFont systemFontOfSize:12.f]
/// 微信红包领取描述文字字体
#define WXRedpacketMsgDescTextFont    [UIFont systemFontOfSize:13.f]
/// 微信转账消息标题字体<已领取>
#define WXTransferMsgTitleTextFont    [UIFont systemFontOfSize:18.f]
/// 微信转账消息领取状态字体
#define WXTransferMsgStateTextFont    [UIFont systemFontOfSize:12.f]
/// 微信转账文字字体
#define WXTransferMsgDetailTextFont    [UIFont systemFontOfSize:12.f]
/// 微信转账领取描述文字字体
#define WXTransferMsgDescTextFont    [UIFont systemFontOfSize:13.f]
/// 微信语音消息时长文字字体
#define WXVoiceMsgDurationTextFont    [UIFont systemFontOfSize:14.f]
/// 微信通话消息字体
#define WXCallMsgTextFont    [UIFont systemFontOfSize:17.f]

#endif /* WXMsg_h */

/// 微信消息内容最大宽度
#define WXMsgContentMaxWidth   __WXMsgContentMaxWidth()
static inline CGFloat __WXMsgContentMaxWidth (void) {
    return 250.f;
}
/// 微信消息内容最小高度
#define WXMsgContentMinWidth   __WXMsgContentMinWidth()
static inline CGFloat __WXMsgContentMinWidth (void) {
    return 100.f;
}
/// 微信消息内容最大高度
#define WXMsgContentMaxHeight   __WXMsgContentMaxHeight()
static inline CGFloat __WXMsgContentMaxHeight (void) {
    return 300.f;
}
